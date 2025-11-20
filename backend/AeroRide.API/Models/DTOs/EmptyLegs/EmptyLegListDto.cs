namespace AeroRide.API.Models.DTOs.EmptyLegs
{
    public class EmptyLegListDto
    {
        public int Id { get; set; }

        // Fecha y formato final del card
        public DateTime DepartureTime { get; set; }

        // Aeropuertos
        public string DepartureAirportName { get; set; } = null!;
        public string DepartureIATA { get; set; } = null!;
        public string ArrivalAirportName { get; set; } = null!;
        public string ArrivalIATA { get; set; } = null!;

        // Avioneta
        public string AircraftModel { get; set; } = null!;
        public string AircraftImage { get; set; } = null!;
        public int Seats { get; set; }
        public int MaxWeight { get; set; }

        // Precio (ya con descuento aplicado)
        public double FinalPrice { get; set; }
    }

}
