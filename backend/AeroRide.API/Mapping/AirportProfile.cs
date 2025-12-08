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
                .ForMember(dest => dest.Ubication, opt => opt.MapFrom(src =>
                    new Point((double)src.Longitude, (double)src.Latitude) { SRID = 4326 }))
                .ForMember(dest => dest.IsActive, opt => opt.MapFrom(_ => true))
                .ForMember(dest => dest.TimeZone, opt => opt.MapFrom(src => src.TimeZone))
                .ForMember(dest => dest.MaxAllowedWeight, opt => opt.MapFrom(src => src.MaxAllowedWeight))
                .ForMember(dest => dest.DepartureMarginMinutes, opt => opt.MapFrom(src => src.DepartureMarginMinutes))
                .ForMember(dest => dest.ArrivalMarginMinutes, opt => opt.MapFrom(src => src.ArrivalMarginMinutes));


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

                    var destinationProperty = opt.DestinationMember as PropertyInfo;
                    if (destinationProperty == null)
                        return true;

                    var memberType = destinationProperty.PropertyType;
                    bool isNullable = Nullable.GetUnderlyingType(memberType) != null;

                    // ⚙️ Evitar usar Activator.CreateInstance con strings
                    if (memberType == typeof(string))
                        return true;

                    // ⚙️ Excepción especial para MaxAllowedWeight
                    if (destinationProperty.Name == nameof(Airport.MaxAllowedWeight))
                    {
                        double value = 0;

                        if (srcMember is int)
                            value = Convert.ToDouble(srcMember);
                        else if (srcMember is int?)
                            value = Convert.ToDouble((int?)srcMember ?? 0);
                        else if (srcMember is double)
                            value = (double)srcMember;
                        else if (srcMember is double?)
                            value = ((double?)srcMember) ?? 0;
                        else if (srcMember is decimal)
                            value = (double)(decimal)srcMember;
                        else if (srcMember is decimal?)
                            value = (double)(((decimal?)srcMember) ?? 0);

                        // ✅ Solo mapear si es > 0
                        return value > 0;
                    }

                    // ❌ Evitar sobrescribir con valores por defecto
                    if (!isNullable)
                    {
                        var defaultValue = Activator.CreateInstance(memberType);
                        if (Equals(srcMember, defaultValue))
                            return false;
                    }

                    return true; // ✅ Mapear en cualquier otro caso válido
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