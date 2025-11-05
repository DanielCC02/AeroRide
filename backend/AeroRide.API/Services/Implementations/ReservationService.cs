using AeroRide.API.Data;
using AeroRide.API.Models.Domain;
using AeroRide.API.Models.DTOs.Reservations;
using AeroRide.API.Models.Enums;
using AeroRide.API.Services.Interfaces;
using AutoMapper;
using Microsoft.EntityFrameworkCore;

namespace AeroRide.API.Services.Implementations
{
    /// <summary>
    /// Implementa la lógica de negocio para la gestión de reservas.
    /// Incluye creación, consulta y cancelación.
    /// </summary>
    public class ReservationService : IReservationService
    {
        private readonly AeroRideDbContext _db;
        private readonly IMapper _mapper;

        public ReservationService(AeroRideDbContext db, IMapper mapper)
        {
            _db = db;
            _mapper = mapper;
        }

        // ======================================================
        // 🟢 CREATE RESERVATION
        // ======================================================        
        public async Task<ReservationResponseDto> CreateAsync(int userId, ReservationCreateDto dto)
        {
            using var transaction = await _db.Database.BeginTransactionAsync();

            try
            {
                // ======================================================
                // 1️⃣ VALIDAR COMPAÑÍA Y DISPONIBILIDAD DE AERONAVE
                // ======================================================
                var company = await _db.Companies.FirstOrDefaultAsync(c => c.Id == dto.CompanyId && c.IsActive);
                if (company == null)
                    throw new Exception("La compañía seleccionada no existe o está inactiva.");

                var totalPassengers = dto.Passengers.Count;
                var requestedStart = dto.Segments.Min(s => s.DepartureTime);
                var requestedEnd = dto.Segments.Max(s => s.ArrivalTime);

                var selectedAircraft = await CheckAircraftAvailabilityAsync(
                    dto.CompanyId,
                    dto.AircraftModel,
                    totalPassengers,
                    requestedStart,
                    requestedEnd
                );

                if (selectedAircraft == null)
                    throw new Exception($"No hay aeronaves disponibles del modelo '{dto.AircraftModel}' en el rango de tiempo solicitado.");

                // ======================================================
                // 2️⃣ CREAR RESERVA BASE
                // ======================================================
                var reservation = _mapper.Map<Reservation>(dto);
                reservation.UserId = userId;
                reservation.CompanyId = dto.CompanyId;
                reservation.ReservationCode = await GenerateReservationCodeAsync();
                reservation.Status = ReservationStatus.Pendiente;
                reservation.CreatedAt = DateTime.UtcNow;

                await _db.Reservations.AddAsync(reservation);
                await _db.SaveChangesAsync();

                // ======================================================
                // 3️⃣ CREAR PASAJEROS
                // ======================================================
                foreach (var paxDto in dto.Passengers)
                {
                    var passenger = _mapper.Map<PassengerDetail>(paxDto);
                    passenger.ReservationId = reservation.Id;
                    await _db.PassengerDetails.AddAsync(passenger);
                }
                await _db.SaveChangesAsync();

                // ======================================================
                // 4️⃣ VARIABLES DE ITINERARIO
                // ======================================================
                var baseAirportId = selectedAircraft.BaseAirportId;
                var baseAirport = await _db.Airports.FirstAsync(a => a.Id == baseAirportId);

                var firstSegment = dto.Segments.First();
                var lastSegment = dto.Segments.Last();
                bool isRoundTrip = dto.IsRoundTrip;

                var allFlights = new List<Flight>();

                // ======================================================
                // ✈️ 5️⃣ GENERAR VUELOS SEGÚN LÓGICA DE NEGOCIO
                // ======================================================

                // 🟩 (A) Empty leg de salida — base → origen cliente
                if (!isRoundTrip && firstSegment.DepartureAirportId != baseAirportId)
                {
                    var originAirport = await _db.Airports.FirstAsync(a => a.Id == firstSegment.DepartureAirportId);
                    double duracionMin = CalcularDuracionVuelo(baseAirport, originAirport, selectedAircraft);

                    var emptyLegOut = new Flight
                    {
                        CompanyId = dto.CompanyId,
                        AircraftId = selectedAircraft.Id,
                        ReservationId = null, // 🚫 sin reserva
                        DepartureAirportId = baseAirportId,
                        ArrivalAirportId = firstSegment.DepartureAirportId,
                        DepartureTime = firstSegment.DepartureTime.AddMinutes(-duracionMin - 20),
                        ArrivalTime = firstSegment.DepartureTime.AddMinutes(-20),
                        DurationMinutes = duracionMin,
                        IsEmptyLeg = true,
                        IsInternational = baseAirport.Country != originAirport.Country,
                        Status = FlightStatus.Programado,
                        CreatedAt = DateTime.UtcNow
                    };

                    allFlights.Add(emptyLegOut);
                }

                // 🟦 (B) Vuelos comerciales del cliente
                foreach (var segment in dto.Segments)
                {
                    var airportFrom = await _db.Airports.FirstAsync(a => a.Id == segment.DepartureAirportId);
                    var airportTo = await _db.Airports.FirstAsync(a => a.Id == segment.ArrivalAirportId);

                    // 🧱 Validar vuelos internacionales
                    bool isInternational = airportFrom.Country.Trim().ToLower() != airportTo.Country.Trim().ToLower();
                    if (isInternational && !selectedAircraft.CanFlyInternational)
                    {
                        throw new InvalidOperationException(
                            $"La aeronave '{selectedAircraft.Model}' (matrícula {selectedAircraft.Patent}) no puede realizar vuelos internacionales."
                        );
                    }

                    double duracionMin = CalcularDuracionVuelo(airportFrom, airportTo, selectedAircraft);

                    var flight = new Flight
                    {
                        CompanyId = dto.CompanyId,
                        AircraftId = selectedAircraft.Id,
                        ReservationId = reservation.Id,
                        DepartureAirportId = segment.DepartureAirportId,
                        ArrivalAirportId = segment.ArrivalAirportId,
                        DepartureTime = segment.DepartureTime,
                        ArrivalTime = segment.DepartureTime.AddMinutes(duracionMin),
                        DurationMinutes = duracionMin,
                        IsEmptyLeg = false,
                        IsInternational = isInternational,
                        Status = FlightStatus.Programado,
                        CreatedAt = DateTime.UtcNow
                    };

                    allFlights.Add(flight);
                }


                // 🟥 (C) Empty leg de regreso — destino cliente → base
                if (!isRoundTrip && lastSegment.ArrivalAirportId != baseAirportId)
                {
                    var destinationAirport = await _db.Airports.FirstAsync(a => a.Id == lastSegment.ArrivalAirportId);
                    double duracionMin = CalcularDuracionVuelo(destinationAirport, baseAirport, selectedAircraft);

                    var emptyLegReturn = new Flight
                    {
                        CompanyId = dto.CompanyId,
                        AircraftId = selectedAircraft.Id,
                        ReservationId = null, // 🚫 sin reserva
                        DepartureAirportId = lastSegment.ArrivalAirportId,
                        ArrivalAirportId = baseAirportId,
                        DepartureTime = lastSegment.ArrivalTime.AddMinutes(15),
                        ArrivalTime = lastSegment.ArrivalTime.AddMinutes(15 + duracionMin),
                        DurationMinutes = duracionMin,
                        IsEmptyLeg = true,
                        IsInternational = destinationAirport.Country != baseAirport.Country,
                        Status = FlightStatus.Programado,
                        CreatedAt = DateTime.UtcNow
                    };

                    allFlights.Add(emptyLegReturn);
                }

                // ======================================================
                // 6️⃣ GUARDAR VUELOS Y BLOQUEAR HORARIO
                // ======================================================
                await _db.Flights.AddRangeAsync(allFlights);
                await _db.SaveChangesAsync();

                var commercialFlights = allFlights.Where(f => !f.IsEmptyLeg).ToList();
                var startTime = commercialFlights.Min(f => f.DepartureTime);
                var endTime = commercialFlights.Max(f => f.ArrivalTime);

                var ocupacion = new AircraftAvailability
                {
                    AircraftId = selectedAircraft.Id,
                    ReservationId = reservation.Id,
                    StartTime = startTime,
                    EndTime = endTime,
                    Type = "Reserva",
                    Status = "Confirmado"
                };

                await _db.AircraftAvailabilities.AddAsync(ocupacion);
                await _db.SaveChangesAsync();

                // ======================================================
                // 7️⃣ ACTUALIZAR UBICACIÓN (NO EL ESTADO)
                // ======================================================
                selectedAircraft.StatusLastUpdated = DateTime.UtcNow;
                selectedAircraft.CurrentAirportId = baseAirportId;
                await _db.SaveChangesAsync();

                await transaction.CommitAsync();

                // ======================================================
                // 8️⃣ RETORNAR DTO COMPLETO
                // ======================================================
                var created = await _db.Reservations
                    .Include(r => r.Company)
                    .Include(r => r.Flights).ThenInclude(f => f.DepartureAirport)
                    .Include(r => r.Flights).ThenInclude(f => f.ArrivalAirport)
                    .Include(r => r.Flights).ThenInclude(f => f.Aircraft)
                    .Include(r => r.Passengers)
                    .FirstAsync(r => r.Id == reservation.Id);

                return _mapper.Map<ReservationResponseDto>(created);
            }
            catch
            {
                await transaction.RollbackAsync();
                throw;
            }
        }

