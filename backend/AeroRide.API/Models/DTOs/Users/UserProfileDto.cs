/// <summary>
/// Objeto que representa el perfil del usuario autenticado.
/// Se utiliza para mostrar los datos personales del usuario
/// actualmente logueado en la aplicación.
/// </summary>
public class UserProfileDto
{
    /// <summary>
    /// Identificador del usuario autenticado.
    /// </summary>
    public int Id { get; set; }

    /// <summary>
    /// Nombre del usuario.
    /// </summary>
    public string Name { get; set; } = null!;

    /// <summary>
    /// Apellido del usuario.
    /// </summary>
    public string LastName { get; set; } = null!;

    /// <summary>
    /// Correo electrónico asociado a la cuenta.
    /// </summary>
    public string Email { get; set; } = null!;

    /// <summary>
    /// Número de teléfono del usuario.
    /// </summary>
    public string PhoneNumber { get; set; } = null!;

    /// <summary>
    /// Rol actual asignado al usuario (Admin, Broker, Pilot o User).
    /// </summary>
    public string Role { get; set; } = null!;

    /// <summary>
    /// Compañia actual asignado al usuario (AeroCaribe, etc...).
    /// </summary>
    public string? CompanyName { get; set; }

    /// <summary>
    /// Fecha de registro en la plataforma.
    /// </summary>
    public DateTime RegistrationDate { get; set; }
}