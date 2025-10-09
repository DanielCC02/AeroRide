/// <summary>
/// DTO utilizado por los administradores para modificar
/// la información de un usuario existente.
/// Permite cambiar nombre, teléfono, rol o estado activo.
/// </summary>
public class UserUpdateAdminDto
{
    /// <summary>Nuevo nombre del usuario (opcional).</summary>
    public string? Name { get; set; }

    /// <summary>Nuevo apellido del usuario (opcional).</summary>
    public string? LastName { get; set; }

    /// <summary>Nuevo número de teléfono del usuario (opcional).</summary>
    public string? PhoneNumber { get; set; }

    /// <summary>
    /// Identificador del nuevo rol asignado (opcional).
    /// </summary>
    public int? RoleId { get; set; }

    /// <summary>
    /// Indica si el usuario debe estar activo o desactivado.
    /// Permite control administrativo directo sobre el estado.
    /// </summary>
    public bool? IsActive { get; set; }
}