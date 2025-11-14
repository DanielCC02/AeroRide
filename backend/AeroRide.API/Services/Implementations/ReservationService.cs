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
                    double duracionMin = FlightMathHelper.CalcularDuracionVuelo(baseAirport, origin, aircraft);

                    // Convertir hora local del aeropuerto a UTC
                    var departureUtc = TimeHelper.ToUtc(firstSegment.DepartureTime.AddMinutes(-duracionMin - 60), origin.TimeZone);
                    var arrivalUtc = TimeHelper.ToUtc(firstSegment.DepartureTime.AddMinutes(-60), origin.TimeZone);

                    // Redondear
                    departureUtc = TimeHelper.RedondearAHoraProxima(departureUtc, 5);
                    arrivalUtc = TimeHelper.RedondearAHoraProxima(arrivalUtc, 5);

                    allFlights.Add(new Flight
                    {
                        CompanyId = dto.CompanyId,
                        AircraftId = aircraft.Id,
                        ReservationId = null,
                        DepartureAirportId = baseAirport.Id,
                        ArrivalAirportId = origin.Id,
                        DepartureTime = departureUtc,
                        ArrivalTime = arrivalUtc,
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

                    // 🔹 Convertir horas locales a UTC (según cada aeropuerto)
                    var depUtc = TimeHelper.ToUtc(seg.DepartureTime, dep.TimeZone);
                    var arrUtc = TimeHelper.ToUtc(seg.ArrivalTime, arr.TimeZone);

                    // 🔹 Validar horarios operativos (en hora UTC)
                    if (!AirportTimeHelper.IsWithinOperatingHours(depUtc, dep))
                        throw new InvalidOperationException($"El aeropuerto {dep.Name} está cerrado en esa hora de salida.");

                    if (!AirportTimeHelper.IsWithinOperatingHours(arrUtc, arr))
                        throw new InvalidOperationException($"El aeropuerto {arr.Name} está cerrado en esa hora de llegada.");

                    // 🌎 Validar vuelo internacional
                    bool isInternational = dep.Country.Trim().ToLower() != arr.Country.Trim().ToLower();
                    if (isInternational && !aircraft.CanFlyInternational)
                        throw new InvalidOperationException($"La aeronave '{aircraft.Model}' no puede realizar vuelos internacionales.");

                    // ⏱ Calcular duración real por distancia
                    double duracionMin = FlightMathHelper.CalcularDuracionVuelo(dep, arr, aircraft);
                    if (duracionMin < 10) duracionMin = 10;

                    // 🔹 Redondear horas en UTC
                    depUtc = TimeHelper.RedondearAHoraProxima(depUtc, 5);
                    arrUtc = TimeHelper.RedondearAHoraProxima(depUtc.AddMinutes(duracionMin), 5);

                    allFlights.Add(new Flight
                    {
                        CompanyId = dto.CompanyId,
                        AircraftId = aircraft.Id,
                        ReservationId = reservation.Id,
                        DepartureAirportId = dep.Id,
                        ArrivalAirportId = arr.Id,
                        DepartureTime = depUtc,
                        ArrivalTime = arrUtc,
                        DurationMinutes = duracionMin,
                        IsEmptyLeg = false,
                        IsInternational = isInternational,
                        Status = FlightStatus.Programado,
                        CreatedAt = DateTime.UtcNow
                    });

                    // 🕐 R3 – Espera mínima de 30 minutos entre vuelos
                    if (i < dto.Segments.Count - 1)
                    {
                        var siguiente = dto.Segments[i + 1];
                        if ((siguiente.DepartureTime - seg.ArrivalTime).TotalMinutes < 30)
                            throw new InvalidOperationException("Debe haber al menos 30 minutos entre vuelos consecutivos.");
                    }
                }


                // 🟥 Empty leg regreso — destino cliente → base (solo one-way)
                if (!isRoundTrip && lastSegment.ArrivalAirportId != baseAirport.Id)
                {
                    var destinationAirport = await _db.Airports.FirstAsync(a => a.Id == lastSegment.ArrivalAirportId);

                    // 🚫 Evitar duplicar si se activará una pernocta
                    if (!AirportTimeHelper.ShouldOvernight(destinationAirport, lastSegment.ArrivalTime))
                    {
                        double duracionMin = FlightMathHelper.CalcularDuracionVuelo(destinationAirport, baseAirport, aircraft);

                        // 🔹 Calcular horas en UTC
                        var departureUtc = TimeHelper.ToUtc(lastSegment.ArrivalTime.AddMinutes(30), destinationAirport.TimeZone);
                        var arrivalUtc = departureUtc.AddMinutes(duracionMin);

                        // 🔹 Redondear
                        departureUtc = TimeHelper.RedondearAHoraProxima(departureUtc, 5);
                        arrivalUtc = TimeHelper.RedondearAHoraProxima(arrivalUtc, 5);

                        allFlights.Add(new Flight
                        {
                            CompanyId = dto.CompanyId,
                            AircraftId = aircraft.Id,
                            ReservationId = null,
                            DepartureAirportId = destinationAirport.Id,
                            ArrivalAirportId = baseAirport.Id,
                            DepartureTime = departureUtc,
                            ArrivalTime = arrivalUtc,
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
                    // 🔹 Convertir hora de llegada local → UTC
                    var arrivalUtc = TimeHelper.ToUtc(lastSegment.ArrivalTime, destinoFinal.TimeZone);

                    // 🔹 Calcular hora de salida del día siguiente (hora local del aeropuerto)
                    var localArrival = TimeHelper.ToLocalTime(arrivalUtc, destinoFinal.TimeZone);
                    var salidaLocal = localArrival.Date.AddDays(1).Add(destinoFinal.OpeningTime ?? new TimeSpan(6, 0, 0));

                    // 🔹 Convertir esa salida local a UTC
                    var salidaUtc = TimeHelper.ToUtc(salidaLocal, destinoFinal.TimeZone);

                    double duracionMin = FlightMathHelper.CalcularDuracionVuelo(destinoFinal, baseAirport, aircraft);

                    // 🔹 Redondear
                    salidaUtc = TimeHelper.RedondearAHoraProxima(salidaUtc, 5);
                    var llegadaUtc = TimeHelper.RedondearAHoraProxima(salidaUtc.AddMinutes(duracionMin), 5);

                    allFlights.Add(new Flight
                    {
                        CompanyId = dto.CompanyId,
                        AircraftId = aircraft.Id,
                        ReservationId = null,
                        DepartureAirportId = destinoFinal.Id,
                        ArrivalAirportId = baseAirport.Id,
                        DepartureTime = salidaUtc,
                        ArrivalTime = llegadaUtc,
                        DurationMinutes = duracionMin,
                        IsEmptyLeg = true,
                        IsInternational = destinoFinal.Country != baseAirport.Country,
                        Status = FlightStatus.Programado,
                        CreatedAt = DateTime.UtcNow
                    });
                }



                // ======================================================
                // 🔁 8️⃣ R11 – ROUNDTRIP EXTENDIDO (>6h de espera)
                // ======================================================
                if (isRoundTrip && dto.Segments.Count == 2)
                {
                    var segIda = dto.Segments[0];
                    var segVuelta = dto.Segments[1];

                    double horasEspera = (segVuelta.DepartureTime - segIda.ArrivalTime).TotalHours;
                    if (horasEspera > 6)
                    {
                        var arrIda = await _db.Airports.FirstAsync(a => a.Id == segIda.ArrivalAirportId);

                        // 🔹 Calcular vuelo regreso base tras la ida
                        double durRegreso = FlightMathHelper.CalcularDuracionVuelo(arrIda, baseAirport, aircraft);

                        var departureBackUtc = TimeHelper.ToUtc(segIda.ArrivalTime.AddMinutes(30), arrIda.TimeZone);
                        var arrivalBackUtc = departureBackUtc.AddMinutes(durRegreso);

                        // Redondear
                        departureBackUtc = TimeHelper.RedondearAHoraProxima(departureBackUtc, 5);
                        arrivalBackUtc = TimeHelper.RedondearAHoraProxima(arrivalBackUtc, 5);

                        allFlights.Add(new Flight
                        {
                            CompanyId = dto.CompanyId,
                            AircraftId = aircraft.Id,
                            ReservationId = null,
                            DepartureAirportId = arrIda.Id,
                            ArrivalAirportId = baseAirport.Id,
                            DepartureTime = departureBackUtc,
                            ArrivalTime = arrivalBackUtc,
                            DurationMinutes = durRegreso,
                            IsEmptyLeg = true,
                            Status = FlightStatus.Programado
                        });

                        // 🔹 Calcular empty leg de salida para recoger vuelta
                        double durSalida = FlightMathHelper.CalcularDuracionVuelo(baseAirport, arrIda, aircraft);

                        var departureOutUtc = TimeHelper.ToUtc(segVuelta.DepartureTime.AddMinutes(-durSalida - 60), arrIda.TimeZone);
                        var arrivalOutUtc = TimeHelper.ToUtc(segVuelta.DepartureTime.AddMinutes(-60), arrIda.TimeZone);

                        // Redondear
                        departureOutUtc = TimeHelper.RedondearAHoraProxima(departureOutUtc, 5);
                        arrivalOutUtc = TimeHelper.RedondearAHoraProxima(arrivalOutUtc, 5);

                        allFlights.Add(new Flight
                        {
                            CompanyId = dto.CompanyId,
                            AircraftId = aircraft.Id,
                            ReservationId = null,
                            DepartureAirportId = baseAirport.Id,
                            ArrivalAirportId = arrIda.Id,
                            DepartureTime = departureOutUtc,
                            ArrivalTime = arrivalOutUtc,
                            DurationMinutes = durSalida,
                            IsEmptyLeg = true,
                            Status = FlightStatus.Programado
                        });
                    }
                }


                // ======================================================
                // 9️⃣ GUARDAR Y BLOQUEAR HORARIOS (agrupado con 30 min)
                // ======================================================
                await _db.Flights.AddRangeAsync(allFlights);
                await _db.SaveChangesAsync();

                // 🔹 Ordenar vuelos por hora UTC
                var orderedFlights = allFlights.OrderBy(f => f.DepartureTime).ToList();
                var grupos = new List<(DateTime inicio, DateTime fin)>();

                DateTime grupoInicio = orderedFlights[0].DepartureTime;
                DateTime grupoFin = orderedFlights[0].ArrivalTime;

                for (int i = 1; i < orderedFlights.Count; i++)
                {
                    var gap = orderedFlights[i].DepartureTime - grupoFin;

                    // 🔹 Unir vuelos si están cercanos (<90 min)
                    //    o si pertenecen al mismo día y reserva,
                    //    pero si hay más de 6h entre vuelos, crear bloque separado
                    bool mismoDia = orderedFlights[i].DepartureTime.Date == grupoInicio.Date;
                    bool mismaReserva = orderedFlights[i].ReservationId == orderedFlights[i - 1].ReservationId;

                    if ((gap.TotalMinutes <= 90 || (mismaReserva && mismoDia)) && gap.TotalHours < 6)
                    {
                        grupoFin = orderedFlights[i].ArrivalTime;
                    }
                    else
                    {
                        grupos.Add((grupoInicio, grupoFin));
                        grupoInicio = orderedFlights[i].DepartureTime;
                        grupoFin = orderedFlights[i].ArrivalTime;
                    }
                }
                grupos.Add((grupoInicio, grupoFin));

                // 🔹 Crear registros de disponibilidad (en UTC)
                foreach (var g in grupos)
                {
                    // Redondear el bloque a múltiplos de 5 minutos
                    var startUtc = TimeHelper.RedondearAHoraProxima(g.inicio, 5);
                    var endUtc = TimeHelper.RedondearAHoraProxima(g.fin.AddMinutes(30), 5); // margen 30 min post-vuelo

                    await _db.AircraftAvailabilities.AddAsync(new AircraftAvailability
                    {
                        AircraftId = aircraft.Id,
                        ReservationId = reservation.Id,
                        StartTime = startUtc,
                        EndTime = endUtc,
                        Type = "Reserva",
                        Status = "Confirmado"
                    });
                }

                await _db.SaveChangesAsync();


                // ======================================================
                // 🔟 ACTUALIZAR UBICACIÓN FINAL DEL AVIÓN
                // ======================================================

                // ✅ Siempre mantener coherencia UTC en los registros
                aircraft.StatusLastUpdated = DateTime.UtcNow;

                // 🔹 Si el vuelo final termina en la base → actualizar ubicación
                var ultimoVuelo = orderedFlights.Last();
                aircraft.CurrentAirportId = (ultimoVuelo.ArrivalAirportId == baseAirport.Id)
                    ? baseAirport.Id
                    : ultimoVuelo.ArrivalAirportId;

                await _db.SaveChangesAsync();

                await transaction.CommitAsync();


                // ======================================================
                // 🔁 DEVOLVER RESULTADO COMPLETO (incluye vuelos y pasajeros)
                // ======================================================
                var created = await _db.Reservations
                    .Include(r => r.Company)
                    .Include(r => r.Flights).ThenInclude(f => f.DepartureAirport)
                    .Include(r => r.Flights).ThenInclude(f => f.ArrivalAirport)
                    .Include(r => r.Flights).ThenInclude(f => f.Aircraft)
                    .Include(r => r.Passengers)
                    .FirstAsync(r => r.Id == reservation.Id);

                return _mapper.Map<ReservationResponseDto>(created);

                Console.WriteLine($"{dto.Segments[0].DepartureTime:o} - Kind: {dto.Segments[0].DepartureTime.Kind}");


            }
            catch (Exception ex)
            {
                await transaction.RollbackAsync();

                // Extraer el mensaje de la inner exception (la que tiene el detalle SQL)
                string inner = ex.InnerException?.Message ?? ex.Message;

                // Opcional: si hay una inner de inner (por ejemplo PostgresException.InnerException)
                if (ex.InnerException?.InnerException != null)
                    inner += $" → {ex.InnerException.InnerException.Message}";

                // Mostrar el detalle real del error al frontend
                throw new Exception($"Error al crear la reserva: {inner}");
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
                totalMinutos += FlightMathHelper.CalcularDuracionVuelo(airportFrom, airportTo, aircraft);
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
            DateTime requestedEnd
            )
        {
            const int turnaroundMinutes = 30;       // 🔹 margen estándar entre vuelos
            const int ventanaMinimaLibreHoras = 6;  // 🔹 si el hueco es mayor a 6h, se considera ventana aprovechable

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

                // ✅ Sin reservas → libre
                if (!ocupaciones.Any())
                    return new AircraftAvailabilityResult { Aircraft = aircraft, Reason = "Aeronave libre (sin reservas previas)." };

                // ⚠️ Conflicto directo con otra reserva
                bool conflicto = ocupaciones.Any(av =>
                    requestedStart < av.EndTime.AddMinutes(turnaroundMinutes) &&
                    requestedEnd > av.StartTime.AddMinutes(-turnaroundMinutes));

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
                        var ventanaInicio = actual.EndTime.AddMinutes(turnaroundMinutes);
                        var ventanaFin = siguiente.StartTime.AddMinutes(-turnaroundMinutes);
                        double minutosVentana = (ventanaFin - ventanaInicio).TotalMinutes;

                        // 🕓 calcular distancia (ida y vuelta a base)
                        var baseAirport = await _db.Airports.FirstAsync(a => a.Id == aircraft.BaseAirportId);
                        double duracionIda = 0, duracionVuelta = 0;

                        // Determinar aeropuerto actual del avión (por ahora tomamos base)
                        var aeropuertoActual = baseAirport;

                        // Calcular tiempos de traslado desde/hacia base
                        if (aeropuertoActual.Id != baseAirport.Id)
                        {
                            duracionIda = FlightMathHelper.CalcularDuracionVuelo(aeropuertoActual, baseAirport, aircraft);
                            duracionVuelta = FlightMathHelper.CalcularDuracionVuelo(baseAirport, aeropuertoActual, aircraft);
                        }

                        // Duración total estimada (vuelo solicitado + traslado base ↔ origen + margen 30 min)
                        double duracionSolicitada = (requestedEnd - requestedStart).TotalMinutes;
                        double duracionTotal = duracionIda + duracionVuelta + duracionSolicitada + (turnaroundMinutes * 2);

                        if (requestedStart >= ventanaInicio && requestedEnd <= ventanaFin && duracionTotal <= minutosVentana)
                        {
                            return new AircraftAvailabilityResult
                            {
                                Aircraft = aircraft,
                                Reason = $"Disponible en ventana libre ({ventanaInicio:t}–{ventanaFin:t}). Duración total: {duracionTotal:F0} min"
                            };
                        }
                    }
                }
            }

            // 🚫 Ninguna aeronave aplicó
            return new AircraftAvailabilityResult
            {
                Reason = "Todas las aeronaves del modelo están ocupadas o sin suficiente ventana libre."
            };
        }


    }
}
