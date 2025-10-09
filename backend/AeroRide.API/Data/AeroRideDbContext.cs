using AeroRide.API.Models.Domain;
using Microsoft.EntityFrameworkCore;

namespace AeroRide.API.Data
{
    /// <summary>
    /// Contexto principal de base de datos para la aplicación AeroRide.
    /// 
    /// Configura entidades, relaciones, restricciones, índices y datos semilla.
    /// Integra PostGIS, manejo de tokens, usuarios, vuelos y bitácoras.
    /// </summary>
    public class AeroRideDbContext : DbContext
    {
        public AeroRideDbContext(DbContextOptions<AeroRideDbContext> options) : base(options) { }

        // ======================================================
        // 🧩 Tablas (DbSet)
        // ======================================================
        public DbSet<User> Users { get; set; } = null!;
        public DbSet<Role> Roles { get; set; } = null!;
        public DbSet<Reservation> Reservations { get; set; } = null!;
        public DbSet<Flight> Flights { get; set; } = null!;
        public DbSet<PassengerDetails> PassengerDetails { get; set; } = null!;
        public DbSet<Aircraft> Aircrafts { get; set; } = null!;
        public DbSet<Airport> Airports { get; set; } = null!;
        public DbSet<FlightLog> FlightLogs { get; set; } = null!;
        public DbSet<FlightAssignment> FlightAssignments { get; set; } = null!;
        public DbSet<RefreshToken> RefreshTokens { get; set; } = null!;
        public DbSet<RevokedToken> RevokedTokens { get; set; } = null!;

        /// <summary>
        /// Configuración de relaciones, índices, constraints y valores por defecto.
        /// </summary>
        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            base.OnModelCreating(modelBuilder);

            // ======================================================
            // 👤 USERS / ROLES
            // ======================================================

            // 🔹 Filtro global: oculta usuarios inactivos (IsActive = false)
            modelBuilder.Entity<User>().HasQueryFilter(u => u.IsActive);

            // 🔹 Relación User -> RefreshTokens (1:N)
            modelBuilder.Entity<RefreshToken>()
                .HasOne(r => r.User)
                .WithMany(u => u.RefreshTokens)
                .HasForeignKey(r => r.UserId)
                .OnDelete(DeleteBehavior.Cascade);

            // 🔹 RefreshToken.Token único
            modelBuilder.Entity<RefreshToken>()
                .HasIndex(r => r.Token)
                .IsUnique();

            // 🔹 User
            modelBuilder.Entity<User>(e =>
            {
                e.ToTable("Users");
                e.HasIndex(u => u.Email).IsUnique();

                e.HasOne(u => u.Role)
                 .WithMany(r => r.Users)
                 .HasForeignKey(u => u.RoleId)
                 .OnDelete(DeleteBehavior.Restrict);
            });

            // 🔹 Role
            modelBuilder.Entity<Role>(e =>
            {
                e.ToTable("Roles");
                e.HasIndex(r => r.Name).IsUnique();
                e.Property(r => r.Name).HasMaxLength(50).IsRequired();
            });

            // 🔹 Seed inicial de roles
            modelBuilder.Entity<Role>().HasData(
                new Role { Id = 1, Name = "Admin" },
                new Role { Id = 2, Name = "Broker" },
                new Role { Id = 3, Name = "Pilot" },
                new Role { Id = 4, Name = "User" }
            );

            // ======================================================
            // 🔐 REVOKED TOKENS
            // ======================================================
            modelBuilder.Entity<RevokedToken>(e =>
            {
                e.ToTable("RevokedTokens");
                e.HasIndex(rt => rt.Token).IsUnique();

                e.HasOne(rt => rt.User)
                 .WithMany()
                 .HasForeignKey(rt => rt.UserId)
                 .OnDelete(DeleteBehavior.Cascade);
            });

            // ======================================================
            // ✈️ RESERVATIONS
            // ======================================================
            modelBuilder.Entity<Reservation>(e =>
            {
                e.ToTable("Reservations");

                e.HasOne(r => r.User)
                 .WithMany(u => u.Reservations)
                 .HasForeignKey(r => r.UserId)
                 .OnDelete(DeleteBehavior.Cascade);

                e.HasMany(r => r.Passengers)
                 .WithOne(p => p.Reservation)
                 .HasForeignKey(p => p.ReservationId)
                 .OnDelete(DeleteBehavior.Cascade);

                e.HasMany(r => r.Flights)
                 .WithOne(f => f.Reservation)
                 .HasForeignKey(f => f.ReservationId)
                 .IsRequired(false)
                 .OnDelete(DeleteBehavior.SetNull);
            });

