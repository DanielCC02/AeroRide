using AeroRide.API.Models.Domain;
using AeroRide.API.Models.DTOs.FlightLogs;
using AutoMapper;

namespace AeroRide.API.Mappings
{
    /// <summary>
    /// Mapeos para las bitácoras de vuelo (FlightLog).
    /// </summary>
    public class FlightLogsProfile : Profile
    {
        public FlightLogsProfile()
        {
            // ================================
            // 🔹 FlightLog → FlightLogResponseDto
            // ================================
            CreateMap<FlightLog, FlightLogResponseDto>()
                .ForMember(dest => dest.PilotName,
                    opt => opt.MapFrom(src => src.PilotUser.Name))
                .ForMember(dest => dest.PilotLastName,
                    opt => opt.MapFrom(src => src.PilotUser.LastName));
        }
    }
}