        // ======================================================
        // 🧮 ESTIMAR PRECIO (GENÉRICO POR EMPRESA)
        // ======================================================
        /// <summary>
        /// Calcula el precio estimado de una reserva antes de crearla.
        /// Aplica reglas diferentes para vuelos nacionales e internacionales,
        /// considerando tiempo total, impuestos, espera y pernocta.
        /// </summary>
        public async Task<ReservationEstimateResponseDto> EstimatePriceAsync(ReservationEstimateDto dto)
        {
            // ======================================================
            // 1️⃣ VALIDAR DATOS BÁSICOS
            // ======================================================
            var aircraft = await _db.Aircrafts
                .FirstOrDefaultAsync(a =>
                    a.CompanyId == dto.CompanyId &&
                    a.Model.ToLower() == dto.AircraftModel.ToLower() &&
                    a.IsActive);

            if (aircraft == null)
                throw new Exception("No se encontró la aeronave especificada.");

            if (aircraft.MinuteCost <= 0)
                throw new Exception("La aeronave no tiene una tarifa válida configurada.");

            double totalMinutos = 0;
            bool esInternacional = false;

            // ======================================================
            // 2️⃣ CALCULAR DURACIÓN TOTAL Y DETECTAR VUELOS INTERNACIONALES
            // ======================================================
            foreach (var segment in dto.Segments)
            {
                var airportFrom = await _db.Airports.FirstAsync(a => a.Id == segment.DepartureAirportId);
                var airportTo = await _db.Airports.FirstAsync(a => a.Id == segment.ArrivalAirportId);

                // Detectar si el vuelo cruza fronteras
                if (!string.Equals(airportFrom.Country.Trim(), airportTo.Country.Trim(), StringComparison.OrdinalIgnoreCase))
                    esInternacional = true;

                // Validar si la aeronave puede operar internacionalmente
                if (esInternacional && !aircraft.CanFlyInternational)
                {
                    throw new InvalidOperationException(
                        $"La aeronave '{aircraft.Model}' (matrícula {aircraft.Patent}) no puede realizar vuelos internacionales."
                    );
                }

                // Calcular duración del segmento
                totalMinutos += CalcularDuracionVuelo(airportFrom, airportTo, aircraft);
            }

            // ======================================================
            // 3️⃣ CALCULAR COSTO BASE POR MINUTO
            // ======================================================
            double costoBase = totalMinutos * aircraft.MinuteCost;

            // ======================================================
            // 4️⃣ CALCULAR IMPUESTOS SI ES INTERNACIONAL
            // ======================================================
            double impuestos = 0;
            if (esInternacional)
            {
                double impuestoAeroportuario = dto.TotalPassengers * 30;
                double handling = dto.TotalPassengers * 100;
                impuestos = impuestoAeroportuario + handling;
            }

            // ======================================================
            // 5️⃣ CALCULAR COSTOS DE ESPERA Y PERNOCTA (solo si hay varios segmentos)
            // ======================================================
            double costoEspera = 0;
            double costoPernocta = 0;

            if (dto.Segments.Count > 1)
            {
                for (int i = 0; i < dto.Segments.Count - 1; i++)
                {
                    var actual = dto.Segments[i];
                    var siguiente = dto.Segments[i + 1];

                    double horasDiferencia = (siguiente.DepartureTime - actual.ArrivalTime).TotalHours;

                    // 🔹 Si la espera es entre 6h y 24h → Hora de espera
                    if (horasDiferencia >= 6 && horasDiferencia < 24)
                        costoEspera += esInternacional ? 200 : 50;

                    // 🔹 Si cruza un día o supera las 24h → Pernocta
                    if (horasDiferencia >= 24 || actual.ArrivalTime.Date != siguiente.DepartureTime.Date)
                        costoPernocta += esInternacional ? 500 : 300;
                }
            }

            // ======================================================
            // 6️⃣ CALCULAR TOTAL
            // ======================================================
            double totalPrice = Math.Round(costoBase + impuestos + costoEspera + costoPernocta, 2);

            // ======================================================
            // 7️⃣ DEVOLVER DESGLOSE COMPLETO
            // ======================================================
            return new ReservationEstimateResponseDto
            {
                TotalMinutes = Math.Round(totalMinutos, 2),
                MinuteCost = aircraft.MinuteCost,
                BaseCost = Math.Round(costoBase, 2),
                Taxes = Math.Round(impuestos, 2),
                WaitCost = Math.Round(costoEspera, 2),
                OvernightCost = Math.Round(costoPernocta, 2),
                TotalPrice = totalPrice,
                IsInternational = esInternacional
            };
        }




