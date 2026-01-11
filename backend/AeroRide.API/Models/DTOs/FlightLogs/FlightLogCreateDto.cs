using System.ComponentModel.DataAnnotations;

namespace AeroRide.API.Models.DTOs.FlightLogs
{
    /// <summary>
    /// Data Transfer Object used to create a flight log entry.
    ///
    /// Note: the PDF file (<see cref="IFormFile"/>) is received directly
    /// in the controller action. This DTO models only the logical data
    /// required for the operation.
    /// </summary>
    public class FlightLogCreateDto
    {
        /// <summary>
        /// Identifier of the flight associated with the flight log.
        /// </summary>
        public int FlightId { get; set; }

        /// <summary>
        /// Identifier of the pilot who submits the flight log.
        /// </summary>
        public int PilotUserId { get; set; }

        /// <summary>
        /// PDF file containing the flight log document.
        /// This field is required for uploading the log.
        /// </summary>
        public IFormFile PdfFile { get; set; } = null!;
    }
}
