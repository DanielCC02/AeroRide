namespace AeroRide.API.Models.Domain
{
    /// <summary>
    /// Entidad que representa una aeronave registrada en el sistema AeroRide.
    /// Incluye información técnica, capacidad, estado operativo y relación con la empresa propietaria.
    /// </summary>
    public class Aircraft
    {
        /// <summary>
        /// Identificador único de la aeronave.
        /// EF Core la reconoce automáticamente como clave primaria (<c>PK</c>) al denominarse <c>Id</c>.
        /// </summary>
        public int Id { get; set; }

        // ======================================================
        // ✈️ INFORMACIÓN GENERAL Y TÉCNICA
        // ======================================================

        /// <summary>
        /// Matrícula o patente de la aeronave (por ejemplo: <c>TI-ABC</c>).
        /// </summary>
        public string Patent { get; set; } = null!;

        /// <summary>
        /// Modelo o tipo de aeronave (por ejemplo: <c>Cessna 208B Grand Caravan</c>).
        /// </summary>
        public string Model { get; set; } = null!;

        /// <summary>
        /// Precio o costo de operación estimado de la aeronave.
        /// Puede representar el costo por vuelo o por hora.
        /// </summary>
        public double Price { get; set; }

        /// <summary>
        /// Número máximo de pasajeros que puede transportar la aeronave.
        /// </summary>
        public int Seats { get; set; }

        /// <summary>
        /// Peso máximo permitido (en kilogramos o libras, según la configuración del sistema).
        /// </summary>
        public int MaxWeight { get; set; }

        /// <summary>
        /// Velocidad promedio de crucero (en kilómetros por hora).
        /// </summary>
        public double CruisingSpeed { get; set; }

        /// <summary>
        /// Indica si la aeronave está autorizada para realizar vuelos internacionales.
        /// </summary>
        public bool CanFlyInternational { get; set; } = false;

        /// <summary>
        /// Estado actual operativo de la aeronave.
        /// Ejemplos: <c>Disponible</c>, <c>En mantenimiento</c>, <c>Reservado</c>.
        /// </summary>
        public string State { get; set; } = "Disponible";

        /// <summary>
        /// Fecha y hora de la última actualización del estado o ubicación de la aeronave.
        /// </summary>
        public DateTime StatusLastUpdated { get; set; } = DateTime.UtcNow;

        /// <summary>
        /// Ruta o URL de la imagen representativa de la aeronave.
        /// </summary>
        public string Image { get; set; } = null!;

        /// <summary>
        /// Indica si la aeronave está activa o desactivada dentro del sistema.
        /// Cuando se marca como <c>false</c>, se considera eliminada lógicamente.
        /// </summary>
        public bool IsActive { get; set; } = true;

        // ======================================================
        // 🌎 UBICACIÓN Y RELACIONES
        // ======================================================

        /// <summary>
        /// Aeropuerto en el que actualmente se encuentra la aeronave (opcional).
        /// </summary>
        public int? CurrentAirportId { get; set; }

        /// <summary>
        /// Relación de navegación hacia el aeropuerto actual.
        /// </summary>
        public Airport? CurrentAirport { get; set; }

        /// <summary>
        /// Identificador de la empresa propietaria de la aeronave.
        /// </summary>
        public int CompanyId { get; set; }

        /// <summary>
        /// Empresa o aerolínea propietaria de la aeronave.
        /// </summary>
        public Company Company { get; set; } = null!;

        // ======================================================
        // 🔗 RELACIONES DE NAVEGACIÓN
        // ======================================================

        /// <summary>
        /// Colección de vuelos asociados a la aeronave.
        /// Representa una relación uno a muchos (<c>1:N</c>) entre <see cref="Aircraft"/> y <see cref="Flight"/>.
        /// </summary>
        public ICollection<Flight> Flights { get; set; } = new List<Flight>();
    }
}
