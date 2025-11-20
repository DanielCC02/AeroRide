using AeroRide.API.Data;
using AeroRide.API.Helpers;
using AeroRide.API.Models.Domain;
using AeroRide.API.Models.DTOs.FlightLogs;
using AeroRide.API.Services.Interfaces;
using AutoMapper;
using Microsoft.EntityFrameworkCore;


namespace AeroRide.API.Services.Implementations
{
    public class FlightLogService : IFlightLogService
    {
        private readonly AeroRideDbContext _db;
        private readonly BlobStorageService _blob;
        private readonly IMapper _mapper;

        public FlightLogService(AeroRideDbContext db, BlobStorageService blob, IMapper mapper)
        {
            _db = db;
            _blob = blob;
            _mapper = mapper;
        }

        // ===========================================================
        // CREATE LOG
        // ===========================================================
        public async Task<FlightLogResponseDto> CreateLogAsync(FlightLogCreateDto dto)
        {
            // Validar existencia de vuelo
            var flight = await _db.Flights
                .FirstOrDefaultAsync(f => f.Id == dto.FlightId);

            if (flight == null)
                throw new Exception("El vuelo no existe.");

            // Validar piloto
            var pilot = await _db.Users
                .FirstOrDefaultAsync(u => u.Id == dto.PilotUserId);

            if (pilot == null)
                throw new Exception("El piloto no existe.");

            // Subir archivo PDF
            var pdfUrl = await _blob.UploadFileAsync(dto.PdfFile);

            // Crear objeto FlightLog
            var log = new FlightLog
            {
                FlightId = dto.FlightId,
                PilotUserId = dto.PilotUserId,
                PdfUrl = pdfUrl,
                CreatedAt = DateTime.UtcNow
            };

            _db.FlightLogs.Add(log);
            await _db.SaveChangesAsync();

            return new FlightLogResponseDto
            {
                Id = log.Id,
                FlightId = log.FlightId,
                PilotUserId = log.PilotUserId,
                PilotName = pilot.Name,
                PilotLastName = pilot.LastName,
                PdfUrl = log.PdfUrl,
                CreatedAt = log.CreatedAt
            };
        }

        // ===========================================================
        // GET BY FLIGHT
        // ===========================================================
        public async Task<FlightLogResponseDto?> GetLogByFlightAsync(int flightId)
        {
            var log = await _db.FlightLogs
                .Include(l => l.PilotUser)
                .FirstOrDefaultAsync(l => l.FlightId == flightId);

            return log != null ? _mapper.Map<FlightLogResponseDto>(log) : null;
        }
    }
}
