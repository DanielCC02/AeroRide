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
        public static bool ShouldOvernight(Airport destino, DateTime arrivalUtc)
        {
            if (destino.OpeningTime == null || destino.ClosingTime == null)
                return false;

            var arrivalLocal = TimeHelper.ToLocalTime(arrivalUtc, destino.TimeZone);
            var cierre = destino.ClosingTime.Value;

            // Si faltan 3 horas o menos para el cierre → pernocta
            return (cierre - arrivalLocal.TimeOfDay) <= TimeSpan.FromHours(3);
        }
    }
}
