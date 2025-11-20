public class AircraftAvailabilityCriteriaDto
{
    public int MinSeats { get; set; }
    public int DepartureAirportId { get; set; }
    public int ArrivalAirportId { get; set; }

    // Local time del aeropuerto de salida
    public DateTime DepartureTime { get; set; }

    public int? CompanyId { get; set; } // opcional
}
