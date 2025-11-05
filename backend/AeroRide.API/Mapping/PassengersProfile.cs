using AutoMapper;
using AeroRide.API.Models.Domain;
using AeroRide.API.Models.DTOs.Passengers;

namespace AeroRide.API.Mappings
{
    /// <summary>
    /// Configura los mapeos entre PassengerDetail y sus DTOs asociados.
    /// </summary>
    public class PassengersProfile : Profile
    {
        public PassengersProfile()
        {
            // 🔹 Domain → DTO
            CreateMap<PassengerDetail, PassengerDetailDto>();

            // 🔹 DTO → Domain (crear nuevo pasajero)
            CreateMap<PassengerCreateDto, PassengerDetail>()
                .ForMember(dest => dest.Id, opt => opt.Ignore())
                .ForMember(dest => dest.Reservation, opt => opt.Ignore());

            // 🔹 DTO → Domain (actualizar pasajero existente)
            CreateMap<PassengerUpdateDto, PassengerDetail>()
                .ForMember(dest => dest.Reservation, opt => opt.Ignore());
        }
    }
}
