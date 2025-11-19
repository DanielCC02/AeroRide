public class FlightResponseDto
{
    public int Id { get; set; }
    public DateTime DepartureTime { get; set; }
    public DateTime ArrivalTime { get; set; }
    public double DurationMinutes { get; set; }
    public bool IsEmptyLeg { get; set; }
    public bool IsInternational { get; set; }
    public string Status { get; set; } = string.Empty;

    // =====================
    // 🔗 Aeropuertos
    // =====================
    public string? DepartureAirportName { get; set; }
    public string? DepartureAirportIATA { get; set; }
    public string? DepartureAirportOACI { get; set; }

    public string? ArrivalAirportName { get; set; }
    public string? ArrivalAirportIATA { get; set; }
    public string? ArrivalAirportOACI { get; set; }

    // =====================
    // 🛩️ Aeronave
    // =====================
    public string? AircraftModel { get; set; }
    public string? AircraftPatent { get; set; }

    // =====================
    // 🏢 Empresa
    // =====================
    public string? CompanyName { get; set; }

    // 🧾 Reserva
    public string? ReservationCode { get; set; }

    public bool HasAssignedPilots { get; set; }
    public int AssignedPilotCount { get; set; }
}
