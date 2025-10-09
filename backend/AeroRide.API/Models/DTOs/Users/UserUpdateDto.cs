using System.ComponentModel.DataAnnotations;

/// <summary>
/// Objeto de transferencia para actualizar los datos personales
/// del usuario autenticado.
/// 
/// Solo permite modificar información básica como nombre o teléfono.
/// </summary>
public class UserUpdateDto
{
    /// <summary>
    /// Nuevo nombre del usuario.
    /// </summary>
    [Required(ErrorMessage = "El nombre es obligatorio.")]
    [StringLength(50, ErrorMessage = "El nombre no debe exceder los 50 caracteres.")]
    public string Name { get; set; } = null!;

    /// <summary>
    /// Nuevo apellido del usuario.
    /// </summary>
    [Required(ErrorMessage = "El apellido es obligatorio.")]
    [StringLength(50, ErrorMessage = "El apellido no debe exceder los 50 caracteres.")]
    public string LastName { get; set; } = null!;

    /// <summary>
    /// Nuevo número de teléfono del usuario.
    /// </summary>
    [Required(ErrorMessage = "El número de teléfono es obligatorio.")]
    [Phone(ErrorMessage = "Debe ingresar un número de teléfono válido.")]
    public string PhoneNumber { get; set; } = null!;
}