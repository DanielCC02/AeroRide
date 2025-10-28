using AeroRide.API.Models.Domain;
using AeroRide.API.Models.DTOs.Airports;
using AutoMapper;
using NetTopologySuite.Geometries;

namespace AeroRide.API.Mapping.Mappings
{
    /// <summary>
    /// Perfil de AutoMapper encargado de mapear entre entidades del dominio y DTOs
    /// del módulo de Aeropuertos.
    /// Controla la creación, actualización y proyección de datos sin sobreescribir
    /// valores existentes por defecto (como <c>Tax</c> o <c>IsActive</c>).
    /// </summary>
    public class AirportProfile : Profile
    {
        public AirportProfile()
        {
            // ======================================================
            // 🏗️ CREATE → DOMAIN
            // ======================================================
            CreateMap<AirportCreateDto, Airport>()
                // 🔹 Genera la ubicación geoespacial (Point) con SRID 4326
                .ForMember(dest => dest.Ubication, opt => opt.MapFrom(src =>
                    new Point((double)src.Longitude, (double)src.Latitude) { SRID = 4326 }))
                // 🔹 Define IsActive = true automáticamente al crear
                .ForMember(dest => dest.IsActive, opt => opt.MapFrom(src => true));

            // ======================================================
            // ✏️ UPDATE → DOMAIN
            // ======================================================
            var updateMap = CreateMap<AirportUpdateDto, Airport>();

            // 🔹 Regla general: ignora valores nulos o por defecto para evitar sobrescribir
            updateMap.ForAllMembers(opt =>
            {
                opt.Condition((src, dest, srcMember) =>
                {
                    if (srcMember == null) return false;

                    // Evitar sobrescribir con valores por defecto
                    if (srcMember is int i && i == 0) return false;
                    if (srcMember is double d && d == 0.0) return false;
                    if (srcMember is decimal m && m == 0.0m) return false;
                    if (srcMember is bool b && !b) return false;
                    if (srcMember is TimeSpan t && t == default) return false;
                    if (srcMember is string s && string.IsNullOrWhiteSpace(s)) return false;

                    // ✅ Evita que Tax se ponga en 0 cuando no viene en el JSON
                    if (srcMember is decimal? && srcMember == null) return false;

                    return true;
                });
            });

            // 🔹 Regla especial: genera la ubicación si se envían coordenadas válidas
            updateMap.AfterMap((src, dest) =>
            {
                if (src.Latitude.HasValue && src.Longitude.HasValue)
                {
                    dest.Ubication = new Point(
                        (double)src.Longitude.Value,
                        (double)src.Latitude.Value
                    )
                    {
                        SRID = 4326
                    };
                }
            });

            // ======================================================
            // 🧾 DOMAIN → RESPONSE
            // ======================================================
            CreateMap<Airport, AirportResponseDto>();

            // ======================================================
            // 📋 DOMAIN → LIST
            // ======================================================
            CreateMap<Airport, AirportListDto>();

            // ======================================================
            // 📑 DOMAIN → DETAIL
            // ======================================================
            CreateMap<Airport, AirportDetailDto>();
        }
    }
}
