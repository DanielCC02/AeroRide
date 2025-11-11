using AutoMapper;
using AeroRide.API.Models.Domain;
using AeroRide.API.Models.DTOs.Aircrafts;
using AeroRide.API.Models.Enums;

namespace AeroRide.API.Mappings
{
    /// <summary>
    /// Configuración de AutoMapper para el módulo de Aeronaves.
    /// Controla la conversión entre DTOs y entidades del dominio Aircraft.
    /// </summary>
    public class AircraftProfile : Profile
    {
        public AircraftProfile()
        {
            // ======================================================
            // 🏗️ CREATE → DOMAIN
            // ======================================================
            CreateMap<AircraftCreateDto, Aircraft>()
                .ForMember(dest => dest.State, opt => opt.MapFrom(src => src.State))
                .ForMember(dest => dest.EmptyWeight, opt => opt.MapFrom(src => src.EmptyWeight))
                .ForMember(dest => dest.Image, opt => opt.MapFrom(src => src.Image))
                .ForMember(dest => dest.CanFlyInternational, opt => opt.MapFrom(src => src.CanFlyInternational))
                .ForMember(dest => dest.BaseAirportId, opt => opt.MapFrom(src => src.BaseAirportId))
                .ForMember(dest => dest.CurrentAirportId, opt => opt.MapFrom(src => src.CurrentAirportId))
                .ForMember(dest => dest.CompanyId, opt => opt.MapFrom(src => src.CompanyId))
                .ForMember(dest => dest.IsActive, opt => opt.MapFrom(_ => true)); // activa por defecto


            // ======================================================
            // ✏️ UPDATE → DOMAIN
            // ======================================================
            CreateMap<AircraftUpdateDto, Aircraft>()
                // 🔹 Mapear correctamente el estado si se envía (enum nullable)
                .ForMember(dest => dest.State,
                    opt =>
                    {
                        opt.PreCondition(src => src.State.HasValue); // Solo si viene en el DTO
                        opt.MapFrom(src => src.State!.Value);
                    })

                // 🔹 Para los demás campos, evitar sobrescribir con valores nulos o vacíos
                .ForAllMembers(opt =>
                    opt.Condition((src, dest, srcMember) =>
                    {
                        if (srcMember == null) return false;
                        if (srcMember is string s && string.IsNullOrWhiteSpace(s)) return false;
                        if (srcMember is double d && d == 0.0) return false;
                        if (srcMember is int i && i == 0) return false;
                        if (srcMember is bool b && !b) return false;
                        return true;
                    }));


            // ======================================================
            // 🧾 DOMAIN → DTO (List)
            // ======================================================
            CreateMap<Aircraft, AircraftListDto>()
                .ForMember(dest => dest.EmptyWeight, opt => opt.MapFrom(src => src.EmptyWeight))
                .ForMember(dest => dest.CompanyName, opt => opt.MapFrom(src => src.Company.Name))
                .ForMember(dest => dest.BaseAirportName, opt => opt.MapFrom(src => src.BaseAirport.Name));

            // ======================================================
            // 📑 DOMAIN → DTO (Detail / Response)
            // ======================================================
            CreateMap<Aircraft, AircraftResponseDto>()
                .ForMember(dest => dest.EmptyWeight, opt => opt.MapFrom(src => src.EmptyWeight))
                .ForMember(dest => dest.CompanyName, opt => opt.MapFrom(src => src.Company.Name))
                .ForMember(dest => dest.BaseAirportName,
                    opt => opt.MapFrom(src => src.BaseAirport != null ? src.BaseAirport.Name : null))
                .ForMember(dest => dest.CurrentAirportName,
                    opt => opt.MapFrom(src => src.CurrentAirport != null ? src.CurrentAirport.Name : null));

            // ======================================================
            // 🛩️ DOMAIN → DTO (Category)
            // ======================================================
            CreateMap<Aircraft, AircraftCategoryDto>()
                .ForMember(dest => dest.CompanyName,
                    opt => opt.MapFrom(src => src.Company != null ? src.Company.Name : "Sin compañía"));
        }
    }
}
