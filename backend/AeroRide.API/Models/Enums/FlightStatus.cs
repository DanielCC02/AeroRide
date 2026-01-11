namespace AeroRide.API.Models.Enums
{
    /// <summary>
    /// Represents the different operational phases of a flight
    /// throughout its complete lifecycle within the AeroRide system.
    /// </summary>
    public enum FlightStatus
    {
        /// <summary>
        /// Aircraft is being prepared for the flight or removed from the hangar.
        /// </summary>
        PreFlight = 1,

        /// <summary>
        /// Passengers are boarding the aircraft.
        /// </summary>
        Boarding = 2,

        /// <summary>
        /// Aircraft is leaving the hangar or moving to the ramp area.
        /// </summary>
        PushbackOrRamp = 3,

        /// <summary>
        /// Aircraft is taxiing toward the runway.
        /// </summary>
        TaxiToRunway = 4,

        /// <summary>
        /// Aircraft is holding short at the runway threshold,
        /// waiting for air traffic control clearance.
        /// </summary>
        HoldingShort = 5,

        /// <summary>
        /// Aircraft has been cleared for takeoff.
        /// </summary>
        Takeoff = 6,

        /// <summary>
        /// Aircraft is airborne and en route to the destination.
        /// </summary>
        EnRoute = 7,

        /// <summary>
        /// Aircraft is in the landing phase or has been cleared to land.
        /// </summary>
        Landing = 8,

        /// <summary>
        /// Aircraft is taxiing to the ramp after landing.
        /// </summary>
        TaxiToRamp = 9,

        /// <summary>
        /// Passengers are deboarding the aircraft.
        /// </summary>
        Deboarding = 10,

        /// <summary>
        /// Flight has been completed and closing procedures are in progress.
        /// </summary>
        Completed = 11,
    }
}