            // ======================================================
            // 🧍 PASSENGER DETAILS
            // ======================================================
            modelBuilder.Entity<PassengerDetails>(e =>
            {
                e.ToTable("PassengerDetails");

                // 🔹 Convierte el enum GenderType en texto (string) en PostgreSQL
                e.Property(p => p.Gender)
                 .HasConversion<string>()
                 .HasMaxLength(15);
            });

            // ======================================================
            // 🛩️ AIRCRAFTS
            // ======================================================
            modelBuilder.Entity<Aircraft>(e =>
            {
                e.ToTable("Aircrafts");
                // e.Property(a => a.Price).HasColumnType("decimal(18,2)");
            });

            // ======================================================
            // 🌎 AIRPORTS (PostGIS)
            // ======================================================
            modelBuilder.Entity<Airport>(e =>
            {
                e.ToTable("Airports");

                e.HasIndex(a => a.CodeIATA).IsUnique();
                e.HasIndex(a => a.CodeOACI).IsUnique();

                e.Property(a => a.Ubication)
                 .HasColumnType("geometry(Point,4326)");

                e.HasIndex(a => a.Ubication).HasMethod("GIST");
            });

            // ======================================================
            // 🛫 FLIGHTS
            // ======================================================
            modelBuilder.Entity<Flight>(e =>
            {
                e.ToTable("Flights");

                e.HasIndex(f => f.DepartureTime);
                e.HasIndex(f => f.ArrivalTime);

                e.HasOne(f => f.Aircraft)
                 .WithMany(a => a.Flights)
                 .HasForeignKey(f => f.AircraftId)
                 .OnDelete(DeleteBehavior.Restrict);

                e.HasOne(f => f.DepartureAirport)
                 .WithMany(a => a.DepartureFlights)
                 .HasForeignKey(f => f.DepartureAirportId)
                 .OnDelete(DeleteBehavior.Restrict);

                e.HasOne(f => f.ArrivalAirport)
                 .WithMany(a => a.ArrivalFlights)
                 .HasForeignKey(f => f.ArrivalAirportId)
                 .OnDelete(DeleteBehavior.Restrict);

                e.HasMany(f => f.Assignments)
                 .WithOne(fa => fa.Flight)
                 .HasForeignKey(fa => fa.FlightId)
                 .OnDelete(DeleteBehavior.Cascade);
            });

            // ======================================================
            // 👨‍✈️ FLIGHT ASSIGNMENTS
            // ======================================================
            modelBuilder.Entity<FlightAssignment>(e =>
            {
                e.ToTable("FlightAssignments");

                e.HasOne(fa => fa.PilotUser)
                 .WithMany()
                 .HasForeignKey(fa => fa.PilotUserId)
                 .OnDelete(DeleteBehavior.Restrict);

                e.Property(fa => fa.AssignedAt)
                 .HasDefaultValueSql("now()");

                e.Property(fa => fa.Status)
                 .HasConversion<string>()
                 .HasMaxLength(20)
                 .HasDefaultValue(FlightAssignment.AssignmentStatus.Assigned);

                e.HasIndex(fa => new { fa.FlightId, fa.PilotUserId }).IsUnique();
            });

            // ======================================================
            // 📘 FLIGHT LOGS
            // ======================================================
            modelBuilder.Entity<FlightLog>(e =>
            {
                e.ToTable("FlightLogs");

                e.HasOne(fl => fl.User)
                 .WithMany(u => u.FlightLogs)
                 .HasForeignKey(fl => fl.UserId)
                 .OnDelete(DeleteBehavior.Restrict);

                e.HasOne(fl => fl.Flight)
                 .WithMany()
                 .HasForeignKey(fl => fl.FlightId)
                 .OnDelete(DeleteBehavior.Restrict);

                e.HasOne(fl => fl.Reservation)
                 .WithMany()
                 .HasForeignKey(fl => fl.ReservationId)
                 .IsRequired(false)
                 .OnDelete(DeleteBehavior.SetNull);

                e.HasIndex(fl => fl.FlightId);
                e.HasIndex(fl => fl.UserId);
            });
        }
    }
}
