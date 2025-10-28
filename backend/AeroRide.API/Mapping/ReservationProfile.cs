using AeroRide.API.Models.Domain;
using AeroRide.API.Models.DTOs.Reservations;
using AutoMapper;

namespace AeroRide.API.Mappings
{
    /// <summary>
    /// Perfil de configuración de AutoMapper para la entidad Reservation.
    /// Define los mapeos entre la entidad de dominio y sus respectivos DTOs.
    /// </summary>
    public class ReservationProfile : Profile
    {
        /// <summary>
        /// Inicializa las reglas de conversión entre Reservation y sus DTOs.
        /// </summary>
        public ReservationProfile()
        {
            // Entidad → DTOs
            CreateMap<Reservation, ReservationListDto>();
            CreateMap<Reservation, ReservationResponse>()
                .ForMember(dest => dest.UserEmail, opt => opt.MapFrom(src => src.User.Email));

            // DTOs → Entidad
            CreateMap<ReservationCreateDto, Reservation>();
            CreateMap<ReservationUpdateDto, Reservation>();
        }
    }
}
