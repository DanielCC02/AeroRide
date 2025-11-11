using System;

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
            var tz = TimeZoneInfo.FindSystemTimeZoneById(timeZoneId);
            return TimeZoneInfo.ConvertTimeToUtc(localTime, tz);
        }
    }
}
