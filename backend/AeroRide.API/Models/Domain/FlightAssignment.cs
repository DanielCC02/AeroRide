using AeroRide.API.Models.Domain;

namespace AeroRide.API.Models.Domain
{
    /// <summary>
    /// Entidad intermedia que representa la asignación de un piloto a un vuelo específico.
    /// 
    /// Permite registrar quién fue el piloto designado, cuándo se realizó la asignación,
    /// y el estado actual de dicha relación (asignado, aceptado, completado o cancelado).
    /// 
    /// Esta entidad soporta múltiples pilotos por vuelo (por ejemplo: capitán y copiloto),
    /// así como el almacenamiento de un historial de asignaciones.
    /// </summary>
    public class FlightAssignment
    {
        /// <summary>
        /// Identificador único de la asignación del piloto al vuelo.
        /// </summary>
        public int Id { get; set; }

        /// <summary>
        /// Identificador del vuelo al que se asigna el piloto.
        /// </summary>
        public int FlightId { get; set; }

        /// <summary>
        /// Navegación hacia el vuelo asociado a la asignación.
        /// </summary>
        public Flight Flight { get; set; } = null!;

        /// <summary>
        /// Identificador del usuario piloto asignado al vuelo.
        /// </summary>
        public int PilotUserId { get; set; }

        /// <summary>
        /// Navegación hacia el piloto asignado (usuario con rol "Piloto").
        /// </summary>
        public User PilotUser { get; set; } = null!;

        /// <summary>
        /// Fecha y hora en que se registró la asignación del piloto.
        /// Se guarda en formato UTC por defecto.
        /// </summary>
        public DateTime AssignedAt { get; set; } = DateTime.UtcNow;

        /// <summary>
        /// Estado actual de la asignación del vuelo.
        /// </summary>
        public AssignmentStatus Status { get; set; } = AssignmentStatus.Assigned;

        /// <summary>
        /// Enumeración que define los posibles estados de una asignación de vuelo.
        /// </summary>
        public enum AssignmentStatus
        {
            /// <summary>
            /// El operador ha asignado al piloto, pero aún no ha sido confirmado.
            /// </summary>
            Assigned,

            /// <summary>
            /// El piloto confirmó su asignación al vuelo.
            /// </summary>
            Accepted,

            /// <summary>
            /// El vuelo fue completado satisfactoriamente.
            /// </summary>
            Completed,

            /// <summary>
            /// La asignación fue cancelada por el piloto o por el operador.
            /// </summary>
            Cancelled
        }
    }
}
