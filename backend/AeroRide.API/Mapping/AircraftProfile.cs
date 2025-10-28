using AeroRide.API.Models.Domain;
using AeroRide.API.Models.DTOs.Aircrafts;
using AutoMapper;

namespace AeroRide.API.Mappings
{
    /// <summary>
    /// Perfil de configuración de AutoMapper para la entidad Aircraft.
    /// Define las reglas de conversión entre los objetos de dominio y sus respectivos DTOs.
    /// </summary>
    public class AircraftProfile : Profile
    {
        public AircraftProfile()
        {
            // DTO → Entidad (Create)
            CreateMap<AircraftCreateDto, Aircraft>()
                .ForMember(dest => dest.Id, opt => opt.Ignore())
                .ForMember(dest => dest.IsActive, opt => opt.MapFrom(src => true));

            // DTO → Entidad (Update parcial)
            CreateMap<AircraftUpdateDto, Aircraft>()
                .ForAllMembers(opt =>
                    opt.Condition((src, dest, srcMember) =>
                    {
                        if (srcMember is int i && i == 0) return false;
                        if (srcMember is double d && d == 0.0) return false;
                        if (srcMember is bool b && !b) return false;
                        return srcMember != null;
                    }));

            // Entidad → DTO (para listados simples)
            CreateMap<Aircraft, AircraftListDto>();

            // Entidad → DTO (para detalles completos)
            CreateMap<Aircraft, AircraftResponseDto>();

            // 🌐 Entidad → DTO (para agrupaciones / categorías)
            CreateMap<Aircraft, AircraftCategoryDto>()
                .ForMember(dest => dest.CompanyName, opt => opt.MapFrom(src => src.Company != null ? src.Company.Name : "Sin compañía"));

        }
    }
}
