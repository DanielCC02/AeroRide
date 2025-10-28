using AutoMapper;
using AeroRide.API.Models.Domain;
using AeroRide.API.Models.DTOs.Companies;

namespace AeroRide.API.Mappings
{
    /// <summary>
    /// Perfil de configuración de AutoMapper para la entidad Company.
    /// Define las reglas de conversión entre los objetos de dominio y sus respectivos DTOs.
    /// </summary>
    public class CompanyProfile : Profile
    {
        public CompanyProfile()
        {
            // ======================================================
            // 📥 DTO → ENTIDAD (CREACIÓN)
            // ======================================================
            CreateMap<CompanyCreateDto, Company>()
                .ForMember(dest => dest.CreatedAt, opt => opt.MapFrom(_ => DateTime.UtcNow))
                .ForMember(dest => dest.IsActive, opt => opt.MapFrom(_ => true))
                .ForMember(dest => dest.EmptyLegDiscount, opt => opt.MapFrom(src =>
                    src.EmptyLegDiscount >= 0 && src.EmptyLegDiscount <= 1 ? src.EmptyLegDiscount : 0.5));

            // ======================================================
            // ✏️ DTO → ENTIDAD (ACTUALIZACIÓN PARCIAL)
            // ======================================================
            CreateMap<CompanyUpdateDto, Company>()
                .ForAllMembers(opt =>
                    opt.Condition((src, dest, srcMember) =>
                    {
                        if (srcMember == null) return false;

                        // Evitar sobrescribir con valores por defecto
                        if (srcMember is string s && string.IsNullOrWhiteSpace(s)) return false;
                        if (srcMember is double d && d == 0.0) return false;
                        if (srcMember is bool b && !b) return false;

                        // Solo mapear si hay un valor significativo
                        return true;
                    }));

            // ======================================================
            // 📤 ENTIDAD → DTOs
            // ======================================================
            CreateMap<Company, CompanyResponseDto>();
        }
    }
}
