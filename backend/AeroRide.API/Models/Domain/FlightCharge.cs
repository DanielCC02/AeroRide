namespace AeroRide.API.Models.Domain
{
    /// <summary>
    /// Entidad que representa el resumen de cargos e impuestos
    /// asociados a un vuelo específico.
    /// 
    /// Contiene únicamente los valores esenciales para registrar
    /// el costo total operativo del vuelo.
    /// </summary>
    public class FlightCharge
    {
        /// <summary>
        /// Identificador único del registro de cargos asociados a un vuelo.
        /// </summary>
        public int Id { get; set; }

        /// <summary>
        /// Costo base del vuelo (precio de la aeronave × duración del vuelo).
        /// </summary>
        public double BaseCost { get; set; }

        /// <summary>
        /// Monto total de impuestos y tasas aplicados al vuelo.
        /// </summary>
        public double TaxesAndFees { get; set; }

        /// <summary>
        /// Porcentaje de descuento aplicado (por ejemplo: 0.5 = 50%).
        /// </summary>
        public double DiscountApplied { get; set; }

        /// <summary>
        /// Costo total final del vuelo, después de aplicar impuestos y descuentos.
        /// </summary>
        public double TotalCharge { get; set; }

        /// <summary>
        /// Fecha y hora en que se calculó el cargo total del vuelo.
        /// </summary>
        public DateTime CalculatedAt { get; set; } = DateTime.UtcNow;

        // ======================================================
        // 🔗 RELACIONES DE NAVEGACIÓN
        // ======================================================

        /// <summary>
        /// Identificador del vuelo al que pertenece este cálculo.
        /// </summary>
        public int FlightId { get; set; }

        /// <summary>
        /// Vuelo asociado a los cargos registrados.
        /// </summary>
        public Flight Flight { get; set; } = null!;

        /// <summary>
        /// Identificador de la empresa operadora del vuelo.
        /// </summary>
        public int CompanyId { get; set; }

        /// <summary>
        /// Empresa o aerolínea responsable de la operación del vuelo.
        /// </summary>
        public Company Company { get; set; } = null!;
    }
}
