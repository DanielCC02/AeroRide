namespace AeroRide.API.Models.DTOs.Aircrafts
{
    /// <summary>
    /// DTO utilizado para representar una categoría agrupada de aeronaves disponibles.
    /// Se usa para mostrar al cliente modelos agrupados por compañía.
    /// </summary>
    public class AircraftCategoryDto
    {
        /// <summary>
        /// Modelo o tipo de aeronave (por ejemplo: Cessna 206).
        /// </summary>
        public string Model { get; set; } = null!;

        /// <summary>
        /// Cantidad máxima de pasajeros que admite este modelo.
        /// </summary>
        public int Seats { get; set; }

        /// <summary>
        /// Nombre de la compañía propietaria de las aeronaves de este modelo.
        /// </summary>
        public string CompanyName { get; set; } = null!;

        /// <summary>
        /// Estado actual (por ejemplo: Disponible, En mantenimiento, etc.)
        /// </summary>
        public string State { get; set; } = null!;

    }
}
