using System.ComponentModel.DataAnnotations;

namespace AeroRide.API.Models.DTOs.FlightLogs
{
    /// <summary>
    /// DTO para crear una bitácora de vuelo.
    /// 
    /// Nota: el PDF (IFormFile) se recibirá en el action del controlador,
    /// este DTO modela solo los datos lógicos.
    /// </summary>
    public class FlightLogCreateDto
    {
        public int FlightId { get; set; }
        public int PilotUserId { get; set; }

        // 👇 OBLIGATORIO PARA SUBIR ARCHIVOS
        public IFormFile PdfFile { get; set; } = null!;
    }

}
