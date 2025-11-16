using AeroRide.API.Models.Enums;

namespace AeroRide.API.Models.Domain
{
    /// <summary>
    /// Relación intermedia que representa la asignación de un piloto
    /// (capitán o copiloto) a un vuelo específico.
    /// </summary>
    public class FlightAssignment
    {
        /// <summary>Identificador único de la asignación.</summary>
        public int Id { get; set; }

        /// <summary>Identificador del vuelo al cual se asigna el piloto.</summary>
        public int FlightId { get; set; }

        /// <summary>Referencia al vuelo asociado.</summary>
        public Flight Flight { get; set; } = null!;

        /// <summary>Identificador del usuario piloto asignado.</summary>
        public int PilotUserId { get; set; }

        /// <summary>Referencia al piloto asignado.</summary>
        public User PilotUser { get; set; } = null!;

        /// <summary>
        /// Fecha en formato UTC cuando se registró la asignación.
        /// </summary>
        public DateTime AssignedAt { get; set; } = DateTime.UtcNow;

        /// <summary>
        /// Estado actual de la asignación.
        /// </summary>
        public FlightAssignmentStatus Status { get; set; } = FlightAssignmentStatus.Assigned;

        public CrewRole CrewRole { get; set; } = CrewRole.Pilot;
    }
}
