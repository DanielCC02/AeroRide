namespace AeroRide.API.Models.Domain
{
    /// <summary>
    /// Entidad que representa una aeronave registrada en el sistema AeroRide.
    /// Incluye información técnica, capacidad, estado operativo y relación con los vuelos asignados.
    /// </summary>
    public class Aircraft
    {
        /// <summary>
        /// Identificador único de la aeronave.
        /// EF Core la reconoce automáticamente como clave primaria (<c>PK</c>) al denominarse <c>Id</c>.
        /// </summary>
        public int Id { get; set; }

        /// <summary>
        /// Matrícula o patente de la aeronave (por ejemplo: <c>TI-ABC</c>).
        /// </summary>
        public string Patent { get; set; } = null!;

        /// <summary>
        /// Modelo o tipo de aeronave (por ejemplo: <c>Cessna 208B</c>).
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
        /// Estado actual operativo de la aeronave.
        /// Ejemplos: <c>Disponible</c>, <c>En mantenimiento</c>, <c>En vuelo</c>.
        /// </summary>
        public string State { get; set; } = null!;

        /// <summary>
        /// Ruta o URL de la imagen representativa de la aeronave.
        /// </summary>
        public string Image { get; set; } = null!;

        /// <summary>
        /// Colección de vuelos asociados a la aeronave.
        /// Representa una relación uno a muchos (<c>1:N</c>) entre <see cref="Aircraft"/> y <see cref="Flight"/>.
        /// </summary>
        public ICollection<Flight> Flights { get; set; } = new List<Flight>();
    }
}
