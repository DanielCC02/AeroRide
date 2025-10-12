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
    /// Contiene la lógica de negocio para la gestión de usuarios, incluyendo:
    /// - Consultas generales y por ID.
    /// - Actualización de perfiles.
    /// - Creación manual de usuarios por administradores.
    /// - Desactivación (soft delete) y reactivación de cuentas.
    /// - Actualización de datos por administradores.
    /// </summary>
    public class UserService : IUserService
    {
        private readonly AeroRideDbContext _db;
        private readonly IMapper _mapper;

        /// <summary>
        /// Constructor con inyección de dependencias.
        /// </summary>
        /// <param name="context">Contexto de base de datos de AeroRide.</param>
        /// <param name="mapper">Instancia de AutoMapper para transformar entidades en DTOs.</param>
        public UserService(AeroRideDbContext context, IMapper mapper)
        {
            _db = context;
            _mapper = mapper;
        }

        // ======================================================
        // 1️⃣ Obtener todos los usuarios
        // ======================================================
        /// <summary>
        /// Devuelve una lista con todos los usuarios y su información básica.
        /// </summary>
        /// <returns>
        /// Una colección de objetos <see cref="UserListDto"/> con datos generales de los usuarios registrados.
        /// </returns>
        public async Task<IEnumerable<UserListDto>> GetAllUsersAsync()
        {
            return await _db.Users
                .Include(u => u.Role)
                .IgnoreQueryFilters()
                .ProjectTo<UserListDto>(_mapper.ConfigurationProvider)
                .ToListAsync();
        }

        // ======================================================
        // 2️⃣ Obtener usuario por ID
        // ======================================================
        /// <summary>
        /// Obtiene la información detallada de un usuario específico por su identificador.
        /// </summary>
        /// <param name="id">Identificador único del usuario.</param>
        /// <returns>
        /// Un objeto <see cref="UserDetailDto"/> con información completa del usuario, 
        /// o <c>null</c> si no existe en la base de datos.
        /// </returns>
        public async Task<UserDetailDto?> GetUserByIdAsync(int id)
        {
            var user = await _db.Users
                .Include(u => u.Role)
                .IgnoreQueryFilters()
                .FirstOrDefaultAsync(u => u.Id == id);

            return user == null ? null : _mapper.Map<UserDetailDto>(user);
        }

        // ======================================================
        // 3️⃣ Obtener perfil del usuario autenticado
        // ======================================================
        /// <summary>
        /// Obtiene el perfil del usuario autenticado según su identificador.
        /// </summary>
        /// <param name="userId">Identificador del usuario autenticado (extraído del token JWT).</param>
        /// <returns>
        /// Un objeto <see cref="UserProfileDto"/> con la información del usuario, 
        /// o <c>null</c> si el usuario no existe.
        /// </returns>
        public async Task<UserProfileDto?> GetProfileAsync(int userId)
        {
            var user = await _db.Users
                .Include(u => u.Role)
                .FirstOrDefaultAsync(u => u.Id == userId);

            return user == null ? null : _mapper.Map<UserProfileDto>(user);
        }

        // ======================================================
        // 4️⃣ Crear usuario (solo admin)
        // ======================================================
        /// <summary>
        /// Crea un nuevo usuario en el sistema de manera manual (uso exclusivo de administradores).
        /// </summary>
        /// <param name="dto">Datos del usuario a crear.</param>
        /// <returns>
        /// Objeto <see cref="UserResponseDto"/> con la información del usuario creado.
        /// </returns>
        /// <exception cref="Exception">
        /// Se lanza si el correo ya está registrado o si el rol no existe.
        /// </exception>
        public async Task<UserResponseDto> CreateUserAsync(CreateUserDto dto)
        {
            // Verificar duplicado de correo
            if (await _db.Users.AnyAsync(u => u.Email == dto.Email))
                throw new Exception("El correo ya está registrado.");

            // Verificar que el rol exista
            var role = await _db.Roles.FindAsync(dto.RoleId);
            if (role == null)
                throw new Exception("El rol especificado no existe.");

            // Crear entidad y aplicar hashing de contraseña
            var user = _mapper.Map<User>(dto);
            user.Password = PasswordHelper.HashPassword(dto.Password);

            _db.Users.Add(user);
            await _db.SaveChangesAsync();

            return _mapper.Map<UserResponseDto>(user);
        }

        // ======================================================
        // 5️⃣ Actualizar perfil personal
        // ======================================================
        /// <summary>
        /// Actualiza los datos personales del usuario autenticado.
        /// Solo se modifican los campos permitidos (nombre, apellidos, teléfono, etc.).
        /// </summary>
        /// <param name="userId">Identificador del usuario autenticado.</param>
        /// <param name="dto">Objeto con los datos a actualizar.</param>
        /// <returns>
        /// Un objeto <see cref="UserProfileDto"/> actualizado, 
        /// o <c>null</c> si el usuario no existe.
        /// </returns>
        public async Task<UserProfileDto?> UpdateProfileAsync(int userId, UserUpdateDto dto)
        {
            var user = await _db.Users.Include(u => u.Role).FirstOrDefaultAsync(u => u.Id == userId);

            if (user == null)
                return null;

            _mapper.Map(dto, user);
            await _db.SaveChangesAsync();

            return _mapper.Map<UserProfileDto>(user);
        }

        // ======================================================
        // 6️⃣ Desactivar usuario (soft delete)
        // ======================================================
        /// <summary>
        /// Desactiva un usuario del sistema (soft delete), sin eliminar su registro de la base de datos.
        /// También revoca sus tokens activos.
        /// </summary>
        /// <param name="id">Identificador del usuario a desactivar.</param>
        /// <returns>
        /// <c>true</c> si se desactivó correctamente, 
        /// <c>false</c> si el usuario no se encontró.
        /// </returns>
        public async Task<bool> DeleteUserAsync(int id)
        {
            var user = await _db.Users
                .IgnoreQueryFilters()
                .FirstOrDefaultAsync(u => u.Id == id);

            if (user == null)
                return false;

            if (!user.IsActive)
                return true; // Ya está inactivo

            // 🔹 Marcar como inactivo
            user.IsActive = false;

            // 🔹 Revocar tokens activos
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
        // 7️⃣ Reactivar usuario
        // ======================================================
        /// <summary>
        /// Reactiva un usuario previamente desactivado.
        /// </summary>
        /// <param name="id">Identificador del usuario a reactivar.</param>
        /// <returns>
        /// <c>true</c> si la reactivación fue exitosa, 
        /// <c>false</c> si el usuario no se encontró.
        /// </returns>
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
        // 8️⃣ Actualizar usuario (solo admin)
        // ======================================================
        /// <summary>
        /// Permite a un administrador actualizar los datos de cualquier usuario.
        /// Aplica validaciones sobre el rol y actualiza únicamente los campos enviados.
        /// </summary>
        /// <param name="id">Identificador del usuario a actualizar.</param>
        /// <param name="dto">Objeto con los nuevos datos del usuario.</param>
        /// <returns>
        /// Un objeto <see cref="UserResponseDto"/> actualizado, 
        /// o <c>null</c> si el usuario no existe.
        /// </returns>
        /// <exception cref="Exception">
        /// Se lanza si el rol especificado no existe.
        /// </exception>
        public async Task<UserResponseDto?> UpdateUserByAdminAsync(int id, UserUpdateAdminDto dto)
        {
            var user = await _db.Users
                .IgnoreQueryFilters()
                .Include(u => u.Role)
                .FirstOrDefaultAsync(u => u.Id == id);

            if (user == null)
                return null;

            // Validar rol (si se envió uno nuevo)
            if (dto.RoleId.HasValue)
            {
                var roleExists = await _db.Roles.AnyAsync(r => r.Id == dto.RoleId.Value);
                if (!roleExists)
                    throw new Exception("El rol especificado no existe.");
            }

            _mapper.Map(dto, user);
            await _db.SaveChangesAsync();

            // Recargar la relación con Role
            await _db.Entry(user).Reference(u => u.Role).LoadAsync();

            return _mapper.Map<UserResponseDto>(user);
        }
    }
}
