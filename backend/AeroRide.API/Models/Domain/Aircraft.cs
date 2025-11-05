using AeroRide.API.Models.Enums;

namespace AeroRide.API.Models.Domain
{
    /// <summary>
    /// Entidad que representa una aeronave registrada en el sistema AeroRide.
    /// Incluye información técnica, capacidad, estado operativo y relación con la empresa propietaria.
    /// </summary>
    public class Aircraft
    {
        // ======================================================
        // 🔑 IDENTIFICACIÓN
        // ======================================================

        public int Id { get; set; }

        // ======================================================
        // ✈️ INFORMACIÓN GENERAL Y TÉCNICA
        // ======================================================

        public string Patent { get; set; } = null!;
        public string Model { get; set; } = null!;
        public double MinuteCost { get; set; }
        public int Seats { get; set; }
        public int MaxWeight { get; set; }
        public double CruisingSpeed { get; set; }
        public bool CanFlyInternational { get; set; } = false;

        public AircraftState State { get; set; } = AircraftState.Disponible;
        public DateTime StatusLastUpdated { get; set; } = DateTime.UtcNow;
        public string Image { get; set; } = null!;
        public bool IsActive { get; set; } = true;
        public int EmptyWeight { get; set; }

        // ======================================================
        // 🌎 UBICACIÓN Y RELACIONES
        // ======================================================

        /// <summary>
        /// Aeropuerto base (hangar) donde opera habitualmente esta aeronave.
        /// </summary>
        public int BaseAirportId { get; set; }
        public Airport BaseAirport { get; set; } = null!;

        /// <summary>
        /// Aeropuerto donde la aeronave se encuentra actualmente.
        /// Puede diferir de su base si está en una operación o vuelo reciente.
        /// </summary>
        public int? CurrentAirportId { get; set; }
        public Airport? CurrentAirport { get; set; }

        /// <summary>
        /// Identificador de la empresa propietaria de la aeronave.
        /// </summary>
        public int CompanyId { get; set; }
        public Company Company { get; set; } = null!;

        // ======================================================
        // 🔗 RELACIONES DE NAVEGACIÓN
        // ======================================================

        /// <summary>
        /// Colección de vuelos asociados a la aeronave.
        /// </summary>
        public ICollection<Flight> Flights { get; set; } = new List<Flight>();
    }
}
