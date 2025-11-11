using AeroRide.API.Models.Domain;

public class AircraftAvailabilityResult
{
    public Aircraft? Aircraft { get; set; }
    public string Reason { get; set; } = string.Empty;
}
