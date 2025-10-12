namespace AeroRide.API.Models.DTOs.Aircrafts
{
    /// <summary>
    /// DTO utilizado para modificar la información de una aeronave existente.
    /// Permite actualizar uno o varios campos de forma opcional.
    /// </summary>
    public class AircraftUpdateDto
    {
        /// <summary>Nuevo modelo o tipo de aeronave (opcional).</summary>
        public string? Model { get; set; }

        /// <summary>Nuevo precio o costo de operación estimado (opcional).</summary>
        public double? Price { get; set; }

        /// <summary>Nuevo número máximo de asientos (opcional).</summary>
        public int? Seats { get; set; }

        /// <summary>Nuevo peso máximo permitido (opcional).</summary>
        public int? MaxWeight { get; set; }

        /// <summary>Nuevo estado operativo de la aeronave (opcional).</summary>
        public string? State { get; set; }

        /// <summary>
        /// URL de la nueva imagen representativa de la aeronave (opcional).
        /// Si se cambia, la imagen anterior será eliminada del contenedor.
        /// </summary>
        public string? Image { get; set; }

        /// <summary>
        /// Indica si la aeronave debe estar activa o desactivada (opcional).
        /// Si se envía <c>true</c>, se reactiva; si se envía <c>false</c>, se desactiva.
        /// </summary>
        public bool? IsActive { get; set; }

    }
}
