namespace AeroRide.API.Models.DTOs.Flights
{
    public class AircraftAvailabilityCriteriaDto
    {
        /// <summary>
        /// Minimum number of seats required on the aircraft.
        /// </summary>
        public int MinSeats { get; set; }

        /// <summary>
        /// Identifier of the departure airport.
        /// </summary>
        public int DepartureAirportId { get; set; }

        /// <summary>
        /// Identifier of the arrival airport.
        /// </summary>
        public int ArrivalAirportId { get; set; }

        /// <summary>
        /// Requested departure date and time, expressed in the
        /// local time zone of the departure airport.
        /// </summary>
        public DateTime DepartureTime { get; set; }

        /// <summary>
        /// Optional company identifier used to filter aircraft
        /// belonging to a specific company.
        /// </summary>
        public int? CompanyId { get; set; }
    }

}

