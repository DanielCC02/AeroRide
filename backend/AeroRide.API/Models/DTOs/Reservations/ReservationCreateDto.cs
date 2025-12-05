using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using AeroRide.API.Models.DTOs.Flights;
using AeroRide.API.Models.DTOs.Passengers;

namespace AeroRide.API.Models.DTOs.Reservations
{
    /// <summary>
    /// Datos necesarios para crear una nueva reserva en el sistema AeroRide.
    /// </summary>
    public class ReservationCreateDto
    {
        [Required]
        public int CompanyId { get; set; }

        [Required]
        [StringLength(100)]
        public string AircraftModel { get; set; } = null!;

        // 🆕 Lista de aeronaves válidas para este modelo/compañía
        public List<int> AircraftIds { get; set; } = new();

        [Range(0, 100)]
        public double PorcentPrice { get; set; }

        [Range(0, double.MaxValue)]
        public double TotalPrice { get; set; }

        public bool IsRoundTrip { get; set; }

        public bool LapChild { get; set; }

        public bool AssistanceAnimal { get; set; }

        [StringLength(250)]
        public string? Notes { get; set; }

        [Required]
        [MinLength(1, ErrorMessage = "Debe incluir al menos un pasajero.")]
        public List<PassengerCreateDto> Passengers { get; set; } = new();

        [Required]
        [MinLength(1, ErrorMessage = "Debe incluir al menos un tramo de vuelo.")]
        public List<FlightSegmentDto> Segments { get; set; } = new();
    }
}
