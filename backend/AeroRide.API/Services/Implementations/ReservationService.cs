using AeroRide.API.Data;
using AeroRide.API.Helpers;
using AeroRide.API.Models.Domain;
using AeroRide.API.Models.DTOs.EmptyLegs;
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
        private readonly IEmptyLegNotificationService _emptyLegNotificationService;

        public ReservationService(
        AeroRideDbContext db,
        IMapper mapper,
        IEmptyLegNotificationService emptyLegNotificationService)
        {
            _db = db;
            _mapper = mapper;
            _emptyLegNotificationService = emptyLegNotificationService;
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


                var orderedSegments = dto.Segments.OrderBy(s => s.DepartureTime).ToList();

                var utcRanges = new List<(DateTime Start, DateTime End)>();

                foreach (var s in orderedSegments)
                {
                    var depA = await _db.Airports.FirstAsync(a => a.Id == s.DepartureAirportId);
                    var arrA = await _db.Airports.FirstAsync(a => a.Id == s.ArrivalAirportId);

                    var startUtc = TimeHelper.ToUtc(s.DepartureTime, depA.TimeZone);
                    var endUtc = TimeHelper.ToUtc(s.ArrivalTime, arrA.TimeZone);

                    utcRanges.Add((startUtc, endUtc));
                }

                var requestedStartUtc = utcRanges.Min(x => x.Start);
                var requestedEndUtc = utcRanges.Max(x => x.End);



                // ======================================================
                // 🛩️ 1️⃣ SELECCIONAR UNA AERONAVE REAL ENTRE LAS VÁLIDAS
                // ======================================================
                Aircraft aircraft = null;

                if (dto.AircraftIds == null || !dto.AircraftIds.Any())
                    throw new Exception("No se enviaron aeronaves válidas para esta reserva.");

                foreach (var id in dto.AircraftIds)
                {
                    var candidate = await _db.Aircrafts
                        .Include(a => a.BaseAirport)
                        .Include(a => a.Company)
                        .FirstOrDefaultAsync(a =>
                            a.Id == id &&
                            a.IsActive &&
                            a.CompanyId == dto.CompanyId);

                    if (candidate == null)
                        continue;

                    // Validar disponibilidad exacta
                    bool free = await IsAircraftAvailableInRangeAsync(
                        candidate.Id,
                        requestedStartUtc,
                        requestedEndUtc
                    );

                    if (!free)
                        continue;

                    aircraft = candidate;
                    break;
                }

                if (aircraft == null)
                    throw new Exception("Ninguna aeronave del grupo está disponible en este horario.");

                // 🔹 Validar coherencia temporal de cada segmento
                foreach (var segment in orderedSegments)
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
                foreach (var seg in orderedSegments)
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
                var firstSegment = orderedSegments.First();
                var lastSegment = orderedSegments.Last();


                // 🟩 Empty leg base → origen cliente (si el vuelo NO parte de la base)
                if (firstSegment.DepartureAirportId != baseAirport.Id)
                {

                    var origin = await _db.Airports.FirstAsync(a => a.Id == firstSegment.DepartureAirportId);
                    double duracionMin = FlightMathHelper.CalcularDuracionVuelo(baseAirport, origin, aircraft);

                    // Convertir hora local del aeropuerto a UTC
                    var arrivalUtc = TimeHelper.ToUtc(firstSegment.DepartureTime.AddMinutes(-30), origin.TimeZone);
                    var departureUtc = arrivalUtc.AddMinutes(-duracionMin);


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
                        Status = FlightStatus.PreFlight,
                        CreatedAt = DateTime.UtcNow
                    });
                }


                // 🟦 Vuelos comerciales del cliente
                for (int i = 0; i < orderedSegments.Count; i++)
                {
                    var seg = orderedSegments[i];

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

                    // ⭐ Aplicar turn-around si había vuelos previos
                    if (allFlights.Any())
                        depUtc = ForzarMinimoConTurnaround(allFlights.Last().ArrivalTime, depUtc);

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
                        Status = FlightStatus.PreFlight,
                        CreatedAt = DateTime.UtcNow
                    });

                    // 🕐 R3 – Espera mínima de 30 minutos entre vuelos
                    if (i < dto.Segments.Count - 1)
                    {
                        var siguiente = orderedSegments[i + 1];

                        var siguienteDepAirport = await _db.Airports.FirstAsync(a => a.Id == siguiente.DepartureAirportId);
                        var gapUtc = TimeHelper.ToUtc(siguiente.DepartureTime, siguienteDepAirport.TimeZone)
                                   - TimeHelper.ToUtc(seg.ArrivalTime, arr.TimeZone);


                        if (gapUtc.TotalMinutes < 30)
                            throw new InvalidOperationException("Debe haber al menos 30 minutos entre vuelos consecutivos.");
                    }
                }


                // 🟥 Empty leg regreso — destino cliente → base (solo one-way)
                if (!isRoundTrip && lastSegment.ArrivalAirportId != baseAirport.Id)
                {
                    var destinationAirport = await _db.Airports.FirstAsync(a => a.Id == lastSegment.ArrivalAirportId);

                    // Convertir llegada a UTC (nuevo requisito del método ShouldOvernight)
                    var arrivalUtc = TimeHelper.ToUtc(lastSegment.ArrivalTime, destinationAirport.TimeZone);

                    // Duración real hacia la base (necesaria para la nueva validación)
                    double duracionMin = FlightMathHelper.CalcularDuracionVuelo(destinationAirport, baseAirport, aircraft);

                    // 🚫 Evitar duplicar si se activará una pernocta
                    if (!AirportTimeHelper.ShouldOvernight(destinationAirport, arrivalUtc, baseAirport, duracionMin))
                    {
                        // Salida 30 min después de la llegada
                        var departureUtc = arrivalUtc.AddMinutes(30);
                        var arrivalBackUtc = departureUtc.AddMinutes(duracionMin);

                        // 🔹 Redondear
                        departureUtc = TimeHelper.RedondearAHoraProxima(departureUtc, 5);
                        arrivalBackUtc = TimeHelper.RedondearAHoraProxima(arrivalBackUtc, 5);

                        allFlights.Add(new Flight
                        {
                            CompanyId = dto.CompanyId,
                            AircraftId = aircraft.Id,
                            ReservationId = null,
                            DepartureAirportId = destinationAirport.Id,
                            ArrivalAirportId = baseAirport.Id,
                            DepartureTime = departureUtc,
                            ArrivalTime = arrivalBackUtc,
                            DurationMinutes = duracionMin,
                            IsEmptyLeg = true,
                            IsInternational = destinationAirport.Country != baseAirport.Country,
                            Status = FlightStatus.PreFlight,
                            CreatedAt = DateTime.UtcNow
                        });
                    }
                }




                // ======================================================
                // 🌙 7️⃣ Pernocta automática con reglas reales de aeropuertos
                // ======================================================
                var destinoFinal = await _db.Airports.FirstAsync(a => a.Id == lastSegment.ArrivalAirportId);

                double duracionRegresoMin =
                    FlightMathHelper.CalcularDuracionVuelo(destinoFinal, baseAirport, aircraft);

                var arrivalUtcFinal = TimeHelper.ToUtc(lastSegment.ArrivalTime, destinoFinal.TimeZone);

                if (
                    destinoFinal.Id != baseAirport.Id &&
                    AirportTimeHelper.ShouldOvernight(destinoFinal, arrivalUtcFinal, baseAirport, duracionRegresoMin)
                )
                {
                    // 1️⃣ Hora local de llegada → determinar salida del día siguiente
                    var arrivalLocal = TimeHelper.ToLocalTime(arrivalUtcFinal, destinoFinal.TimeZone);

                    // Apertura según reglas del aeropuerto
                    var opening = destinoFinal.OpeningTime ?? new TimeSpan(6, 0, 0);

                    var salidaLocal = arrivalLocal.Date.AddDays(1).Add(opening);

                    // 2️⃣ Convertir salida local a UTC
                    var salidaUtc = TimeHelper.ToUtc(salidaLocal, destinoFinal.TimeZone);

                    // 3️⃣ Calcular llegada a base
                    var llegadaUtc = salidaUtc.AddMinutes(duracionRegresoMin);

                    // 4️⃣ Redondear
                    salidaUtc = TimeHelper.RedondearAHoraProxima(salidaUtc, 5);
                    llegadaUtc = TimeHelper.RedondearAHoraProxima(llegadaUtc, 5);

                    allFlights.Add(new Flight
                    {
                        CompanyId = dto.CompanyId,
                        AircraftId = aircraft.Id,
                        ReservationId = null,
                        DepartureAirportId = destinoFinal.Id,
                        ArrivalAirportId = baseAirport.Id,
                        DepartureTime = salidaUtc,
                        ArrivalTime = llegadaUtc,
                        DurationMinutes = duracionRegresoMin,
                        IsEmptyLeg = true,
                        IsInternational = destinoFinal.Country != baseAirport.Country,
                        Status = FlightStatus.PreFlight,
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
                            Status = FlightStatus.PreFlight
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
                            Status = FlightStatus.PreFlight
                        });
                    }
                }


                // ======================================================
                // 9️⃣ GUARDAR Y BLOQUEAR HORARIOS (agrupado con 30 min)
                // ======================================================
                await _db.Flights.AddRangeAsync(allFlights);
                await _db.SaveChangesAsync();

                // ======================================================
                // 🔥 NUEVA LÓGICA CORRECTA DE AGRUPACIÓN
                // ======================================================
                var orderedFlights = allFlights.OrderBy(f => f.DepartureTime).ToList();

                var grupos = new List<(DateTime inicio, DateTime fin)>();
                DateTime grupoInicio = orderedFlights[0].DepartureTime;
                DateTime grupoFin = orderedFlights[0].ArrivalTime;

                for (int i = 1; i < orderedFlights.Count; i++)
                {
                    var prev = orderedFlights[i - 1];
                    var curr = orderedFlights[i];

                    var gap = curr.DepartureTime - prev.ArrivalTime;

                    // 🔥 Regla real: si gap > 6h → nuevo bloque SIEMPRE
                    if (gap.TotalHours > 6)
                    {
                        grupos.Add((grupoInicio, grupoFin));
                        grupoInicio = curr.DepartureTime;
                        grupoFin = curr.ArrivalTime;
                    }
                    else
                    {
                        if (curr.ArrivalTime > grupoFin)
                            grupoFin = curr.ArrivalTime;
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
                // 🔔 11️⃣ NOTIFICAR EMPTY LEGS (fuera de la transacción)
                // ======================================================
                var emptyLegsToNotify = allFlights
                    .Where(f => f.IsEmptyLeg)
                    .ToList();

                if (emptyLegsToNotify.Any())
                {
                    await _emptyLegNotificationService.NotifyUsersForEmptyLegsAsync(emptyLegsToNotify);                }


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

                //Console.WriteLine($"{dto.Segments[0].DepartureTime:o} - Kind: {dto.Segments[0].DepartureTime.Kind}");


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
            if (dto.AircraftIds == null || !dto.AircraftIds.Any())
                throw new Exception("Debe seleccionar un modelo válido con aeronaves disponibles.");

            // ============================================
            // 1️⃣ ESCOGER UNA AERONAVE REAL DISPONIBLE
            // ============================================
            Aircraft? selectedAircraft = null;

            foreach (int id in dto.AircraftIds)
            {
                var aircraft = await _db.Aircrafts
                    .Include(a => a.BaseAirport)
                    .FirstOrDefaultAsync(a => a.Id == id && a.IsActive);

                if (aircraft == null)
                    continue;

                bool allSegmentsOk = true;

                foreach (var seg in dto.Segments)
                {
                    var dep = await _db.Airports.FindAsync(seg.DepartureAirportId);
                    var arr = await _db.Airports.FindAsync(seg.ArrivalAirportId);

                    var startUtc = TimeHelper.ToUtc(seg.DepartureTime, dep.TimeZone);
                    var endUtc = TimeHelper.ToUtc(seg.ArrivalTime, dep.TimeZone);

                    if (!await IsAircraftAvailableInRangeAsync(aircraft.Id, startUtc, endUtc))
                    {
                        allSegmentsOk = false;
                        break;
                    }
                }

                if (allSegmentsOk)
                {
                    selectedAircraft = aircraft;
                    break;
                }
            }

            if (selectedAircraft == null)
                throw new Exception("No hay ninguna aeronave disponible para este modelo.");

            // ============================================
            // 2️⃣ CALCULAR DURACIÓN TOTAL DEL VIAJE
            // ============================================
            double totalMinutes = 0;
            bool isInternational = false;

            var baseAirport = selectedAircraft.BaseAirport;

            // --------------------------------------------
            // 2.1 PRIMERA REPOSICIÓN: Base → Departure inicial
            // --------------------------------------------
            var firstSeg = dto.Segments.First();
            if (baseAirport.Id != firstSeg.DepartureAirportId)
            {
                var depBase = baseAirport;
                var depClient = await _db.Airports.FindAsync(firstSeg.DepartureAirportId);

                totalMinutes += FlightMathHelper.CalcularDuracionVuelo(depBase, depClient, selectedAircraft);

                if (!string.Equals(depBase.Country, depClient.Country, StringComparison.OrdinalIgnoreCase))
                    isInternational = true;
            }

            // --------------------------------------------
            // 2.2 VUELOS REALES DEL CLIENTE
            // --------------------------------------------
            foreach (var seg in dto.Segments)
            {
                var dep = await _db.Airports.FindAsync(seg.DepartureAirportId);
                var arr = await _db.Airports.FindAsync(seg.ArrivalAirportId);

                if (!string.Equals(dep.Country, arr.Country, StringComparison.OrdinalIgnoreCase))
                    isInternational = true;

                totalMinutes += FlightMathHelper.CalcularDuracionVuelo(dep, arr, selectedAircraft);
            }

            if (totalMinutes < 10)
                totalMinutes = 10;

            // ============================================
            // 3️⃣ COSTO BASE
            // ============================================
            double baseCost = totalMinutes * selectedAircraft.MinuteCost;

            // ============================================
            // 4️⃣ IMPUESTOS (si es internacional)
            // ============================================
            double taxes = 0;

            if (isInternational)
            {
                double airportTax = dto.TotalPassengers * 30;
                double handling = dto.TotalPassengers * 100;
                taxes = airportTax + handling;
            }

            // ============================================
            // 5️⃣ COSTO DE ESPERA / PERNOCTA (cliente)
            // ============================================
            double waitCost = 0;
            double overnightCost = 0;

            if (dto.Segments.Count > 1)
            {
                for (int i = 0; i < dto.Segments.Count - 1; i++)
                {
                    var current = dto.Segments[i];
                    var next = dto.Segments[i + 1];

                    double hours = (next.DepartureTime - current.ArrivalTime).TotalHours;

                    if (hours >= 6 && hours < 24)
                        waitCost += isInternational ? 200 : 50;

                    if (hours >= 24 || current.ArrivalTime.Date != next.DepartureTime.Date)
                        overnightCost += isInternational ? 500 : 300;
                }
            }

            // ============================================
            // 6️⃣ TOTAL
            // ============================================
            double total = Math.Round(baseCost + taxes + waitCost + overnightCost, 2);

            // ============================================
            // 7️⃣ RESPUESTA
            // ============================================
            return new ReservationEstimateResponseDto
            {
                AircraftId = selectedAircraft.Id,
                IsInternational = isInternational,
                TotalMinutes = Math.Round(totalMinutes, 2),
                MinuteCost = selectedAircraft.MinuteCost,
                BaseCost = Math.Round(baseCost, 2),
                Taxes = Math.Round(taxes, 2),
                WaitCost = Math.Round(waitCost, 2),
                OvernightCost = Math.Round(overnightCost, 2),
                TotalPrice = total
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
            //foreach (var flight in reservation.Flights.Where(f => !f.IsEmptyLeg))
            //    flight.Status = FlightStatus.Cancelado;

            // Liberar ocupación
            var ocupaciones = await _db.AircraftAvailabilities
                .Where(o => o.ReservationId == reservationId && o.Status == "Confirmado")
                .ToListAsync();

            foreach (var o in ocupaciones)
                o.Status = "Cancelado";

            await _db.SaveChangesAsync();
            return true;
        }

        public async Task<ReservationResponseDto> ReserveEmptyLegAsync(EmptyLegReservationCreateDto dto)
        {
            using var transaction = await _db.Database.BeginTransactionAsync();

            // 1️⃣ Validar empty leg
            var flight = await _db.Flights
                .Include(f => f.Aircraft)
                .Include(f => f.Company)
                .Include(f => f.DepartureAirport)
                .Include(f => f.ArrivalAirport)
                .FirstOrDefaultAsync(f => f.Id == dto.EmptyLegFlightId && f.IsEmptyLeg);

            if (flight == null)
                throw new Exception("Empty leg no existe o ya fue reservada.");

            // 2️⃣ Crear reserva usando precio del front
            var reservation = new Reservation
            {
                UserId = dto.UserId,
                CompanyId = flight.CompanyId,
                ReservationCode = await GenerateReservationCodeAsync(),
                Status = ReservationStatus.Pendiente,
                LapChild = dto.LapChild,
                AssistanceAnimal = dto.AssistanceAnimal,
                Notes = dto.Notes,
                CreatedAt = DateTime.UtcNow,
                IsRoundTrip = false,
                PorcentPrice = 0,
                TotalPrice = dto.Price // <- viene desde el front
            };

            _db.Reservations.Add(reservation);
            await _db.SaveChangesAsync();

            // 3️⃣ Crear pasajeros
            foreach (var pax in dto.Passengers)
            {
                var passenger = _mapper.Map<PassengerDetail>(pax);
                passenger.ReservationId = reservation.Id;
                _db.PassengerDetails.Add(passenger);
            }

            await _db.SaveChangesAsync();

            // 4️⃣ Asociar el vuelo vacío → vuelo del cliente
            flight.ReservationId = reservation.Id;
            flight.IsEmptyLeg = false;
            flight.Status = FlightStatus.PreFlight;
            flight.UpdatedAt = DateTime.UtcNow;

            await _db.SaveChangesAsync();

            await transaction.CommitAsync();

            // 5️⃣ Cargar resultado completo
            var result = await _db.Reservations
                .Include(r => r.Company)
                .Include(r => r.Passengers)
                .Include(r => r.Flights).ThenInclude(f => f.DepartureAirport)
                .Include(r => r.Flights).ThenInclude(f => f.ArrivalAirport)
                .Include(r => r.Flights).ThenInclude(f => f.Aircraft)
                .FirstAsync(r => r.Id == reservation.Id);

            return _mapper.Map<ReservationResponseDto>(result);
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
        // 🧭 TRIPS – UPCOMING
        // ======================================================
        public async Task<IEnumerable<ReservationTripItemDto>> GetUpcomingTripsAsync(int userId)
        {
            var now = DateTime.UtcNow;

            var reservations = await _db.Reservations
                .Include(r => r.Flights)
                    .ThenInclude(f => f.DepartureAirport)
                .Include(r => r.Flights)
                    .ThenInclude(f => f.ArrivalAirport)
                .Where(r =>
                    r.UserId == userId &&
                    r.Flights.Any(f =>
                        !f.IsEmptyLeg &&
                        f.Status != FlightStatus.Completed &&
                        f.DepartureTime > now
                    ))
                .OrderBy(r => r.Flights.Min(f => f.DepartureTime))
                .ToListAsync();

            return _mapper.Map<IEnumerable<ReservationTripItemDto>>(reservations);
        }

        // ======================================================
        // 🧭 TRIPS – PAST
        // ======================================================
        public async Task<IEnumerable<ReservationTripItemDto>> GetPastTripsAsync(int userId)
        {
            var now = DateTime.UtcNow;

            var reservations = await _db.Reservations
                .Include(r => r.Flights)
                    .ThenInclude(f => f.DepartureAirport)
                .Include(r => r.Flights)
                    .ThenInclude(f => f.ArrivalAirport)
                .Where(r =>
                    r.UserId == userId &&
                    r.Flights.All(f =>
                        f.IsEmptyLeg ||
                        f.Status == FlightStatus.Completed ||
                        f.ArrivalTime < now
                    ))
                .OrderByDescending(r => r.Flights.Max(f => f.ArrivalTime))
                .ToListAsync();

            return _mapper.Map<IEnumerable<ReservationTripItemDto>>(reservations);
        }


        private async Task<bool> IsAircraftAvailableInRangeAsync(
            int aircraftId,
            DateTime requestedStart,
            DateTime requestedEnd)
        {
            const int turnaroundMinutes = 30;

            var occupancies = await _db.AircraftAvailabilities
                .Where(av => av.AircraftId == aircraftId && av.Status == "Confirmado")
                .OrderBy(av => av.StartTime)
                .ToListAsync();

            // No reservations → free
            if (!occupancies.Any())
                return true;

            // 1️⃣ Direct conflict with any flight
            bool conflict = occupancies.Any(av =>
                requestedStart < av.EndTime.AddMinutes(turnaroundMinutes) &&
                requestedEnd > av.StartTime.AddMinutes(-turnaroundMinutes)
            );

            if (!conflict)
                return true;

            // 2️⃣ Gap BEFORE the first flight
            var first = occupancies.First();
            if (requestedEnd <= first.StartTime.AddMinutes(-turnaroundMinutes))
                return true;

            // 3️⃣ Gaps BETWEEN flights
            for (int i = 0; i < occupancies.Count - 1; i++)
            {
                var current = occupancies[i];
                var next = occupancies[i + 1];

                var gapStart = current.EndTime.AddMinutes(turnaroundMinutes);
                var gapEnd = next.StartTime.AddMinutes(-turnaroundMinutes);

                if (requestedStart >= gapStart && requestedEnd <= gapEnd)
                    return true;
            }

            // 4️⃣ Gap AFTER the last flight
            var last = occupancies.Last();
            if (requestedStart >= last.EndTime.AddMinutes(turnaroundMinutes))
                return true;

            return false;
        }

        /// <summary>
        /// Fuerza que la hora de salida sea al menos 30 min después de la llegada anterior.
        /// Aplica también redondeo a múltiplos de 5 minutos.
        /// </summary>
        private DateTime ForzarMinimoConTurnaround(DateTime arrivalUtc, DateTime proposedUtc)
        {
            var minimo = arrivalUtc.AddMinutes(30);
            if (proposedUtc < minimo)
                proposedUtc = minimo;

            return TimeHelper.RedondearAHoraProxima(proposedUtc, 5);
        }


    }
}
