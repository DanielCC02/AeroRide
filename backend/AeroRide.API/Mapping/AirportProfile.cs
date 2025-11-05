using AeroRide.API.Models.Domain;
using AeroRide.API.Models.DTOs.Airports;
using AutoMapper;
using NetTopologySuite.Geometries;
using System.Reflection;

namespace AeroRide.API.Mappings
{
    /// <summary>
    /// Configuración de AutoMapper para el módulo de Aeropuertos.
    /// Controla la creación, actualización y proyección de datos entre
    /// entidades de dominio y DTOs, evitando sobrescribir valores por defecto.
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
                .ForMember(dest => dest.IsActive, opt => opt.MapFrom(_ => true))
                .ForMember(dest => dest.TimeZone, opt => opt.MapFrom(src => src.TimeZone))
                .ForMember(dest => dest.MaxAllowedWeight, opt => opt.MapFrom(src => src.MaxAllowedWeight));

            // ======================================================
            // ✏️ UPDATE → DOMAIN
            // ======================================================
            var updateMap = CreateMap<AirportUpdateDto, Airport>();

            updateMap.ForAllMembers(opt =>
            {
                opt.Condition((src, dest, srcMember, context) =>
                {
                    // ❌ No mapear valores nulos
                    if (srcMember == null)
                        return false;

                    // ❌ No mapear cadenas vacías
                    if (srcMember is string s && string.IsNullOrWhiteSpace(s))
                        return false;

                    // Intentar obtener el tipo del destino mediante la configuración
                    var destinationProperty = opt.DestinationMember as System.Reflection.PropertyInfo;
                    if (destinationProperty == null)
                        return true; // no aplica restricción si no se puede determinar el tipo

                    var memberType = destinationProperty.PropertyType;
                    bool isNullable = Nullable.GetUnderlyingType(memberType) != null;

                    // ❌ Evitar sobrescribir con valores por defecto (solo si no es nullable)
                    if (!isNullable)
                    {
                        var defaultValue = Activator.CreateInstance(memberType);
                        if (Equals(srcMember, defaultValue))
                            return false;
                    }

                    // ✅ Si pasa todas las condiciones, se mapea
                    return true;
                });
            });


            // 🔁 Recalcular ubicación si cambian las coordenadas
            updateMap.AfterMap((src, dest) =>
            {
                if (src.Latitude.HasValue && src.Longitude.HasValue)
                {
                    dest.Ubication = new Point(
                        (double)src.Longitude.Value,
                        (double)src.Latitude.Value
                    )
                    { SRID = 4326 };
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
