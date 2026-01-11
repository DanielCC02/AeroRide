using AeroRide.API.Models.DTOs.Passengers;

namespace AeroRide.API.Models.DTOs.EmptyLegs
{
    /// <summary>
    /// Data Transfer Object used to create a reservation
    /// for an Empty Leg flight.
    /// </summary>
    public class EmptyLegReservationCreateDto
    {
        /// <summary>
        /// Identifier of the user creating the reservation.
        /// </summary>
        public int UserId { get; set; }

        /// <summary>
        /// Identifier of the Empty Leg flight being reserved.
        /// </summary>
        public int EmptyLegFlightId { get; set; }

        /// <summary>
        /// Final price sent from the frontend.
        /// This value is already calculated and includes discounts.
        /// </summary>
        public double Price { get; set; }

        /// <summary>
        /// Indicates whether the reservation includes a lap child
        /// (infant without an assigned seat).
        /// </summary>
        public bool LapChild { get; set; }

        /// <summary>
        /// Indicates whether an assistance animal is required.
        /// </summary>
        public bool AssistanceAnimal { get; set; }

        /// <summary>
        /// Optional additional notes provided with the reservation.
        /// </summary>
        public string? Notes { get; set; }

        /// <summary>
        /// List of passengers included in the Empty Leg reservation.
        /// </summary>
        public List<PassengerCreateDto> Passengers { get; set; } = new();
    }
}
