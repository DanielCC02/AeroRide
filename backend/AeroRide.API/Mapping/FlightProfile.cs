using AeroRide.API.Models.Domain;
using AeroRide.API.Models.DTOs.Flights;
using AutoMapper;

namespace AeroRide.API.Mappings
{
    /// <summary>
    /// Perfil de AutoMapper para la entidad Flight.
    /// </summary>
    public class FlightProfile : Profile
    {
        public FlightProfile()
        {
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
