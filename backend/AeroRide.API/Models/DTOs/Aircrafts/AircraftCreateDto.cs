using System.ComponentModel.DataAnnotations;

namespace AeroRide.API.Models.DTOs.Aircrafts
{
    /// <summary>
    /// DTO utilizado para la creación de una nueva aeronave en el sistema.
    /// Contiene los campos requeridos para el registro inicial.
    /// </summary>
    public class AircraftCreateDto
    {
        /// <summary>
        /// Matrícula o patente única de la aeronave.
        /// </summary>
        [Required(ErrorMessage = "El campo 'Patent' es obligatorio.")]
        public string Patent { get; set; } = null!;

        /// <summary>
        /// Modelo o tipo de aeronave (por ejemplo: Cessna 208B).
        /// </summary>
        [Required(ErrorMessage = "El campo 'Model' es obligatorio.")]
        public string Model { get; set; } = null!;

        /// <summary>
        /// Precio o costo estimado de operación.
        /// </summary>
        [Range(0, double.MaxValue, ErrorMessage = "El precio debe ser un valor positivo.")]
        public double Price { get; set; }

        /// <summary>
        /// Número máximo de pasajeros.
        /// </summary>
        [Range(1, int.MaxValue, ErrorMessage = "La cantidad de asientos debe ser al menos 1.")]
        public int Seats { get; set; }

        /// <summary>
        /// Peso máximo permitido (en kilogramos).
        /// </summary>
        [Range(1, int.MaxValue, ErrorMessage = "El peso máximo debe ser mayor a cero.")]
        public int MaxWeight { get; set; }

        /// <summary>
        /// Estado actual operativo de la aeronave.
        /// Ejemplo: Disponible, En mantenimiento.
        /// </summary>
        [Required(ErrorMessage = "El estado es obligatorio.")]
        public string State { get; set; } = null!;

        /// <summary>
        /// Ruta o URL de la imagen representativa.
        /// </summary>
        [Required(ErrorMessage = "Debe proporcionar una imagen.")]
        public string Image { get; set; } = null!;
    }
}
