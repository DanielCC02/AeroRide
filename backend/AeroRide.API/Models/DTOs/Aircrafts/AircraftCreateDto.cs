using System.ComponentModel.DataAnnotations;
using AeroRide.API.Models.Enums;

namespace AeroRide.API.Models.DTOs.Aircrafts
{
    /// <summary>
    /// DTO utilizado para registrar una nueva aeronave en el sistema AeroRide.
    /// Contiene la información técnica, capacidad y ubicación base.
    /// </summary>
    public class AircraftCreateDto
    {
        // ======================================================
        // 🔑 IDENTIFICACIÓN
        // ======================================================
        [Required(ErrorMessage = "El campo 'Patent' es obligatorio.")]
        [StringLength(20, ErrorMessage = "La matrícula no puede exceder los 20 caracteres.")]
        public string Patent { get; set; } = null!;

        [Required(ErrorMessage = "El campo 'Model' es obligatorio.")]
        [StringLength(100)]
        public string Model { get; set; } = null!;

        // ======================================================
        // 💰 CARACTERÍSTICAS Y CAPACIDAD
        // ======================================================
        [Range(0, double.MaxValue, ErrorMessage = "El precio debe ser un valor positivo.")]
        public double MinuteCost { get; set; }

        [Range(1, int.MaxValue, ErrorMessage = "Debe tener al menos un asiento.")]
        public int Seats { get; set; }

        [Range(1, int.MaxValue, ErrorMessage = "El peso base debe ser mayor a 0.")]
        public int EmptyWeight { get; set; }

        [Range(1, int.MaxValue, ErrorMessage = "El peso máximo debe ser mayor a 0.")]
        public int MaxWeight { get; set; }


        [Range(100, 1000, ErrorMessage = "La velocidad de crucero debe estar entre 100 y 1000 km/h.")]
        public double CruisingSpeed { get; set; }

        /// <summary>
        /// Indica si la aeronave puede operar vuelos internacionales.
        /// </summary>
        public bool CanFlyInternational { get; set; } = false;

        /// <summary>
        /// Estado técnico inicial (Disponible, EnMantenimiento o FueraDeServicio).
        /// </summary>
        [EnumDataType(typeof(AircraftState))]
        public AircraftState State { get; set; } = AircraftState.Disponible;

        [Required(ErrorMessage = "Debe proporcionar una imagen.")]
        public string Image { get; set; } = null!;

        // ======================================================
        // 🌎 UBICACIÓN Y RELACIONES
        // ======================================================
        [Required(ErrorMessage = "Debe especificar el aeropuerto base.")]
        public int BaseAirportId { get; set; }

        /// <summary>
        /// Aeropuerto donde se encuentra actualmente (opcional).
        /// Si no se indica, se asume igual al aeropuerto base.
        /// </summary>
        public int? CurrentAirportId { get; set; }

        [Required(ErrorMessage = "Debe especificar la compañía propietaria.")]
        public int CompanyId { get; set; }
    }
}
