using AeroRide.API.Models.Domain;
using AeroRide.API.Models.DTOs.Aircrafts;
using AutoMapper;

namespace AeroRide.API.Profiles
{
    /// <summary>
    /// Perfil de configuración de <see cref="AutoMapper"/> para la entidad <see cref="Aircraft"/>.
    /// Define las reglas de conversión entre los objetos de dominio y sus respectivos DTOs.
    /// </summary>
    public class AircraftProfile : Profile
    {
        /// <summary>
        /// Inicializa las configuraciones de mapeo entre los objetos relacionados con aeronaves.
        /// </summary>
        public AircraftProfile()
        {
            // 🔹 DTO → Entidad (para creación de registros)
            CreateMap<AircraftCreateDto, Aircraft>()
                .ForMember(dest => dest.Id, opt => opt.Ignore()) // ID lo genera la BD
                .ForMember(dest => dest.IsActive, opt => opt.MapFrom(src => true)); // Setea IsActive = true

            // 🔹 DTO → Entidad (para actualización parcial)
            CreateMap<AircraftUpdateDto, Aircraft>()
    .ForAllMembers(opt =>
        opt.Condition((src, dest, srcMember) =>
        {
            if (srcMember is int i && i == 0) return false;
            if (srcMember is double d && d == 0.0) return false;
            if (srcMember is bool b && !b) return false;
            return srcMember != null;
        }));




            // 🔹 Entidad → DTO (para respuestas al cliente)
            CreateMap<Aircraft, AircraftResponseDto>();
        }
    }
}
