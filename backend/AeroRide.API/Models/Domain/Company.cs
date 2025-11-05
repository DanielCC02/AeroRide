namespace AeroRide.API.Models.Domain
{
    /// <summary>
    /// Entidad que representa una empresa o aerolínea registrada en el sistema AeroRide.
    /// Cada empresa puede tener aeronaves, vuelos, reservas y personal (usuarios asociados).
    /// Además, define políticas tarifarias específicas para costos de espera, pernocta e impuestos.
    /// </summary>
    public class Company
    {
        public int Id { get; set; }
        public string Name { get; set; } = null!;
        public string? Email { get; set; }
        public string? PhoneNumber { get; set; }
        public string? Address { get; set; }

        /// <summary>Porcentaje de descuento aplicado a vuelos tipo "Empty Leg" (ej. 0.5 = 50%).</summary>
        public double EmptyLegDiscount { get; set; } = 0.5;

        public bool IsActive { get; set; } = true;
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

        // ======================================================
        // 💰 CONFIGURACIÓN TARIFARIA PERSONALIZADA POR EMPRESA
        // ======================================================

        /// <summary>Costo por hora de espera en vuelos nacionales.</summary>
        public double DomesticWaitHourCost { get; set; } = 50;

        /// <summary>Costo por hora de espera en vuelos internacionales.</summary>
        public double InternationalWaitHourCost { get; set; } = 200;

        /// <summary>Costo de pernocta (overnight) en vuelos nacionales.</summary>
        public double DomesticOvernightCost { get; set; } = 300;

        /// <summary>Costo de pernocta (overnight) en vuelos internacionales.</summary>
        public double InternationalOvernightCost { get; set; } = 500;

        /// <summary>Impuesto aeroportuario por pasajero (solo internacional).</summary>
        public double AirportTaxPerPassenger { get; set; } = 30;

        /// <summary>Costo de handling por pasajero (solo internacional).</summary>
        public double HandlingPerPassenger { get; set; } = 100;

        // ======================================================
        // 🔗 RELACIONES DE NAVEGACIÓN
        // ======================================================
        public ICollection<CompanyBase> Bases { get; set; } = new List<CompanyBase>();
        public ICollection<User> Users { get; set; } = new List<User>();
        public ICollection<Aircraft> Aircrafts { get; set; } = new List<Aircraft>();
        public ICollection<Flight> Flights { get; set; } = new List<Flight>();
        public ICollection<Reservation> Reservations { get; set; } = new List<Reservation>();
        public ICollection<FlightCharge> FlightCharges { get; set; } = new List<FlightCharge>();
    }
}
