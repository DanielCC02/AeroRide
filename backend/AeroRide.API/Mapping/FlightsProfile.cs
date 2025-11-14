using AutoMapper;
using AeroRide.API.Models.Domain;
using AeroRide.API.Models.DTOs.Flights;
using AeroRide.API.Models.Enums;

namespace AeroRide.API.Mappings
{
    /// <summary>
    /// Configura los mapeos entre las entidades relacionadas con vuelos y sus DTOs.
    /// </summary>
    public class FlightsProfile : Profile
    {
        public FlightsProfile()
        {
            // 🔹 Flight → FlightSummaryDto
            CreateMap<Flight, FlightSummaryDto>()
                .ForMember(dest => dest.DepartureAirportName, opt => opt.MapFrom(src => src.DepartureAirport.Name))
                .ForMember(dest => dest.ArrivalAirportName, opt => opt.MapFrom(src => src.ArrivalAirport.Name))
                .ForMember(dest => dest.AircraftModel, opt => opt.MapFrom(src => src.Aircraft.Model))
                .ForMember(dest => dest.CompanyName, opt => opt.MapFrom(src => src.Company.Name));

            // 🔹 FlightSegmentDto → Flight
            CreateMap<FlightSegmentDto, Flight>()
                .ForMember(dest => dest.DurationMinutes, opt => opt.MapFrom(src => (src.ArrivalTime - src.DepartureTime).TotalMinutes))
                .ForMember(dest => dest.IsEmptyLeg, opt => opt.MapFrom(_ => false))
                .ForMember(dest => dest.IsInternational, opt => opt.Ignore())
                .ForMember(dest => dest.Status, opt => opt.MapFrom(_ => FlightStatus.Programado))
                .ForMember(dest => dest.CreatedAt, opt => opt.MapFrom(_ => DateTime.UtcNow))
                .ForMember(dest => dest.UpdatedAt, opt => opt.Ignore())
                .ForMember(dest => dest.Company, opt => opt.Ignore())
                .ForMember(dest => dest.DepartureAirport, opt => opt.Ignore())
                .ForMember(dest => dest.ArrivalAirport, opt => opt.Ignore())
                .ForMember(dest => dest.Reservation, opt => opt.Ignore())
                .ForMember(dest => dest.Charge, opt => opt.Ignore());

            CreateMap<Flight, FlightResponseDto>()
                .ForMember(dest => dest.DepartureAirportName, opt => opt.MapFrom(src => src.DepartureAirport.Name))
                .ForMember(dest => dest.ArrivalAirportName, opt => opt.MapFrom(src => src.ArrivalAirport.Name))
                .ForMember(dest => dest.AircraftModel, opt => opt.MapFrom(src => src.Aircraft.Model))
                .ForMember(dest => dest.AircraftPatent, opt => opt.MapFrom(src => src.Aircraft.Patent))
                .ForMember(dest => dest.CompanyName, opt => opt.MapFrom(src => src.Company.Name))
                .ForMember(dest => dest.ReservationCode, opt => opt.MapFrom(src => src.Reservation != null ? src.Reservation.ReservationCode : null))
                .ForMember(dest => dest.Status, opt => opt.MapFrom(src => src.Status.ToString()));
        }
    }
}
