using AeroRide.API.Data;
using AeroRide.API.Helpers;
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
                // 1️⃣ VALIDAR COMPAÑÍA Y DISPONIBILIDAD
                // ======================================================
                var company = await _db.Companies.FirstOrDefaultAsync(c => c.Id == dto.CompanyId && c.IsActive);
                if (company == null)
                    throw new Exception("La compañía seleccionada no existe o está inactiva.");

                var totalPassengers = dto.Passengers.Count;
                var requestedStart = dto.Segments.Min(s => s.DepartureTime);
                var requestedEnd = dto.Segments.Max(s => s.ArrivalTime);

                var availability = await CheckAircraftAvailabilityAsync(
                    dto.CompanyId,
                    dto.AircraftModel,
                    totalPassengers,
                    requestedStart,
                    requestedEnd
                );

                if (availability.Aircraft == null)
                    throw new Exception($"No se pudo asignar aeronave: {availability.Reason}");

                var aircraft = availability.Aircraft;

                if (aircraft.State != AircraftState.Disponible)
                    throw new Exception($"La aeronave seleccionada no está disponible ({availability.Reason}).");



                // 🔹 Validar coherencia temporal de cada segmento
                foreach (var segment in dto.Segments)
                {
                    if (segment.ArrivalTime <= segment.DepartureTime)
                        throw new InvalidOperationException(
                            $"El segmento con salida {segment.DepartureTime:yyyy-MM-dd HH:mm}Z " +
                            $"tiene una hora de llegada anterior o igual a la salida."
                        );
                }


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
                foreach (var pax in dto.Passengers)
                {
                    var passenger = _mapper.Map<PassengerDetail>(pax);
                    passenger.ReservationId = reservation.Id;
                    await _db.PassengerDetails.AddAsync(passenger);
                }
                await _db.SaveChangesAsync();

                // ======================================================
                // 4️⃣ CONFIGURACIÓN INICIAL
                // ======================================================
                var baseAirport = await _db.Airports.FirstAsync(a => a.Id == aircraft.BaseAirportId);
                bool isRoundTrip = dto.IsRoundTrip;
                var allFlights = new List<Flight>();

                // ======================================================
                // 5️⃣ VALIDAR PESOS EN TODOS LOS SEGMENTOS
                // ======================================================
                foreach (var seg in dto.Segments)
                {
                    var dep = await _db.Airports.FirstAsync(a => a.Id == seg.DepartureAirportId);
                    var arr = await _db.Airports.FirstAsync(a => a.Id == seg.ArrivalAirportId);

                    if (aircraft.MaxWeight > dep.MaxAllowedWeight)
                        throw new InvalidOperationException($"La aeronave excede el peso permitido para despegar en {dep.Name}.");

                    if (aircraft.MaxWeight > arr.MaxAllowedWeight)
                        throw new InvalidOperationException($"La aeronave excede el peso permitido para aterrizar en {arr.Name}.");
                }

                // ======================================================
                // ✈️ 6️⃣ GENERAR VUELOS BASE (ida y vuelta)
                // ======================================================
                var firstSegment = dto.Segments.First();
                var lastSegment = dto.Segments.Last();

                // 🟩 Empty leg base → origen cliente (si el vuelo NO parte de la base)
                if (firstSegment.DepartureAirportId != baseAirport.Id)
                {
                    var origin = await _db.Airports.FirstAsync(a => a.Id == firstSegment.DepartureAirportId);
                    double duracionMin = CalcularDuracionVuelo(baseAirport, origin, aircraft);

                    allFlights.Add(new Flight
                    {
                        CompanyId = dto.CompanyId,
                        AircraftId = aircraft.Id,
                        ReservationId = null,
                        DepartureAirportId = baseAirport.Id,
                        ArrivalAirportId = origin.Id,
                        DepartureTime = firstSegment.DepartureTime.AddMinutes(-duracionMin - 60),
                        ArrivalTime = firstSegment.DepartureTime.AddMinutes(-60),
                        DurationMinutes = duracionMin,
                        IsEmptyLeg = true,
                        IsInternational = baseAirport.Country != origin.Country,
                        Status = FlightStatus.Programado,
                        CreatedAt = DateTime.UtcNow
                    });
                }

                // 🟦 Vuelos comerciales del cliente
                for (int i = 0; i < dto.Segments.Count; i++)
                {
                    var seg = dto.Segments[i];
                    var dep = await _db.Airports.FirstAsync(a => a.Id == seg.DepartureAirportId);
                    var arr = await _db.Airports.FirstAsync(a => a.Id == seg.ArrivalAirportId);

                    // 🕓 Validar horario de aeropuerto
                    if (!AirportTimeHelper.IsWithinOperatingHours(seg.DepartureTime, dep))
                        throw new InvalidOperationException($"El aeropuerto {dep.Name} está cerrado en esa hora de salida.");

                    if (!AirportTimeHelper.IsWithinOperatingHours(seg.ArrivalTime, arr))
                        throw new InvalidOperationException($"El aeropuerto {arr.Name} está cerrado en esa hora de llegada.");


                    // 🌎 Validar vuelo internacional
                    bool isInternational = dep.Country.Trim().ToLower() != arr.Country.Trim().ToLower();
                    if (isInternational && !aircraft.CanFlyInternational)
                        throw new InvalidOperationException($"La aeronave '{aircraft.Model}' no puede realizar vuelos internacionales.");

                    // ⏱ Calcular duración y crear vuelo
                    double duracionMin = CalcularDuracionVuelo(dep, arr, aircraft);
                    if (duracionMin < 10) duracionMin = 10;

                    allFlights.Add(new Flight
                    {
                        CompanyId = dto.CompanyId,
                        AircraftId = aircraft.Id,
                        ReservationId = reservation.Id,
                        DepartureAirportId = dep.Id,
                        ArrivalAirportId = arr.Id,
                        DepartureTime = seg.DepartureTime,
                        ArrivalTime = seg.DepartureTime.AddMinutes(duracionMin),
                        DurationMinutes = duracionMin,
                        IsEmptyLeg = false,
                        IsInternational = isInternational,
                        Status = FlightStatus.Programado,
                        CreatedAt = DateTime.UtcNow
                    });

                    // 🕐 R3 – Espera mínima de 45 minutos entre vuelos
                    if (i < dto.Segments.Count - 1)
                    {
                        var siguiente = dto.Segments[i + 1];
                        if ((siguiente.DepartureTime - seg.ArrivalTime).TotalMinutes < 45)
                            throw new InvalidOperationException("Debe haber al menos 45 minutos entre vuelos consecutivos.");
                    }
                }

                // 🟥 Empty leg regreso — destino cliente → base (solo one-way)
                if (!isRoundTrip && lastSegment.ArrivalAirportId != baseAirport.Id)
                {
                    var destinationAirport = await _db.Airports.FirstAsync(a => a.Id == lastSegment.ArrivalAirportId);

                    // 🚫 Evitar duplicar si se activará una pernocta
                    if (!AirportTimeHelper.ShouldOvernight(destinationAirport, lastSegment.ArrivalTime))
                    {
                        double duracionMin = CalcularDuracionVuelo(destinationAirport, baseAirport, aircraft);

                        allFlights.Add(new Flight
                        {
                            CompanyId = dto.CompanyId,
                            AircraftId = aircraft.Id,
                            ReservationId = null,
                            DepartureAirportId = destinationAirport.Id,
                            ArrivalAirportId = baseAirport.Id,
                            DepartureTime = lastSegment.ArrivalTime.AddMinutes(30),
                            ArrivalTime = lastSegment.ArrivalTime.AddMinutes(30 + duracionMin),
                            DurationMinutes = duracionMin,
                            IsEmptyLeg = true,
                            IsInternational = destinationAirport.Country != baseAirport.Country,
                            Status = FlightStatus.Programado,
                            CreatedAt = DateTime.UtcNow
                        });
                    }
                }


                // ======================================================
                // 🌙 7️⃣ Pernocta automática si llega tarde
                // ======================================================
                var destinoFinal = await _db.Airports.FirstAsync(a => a.Id == lastSegment.ArrivalAirportId);
                if (destinoFinal.Id != baseAirport.Id && AirportTimeHelper.ShouldOvernight(destinoFinal, lastSegment.ArrivalTime))
                {
                    var salidaManana = TimeHelper.ToUtc(
                        TimeHelper.ToLocalTime(lastSegment.ArrivalTime, destinoFinal.TimeZone).Date
                            .AddDays(1)
                            .Add(destinoFinal.OpeningTime ?? new TimeSpan(6, 0, 0)),
                        destinoFinal.TimeZone
                    );

                    var duracionMin = CalcularDuracionVuelo(destinoFinal, baseAirport, aircraft);
                    allFlights.Add(new Flight
                    {
                        CompanyId = dto.CompanyId,
                        AircraftId = aircraft.Id,
                        ReservationId = null,
                        DepartureAirportId = destinoFinal.Id,
                        ArrivalAirportId = baseAirport.Id,
                        DepartureTime = salidaManana,
                        ArrivalTime = salidaManana.AddMinutes(duracionMin),
                        DurationMinutes = duracionMin,
                        IsEmptyLeg = true,
                        IsInternational = destinoFinal.Country != baseAirport.Country,
                        Status = FlightStatus.Programado,
                        CreatedAt = DateTime.UtcNow
                    });
                }


                // ======================================================
                // 🔁 8️⃣ R11 – ROUNDTRIP EXTENDIDO (>4h de espera)
                // ======================================================
                if (isRoundTrip && dto.Segments.Count == 2)
                {
                    var segIda = dto.Segments[0];
                    var segVuelta = dto.Segments[1];

                    double horasEspera = (segVuelta.DepartureTime - segIda.ArrivalTime).TotalHours;
                    if (horasEspera > 6)
                    {
                        var arrIda = await _db.Airports.FirstAsync(a => a.Id == segIda.ArrivalAirportId);

                        // Empty leg regreso base después de ida
                        double durRegreso = CalcularDuracionVuelo(arrIda, baseAirport, aircraft);
                        allFlights.Add(new Flight
                        {
                            CompanyId = dto.CompanyId,
                            AircraftId = aircraft.Id,
                            ReservationId = null,
                            DepartureAirportId = arrIda.Id,
                            ArrivalAirportId = baseAirport.Id,
                            DepartureTime = segIda.ArrivalTime.AddMinutes(30),
                            ArrivalTime = segIda.ArrivalTime.AddMinutes(30 + durRegreso),
                            DurationMinutes = durRegreso,
                            IsEmptyLeg = true,
                            Status = FlightStatus.Programado
                        });

                        // Empty leg de salida para recoger vuelta
                        double durSalida = CalcularDuracionVuelo(baseAirport, arrIda, aircraft);
                        allFlights.Add(new Flight
                        {
                            CompanyId = dto.CompanyId,
                            AircraftId = aircraft.Id,
                            ReservationId = null,
                            DepartureAirportId = baseAirport.Id,
                            ArrivalAirportId = arrIda.Id,
                            DepartureTime = segVuelta.DepartureTime.AddMinutes(-durSalida - 60),
                            ArrivalTime = segVuelta.DepartureTime.AddMinutes(-60),
                            DurationMinutes = durSalida,
                            IsEmptyLeg = true,
                            Status = FlightStatus.Programado
                        });
                    }
                }

                // ======================================================
                // 9️⃣ GUARDAR Y BLOQUEAR HORARIOS
                // ======================================================
                await _db.Flights.AddRangeAsync(allFlights);
                await _db.SaveChangesAsync();

                // Agrupa vuelos contiguos con menos de 1h entre ellos
                var orderedFlights = allFlights.OrderBy(f => f.DepartureTime).ToList();
                var grupos = new List<(DateTime inicio, DateTime fin)>();

                DateTime grupoInicio = orderedFlights[0].DepartureTime;
                DateTime grupoFin = orderedFlights[0].ArrivalTime;

                for (int i = 1; i < orderedFlights.Count; i++)
                {
                    var gap = orderedFlights[i].DepartureTime - grupoFin;
                    if (gap.TotalMinutes <= 60)
                    {
                        // Es parte del mismo bloque
                        grupoFin = orderedFlights[i].ArrivalTime;
                    }
                    else
                    {
                        // Nuevo bloque
                        grupos.Add((grupoInicio, grupoFin));
                        grupoInicio = orderedFlights[i].DepartureTime;
                        grupoFin = orderedFlights[i].ArrivalTime;
                    }
                }
                grupos.Add((grupoInicio, grupoFin));

                // Guarda un registro por bloque
                foreach (var g in grupos)
                {
                    await _db.AircraftAvailabilities.AddAsync(new AircraftAvailability
                    {
                        AircraftId = aircraft.Id,
                        ReservationId = reservation.Id,
                        StartTime = g.inicio,
                        EndTime = g.fin.AddMinutes(45),
                        Type = "Reserva",
                        Status = "Confirmado"
                    });
                }

                await _db.SaveChangesAsync();

                // ======================================================
                // 🔟 ACTUALIZAR UBICACIÓN
                // ======================================================
                aircraft.StatusLastUpdated = DateTime.UtcNow;
                aircraft.CurrentAirportId = baseAirport.Id;
                await _db.SaveChangesAsync();

                await transaction.CommitAsync();

                // ======================================================
                // 🔁 DEVOLVER RESULTADO COMPLETO
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
        /// Considera estado operativo, ocupaciones previas y ventanas libres (>6h).
        /// Si la aeronave ya está en la base después del último vuelo, no descuenta traslados.
        /// </summary>
        private async Task<AircraftAvailabilityResult> CheckAircraftAvailabilityAsync(
            int companyId,
            string model,
            int totalPassengers,
            DateTime requestedStart,
            DateTime requestedEnd)
        {
            const int turnaroundMinutesBase = 45;     // margen mínimo entre vuelos
            const int turnaroundMinutesRemote = 60;   // margen si no está en base
            const int ventanaMinimaLibreHoras = 6;    // tiempo mínimo entre bloques grandes

            var aircrafts = await _db.Aircrafts
                .Include(a => a.BaseAirport)
                .Where(a =>
                    a.CompanyId == companyId &&
                    a.Model.ToLower() == model.ToLower() &&
                    a.IsActive &&
                    a.State == AircraftState.Disponible &&
                    a.Seats >= totalPassengers)
                .ToListAsync();

            if (!aircrafts.Any())
                return new AircraftAvailabilityResult { Reason = "No hay aeronaves activas disponibles de este modelo." };

            foreach (var aircraft in aircrafts)
            {
                var ocupaciones = await _db.AircraftAvailabilities
                    .Where(av => av.AircraftId == aircraft.Id && av.Status == "Confirmado")
                    .OrderBy(av => av.StartTime)
                    .ToListAsync();

                // ✅ Sin reservas → totalmente libre
                if (!ocupaciones.Any())
                    return new AircraftAvailabilityResult { Aircraft = aircraft, Reason = "Aeronave libre (sin reservas previas)." };

                // ⚙️ Detectar si la última reserva deja al avión en base
                bool ultimoEnBase = aircraft.CurrentAirportId == aircraft.BaseAirportId;

                // 📆 Revisar conflictos directos
                bool conflicto = ocupaciones.Any(av =>
                    requestedStart < av.EndTime.AddMinutes(turnaroundMinutesRemote) &&
                    requestedEnd > av.StartTime.AddMinutes(-turnaroundMinutesRemote));

                if (!conflicto)
                    return new AircraftAvailabilityResult { Aircraft = aircraft, Reason = "Aeronave libre (sin solapamientos directos)." };

                // 🧩 Buscar ventanas disponibles entre reservas
                for (int i = 0; i < ocupaciones.Count - 1; i++)
                {
                    var actual = ocupaciones[i];
                    var siguiente = ocupaciones[i + 1];
                    var gap = siguiente.StartTime - actual.EndTime;

                    if (gap.TotalHours >= ventanaMinimaLibreHoras)
                    {
                        // 🕓 Detectar si entre reservas está en base
                        bool enBase = ultimoEnBase || aircraft.CurrentAirportId == aircraft.BaseAirportId;
                        int margen = enBase ? turnaroundMinutesBase : turnaroundMinutesRemote;

                        var ventanaInicio = actual.EndTime.AddMinutes(margen);
                        var ventanaFin = siguiente.StartTime.AddMinutes(-margen);

                        // Si la solicitud cabe completa en esa ventana
                        if (requestedStart >= ventanaInicio && requestedEnd <= ventanaFin)
                        {
                            double duracionMin = (requestedEnd - requestedStart).TotalMinutes;

                            // 🧮 Calcular tiempo disponible real de la ventana
                            double minutosVentana = (ventanaFin - ventanaInicio).TotalMinutes;

                            if (duracionMin <= minutosVentana)
                            {
                                return new AircraftAvailabilityResult
                                {
                                    Aircraft = aircraft,
                                    Reason = $"Disponible en base entre reservas ({ventanaInicio:t}–{ventanaFin:t})."
                                };
                            }
                        }
                    }
                }
            }

            // 🚫 Si ninguna aeronave aplica
            return new AircraftAvailabilityResult
            {
                Reason = "Todas las aeronaves del modelo están ocupadas o sin suficiente ventana libre."
            };
        }







    }
}
