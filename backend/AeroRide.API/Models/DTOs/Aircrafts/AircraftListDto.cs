namespace AeroRide.API.Models.DTOs.Aircrafts
{
    /// <summary>
    /// DTO liviano usado para listados de aeronaves.
    /// Muestra únicamente los datos más relevantes.
    /// </summary>
    public class AircraftListDto
    {
        /// <summary>
        /// Identificador único de la aeronave.
        /// </summary>
        public int Id { get; set; }

        /// <summary>
        /// Matrícula o patente.
        /// </summary>
        public string Patent { get; set; } = null!;

        /// <summary>
        /// Modelo o tipo.
        /// </summary>
        public string Model { get; set; } = null!;

        /// <summary>
        /// Estado operativo actual.
        /// </summary>
        public string State { get; set; } = null!;
    }
}
