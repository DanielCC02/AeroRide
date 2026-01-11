using System;

namespace AeroRide.API.Models.Enums
{
    /// <summary>
    /// Represents the current status of a flight assignment
    /// associated with a pilot within the AeroRide system.
    /// </summary>
    public enum FlightAssignmentStatus
    {
        /// <summary>
        /// The pilot has been assigned to the flight but has not yet accepted the assignment.
        /// </summary>
        Assigned = 1,

        /// <summary>
        /// The pilot has accepted the assigned flight.
        /// </summary>
        Accepted = 2,

        /// <summary>
        /// The assigned flight has been successfully completed by the pilot.
        /// </summary>
        Completed = 3,

        /// <summary>
        /// The assignment was cancelled either by the pilot or by the company.
        /// </summary>
        Cancelled = 4
    }
}
