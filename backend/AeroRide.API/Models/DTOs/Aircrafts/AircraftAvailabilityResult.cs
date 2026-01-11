using AeroRide.API.Models.Domain;

/// <summary>
/// Result object that represents the availability status of an aircraft.
/// It includes the aircraft information when available,
/// or a descriptive reason explaining why the aircraft is not available.
/// </summary>
public class AircraftAvailabilityResult
{
    /// <summary>
    /// The available aircraft, or <c>null</c> if no aircraft is available.
    /// </summary>
    public Aircraft? Aircraft { get; set; }

    /// <summary>
    /// Descriptive reason indicating why the aircraft is unavailable
    /// or additional contextual information about the availability result.
    /// </summary>
    public string Reason { get; set; } = string.Empty;
}
