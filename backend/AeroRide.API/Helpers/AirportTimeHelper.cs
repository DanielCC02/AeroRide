using AeroRide.API.Models.Domain;
using System;

namespace AeroRide.API.Helpers
{
    /// <summary>
    /// Helper para cálculos relacionados con horarios locales de aeropuertos.
    /// Convierte OpeningTime y ClosingTime (hora local) a UTC según la zona horaria IANA.
    /// </summary>
    public static class AirportTimeHelper
    {
        /// <summary>
        /// Retorna las horas de apertura y cierre en UTC, basadas en la fecha de referencia (UTC).
        /// Si el aeropuerto opera 24/7, devuelve (DateTime.MinValue, DateTime.MaxValue).
        /// </summary>
        public static (DateTime OpeningUtc, DateTime ClosingUtc) GetUtcOperatingHours(Airport airport, DateTime referenceUtc)
        {
            if (airport.OpeningTime == null || airport.ClosingTime == null)
                return (DateTime.MinValue, DateTime.MaxValue); // Opera 24/7

            var tz = TimeZoneInfo.FindSystemTimeZoneById(airport.TimeZone);

            // Determinar la fecha local correspondiente al día del vuelo
            var localDate = TimeHelper.ToLocalTime(referenceUtc, airport.TimeZone).Date;

            var openingLocal = localDate.Add(airport.OpeningTime.Value);
            var closingLocal = localDate.Add(airport.ClosingTime.Value);

            // Convertir ambas horas locales a UTC
            var openingUtc = TimeZoneInfo.ConvertTimeToUtc(openingLocal, tz);
            var closingUtc = TimeZoneInfo.ConvertTimeToUtc(closingLocal, tz);

            return (openingUtc, closingUtc);
        }

        /// <summary>
        /// Verifica si una hora UTC cae dentro del horario operativo del aeropuerto.
        /// Aplica una hora de margen antes del cierre.
        /// </summary>
        public static bool IsWithinOperatingHours(DateTime utcTime, Airport airport)
        {
            var (openUtc, closeUtc) = GetUtcOperatingHours(airport, utcTime);
            return utcTime >= openUtc && utcTime <= closeUtc.AddHours(-1);
        }

        /// <summary>
        /// Determina si se debe generar una pernocta automática con base en el horario de cierre.
        /// </summary>
        public static bool ShouldOvernight(
     Airport destino,
     DateTime arrivalUtc,
     Airport baseAirport,
     double duracionRegresoMin)
        {
            // 1️⃣ Si el aeropuerto destino es 24/7 → NO pernocta
            if (destino.OpeningTime == null || destino.ClosingTime == null)
                return false;

            // Convertir llegada a hora local del aeropuerto destino
            var arrivalLocal = TimeHelper.ToLocalTime(arrivalUtc, destino.TimeZone);

            var opening = destino.OpeningTime.Value;
            var closing = destino.ClosingTime.Value;

            // 2️⃣ Validar aterrizaje permitido (cierre - margen de aterrizaje)
            var maxArrivalLocal =
                closing - TimeSpan.FromMinutes(destino.ArrivalMarginMinutes);

            if (arrivalLocal.TimeOfDay < opening || arrivalLocal.TimeOfDay > maxArrivalLocal)
                return true;

            // 3️⃣ Validar despegue permitido (cierre - margen para despegue)
            var maxDepartureLocal =
                closing - TimeSpan.FromMinutes(destino.DepartureMarginMinutes);

            // tiempo mínimo después de aterrizar para despegar
            var earliestPossibleDeparture =
                arrivalLocal.AddMinutes(destino.ArrivalMarginMinutes);

            if (earliestPossibleDeparture.TimeOfDay > maxDepartureLocal)
                return true;

            // 4️⃣ Validar llegada al aeropuerto base
            // convertir hora de llegada a base (local destino → local base)
            var arrivalBaseLocal = earliestPossibleDeparture.AddMinutes(duracionRegresoMin);

            if (baseAirport.OpeningTime != null && baseAirport.ClosingTime != null)
            {
                var baseKOpening = baseAirport.OpeningTime.Value;
                var baseKClosing = baseAirport.ClosingTime.Value;

                var maxBaseArrival = baseKClosing
                    - TimeSpan.FromMinutes(baseAirport.ArrivalMarginMinutes);

                if (arrivalBaseLocal.TimeOfDay > maxBaseArrival)
                    return true;
            }

            return false;
        }

    }
}