        // ======================================================
        // 🔍 GET RESERVATION BY ID
        // ======================================================
        public async Task<ReservationResponseDto?> GetByIdAsync(int id)
        {
            var reservation = await _db.Reservations
                .Include(r => r.Company)
                .Include(r => r.Flights).ThenInclude(f => f.DepartureAirport)
                .Include(r => r.Flights).ThenInclude(f => f.ArrivalAirport)
                .Include(r => r.Flights).ThenInclude(f => f.Aircraft)
                .Include(r => r.Passengers)
                .FirstOrDefaultAsync(r => r.Id == id);

            return reservation == null ? null : _mapper.Map<ReservationResponseDto>(reservation);
        }

        // ======================================================
        // 📋 GET RESERVATIONS BY USER
        // ======================================================
        public async Task<IEnumerable<ReservationResponseDto>> GetByUserAsync(int userId)
        {
            var list = await _db.Reservations
                .Include(r => r.Company)
                .Include(r => r.Flights)
                .Where(r => r.UserId == userId)
                .ToListAsync();

            return _mapper.Map<IEnumerable<ReservationResponseDto>>(list);
        }

        // ======================================================
        // ❌ CANCEL RESERVATION
        // ======================================================
        public async Task<bool> CancelAsync(int reservationId)
        {
            var reservation = await _db.Reservations
                .Include(r => r.Flights)
                .ThenInclude(f => f.Aircraft)
                .FirstOrDefaultAsync(r => r.Id == reservationId);

            if (reservation == null)
                return false;

            reservation.Status = ReservationStatus.Cancelada;

            // Cancelar vuelos comerciales (no empty legs)
            foreach (var flight in reservation.Flights.Where(f => !f.IsEmptyLeg))
                flight.Status = FlightStatus.Cancelado;

            // Liberar ocupación
            var ocupaciones = await _db.AircraftAvailabilities
                .Where(o => o.ReservationId == reservationId && o.Status == "Confirmado")
                .ToListAsync();

            foreach (var o in ocupaciones)
                o.Status = "Cancelado";

            await _db.SaveChangesAsync();
            return true;
        }

