using AutoMapper;
using AeroRide.API.Models.Domain;
using AeroRide.API.Models.DTOs.Reservations;
using AeroRide.API.Models.Enums;

namespace AeroRide.API.Mappings
{
    /// <summary>
    /// Configura los mapeos entre entidades del dominio y DTOs del módulo de Reservas.
    /// </summary>
    public class ReservationsProfile : Profile
    {
        public ReservationsProfile()
        {
            // 🔹 Domain → DTO
            CreateMap<Reservation, ReservationResponseDto>()
                .ForMember(dest => dest.CompanyName, opt => opt.MapFrom(src => src.Company.Name))
                .ForMember(dest => dest.Flights, opt => opt.MapFrom(src => src.Flights))
                .ForMember(dest => dest.Passengers, opt => opt.MapFrom(src => src.Passengers));

            // 🔹 DTO → Domain
            CreateMap<ReservationCreateDto, Reservation>()
                .ForMember(dest => dest.CreatedAt, opt => opt.MapFrom(_ => DateTime.UtcNow))
                .ForMember(dest => dest.Status, opt => opt.MapFrom(_ => ReservationStatus.Pendiente))
                .ForMember(dest => dest.ReservationCode, opt => opt.Ignore()) // se genera en el servicio
                .ForMember(dest => dest.User, opt => opt.Ignore())
                .ForMember(dest => dest.Company, opt => opt.Ignore())
                .ForMember(dest => dest.Flights, opt => opt.Ignore())
                .ForMember(dest => dest.Passengers, opt => opt.Ignore());

            CreateMap<Reservation, ReservationTripItemDto>()
                .ForMember(dest => dest.ReservationId,
                    opt => opt.MapFrom(src => src.Id))

                .ForMember(dest => dest.ReservationCode,
                    opt => opt.MapFrom(src => src.ReservationCode))

                .ForMember(dest => dest.DepartureTime,
                    opt => opt.MapFrom(src =>
                        src.Flights
                            .Where(f => !f.IsEmptyLeg)
                            .OrderBy(f => f.DepartureTime)
                            .Select(f => (DateTime?)f.DepartureTime)
                            .FirstOrDefault() ?? DateTime.MinValue
                    ))

                // ORIGEN
                .ForMember(dest => dest.FromCity,
                    opt => opt.MapFrom(src =>
                        src.Flights
                            .Where(f => !f.IsEmptyLeg)
                            .OrderBy(f => f.DepartureTime)
                            .Select(f => f.DepartureAirport != null ? f.DepartureAirport.City : "")
                            .FirstOrDefault() ?? ""
                    ))

                .ForMember(dest => dest.FromCode,
                    opt => opt.MapFrom(src =>
                        src.Flights
                            .Where(f => !f.IsEmptyLeg)
                            .OrderBy(f => f.DepartureTime)
                            .Select(f => f.DepartureAirport != null ? f.DepartureAirport.CodeIATA : "")
                            .FirstOrDefault() ?? ""
                    ))

                // DESTINO
                .ForMember(dest => dest.ToCity,
                    opt => opt.MapFrom(src =>
                        src.Flights
                            .Where(f => !f.IsEmptyLeg)
                            .OrderBy(f => f.DepartureTime)
                            .Select(f => f.ArrivalAirport != null ? f.ArrivalAirport.City : "")
                            .FirstOrDefault() ?? ""
                    ))

                .ForMember(dest => dest.ToCode,
                    opt => opt.MapFrom(src =>
                        src.Flights
                            .Where(f => !f.IsEmptyLeg)
                            .OrderBy(f => f.DepartureTime)
                            .Select(f => f.ArrivalAirport != null ? f.ArrivalAirport.CodeIATA : "")
                            .FirstOrDefault() ?? ""
                    ))

                // IMAGEN (DESTINO)
                .ForMember(dest => dest.ImageUrl,
                    opt => opt.MapFrom(src =>
                        src.Flights
                            .Where(f => !f.IsEmptyLeg)
                            .OrderBy(f => f.DepartureTime)
                            .Select(f => f.ArrivalAirport != null ? f.ArrivalAirport.Image : null)
                            .FirstOrDefault()
                            ?? "https://images.unsplash.com/photo-1502082553048-f009c37129b9"
                    ))

                // UPCOMING FLAG
                .ForMember(dest => dest.IsUpcoming,
                    opt => opt.MapFrom(src =>
                        src.Flights.Any(f => !f.IsEmptyLeg && f.DepartureTime > DateTime.UtcNow)
                    ));

        }
    }
}
