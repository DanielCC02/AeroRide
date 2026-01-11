using AeroRide.API.Models.Enums;

namespace AeroRide.API.Models.Domain
{
    /// <summary>
    /// Intermediate entity that represents the assignment of a pilot
    /// (captain or co-pilot) to a specific flight.
    /// </summary>
    public class FlightAssignment
    {
        /// <summary>
        /// Unique identifier of the flight assignment.
        /// </summary>
        public int Id { get; set; }

        /// <summary>
        /// Identifier of the flight to which the pilot is assigned.
        /// </summary>
        public int FlightId { get; set; }

        /// <summary>
        /// Reference to the associated flight.
        /// </summary>
        public Flight Flight { get; set; } = null!;

        /// <summary>
        /// Identifier of the assigned pilot user.
        /// </summary>
        public int PilotUserId { get; set; }

        /// <summary>
        /// Reference to the assigned pilot user.
        /// </summary>
        public User PilotUser { get; set; } = null!;

        /// <summary>
        /// UTC date and time when the assignment was created.
        /// </summary>
        public DateTime AssignedAt { get; set; } = DateTime.UtcNow;

        /// <summary>
        /// Current status of the flight assignment.
        /// </summary>
        public FlightAssignmentStatus Status { get; set; } = FlightAssignmentStatus.Assigned;

        /// <summary>
        /// Role of the pilot within the flight crew (pilot or co-pilot).
        /// </summary>
        public CrewRole CrewRole { get; set; } = CrewRole.Pilot;
    }
}
