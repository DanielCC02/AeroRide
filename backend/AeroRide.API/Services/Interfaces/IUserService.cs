using AeroRide.API.Models.DTOs.Authorization;
using AeroRide.API.Models.DTOs.Users;

namespace AeroRide.API.Services.Interfaces
{
    /// <summary>
    /// Define la lógica de negocio para las operaciones relacionadas con la gestión de usuarios.
    /// Proporciona métodos para la administración, consulta, actualización y control de estado de los usuarios del sistema.
    /// </summary>
    public interface IUserService
    {
        /// <summary>
        /// Obtiene una lista de todos los usuarios registrados en el sistema.
        /// </summary>
        /// <returns>
        /// Una colección de objetos <see cref="UserListDto"/> con la información básica de los usuarios.
        /// No incluye contraseñas ni datos sensibles.
        /// </returns>
        Task<IEnumerable<UserListDto>> GetAllUsersAsync();

        /// <summary>
        /// Obtiene los detalles completos de un usuario específico según su identificador.
        /// </summary>
        /// <param name="id">Identificador único del usuario.</param>
        /// <returns>
        /// Un objeto <see cref="UserDetailDto"/> con la información completa del usuario, 
        /// o <c>null</c> si no se encuentra en el sistema.
        /// </returns>
        Task<UserDetailDto?> GetUserByIdAsync(int id);

        /// <summary>
        /// Obtiene el perfil del usuario autenticado según su identificador.
        /// </summary>
        /// <param name="userId">Identificador del usuario autenticado.</param>
        /// <returns>
        /// Un objeto <see cref="UserProfileDto"/> con la información del perfil del usuario,
        /// o <c>null</c> si el usuario no existe.
        /// </returns>
        Task<UserProfileDto?> GetProfileAsync(int userId);

        /// <summary>
        /// Crea un nuevo usuario en el sistema (por un administrador).
        /// </summary>
        /// <param name="dto">Datos del nuevo usuario a crear.</param>
        /// <returns>
        /// Un objeto <see cref="UserResponseDto"/> con la información del usuario creado.
        /// </returns>
        /// <exception cref="InvalidOperationException">
        /// Se lanza si el correo electrónico ya está registrado o los datos no son válidos.
        /// </exception>
        Task<UserResponseDto> CreateUserAsync(CreateUserDto dto);

        /// <summary>
        /// Actualiza los datos personales del usuario autenticado.
        /// </summary>
        /// <param name="userId">Identificador del usuario autenticado.</param>
        /// <param name="dto">Datos actualizados del usuario.</param>
        /// <returns>
        /// Un objeto <see cref="UserProfileDto"/> con la información actualizada,
        /// o <c>null</c> si el usuario no existe.
        /// </returns>
        Task<UserProfileDto?> UpdateProfileAsync(int userId, UserUpdateDto dto);

        /// <summary>
        /// Desactiva un usuario del sistema (soft delete).
        /// El usuario no se elimina físicamente de la base de datos.
        /// </summary>
        /// <param name="id">Identificador del usuario a desactivar.</param>
        /// <returns>
        /// <c>true</c> si el usuario fue desactivado correctamente; de lo contrario, <c>false</c>.
        /// </returns>
        Task<bool> DeleteUserAsync(int id);

        /// <summary>
        /// Reactiva un usuario previamente desactivado.
        /// </summary>
        /// <param name="id">Identificador del usuario a reactivar.</param>
        /// <returns>
        /// <c>true</c> si el usuario fue reactivado correctamente; de lo contrario, <c>false</c>.
        /// </returns>
        Task<bool> ReactivateUserAsync(int id);

        /// <summary>
        /// Permite a un administrador actualizar los datos de cualquier usuario.
        /// </summary>
        /// <param name="id">Identificador del usuario a modificar.</param>
        /// <param name="dto">Datos nuevos del usuario.</param>
        /// <returns>
        /// Un objeto <see cref="UserResponseDto"/> con los datos actualizados,
        /// o <c>null</c> si el usuario no se encuentra.
        /// </returns>
        Task<UserProfileDto?> UpdateUserByAdminAsync(int id, UserUpdateAdminDto dto);

        /// <summary>
        /// Obtiene la lista de usuarios que poseen el rol de piloto.
        /// </summary>
        /// <returns>Una colección de usuarios con el rol "Pilot".</returns>
        Task<IEnumerable<UserListDto>> GetAllPilotsAsync();

        /// <summary>
        /// Obtiene todos los pilotos activos pertenecientes a una compañía específica.
        /// </summary>
        /// <param name="companyId">Identificador de la compañía.</param>
        /// <returns>Una lista de pilotos asociados a la compañía indicada.</returns>
        Task<IEnumerable<UserListDto>> GetPilotsByCompanyAsync(int companyId);

        Task<IEnumerable<UserListDto>> GetActivePilotsByCompanyAsync(int companyId);

        /// <summary>
        /// Obtiene todos los usuarios con rol "Pilot" o "CompanyAdmin"
        /// pertenecientes a una compañía específica.
        /// </summary>
        /// <param name="companyId">Identificador de la compañía.</param>
        /// <returns>Lista de usuarios de tipo piloto o admin de esa empresa.</returns>
        Task<IEnumerable<UserListDto>> GetPilotsAndAdminsByCompanyAsync(int companyId);

        /// <summary>
        /// Obtiene todos los administradores pertenecientes a una compañía específica.
        /// Incluye roles como "CompanyAdmin".
        /// </summary>
        /// <param name="companyId">Identificador de la compañía.</param>
        /// <returns>Lista de administradores asociados a la compañía.</returns>
        Task<IEnumerable<UserListDto>> GetAdminsByCompanyAsync(int companyId);

    }
}
