using AutoMapper;
using AeroRide.API.Models.Domain;
using AeroRide.API.Models.DTOs.Reservations;
using AeroRide.API.Models.Enums;

namespace AeroRide.API.Mappings
{
    /// <summary>
    /// Configura los mapeos entre entidades del dominio y DTOs del módulo de Reservas.
    /// </summary>
    public class ReservationsProfile : Profile
    {
        public ReservationsProfile()
        {
            // 🔹 Domain → DTO
            CreateMap<Reservation, ReservationResponseDto>()
                .ForMember(dest => dest.CompanyName, opt => opt.MapFrom(src => src.Company.Name))
                .ForMember(dest => dest.Flights, opt => opt.MapFrom(src => src.Flights))
                .ForMember(dest => dest.Passengers, opt => opt.MapFrom(src => src.Passengers));

            // 🔹 DTO → Domain
            CreateMap<ReservationCreateDto, Reservation>()
                .ForMember(dest => dest.CreatedAt, opt => opt.MapFrom(_ => DateTime.UtcNow))
                .ForMember(dest => dest.Status, opt => opt.MapFrom(_ => ReservationStatus.Pendiente))
                .ForMember(dest => dest.ReservationCode, opt => opt.Ignore()) // se genera en el servicio
                .ForMember(dest => dest.User, opt => opt.Ignore())
                .ForMember(dest => dest.Company, opt => opt.Ignore())
                .ForMember(dest => dest.Flights, opt => opt.Ignore())
                .ForMember(dest => dest.Passengers, opt => opt.Ignore());
        }
    }
}
