namespace AeroRide.API.Helpers
{
    public static class TimeHelper
    {
        public static DateTime ToLocalTime(DateTime utcTime, string timeZoneId)
        {
            var tz = TimeZoneInfo.FindSystemTimeZoneById(timeZoneId);
            return TimeZoneInfo.ConvertTimeFromUtc(utcTime, tz);
        }

        public static DateTime ToUtc(DateTime localTime, string timeZoneId)
        {
            // 🔹 Asegurarse de no pasar valores Local a ConvertTimeToUtc directamente
            DateTime safeLocal;

            if (localTime.Kind == DateTimeKind.Utc)
                return localTime; // ya está en UTC

            if (localTime.Kind == DateTimeKind.Local)
            {
                // Convertir a "Unspecified" antes de usar cualquier zona
                safeLocal = DateTime.SpecifyKind(localTime, DateTimeKind.Unspecified);
            }
            else
            {
                safeLocal = localTime;
            }

            var tz = TimeZoneInfo.FindSystemTimeZoneById(timeZoneId);

            // 🔹 Si el timezone destino es el mismo del sistema local → usar directamente ToUniversalTime()
            if (tz.Id == TimeZoneInfo.Local.Id)
                return safeLocal.ToUniversalTime();

            // 🔹 Convertir desde la zona horaria especificada hacia UTC
            return TimeZoneInfo.ConvertTimeToUtc(safeLocal, tz);
        }



        // ======================================================
        // 🧭 REDONDEAR A MÚLTIPLOS DE X MINUTOS (ajustado)
        // ======================================================
        /// <summary>
        /// Redondea una hora hacia el múltiplo más cercano de "minutos",
        /// sin pasarse más de 2 minutos hacia adelante.
        /// Ej: 09:21 → 09:25, 09:24 → 09:25, 09:26 → 09:25.
        /// </summary>
        public static DateTime RedondearAHoraProxima(DateTime time, int minutos)
        {
            int resto = time.Minute % minutos;
            int diferencia = minutos - resto;

            if (resto == 0)
                return new DateTime(time.Year, time.Month, time.Day, time.Hour, time.Minute, 0);

            // Si está a menos de 2 min del múltiplo, no se redondea más
            if (diferencia <= 2)
                return new DateTime(time.Year, time.Month, time.Day, time.Hour, time.Minute + diferencia, 0);

            // Si se pasa de 60 min, avanza una hora redondeada
            int nuevosMinutos = time.Minute + diferencia;
            if (nuevosMinutos >= 60)
                return new DateTime(time.Year, time.Month, time.Day, time.Hour + 1, 0, 0);

            return new DateTime(time.Year, time.Month, time.Day, time.Hour, nuevosMinutos, 0);
        }
    }
}
