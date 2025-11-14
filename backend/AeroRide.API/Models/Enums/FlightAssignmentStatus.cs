using System;

namespace AeroRide.API.Models.Enums
{
    /// <summary>
    /// Representa el estado actual de una asignación de vuelo
    /// asociada a un piloto dentro del sistema AeroRide.
    /// </summary>
    public enum FlightAssignmentStatus
    {
        /// <summary>
        /// El piloto ha sido asignado pero todavía no ha aceptado la asignación.
        /// </summary>
        Assigned = 1,

        /// <summary>
        /// El piloto aceptó el vuelo asignado.
        /// </summary>
        Accepted = 2,

        /// <summary>
        /// El vuelo fue completado por el piloto asignado.
        /// </summary>
        Completed = 3,

        /// <summary>
        /// La asignación fue cancelada por el piloto o por la empresa.
        /// </summary>
        Cancelled = 4
    }
}
