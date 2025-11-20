using System;

namespace AeroRide.API.Models.DTOs.FlightLogs
{
    /// <summary>
    /// DTO de lectura de bitácoras de vuelo.
    /// Devuelve información básica + URL del PDF.
    /// </summary>
    public class FlightLogResponseDto
    {
        public int Id { get; set; }

        public int FlightId { get; set; }

        public int PilotUserId { get; set; }

        public string PilotName { get; set; } = null!;

        public string PilotLastName { get; set; } = null!;

        public string PdfUrl { get; set; } = null!;

        public DateTime CreatedAt { get; set; }
    }
}
