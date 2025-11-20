using System;

namespace AeroRide.API.Models.Domain
{
    /// <summary>
    /// Registro de bitácora de vuelo generada por un piloto.
    /// Solamente guarda metadatos y la URL del PDF en Azure.
    /// </summary>
    public class FlightLog
    {
        public int Id { get; set; }

        // 🔗 Relación con el vuelo
        public int FlightId { get; set; }
        public Flight Flight { get; set; } = null!;

        // 🔗 Piloto que llenó la bitácora
        public int PilotUserId { get; set; }
        public User PilotUser { get; set; } = null!;

        // 📄 URL del PDF almacenado en Azure Blob Storage
        public string PdfUrl { get; set; } = null!;

        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    }
}
