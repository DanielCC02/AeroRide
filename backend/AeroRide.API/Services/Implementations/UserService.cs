using AeroRide.API.Data;
using AeroRide.API.Helpers;
using AeroRide.API.Models.Domain;
using AeroRide.API.Models.DTOs.Authorization;
using AeroRide.API.Models.DTOs.Users;
using AeroRide.API.Services.Interfaces;
using AutoMapper;
using AutoMapper.QueryableExtensions;
using Microsoft.EntityFrameworkCore;

namespace AeroRide.API.Services.Implementations
{
    /// <summary>
    /// Implementación concreta del servicio de usuarios (<see cref="IUserService"/>).
    /// Contiene la lógica de negocio para la gestión de usuarios:
    /// creación, actualización, perfil, desactivación, reactivación y filtrado.
    /// </summary>
    public class UserService : IUserService
    {
        private readonly AeroRideDbContext _db;
        private readonly IMapper _mapper;

        public UserService(AeroRideDbContext db, IMapper mapper)
        {
            _db = db;
            _mapper = mapper;
        }

        // ======================================================
        // 1️⃣ CREAR USUARIO (solo admin)
        // ======================================================
        public async Task<UserResponseDto> CreateUserAsync(CreateUserDto dto)
        {
            if (await _db.Users.AnyAsync(u => u.Email == dto.Email))
                throw new Exception("El correo ya está registrado.");

            var role = await _db.Roles.FindAsync(dto.RoleId);
            if (role == null)
                throw new Exception("El rol especificado no existe.");

            var user = _mapper.Map<User>(dto);
            user.Password = PasswordHelper.HashPassword(dto.Password);

            _db.Users.Add(user);
            await _db.SaveChangesAsync();

            // 🔹 Cargar relaciones manualmente después de guardar
            await _db.Entry(user).Reference(u => u.Role).LoadAsync();
            await _db.Entry(user).Reference(u => u.Company).LoadAsync();

            return _mapper.Map<UserResponseDto>(user);
        }

        // ======================================================
        // 2️⃣ OBTENER TODOS LOS USUARIOS
        // ======================================================
        public async Task<IEnumerable<UserListDto>> GetAllUsersAsync()
        {
            return await _db.Users
                .Include(u => u.Role)
                .Include(u => u.Company)
                .OrderBy(u => u.Id)
                .ProjectTo<UserListDto>(_mapper.ConfigurationProvider)
                .ToListAsync();
        }

        // ======================================================
        // 3️⃣ OBTENER USUARIO POR ID
        // ======================================================
        public async Task<UserDetailDto?> GetUserByIdAsync(int id)
        {
            var user = await _db.Users
                .Include(u => u.Role)
                .Include(u => u.Company)
                .FirstOrDefaultAsync(u => u.Id == id);

            return user == null ? null : _mapper.Map<UserDetailDto>(user);
        }

        // ======================================================
        // 4️⃣ OBTENER PERFIL AUTENTICADO
        // ======================================================
        public async Task<UserProfileDto?> GetProfileAsync(int userId)
        {
            var user = await _db.Users
                .Include(u => u.Role)
                .Include(u => u.Company)
                .FirstOrDefaultAsync(u => u.Id == userId);

            return user == null ? null : _mapper.Map<UserProfileDto>(user);
        }

        // ======================================================
        // 5️⃣ ACTUALIZAR PERFIL PERSONAL
        // ======================================================
        public async Task<UserProfileDto?> UpdateProfileAsync(int userId, UserUpdateDto dto)
        {
            var user = await _db.Users
                .Include(u => u.Role)
                .Include(u => u.Company)
                .FirstOrDefaultAsync(u => u.Id == userId);

            if (user == null)
                return null;

            _mapper.Map(dto, user);
            await _db.SaveChangesAsync();

            return _mapper.Map<UserProfileDto>(user);
        }

        // ======================================================
        // 6️⃣ DESACTIVAR USUARIO (Soft Delete)
        // ======================================================
        public async Task<bool> DeleteUserAsync(int id)
        {
            var user = await _db.Users
                .IgnoreQueryFilters()
                .FirstOrDefaultAsync(u => u.Id == id);

            if (user == null)
                return false;

            if (!user.IsActive)
                return true; // Ya estaba inactivo

            user.IsActive = false;

            // Revocar tokens activos
            var tokens = await _db.RefreshTokens
                .Where(t => t.UserId == id && !t.IsRevoked)
                .ToListAsync();

            foreach (var token in tokens)
            {
                token.IsRevoked = true;
                _db.RevokedTokens.Add(new RevokedToken
                {
                    Token = token.Token,
                    UserId = id
                });
            }

            await _db.SaveChangesAsync();
            return true;
        }

