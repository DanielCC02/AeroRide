namespace AeroRide.API.Models.Domain
{
    /// <summary>
    /// Entity that represents a JWT token that has been manually invalidated.
    ///
    /// It is used as a security record to prevent the reuse of revoked tokens,
    /// for example in cases of logout, credential changes,
    /// or user suspension.
    /// </summary>
    public class RevokedToken
    {
        /// <summary>
        /// Unique identifier of the revoked token record.
        /// </summary>
        public int Id { get; set; }

        /// <summary>
        /// JWT token that was revoked and invalidated.
        /// </summary>
        public string Token { get; set; } = null!;

        /// <summary>
        /// Identifier of the user to whom the revoked token belonged.
        /// </summary>
        public int UserId { get; set; }

        /// <summary>
        /// UTC date and time when the token was revoked.
        /// Stored in UTC to ensure temporal consistency.
        /// </summary>
        public DateTime RevokedAt { get; set; } = DateTime.UtcNow;

        /// <summary>
        /// Reference to the user who owned the revoked token.
        /// </summary>
        public User User { get; set; } = null!;
    }
}
