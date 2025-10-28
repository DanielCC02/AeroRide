namespace AeroRide.API.Models.Domain
{
    /// <summary>
    /// Entidad que representa una empresa o aerolínea registrada en el sistema AeroRide.
    /// 
    /// Cada empresa puede tener aeronaves, vuelos, reservas y personal (usuarios asociados).
    /// </summary>
    public class Company
    {
        /// <summary>
        /// Identificador único de la empresa.
        /// </summary>
        public int Id { get; set; }

        /// <summary>
        /// Nombre comercial de la empresa (por ejemplo, "AeroCaribe", "SkyJet").
        /// </summary>
        public string Name { get; set; } = null!;

        /// <summary>
        /// Correo de contacto principal de la empresa.
        /// </summary>
        public string? Email { get; set; }

        /// <summary>
        /// Teléfono de contacto principal.
        /// </summary>
        public string? PhoneNumber { get; set; }

        /// <summary>
        /// Dirección física o base principal de operaciones.
        /// </summary>
        public string? Address { get; set; }

        /// <summary>
        /// Porcentaje de descuento aplicado a vuelos tipo "Empty Leg".
        /// Ejemplo: 0.5 = 50%.
        /// </summary>
        public double EmptyLegDiscount { get; set; } = 0.5;

        /// <summary>
        /// Indica si la empresa se encuentra activa en el sistema.
        /// </summary>
        public bool IsActive { get; set; } = true;

        /// <summary>
        /// Fecha de registro o incorporación de la empresa al sistema.
        /// </summary>
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

        // ======================================================
        // 🔗 RELACIONES DE NAVEGACIÓN
        // ======================================================

        /// <summary>
        /// Colección de usuarios asociados a la empresa (pilotos, administradores, etc.).
        /// </summary>
        public ICollection<User> Users { get; set; } = new List<User>();

        /// <summary>
        /// Aeronaves registradas bajo esta empresa.
        /// </summary>
        public ICollection<Aircraft> Aircrafts { get; set; } = new List<Aircraft>();

        /// <summary>
        /// Vuelos operados por la empresa.
        /// </summary>
        public ICollection<Flight> Flights { get; set; } = new List<Flight>();

        /// <summary>
        /// Reservas realizadas bajo esta empresa.
        /// </summary>
        public ICollection<Reservation> Reservations { get; set; } = new List<Reservation>();

        /// <summary>
        /// Cargos y costos operativos asociados a los vuelos de esta empresa.
        /// </summary>
        public ICollection<FlightCharge> FlightCharges { get; set; } = new List<FlightCharge>();
    }
}
