namespace AeroRide.API.Models.Enums
{
    public enum FlightStatus
    {
        PreFlight = 1,          // Aircraft is being prepared / removed from hangar
        Boarding = 2,           // Passengers boarding
        PushbackOrRamp = 3,     // Leaving hangar / moving to ramp
        TaxiToRunway = 4,       // Taxiing toward runway
        HoldingShort = 5,       // Waiting for clearance at runway threshold
        Takeoff = 6,            // Cleared for takeoff
        EnRoute = 7,            // Airborne / en route
        Landing = 8,            // Cleared for landing / in landing phase
        TaxiToRamp = 9,         // Exiting runway after landing
        Deboarding = 10,        // Passengers deboarding
        Completed = 11,         // Flight completed (closing procedures)
    }
}
