namespace AeroRide.API.Helpers
{
    /// <summary>
    /// Helper para manejar hashing y verificación de contraseñas.
    /// Encapsula BCrypt para mantener la lógica de seguridad centralizada.
    /// </summary>
    public static class PasswordHelper
    {
        /// <summary>
        /// Hashea una contraseña en texto plano usando BCrypt.
        /// </summary>
        /// <param name="plainPassword">Contraseña en texto plano.</param>
        /// <returns>Contraseña hasheada lista para guardar en la BD.</returns>
        public static string HashPassword(string plainPassword)
        {
            return BCrypt.Net.BCrypt.HashPassword(plainPassword);
        }

        /// <summary>
        /// Verifica si una contraseña en texto plano coincide con su hash.
        /// </summary>
        /// <param name="plainPassword">Contraseña ingresada por el usuario.</param>
        /// <param name="hashedPassword">Contraseña previamente hasheada (guardada en la BD).</param>
        /// <returns>true si coinciden, false si no.</returns>
        public static bool VerifyPassword(string plainPassword, string hashedPassword)
        {
            return BCrypt.Net.BCrypt.Verify(plainPassword, hashedPassword);
        }
    }
}