        // ======================================================
        // 7️⃣ REACTIVAR USUARIO
        // ======================================================
        public async Task<bool> ReactivateUserAsync(int id)
        {
            var user = await _db.Users
                .IgnoreQueryFilters()
                .FirstOrDefaultAsync(u => u.Id == id);

            if (user == null)
                return false;

            user.IsActive = true;
            await _db.SaveChangesAsync();
            return true;
        }

        // ======================================================
        // 8️⃣ ACTUALIZAR USUARIO (por admin)
        // ======================================================
        public async Task<UserProfileDto?> UpdateUserByAdminAsync(int id, UserUpdateAdminDto dto)
        {
            var user = await _db.Users
                .Include(u => u.Role)
                .Include(u => u.Company)
                .FirstOrDefaultAsync(u => u.Id == id);

            if (user == null)
                return null;

            if (dto.RoleId.HasValue)
            {
                bool roleExists = await _db.Roles.AnyAsync(r => r.Id == dto.RoleId.Value);
                if (!roleExists)
                    throw new Exception("El rol especificado no existe.");
            }

            _mapper.Map(dto, user);
            await _db.SaveChangesAsync();

            await _db.Entry(user).Reference(u => u.Role).LoadAsync();
            await _db.Entry(user).Reference(u => u.Company).LoadAsync();

            return _mapper.Map<UserProfileDto>(user);
        }

        // ======================================================
        // 9️⃣ LISTAR PILOTOS
        // ======================================================
        public async Task<IEnumerable<UserListDto>> GetAllPilotsAsync()
        {
            var pilots = await _db.Users
                .Include(u => u.Role)
                .Include(u => u.Company)
                .Where(u => u.IsActive && u.Role.Name == "Pilot")
                .OrderBy(u => u.Id)
                .AsNoTracking()
                .ToListAsync();

            return _mapper.Map<IEnumerable<UserListDto>>(pilots);
        }

        // ======================================================
        // 🔟 LISTAR PILOTOS DE UNA COMPAÑÍA ESPECÍFICA
        // ======================================================
        public async Task<IEnumerable<UserListDto>> GetPilotsByCompanyAsync(int companyId)
        {
            var pilots = await _db.Users
                .Include(u => u.Role)
                .Include(u => u.Company)
                .Where(u => u.IsActive &&
                            u.Role.Name == "Pilot" &&
                            u.CompanyId == companyId)
                .OrderBy(u => u.Id)
                .AsNoTracking()
                .ToListAsync();

            return _mapper.Map<IEnumerable<UserListDto>>(pilots);
        }

        // ======================================================
        // 🔟 LISTAR PILOTOS Y ADMINS DE UNA COMPAÑÍA
        // ======================================================
        public async Task<IEnumerable<UserListDto>> GetPilotsAndAdminsByCompanyAsync(int companyId)
        {
            var users = await _db.Users
                .Include(u => u.Role)
                .Include(u => u.Company)
                .Where(u => u.IsActive &&
                            u.CompanyId == companyId &&
                            (u.Role.Name == "Pilot" || u.Role.Name == "CompanyAdmin"))
                .OrderBy(u => u.Id)
                .AsNoTracking()
                .ToListAsync();

            return _mapper.Map<IEnumerable<UserListDto>>(users);
        }

        // ======================================================
        // 🔟 LISTAR SOLO ADMINISTRADORES DE UNA COMPAÑÍA
        // ======================================================
        public async Task<IEnumerable<UserListDto>> GetAdminsByCompanyAsync(int companyId)
        {
            var admins = await _db.Users
                .Include(u => u.Role)
                .Include(u => u.Company)
                .Where(u => u.IsActive && u.CompanyId == companyId && u.Role.Name == "CompanyAdmin")
                .OrderBy(u => u.Id)
                .AsNoTracking()
                .ToListAsync();

            return _mapper.Map<IEnumerable<UserListDto>>(admins);
        }

    }
}
