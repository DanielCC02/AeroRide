namespace AeroRide.API.Models.Domain
{
    /// <summary>
    /// Entidad que representa una bitácora o registro de vuelo (logbook) creada por el piloto.
    /// 
    /// Esta bitácora documenta información del vuelo realizado y puede incluir evidencia visual o reportes técnicos.
    /// Está vinculada directamente a un vuelo (<see cref="Flight"/>) y, de forma opcional, 
    /// a una reserva (<see cref="Reservation"/>).
    /// </summary>
    public class FlightLog
    {
        /// <summary>
        /// Identificador único de la bitácora.
        /// </summary>
        public int Id { get; set; }

        /// <summary>
        /// Identificador del usuario (piloto) que registró la bitácora.
        /// </summary>
        public int UserId { get; set; }

        /// <summary>
        /// Referencia al usuario piloto que generó la bitácora.
        /// </summary>
        public User User { get; set; } = null!;

        /// <summary>
        /// Identificador del vuelo al que pertenece esta bitácora.
        /// </summary>
        public int FlightId { get; set; }

        /// <summary>
        /// Referencia al vuelo correspondiente a esta bitácora.
        /// Representa una relación muchos a uno (<c>N:1</c>) entre <see cref="FlightLog"/> y <see cref="Flight"/>.
        /// </summary>
        public Flight Flight { get; set; } = null!;

        /// <summary>
        /// Identificador de la reserva asociada (opcional).
        /// Este campo se utiliza cuando el vuelo forma parte de una reserva activa.
        /// </summary>
        public int? ReservationId { get; set; }

        /// <summary>
        /// Referencia opcional a la reserva vinculada al vuelo.
        /// </summary>
        public Reservation? Reservation { get; set; }

        /// <summary>
        /// Archivo de evidencia adjunto al registro del vuelo.
        /// Puede ser una imagen, fotografía del panel, reporte o documento firmado.
        /// </summary>
        public string Image { get; set; } = null!;
    }
}
