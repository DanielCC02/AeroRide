using System.ComponentModel.DataAnnotations;
using AeroRide.API.Models.Enums;

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

        [Range(1, int.MaxValue, ErrorMessage = "Debe tener al menos un asiento.")]
        public int? Seats { get; set; }

        [Range(1, int.MaxValue, ErrorMessage = "El peso base debe ser mayor a 0.")]
        public int? EmptyWeight { get; set; }

        [Range(1, int.MaxValue, ErrorMessage = "El peso máximo debe ser mayor a 0.")]
        public int? MaxWeight { get; set; }

        [Range(100, 1000, ErrorMessage = "La velocidad de crucero debe estar entre 100 y 1000 km/h.")]
        public double? CruisingSpeed { get; set; }

        public bool? CanFlyInternational { get; set; }

        /// <summary>
        /// Nuevo estado técnico de la aeronave (Disponible, EnMantenimiento o FueraDeServicio).
        /// </summary>
        public AircraftState? State { get; set; }

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
