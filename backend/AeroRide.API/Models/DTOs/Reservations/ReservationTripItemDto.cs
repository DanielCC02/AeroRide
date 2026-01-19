namespace AeroRide.API.Models.DTOs.Reservations
{
    public class ReservationTripItemDto
    {
        public int ReservationId { get; set; }
        public string ReservationCode { get; set; } = null!;

        public DateTime DepartureTime { get; set; }

        // Origen
        public string FromCity { get; set; } = null!;
        public string FromCode { get; set; } = null!;

        // Destino
        public string ToCity { get; set; } = null!;
        public string ToCode { get; set; } = null!;

        // 📸 Imagen del aeropuerto de llegada
        public string ImageUrl { get; set; } = null!;

        public bool IsUpcoming { get; set; }
    }
}
