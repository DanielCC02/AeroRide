using System.ComponentModel.DataAnnotations;

/// <summary>
/// Data Transfer Object used to update the personal information
/// of the authenticated user.
///
/// It only allows modifying basic information such as name or phone number.
/// </summary>
public class UserUpdateDto
{
    /// <summary>
    /// New first name of the user.
    /// </summary>
    [Required(ErrorMessage = "First name is required.")]
    [StringLength(50, ErrorMessage = "First name must not exceed 50 characters.")]
    public string Name { get; set; } = null!;

    /// <summary>
    /// New last name of the user.
    /// </summary>
    [Required(ErrorMessage = "Last name is required.")]
    [StringLength(50, ErrorMessage = "Last name must not exceed 50 characters.")]
    public string LastName { get; set; } = null!;

    /// <summary>
    /// New phone number of the user.
    /// </summary>
    [Required(ErrorMessage = "Phone number is required.")]
    [Phone(ErrorMessage = "A valid phone number must be provided.")]
    public string PhoneNumber { get; set; } = null!;
}