        // ======================================================
        // 🧮 GENERADOR DE CÓDIGO DE RESERVA
        // ======================================================
        private async Task<string> GenerateReservationCodeAsync()
        {
            var total = await _db.Reservations.CountAsync() + 1;
            return $"AERO-{DateTime.UtcNow.Year}-{total:D5}";
        }

        // ======================================================
        // 📏 CÁLCULOS DE DISTANCIA Y DURACIÓN
        // ======================================================
        private double CalcularDistanciaKm(decimal lat1, decimal lon1, decimal lat2, decimal lon2)
        {
            const double R = 6371;
            double dLat = Math.PI / 180 * ((double)lat2 - (double)lat1);
            double dLon = Math.PI / 180 * ((double)lon2 - (double)lon1);

            double a = Math.Sin(dLat / 2) * Math.Sin(dLat / 2) +
                       Math.Cos(Math.PI / 180 * (double)lat1) *
                       Math.Cos(Math.PI / 180 * (double)lat2) *
                       Math.Sin(dLon / 2) * Math.Sin(dLon / 2);

            double c = 2 * Math.Atan2(Math.Sqrt(a), Math.Sqrt(1 - a));
            return R * c;
        }

        private double CalcularDuracionVuelo(Airport origen, Airport destino, Aircraft avion)
        {
            double distanciaKm = CalcularDistanciaKm(
                origen.Latitude, origen.Longitude,
                destino.Latitude, destino.Longitude
            );

            double velocidadKmH = avion.CruisingSpeed > 0 ? avion.CruisingSpeed : 250;
            double horas = distanciaKm / velocidadKmH;
            return horas * 60 + 10; // 10 min extra
        }

