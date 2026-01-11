using System;

namespace AeroRide.API.Models.DTOs.FlightLogs
{
    /// <summary>
    /// Data Transfer Object used to read flight log entries.
    /// It returns basic information along with the PDF file URL.
    /// </summary>
    public class FlightLogResponseDto
    {
        /// <summary>
        /// Unique identifier of the flight log.
        /// </summary>
        public int Id { get; set; }

        /// <summary>
        /// Identifier of the associated flight.
        /// </summary>
        public int FlightId { get; set; }

        /// <summary>
        /// Identifier of the pilot who created the flight log.
        /// </summary>
        public int PilotUserId { get; set; }

        /// <summary>
        /// First name of the pilot who submitted the flight log.
        /// </summary>
        public string PilotName { get; set; } = null!;

        /// <summary>
        /// Last name of the pilot who submitted the flight log.
        /// </summary>
        public string PilotLastName { get; set; } = null!;

        /// <summary>
        /// URL of the PDF document stored in Azure Blob Storage.
        /// </summary>
        public string PdfUrl { get; set; } = null!;

        /// <summary>
        /// Date and time when the flight log was created (UTC).
        /// </summary>
        public DateTime CreatedAt { get; set; }
    }
}
