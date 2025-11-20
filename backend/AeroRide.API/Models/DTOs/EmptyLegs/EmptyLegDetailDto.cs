namespace AeroRide.API.Models.DTOs.EmptyLegs
{
    public class EmptyLegDetailDto
    {
        public int Id { get; set; }

        // Aeronave
        public string AircraftModel { get; set; } = null!;
        public string AircraftPatent { get; set; } = null!;
        public string AircraftImage { get; set; } = null!;
        public int Seats { get; set; }
        public int MaxWeight { get; set; }
        public double MinuteCost { get; set; }
        public bool CanFlyInternational { get; set; }

        // Precio final con descuento
        public double FinalPrice { get; set; }

        // Itinerario
        public DateTime DepartureTime { get; set; }
        public DateTime ArrivalTime { get; set; }
        public double DurationMinutes { get; set; }
        public string EFT { get; set; } = null!; // “0h 40m”

        // Aeropuerto Origen
        public string DepartureIATA { get; set; } = null!;
        public string DepartureOACI { get; set; } = null!;
        public string DepartureAirportName { get; set; } = null!;
        public string DepartureCity { get; set; } = null!;
        public string DepartureCountry { get; set; } = null!;
        public string DepartureAirportImage { get; set; } = null!;

        // Aeropuerto Destino
        public string ArrivalIATA { get; set; } = null!;
        public string ArrivalOACI { get; set; } = null!;
        public string ArrivalAirportName { get; set; } = null!;
        public string ArrivalCity { get; set; } = null!;
        public string ArrivalCountry { get; set; } = null!;
        public string ArrivalAirportImage { get; set; } = null!;

        // Asignada a qué empresa
        public string CompanyName { get; set; } = null!;
        public int CompanyId { get; set; }

        // Para el formulario del frontend
        public int MaxPassengerCount => Seats; // porque es empty leg
    }

}