        // ======================================================
        // 🔍 VALIDACIÓN DE DISPONIBILIDAD
        // ======================================================
        /// <summary>
        /// Verifica si una aeronave está disponible durante el rango horario solicitado.
        /// Considera tanto su estado operativo como las ocupaciones registradas.
        /// Aplica un margen de 1 hora antes y después de cada reserva (turnaround).
        /// </summary>
        private async Task<Aircraft?> CheckAircraftAvailabilityAsync(
            int companyId,
            string model,
            int totalPassengers,
            DateTime requestedStart,
            DateTime requestedEnd)
        {
            const int turnaroundHours = 1; // 🔹 Margen de 1 hora antes y después

            return await _db.Aircrafts
                .Include(a => a.BaseAirport)
                .Where(a =>
                    a.CompanyId == companyId &&
                    a.Model.ToLower() == model.ToLower() &&
                    a.IsActive &&
                    a.State == AircraftState.Disponible &&
                    a.Seats >= totalPassengers &&
                    !_db.AircraftAvailabilities.Any(av =>
                        av.AircraftId == a.Id &&
                        av.Status == "Confirmado" &&
                        requestedStart < av.EndTime.AddHours(turnaroundHours) &&
                        requestedEnd > av.StartTime.AddHours(-turnaroundHours))
                )
                .FirstOrDefaultAsync();
        }

    }
}
