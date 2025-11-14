using AeroRide.API.Models.Domain;

namespace AeroRide.API.Helpers
{
    public static class FlightMathHelper
    {
        public static double CalcularDistanciaKm(decimal lat1, decimal lon1, decimal lat2, decimal lon2)
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

        public static double CalcularDuracionVuelo(Airport origen, Airport destino, Aircraft avion)
        {
            double distanciaKm = CalcularDistanciaKm(
                origen.Latitude, origen.Longitude,
                destino.Latitude, destino.Longitude
            );

            double velocidadKmH = avion.CruisingSpeed > 0 ? avion.CruisingSpeed : 250;
            double horas = distanciaKm / velocidadKmH;
            return horas * 60 + 10; // 10 min extra
        }
    }
}
