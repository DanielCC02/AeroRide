using AeroRide.API.Data;
using AeroRide.API.Interfaces;
using AeroRide.API.Models.Domain;
using AeroRide.API.Models.DTOs.Passengers;
using AeroRide.API.Models.DTOs.Reservations;
using AutoMapper;
using AutoMapper.QueryableExtensions;
using Microsoft.EntityFrameworkCore;

namespace AeroRide.API.Services
{
    /// <summary>
    /// Servicio que implementa la lógica de negocio para la gestión de reservas.
    /// </summary>
    public class ReservationService : IReservationService
    {
        private readonly AeroRideDbContext _db;
        private readonly IMapper _mapper;

        public ReservationService(AeroRideDbContext db, IMapper mapper)
        {
            _db = db;
            _mapper = mapper;
        }

        // ======================================================
        // 🔹 Métodos CRUD (ya existentes)
        // ======================================================

        public async Task<IEnumerable<ReservationResponse>> GetAllAsync()
        {
            return await _db.Reservations
                .Include(r => r.User)
                .Include(r => r.Passengers)
                .Include(r => r.Flights)
                .AsNoTracking()
                .ProjectTo<ReservationResponse>(_mapper.ConfigurationProvider)
                .ToListAsync();
        }

        public async Task<ReservationResponse?> GetByIdAsync(int id)
        {
            var reservation = await _db.Reservations
                .Include(r => r.User)
                .Include(r => r.Passengers)
                .Include(r => r.Flights)
                .FirstOrDefaultAsync(r => r.Id == id);

            return reservation == null
                ? null
                : _mapper.Map<ReservationResponse>(reservation);
        }

        public async Task<IEnumerable<ReservationResponse>> GetByUserAsync(int userId)
        {
            return await _db.Reservations
                .Include(r => r.User)
                .Include(r => r.Passengers)
                .Include(r => r.Flights)
                .Where(r => r.UserId == userId)
                .AsNoTracking()
                .ProjectTo<ReservationResponse>(_mapper.ConfigurationProvider)
                .ToListAsync();
        }

        public async Task<ReservationResponse> CreateAsync(ReservationCreateDto dto)
        {
            var entity = _mapper.Map<Reservation>(dto);
            await _db.Reservations.AddAsync(entity);
            await _db.SaveChangesAsync();



            var created = await _db.Reservations
                .Include(r => r.User)
                .Include(r => r.Passengers)
                .Include(r => r.Flights)
                .FirstOrDefaultAsync(r => r.Id == entity.Id);

            return _mapper.Map<ReservationResponse>(created);
        }

        public async Task<bool> DeleteAsync(int id)
        {
            var reservation = await _db.Reservations.FindAsync(id);
            if (reservation == null)
                return false;

            _db.Reservations.Remove(reservation);
            await _db.SaveChangesAsync();
            return true;
        }

        // ======================================================
        // 🧭 NUEVAS ACCIONES DE NEGOCIO
        // ======================================================

        /// <summary>
        /// Cancela una reserva existente cambiando su estado a "Cancelada".
        /// </summary>
        public async Task<bool> CancelAsync(int id)
        {
            var reservation = await _db.Reservations.FindAsync(id);
            if (reservation == null)
                return false;

            if (reservation.Status == "Cancelada")
                return false;

            reservation.Status = "Cancelada";
            await _db.SaveChangesAsync();
            return true;
        }

        /// <summary>
        /// Confirma una reserva cambiando su estado a "Confirmada".
        /// </summary>
        public async Task<bool> ConfirmAsync(int id)
        {
            var reservation = await _db.Reservations.FindAsync(id);
            if (reservation == null)
                return false;

            if (reservation.Status == "Confirmada")
                return false;

            reservation.Status = "Confirmada";
            await _db.SaveChangesAsync();
            return true;
        }

        /// <summary>
        /// Agrega un nuevo pasajero a una reserva existente.
        /// </summary>
        public async Task<ReservationResponse?> AddPassengerAsync(int reservationId, PassengerCreateDto dto)
        {
            var reservation = await _db.Reservations
                .Include(r => r.Passengers)
                .Include(r => r.Flights)
                .Include(r => r.User)
                .FirstOrDefaultAsync(r => r.Id == reservationId);

            if (reservation == null)
                return null;

            var passenger = _mapper.Map<PassengerDetail>(dto);
            reservation.Passengers.Add(passenger);

            await _db.SaveChangesAsync();
            return _mapper.Map<ReservationResponse>(reservation);
        }

        /// <summary>
        /// Asigna un vuelo existente a una reserva.
        /// </summary>
        public async Task<ReservationResponse?> AssignFlightAsync(int reservationId, int flightId)
        {
            var reservation = await _db.Reservations
                .Include(r => r.Flights)
                .Include(r => r.User)
                .Include(r => r.Passengers)
                .FirstOrDefaultAsync(r => r.Id == reservationId);

            var flight = await _db.Flights.FindAsync(flightId);

            if (reservation == null || flight == null)
                return null;

            reservation.Flights.Add(flight);
            await _db.SaveChangesAsync();

            return _mapper.Map<ReservationResponse>(reservation);
        }
    }
}
