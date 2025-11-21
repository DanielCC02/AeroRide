using AeroRide.API.Models.Domain;
using AeroRide.API.Models.DTOs.EmptyLegs;
using AeroRide.API.Models.DTOs.FlightAssignments;
using AeroRide.API.Models.DTOs.Flights;
using AeroRide.API.Models.Enums;
using AutoMapper;

namespace AeroRide.API.Mappings
{
    /// <summary>
    /// Configura los mapeos entre las entidades relacionadas con vuelos y sus DTOs.
    /// </summary>
    public class FlightsProfile : Profile
    {
        public FlightsProfile()
        {
            // 🔹 Flight → FlightSummaryDto
            CreateMap<Flight, FlightSummaryDto>()
                .ForMember(dest => dest.DepartureAirportName, opt => opt.MapFrom(src => src.DepartureAirport.Name))
                .ForMember(dest => dest.ArrivalAirportName, opt => opt.MapFrom(src => src.ArrivalAirport.Name))
                .ForMember(dest => dest.AircraftModel, opt => opt.MapFrom(src => src.Aircraft.Model))
                .ForMember(dest => dest.CompanyName, opt => opt.MapFrom(src => src.Company.Name));

            // 🔹 FlightSegmentDto → Flight
            CreateMap<FlightSegmentDto, Flight>()
                .ForMember(dest => dest.DurationMinutes, opt => opt.MapFrom(src => (src.ArrivalTime - src.DepartureTime).TotalMinutes))
                .ForMember(dest => dest.IsEmptyLeg, opt => opt.MapFrom(_ => false))
                .ForMember(dest => dest.IsInternational, opt => opt.Ignore())
                .ForMember(dest => dest.Status, opt => opt.MapFrom(_ => FlightStatus.PreFlight))
                .ForMember(dest => dest.CreatedAt, opt => opt.MapFrom(_ => DateTime.UtcNow))
                .ForMember(dest => dest.UpdatedAt, opt => opt.Ignore())
                .ForMember(dest => dest.Company, opt => opt.Ignore())
                .ForMember(dest => dest.DepartureAirport, opt => opt.Ignore())
                .ForMember(dest => dest.ArrivalAirport, opt => opt.Ignore())
                .ForMember(dest => dest.Reservation, opt => opt.Ignore())
                .ForMember(dest => dest.Charge, opt => opt.Ignore());

            CreateMap<Flight, FlightResponseDto>()
                .ForMember(dest => dest.DepartureAirportName, opt => opt.MapFrom(src => src.DepartureAirport.Name))
                .ForMember(dest => dest.DepartureAirportIATA, opt => opt.MapFrom(src => src.DepartureAirport.CodeIATA))
                .ForMember(dest => dest.DepartureAirportOACI, opt => opt.MapFrom(src => src.DepartureAirport.CodeOACI))
                .ForMember(dest => dest.ArrivalAirportName, opt => opt.MapFrom(src => src.ArrivalAirport.Name))
                .ForMember(dest => dest.ArrivalAirportIATA, opt => opt.MapFrom(src => src.ArrivalAirport.CodeIATA))
                .ForMember(dest => dest.ArrivalAirportOACI, opt => opt.MapFrom(src => src.ArrivalAirport.CodeOACI))
                .ForMember(dest => dest.AircraftModel, opt => opt.MapFrom(src => src.Aircraft.Model))
                .ForMember(dest => dest.AircraftPatent, opt => opt.MapFrom(src => src.Aircraft.Patent))
                .ForMember(dest => dest.CompanyName, opt => opt.MapFrom(src => src.Company.Name))
                .ForMember(dest => dest.ReservationCode, opt => opt.MapFrom(src => src.Reservation != null ? src.Reservation.ReservationCode : null))
                .ForMember(dest => dest.Status, opt => opt.MapFrom(src => src.Status.ToString()))

                // ⭐ NUEVO — si tiene al menos un piloto asignado
                .ForMember(dest => dest.HasAssignedPilots,
                    opt => opt.MapFrom(src =>
                        src.Assignments != null && src.Assignments.Any()))

                // ⭐ NUEVO — cantidad de pilotos asignados
                .ForMember(dest => dest.AssignedPilotCount,
                    opt => opt.MapFrom(src =>
                        src.Assignments != null ? src.Assignments.Count : 0));


            CreateMap<FlightAssignment, FlightPilotDto>()
                .ForMember(dest => dest.PilotId, opt => opt.MapFrom(src => src.PilotUserId))
                .ForMember(dest => dest.PilotName, opt => opt.MapFrom(src => src.PilotUser.Name))
                .ForMember(dest => dest.PilotLastName, opt => opt.MapFrom(src => src.PilotUser.LastName))
                .ForMember(dest => dest.Email, opt => opt.MapFrom(src => src.PilotUser.Email))
                .ForMember(dest => dest.PhoneNumber, opt => opt.MapFrom(src => src.PilotUser.PhoneNumber))
                .ForMember(dest => dest.Status, opt => opt.MapFrom(src => src.Status.ToString()))
                .ForMember(dest => dest.CrewRole, opt => opt.MapFrom(src => src.CrewRole.ToString()));

            // =====================
            // EMPTY LEG LIST DTO
            // =====================
            CreateMap<Flight, EmptyLegListDto>()
                .ForMember(d => d.DepartureAirportName, o => o.MapFrom(s => s.DepartureAirport.Name))
                .ForMember(d => d.DepartureIATA, o => o.MapFrom(s => s.DepartureAirport.CodeIATA))
                .ForMember(d => d.ArrivalAirportName, o => o.MapFrom(s => s.ArrivalAirport.Name))
                .ForMember(d => d.ArrivalIATA, o => o.MapFrom(s => s.ArrivalAirport.CodeIATA))
                .ForMember(d => d.AircraftModel, o => o.MapFrom(s => s.Aircraft.Model))
                .ForMember(d => d.AircraftImage, o => o.MapFrom(s => s.Aircraft.Image))
                .ForMember(d => d.Seats, o => o.MapFrom(s => s.Aircraft.Seats))
                .ForMember(d => d.MaxWeight, o => o.MapFrom(s => s.Aircraft.MaxWeight))
                .ForMember(d => d.FinalPrice, o => o.Ignore()); // Se calcula afuera
            ;

            // =====================
            // EMPTY LEG DETAIL DTO
            // =====================
            CreateMap<Flight, EmptyLegDetailDto>()
                .ForMember(d => d.AircraftModel, o => o.MapFrom(s => s.Aircraft.Model))
                .ForMember(d => d.AircraftPatent, o => o.MapFrom(s => s.Aircraft.Patent))
                .ForMember(d => d.AircraftImage, o => o.MapFrom(s => s.Aircraft.Image))
                .ForMember(d => d.Seats, o => o.MapFrom(s => s.Aircraft.Seats))
                .ForMember(d => d.MaxWeight, o => o.MapFrom(s => s.Aircraft.MaxWeight))
                .ForMember(d => d.MinuteCost, o => o.MapFrom(s => s.Aircraft.MinuteCost))
                .ForMember(d => d.CanFlyInternational, o => o.MapFrom(s => s.Aircraft.CanFlyInternational))

                // Aeropuerto salida
                .ForMember(d => d.DepartureIATA, o => o.MapFrom(s => s.DepartureAirport.CodeIATA))
                .ForMember(d => d.DepartureOACI, o => o.MapFrom(s => s.DepartureAirport.CodeOACI))
                .ForMember(d => d.DepartureAirportName, o => o.MapFrom(s => s.DepartureAirport.Name))
                .ForMember(d => d.DepartureCity, o => o.MapFrom(s => s.DepartureAirport.City))
                .ForMember(d => d.DepartureCountry, o => o.MapFrom(s => s.DepartureAirport.Country))
                .ForMember(d => d.DepartureAirportImage, o => o.MapFrom(s => s.DepartureAirport.Image))

                // Aeropuerto destino
                .ForMember(d => d.ArrivalIATA, o => o.MapFrom(s => s.ArrivalAirport.CodeIATA))
                .ForMember(d => d.ArrivalOACI, o => o.MapFrom(s => s.ArrivalAirport.CodeOACI))
                .ForMember(d => d.ArrivalAirportName, o => o.MapFrom(s => s.ArrivalAirport.Name))
                .ForMember(d => d.ArrivalCity, o => o.MapFrom(s => s.ArrivalAirport.City))
                .ForMember(d => d.ArrivalCountry, o => o.MapFrom(s => s.ArrivalAirport.Country))
                .ForMember(d => d.ArrivalAirportImage, o => o.MapFrom(s => s.ArrivalAirport.Image))

                // Empresa
                .ForMember(d => d.CompanyName, o => o.MapFrom(s => s.Company.Name))
                .ForMember(d => d.CompanyId, o => o.MapFrom(s => s.Company.Id))

                // Valores calculados
                .ForMember(d => d.FinalPrice, o => o.Ignore())
                .ForMember(d => d.EFT, o => o.Ignore());

        }
    }
}
