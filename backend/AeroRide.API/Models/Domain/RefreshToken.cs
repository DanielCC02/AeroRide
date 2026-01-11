namespace AeroRide.API.Models.Domain
{
    /// <summary>
    /// Entity that represents a Refresh Token issued to a user.
    ///
    /// Its purpose is to allow secure renewal of the access token (JWT)
    /// without requiring the user to re-authenticate with their credentials.
    ///
    /// Each user may have multiple active Refresh Tokens, typically associated
    /// with different devices or sessions.
    /// </summary>
    public class RefreshToken
    {
        /// <summary>
        /// Unique identifier of the Refresh Token within the system.
        /// </summary>
        public int Id { get; set; }

        /// <summary>
        /// Unique random string that represents the refresh token provided to the client.
        /// It is generated using <see cref="Guid.NewGuid()"/> or another cryptographically secure method.
        /// </summary>
        public string Token { get; set; } = null!;

        /// <summary>
        /// Date and time when the Refresh Token expires.
        /// Once expired, it can no longer be used to generate new JWTs.
        /// </summary>
        public DateTime Expiration { get; set; }

        /// <summary>
        /// Indicates whether the token has been manually revoked
        /// (for example, during logout or session invalidation).
        /// </summary>
        public bool IsRevoked { get; set; } = false;

        /// <summary>
        /// Identifier of the user who owns this Refresh Token.
        /// </summary>
        public int UserId { get; set; }

        /// <summary>
        /// Reference to the user associated with this Refresh Token.
        /// Represents a many-to-one (<c>N:1</c>) relationship with the <see cref="User"/> entity.
        /// </summary>
        public User User { get; set; } = null!;
    }
}
