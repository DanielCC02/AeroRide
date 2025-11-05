using AutoMapper;
using AeroRide.API.Models.Domain;
using AeroRide.API.Models.DTOs.Aircrafts;

namespace AeroRide.API.Mappings
{
    public class AircraftProfile : Profile
    {
        public AircraftProfile()
        {
            // DTO → Domain (Create)
            CreateMap<AircraftUpdateDto, Aircraft>()
                // 🔹 Permitir actualizar el estado incluso si su valor es 0 (Disponible)
                .ForMember(dest => dest.State,
                opt => opt.Condition(src => src.State != null))
            
                // 🔹 Para los demás campos, evitar sobrescribir con valores nulos o vacíos
                .ForAllMembers(opt =>
                    opt.Condition((src, dest, srcMember) =>
                    {
                        if (srcMember == null) return false;
                        if (srcMember is string s && string.IsNullOrWhiteSpace(s)) return false;
                        if (srcMember is double d && d == 0.0) return false;
                        if (srcMember is bool b && !b) return false;
                        return true;
                    }));


            // 🔹 Domain → DTO (List)
            CreateMap<Aircraft, AircraftListDto>()
                .ForMember(dest => dest.CompanyName, opt => opt.MapFrom(src => src.Company.Name))
                .ForMember(dest => dest.BaseAirportName, opt => opt.MapFrom(src => src.BaseAirport.Name));

            // 🔹 Domain → DTO (Detail / Response)
            CreateMap<Aircraft, AircraftResponseDto>()
                .ForMember(dest => dest.CompanyName, opt => opt.MapFrom(src => src.Company.Name))
                .ForMember(dest => dest.BaseAirportName, opt => opt.MapFrom(src => src.BaseAirport != null ? src.BaseAirport.Name : null))
                .ForMember(dest => dest.CurrentAirportName, opt => opt.MapFrom(src => src.CurrentAirport != null ? src.CurrentAirport.Name : null));

            // 🔹 Domain → DTO (Category)
            CreateMap<Aircraft, AircraftCategoryDto>()
                .ForMember(dest => dest.CompanyName, opt => opt.MapFrom(src => src.Company != null ? src.Company.Name : "Sin compañía"));
        }
    }
}
