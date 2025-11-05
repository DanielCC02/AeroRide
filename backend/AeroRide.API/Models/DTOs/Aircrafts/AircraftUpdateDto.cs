namespace AeroRide.API.Models.DTOs.Aircrafts
{
    /// <summary>
    /// DTO utilizado para actualizar parcialmente una aeronave existente.
    /// Permite modificar información técnica, capacidad o ubicación.
    /// </summary>
    public class AircraftUpdateDto
    {
        public string? Patent { get; set; }
        public string? Model { get; set; }
        public double? MinuteCost { get; set; }
        public int? Seats { get; set; }
        public int? MaxWeight { get; set; }
        public double? CruisingSpeed { get; set; }
        public bool? CanFlyInternational { get; set; }
        public int? EmptyWeight { get; set; }


        /// <summary>
        /// Nuevo estado técnico de la aeronave (Disponible, EnMantenimiento o FueraDeServicio).
        /// </summary>
        public string? State { get; set; }

        public string? Image { get; set; }
        public bool? IsActive { get; set; }

        /// <summary>
        /// Nueva base operativa (si se reubica la aeronave).
        /// </summary>
        public int? BaseAirportId { get; set; }

        /// <summary>
        /// Aeropuerto actual (si la aeronave se encuentra fuera de su base).
        /// </summary>
        public int? CurrentAirportId { get; set; }
    }
}
