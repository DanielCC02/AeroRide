namespace AeroRide.API.Models.DTOs.Aircrafts
{
    /// <summary>
    /// DTO utilizado para actualizar únicamente el estado operativo de una aeronave.
    /// </summary>
    public class UpdateAircraftStateDto
    {
        /// <summary>
        /// Nuevo estado operativo de la aeronave (por ejemplo: Disponible, En vuelo, En mantenimiento).
        /// </summary>
        public string State { get; set; } = null!;
    }
}
