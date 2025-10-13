namespace AeroRide.API.Models.DTOs.Aircrafts
{
    /// <summary>
    /// DTO utilizado para devolver información completa de una aeronave
    /// hacia el cliente en respuestas de la API.
    /// </summary>
    public class AircraftResponseDto
    {
        /// <summary>
        /// Identificador único de la aeronave.
        /// </summary>
        public int Id { get; set; }

        /// <summary>
        /// Matrícula o patente de la aeronave.
        /// </summary>
        public string Patent { get; set; } = null!;

        /// <summary>
        /// Modelo o tipo de aeronave.
        /// </summary>
        public string Model { get; set; } = null!;

        /// <summary>
        /// Precio o costo de operación estimado.
        /// </summary>
        public double Price { get; set; }

        /// <summary>
        /// Número máximo de pasajeros.
        /// </summary>
        public int Seats { get; set; }

        /// <summary>
        /// Peso máximo permitido.
        /// </summary>
        public int MaxWeight { get; set; }

        /// <summary>
        /// Estado operativo actual.
        /// </summary>
        public string State { get; set; } = null!;

        /// <summary>
        /// URL o ruta de la imagen asociada.
        /// </summary>
        public string Image { get; set; } = null!;

        public bool IsActive { get; set; }
    }
}
