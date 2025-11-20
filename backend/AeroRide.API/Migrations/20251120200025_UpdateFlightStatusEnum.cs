using System;
using Microsoft.EntityFrameworkCore.Migrations;
using NetTopologySuite.Geometries;
using Npgsql.EntityFrameworkCore.PostgreSQL.Metadata;

#nullable disable

#pragma warning disable CA1814 // Prefer jagged arrays over multidimensional

namespace AeroRide.API.Migrations
{
    /// <inheritdoc />
    public partial class UpdateFlightStatusEnum : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AlterDatabase()
                .Annotation("Npgsql:PostgresExtension:postgis", ",,");

            migrationBuilder.CreateTable(
                name: "Airports",
                columns: table => new
                {
                    Id = table.Column<int>(type: "integer", nullable: false)
                        .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityByDefaultColumn),
                    Name = table.Column<string>(type: "text", nullable: false),
                    CodeIATA = table.Column<string>(type: "text", nullable: false),
                    CodeOACI = table.Column<string>(type: "text", nullable: false),
                    City = table.Column<string>(type: "text", nullable: false),
                    Country = table.Column<string>(type: "text", nullable: false),
                    TimeZone = table.Column<string>(type: "text", nullable: false),
                    OpeningTime = table.Column<TimeSpan>(type: "interval", nullable: true),
                    ClosingTime = table.Column<TimeSpan>(type: "interval", nullable: true),
                    Latitude = table.Column<decimal>(type: "numeric", nullable: false),
                    Longitude = table.Column<decimal>(type: "numeric", nullable: false),
                    Ubication = table.Column<Point>(type: "geometry(Point,4326)", nullable: false),
                    Image = table.Column<string>(type: "text", nullable: false),
                    MaxAllowedWeight = table.Column<int>(type: "integer", nullable: false),
                    IsActive = table.Column<bool>(type: "boolean", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Airports", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "Companies",
                columns: table => new
                {
                    Id = table.Column<int>(type: "integer", nullable: false)
                        .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityByDefaultColumn),
                    Name = table.Column<string>(type: "text", nullable: false),
                    Email = table.Column<string>(type: "text", nullable: true),
                    PhoneNumber = table.Column<string>(type: "text", nullable: true),
                    Address = table.Column<string>(type: "text", nullable: true),
                    EmptyLegDiscount = table.Column<double>(type: "double precision", nullable: false),
                    IsActive = table.Column<bool>(type: "boolean", nullable: false),
                    CreatedAt = table.Column<DateTime>(type: "timestamp without time zone", nullable: false),
                    DomesticWaitHourCost = table.Column<double>(type: "double precision", nullable: false),
                    InternationalWaitHourCost = table.Column<double>(type: "double precision", nullable: false),
                    DomesticOvernightCost = table.Column<double>(type: "double precision", nullable: false),
                    InternationalOvernightCost = table.Column<double>(type: "double precision", nullable: false),
                    AirportTaxPerPassenger = table.Column<double>(type: "double precision", nullable: false),
                    HandlingPerPassenger = table.Column<double>(type: "double precision", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Companies", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "Roles",
                columns: table => new
                {
                    Id = table.Column<int>(type: "integer", nullable: false)
                        .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityByDefaultColumn),
                    Name = table.Column<string>(type: "character varying(50)", maxLength: 50, nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Roles", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "Aircrafts",
                columns: table => new
                {
                    Id = table.Column<int>(type: "integer", nullable: false)
                        .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityByDefaultColumn),
                    Patent = table.Column<string>(type: "text", nullable: false),
                    Model = table.Column<string>(type: "text", nullable: false),
                    MinuteCost = table.Column<double>(type: "double precision", nullable: false),
                    Seats = table.Column<int>(type: "integer", nullable: false),
                    MaxWeight = table.Column<int>(type: "integer", nullable: false),
                    CruisingSpeed = table.Column<double>(type: "double precision", nullable: false),
                    CanFlyInternational = table.Column<bool>(type: "boolean", nullable: false),
                    State = table.Column<string>(type: "text", nullable: false),
                    StatusLastUpdated = table.Column<DateTime>(type: "timestamp without time zone", nullable: false),
                    Image = table.Column<string>(type: "text", nullable: false),
                    IsActive = table.Column<bool>(type: "boolean", nullable: false),
                    EmptyWeight = table.Column<int>(type: "integer", nullable: false),
                    BaseAirportId = table.Column<int>(type: "integer", nullable: false),
                    CurrentAirportId = table.Column<int>(type: "integer", nullable: true),
                    CompanyId = table.Column<int>(type: "integer", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Aircrafts", x => x.Id);
                    table.ForeignKey(
                        name: "FK_Aircrafts_Airports_BaseAirportId",
                        column: x => x.BaseAirportId,
                        principalTable: "Airports",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_Aircrafts_Airports_CurrentAirportId",
                        column: x => x.CurrentAirportId,
                        principalTable: "Airports",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_Aircrafts_Companies_CompanyId",
                        column: x => x.CompanyId,
                        principalTable: "Companies",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "CompanyBases",
                columns: table => new
                {
                    Id = table.Column<int>(type: "integer", nullable: false)
                        .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityByDefaultColumn),
                    CompanyId = table.Column<int>(type: "integer", nullable: false),
                    AirportId = table.Column<int>(type: "integer", nullable: false),
                    IsPrimary = table.Column<bool>(type: "boolean", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_CompanyBases", x => x.Id);
                    table.ForeignKey(
                        name: "FK_CompanyBases_Airports_AirportId",
                        column: x => x.AirportId,
                        principalTable: "Airports",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_CompanyBases_Companies_CompanyId",
                        column: x => x.CompanyId,
                        principalTable: "Companies",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "Users",
                columns: table => new
                {
                    Id = table.Column<int>(type: "integer", nullable: false)
                        .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityByDefaultColumn),
                    Name = table.Column<string>(type: "text", nullable: false),
                    LastName = table.Column<string>(type: "text", nullable: false),
                    Email = table.Column<string>(type: "text", nullable: false),
                    Password = table.Column<string>(type: "text", nullable: false),
                    PhoneNumber = table.Column<string>(type: "text", nullable: false),
                    RegistrationDate = table.Column<DateTime>(type: "timestamp without time zone", nullable: false),
                    TermsOfUse = table.Column<bool>(type: "boolean", nullable: false),
                    PrivacyNotice = table.Column<bool>(type: "boolean", nullable: false),
                    RoleId = table.Column<int>(type: "integer", nullable: true),
                    EmailVerificationToken = table.Column<string>(type: "text", nullable: true),
                    IsVerified = table.Column<bool>(type: "boolean", nullable: false),
                    PasswordResetToken = table.Column<string>(type: "text", nullable: true),
                    PasswordResetTokenExpires = table.Column<DateTime>(type: "timestamp without time zone", nullable: true),
                    IsActive = table.Column<bool>(type: "boolean", nullable: false),
                    CompanyId = table.Column<int>(type: "integer", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Users", x => x.Id);
                    table.ForeignKey(
                        name: "FK_Users_Companies_CompanyId",
                        column: x => x.CompanyId,
                        principalTable: "Companies",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.SetNull);
                    table.ForeignKey(
                        name: "FK_Users_Roles_RoleId",
                        column: x => x.RoleId,
                        principalTable: "Roles",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateTable(
                name: "RefreshTokens",
                columns: table => new
                {
                    Id = table.Column<int>(type: "integer", nullable: false)
                        .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityByDefaultColumn),
                    Token = table.Column<string>(type: "text", nullable: false),
                    Expiration = table.Column<DateTime>(type: "timestamp without time zone", nullable: false),
                    IsRevoked = table.Column<bool>(type: "boolean", nullable: false),
                    UserId = table.Column<int>(type: "integer", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_RefreshTokens", x => x.Id);
                    table.ForeignKey(
                        name: "FK_RefreshTokens_Users_UserId",
                        column: x => x.UserId,
                        principalTable: "Users",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "Reservations",
                columns: table => new
                {
                    Id = table.Column<int>(type: "integer", nullable: false)
                        .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityByDefaultColumn),
                    ReservationCode = table.Column<string>(type: "text", nullable: false),
                    UserId = table.Column<int>(type: "integer", nullable: false),
                    CompanyId = table.Column<int>(type: "integer", nullable: false),
                    PorcentPrice = table.Column<double>(type: "double precision", nullable: false),
                    TotalPrice = table.Column<double>(type: "double precision", nullable: false),
                    IsRoundTrip = table.Column<bool>(type: "boolean", nullable: false),
                    LapChild = table.Column<bool>(type: "boolean", nullable: false),
                    AssistanceAnimal = table.Column<bool>(type: "boolean", nullable: false),
                    Status = table.Column<string>(type: "text", nullable: false),
                    Notes = table.Column<string>(type: "text", nullable: true),
                    CreatedAt = table.Column<DateTime>(type: "timestamp without time zone", nullable: false),
                    UpdatedAt = table.Column<DateTime>(type: "timestamp without time zone", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Reservations", x => x.Id);
                    table.ForeignKey(
                        name: "FK_Reservations_Companies_CompanyId",
                        column: x => x.CompanyId,
                        principalTable: "Companies",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_Reservations_Users_UserId",
                        column: x => x.UserId,
                        principalTable: "Users",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "RevokedTokens",
                columns: table => new
                {
                    Id = table.Column<int>(type: "integer", nullable: false)
                        .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityByDefaultColumn),
                    Token = table.Column<string>(type: "text", nullable: false),
                    UserId = table.Column<int>(type: "integer", nullable: false),
                    RevokedAt = table.Column<DateTime>(type: "timestamp without time zone", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_RevokedTokens", x => x.Id);
                    table.ForeignKey(
                        name: "FK_RevokedTokens_Users_UserId",
                        column: x => x.UserId,
                        principalTable: "Users",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "AircraftAvailabilities",
                columns: table => new
                {
                    Id = table.Column<int>(type: "integer", nullable: false)
                        .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityByDefaultColumn),
                    AircraftId = table.Column<int>(type: "integer", nullable: false),
                    StartTime = table.Column<DateTime>(type: "timestamp without time zone", nullable: false),
                    EndTime = table.Column<DateTime>(type: "timestamp without time zone", nullable: false),
                    Type = table.Column<string>(type: "text", nullable: false),
                    ReservationId = table.Column<int>(type: "integer", nullable: true),
                    Status = table.Column<string>(type: "text", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_AircraftAvailabilities", x => x.Id);
                    table.ForeignKey(
                        name: "FK_AircraftAvailabilities_Aircrafts_AircraftId",
                        column: x => x.AircraftId,
                        principalTable: "Aircrafts",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_AircraftAvailabilities_Reservations_ReservationId",
                        column: x => x.ReservationId,
                        principalTable: "Reservations",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.SetNull);
                });

            migrationBuilder.CreateTable(
                name: "Flights",
                columns: table => new
                {
                    Id = table.Column<int>(type: "integer", nullable: false)
                        .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityByDefaultColumn),
                    DepartureTime = table.Column<DateTime>(type: "timestamp without time zone", nullable: false),
                    ArrivalTime = table.Column<DateTime>(type: "timestamp without time zone", nullable: false),
                    DurationMinutes = table.Column<double>(type: "double precision", nullable: false),
                    IsEmptyLeg = table.Column<bool>(type: "boolean", nullable: false),
                    IsInternational = table.Column<bool>(type: "boolean", nullable: false),
                    Status = table.Column<string>(type: "text", nullable: false),
                    CreatedAt = table.Column<DateTime>(type: "timestamp without time zone", nullable: false),
                    UpdatedAt = table.Column<DateTime>(type: "timestamp without time zone", nullable: true),
                    ReservationId = table.Column<int>(type: "integer", nullable: true),
                    AircraftId = table.Column<int>(type: "integer", nullable: false),
                    DepartureAirportId = table.Column<int>(type: "integer", nullable: false),
                    ArrivalAirportId = table.Column<int>(type: "integer", nullable: false),
                    CompanyId = table.Column<int>(type: "integer", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Flights", x => x.Id);
                    table.ForeignKey(
                        name: "FK_Flights_Aircrafts_AircraftId",
                        column: x => x.AircraftId,
                        principalTable: "Aircrafts",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_Flights_Airports_ArrivalAirportId",
                        column: x => x.ArrivalAirportId,
                        principalTable: "Airports",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_Flights_Airports_DepartureAirportId",
                        column: x => x.DepartureAirportId,
                        principalTable: "Airports",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_Flights_Companies_CompanyId",
                        column: x => x.CompanyId,
                        principalTable: "Companies",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_Flights_Reservations_ReservationId",
                        column: x => x.ReservationId,
                        principalTable: "Reservations",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.SetNull);
                });

            migrationBuilder.CreateTable(
                name: "PassengerDetails",
                columns: table => new
                {
                    Id = table.Column<int>(type: "integer", nullable: false)
                        .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityByDefaultColumn),
                    Name = table.Column<string>(type: "text", nullable: false),
                    MiddleName = table.Column<string>(type: "text", nullable: true),
                    LastName = table.Column<string>(type: "text", nullable: false),
                    Passport = table.Column<string>(type: "text", nullable: false),
                    Nationality = table.Column<string>(type: "text", nullable: false),
                    DateOfBirth = table.Column<DateTime>(type: "timestamp without time zone", nullable: false),
                    Gender = table.Column<string>(type: "character varying(15)", maxLength: 15, nullable: false),
                    ReservationId = table.Column<int>(type: "integer", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_PassengerDetails", x => x.Id);
                    table.ForeignKey(
                        name: "FK_PassengerDetails_Reservations_ReservationId",
                        column: x => x.ReservationId,
                        principalTable: "Reservations",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "FlightAssignments",
                columns: table => new
                {
                    Id = table.Column<int>(type: "integer", nullable: false)
                        .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityByDefaultColumn),
                    FlightId = table.Column<int>(type: "integer", nullable: false),
                    PilotUserId = table.Column<int>(type: "integer", nullable: false),
                    AssignedAt = table.Column<DateTime>(type: "timestamp without time zone", nullable: false, defaultValueSql: "now()"),
                    Status = table.Column<string>(type: "character varying(20)", maxLength: 20, nullable: false, defaultValue: "Assigned"),
                    CrewRole = table.Column<string>(type: "text", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_FlightAssignments", x => x.Id);
                    table.ForeignKey(
                        name: "FK_FlightAssignments_Flights_FlightId",
                        column: x => x.FlightId,
                        principalTable: "Flights",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_FlightAssignments_Users_PilotUserId",
                        column: x => x.PilotUserId,
                        principalTable: "Users",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateTable(
                name: "FlightCharges",
                columns: table => new
                {
                    Id = table.Column<int>(type: "integer", nullable: false)
                        .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityByDefaultColumn),
                    BaseCost = table.Column<double>(type: "double precision", nullable: false),
                    TaxesAndFees = table.Column<double>(type: "double precision", nullable: false),
                    DiscountApplied = table.Column<double>(type: "double precision", nullable: false),
                    TotalCharge = table.Column<double>(type: "double precision", nullable: false),
                    CalculatedAt = table.Column<DateTime>(type: "timestamp without time zone", nullable: false),
                    FlightId = table.Column<int>(type: "integer", nullable: false),
                    CompanyId = table.Column<int>(type: "integer", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_FlightCharges", x => x.Id);
                    table.ForeignKey(
                        name: "FK_FlightCharges_Companies_CompanyId",
                        column: x => x.CompanyId,
                        principalTable: "Companies",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_FlightCharges_Flights_FlightId",
                        column: x => x.FlightId,
                        principalTable: "Flights",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "FlightLogs",
                columns: table => new
                {
                    Id = table.Column<int>(type: "integer", nullable: false)
                        .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityByDefaultColumn),
                    FlightId = table.Column<int>(type: "integer", nullable: false),
                    PilotUserId = table.Column<int>(type: "integer", nullable: false),
                    PdfUrl = table.Column<string>(type: "character varying(500)", maxLength: 500, nullable: false),
                    CreatedAt = table.Column<DateTime>(type: "timestamp without time zone", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_FlightLogs", x => x.Id);
                    table.ForeignKey(
                        name: "FK_FlightLogs_Flights_FlightId",
                        column: x => x.FlightId,
                        principalTable: "Flights",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_FlightLogs_Users_PilotUserId",
                        column: x => x.PilotUserId,
                        principalTable: "Users",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.InsertData(
                table: "Roles",
                columns: new[] { "Id", "Name" },
                values: new object[,]
                {
                    { 1, "Admin" },
                    { 2, "CompanyAdmin" },
                    { 3, "Pilot" },
                    { 4, "User" }
                });

            migrationBuilder.CreateIndex(
                name: "IX_AircraftAvailabilities_AircraftId_StartTime_EndTime",
                table: "AircraftAvailabilities",
                columns: new[] { "AircraftId", "StartTime", "EndTime" });

            migrationBuilder.CreateIndex(
                name: "IX_AircraftAvailabilities_ReservationId",
                table: "AircraftAvailabilities",
                column: "ReservationId");

            migrationBuilder.CreateIndex(
                name: "IX_Aircrafts_BaseAirportId",
                table: "Aircrafts",
                column: "BaseAirportId");

            migrationBuilder.CreateIndex(
                name: "IX_Aircrafts_CompanyId",
                table: "Aircrafts",
                column: "CompanyId");

            migrationBuilder.CreateIndex(
                name: "IX_Aircrafts_CurrentAirportId",
                table: "Aircrafts",
                column: "CurrentAirportId");

            migrationBuilder.CreateIndex(
                name: "IX_Airports_CodeIATA",
                table: "Airports",
                column: "CodeIATA",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_Airports_CodeOACI",
                table: "Airports",
                column: "CodeOACI",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_Airports_Ubication",
                table: "Airports",
                column: "Ubication")
                .Annotation("Npgsql:IndexMethod", "GIST");

            migrationBuilder.CreateIndex(
                name: "IX_CompanyBases_AirportId",
                table: "CompanyBases",
                column: "AirportId");

            migrationBuilder.CreateIndex(
                name: "IX_CompanyBases_CompanyId",
                table: "CompanyBases",
                column: "CompanyId");

            migrationBuilder.CreateIndex(
                name: "IX_FlightAssignments_FlightId_PilotUserId",
                table: "FlightAssignments",
                columns: new[] { "FlightId", "PilotUserId" },
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_FlightAssignments_PilotUserId",
                table: "FlightAssignments",
                column: "PilotUserId");

            migrationBuilder.CreateIndex(
                name: "IX_FlightCharges_CompanyId",
                table: "FlightCharges",
                column: "CompanyId");

            migrationBuilder.CreateIndex(
                name: "IX_FlightCharges_FlightId",
                table: "FlightCharges",
                column: "FlightId",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_FlightLogs_FlightId",
                table: "FlightLogs",
                column: "FlightId");

            migrationBuilder.CreateIndex(
                name: "IX_FlightLogs_PilotUserId",
                table: "FlightLogs",
                column: "PilotUserId");

            migrationBuilder.CreateIndex(
                name: "IX_Flights_AircraftId",
                table: "Flights",
                column: "AircraftId");

            migrationBuilder.CreateIndex(
                name: "IX_Flights_ArrivalAirportId",
                table: "Flights",
                column: "ArrivalAirportId");

            migrationBuilder.CreateIndex(
                name: "IX_Flights_ArrivalTime",
                table: "Flights",
                column: "ArrivalTime");

            migrationBuilder.CreateIndex(
                name: "IX_Flights_CompanyId",
                table: "Flights",
                column: "CompanyId");

            migrationBuilder.CreateIndex(
                name: "IX_Flights_DepartureAirportId",
                table: "Flights",
                column: "DepartureAirportId");

            migrationBuilder.CreateIndex(
                name: "IX_Flights_DepartureTime",
                table: "Flights",
                column: "DepartureTime");

            migrationBuilder.CreateIndex(
                name: "IX_Flights_ReservationId",
                table: "Flights",
                column: "ReservationId");

            migrationBuilder.CreateIndex(
                name: "IX_PassengerDetails_ReservationId",
                table: "PassengerDetails",
                column: "ReservationId");

            migrationBuilder.CreateIndex(
                name: "IX_RefreshTokens_Token",
                table: "RefreshTokens",
                column: "Token",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_RefreshTokens_UserId",
                table: "RefreshTokens",
                column: "UserId");

            migrationBuilder.CreateIndex(
                name: "IX_Reservations_CompanyId",
                table: "Reservations",
                column: "CompanyId");

            migrationBuilder.CreateIndex(
                name: "IX_Reservations_UserId",
                table: "Reservations",
                column: "UserId");

            migrationBuilder.CreateIndex(
                name: "IX_RevokedTokens_Token",
                table: "RevokedTokens",
                column: "Token",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_RevokedTokens_UserId",
                table: "RevokedTokens",
                column: "UserId");

            migrationBuilder.CreateIndex(
                name: "IX_Roles_Name",
                table: "Roles",
                column: "Name",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_Users_CompanyId",
                table: "Users",
                column: "CompanyId");

            migrationBuilder.CreateIndex(
                name: "IX_Users_Email",
                table: "Users",
                column: "Email",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_Users_RoleId",
                table: "Users",
                column: "RoleId");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "AircraftAvailabilities");

            migrationBuilder.DropTable(
                name: "CompanyBases");

            migrationBuilder.DropTable(
                name: "FlightAssignments");

            migrationBuilder.DropTable(
                name: "FlightCharges");

            migrationBuilder.DropTable(
                name: "FlightLogs");

            migrationBuilder.DropTable(
                name: "PassengerDetails");

            migrationBuilder.DropTable(
                name: "RefreshTokens");

            migrationBuilder.DropTable(
                name: "RevokedTokens");

            migrationBuilder.DropTable(
                name: "Flights");

            migrationBuilder.DropTable(
                name: "Aircrafts");

            migrationBuilder.DropTable(
                name: "Reservations");

            migrationBuilder.DropTable(
                name: "Airports");

            migrationBuilder.DropTable(
                name: "Users");

            migrationBuilder.DropTable(
                name: "Companies");

            migrationBuilder.DropTable(
                name: "Roles");
        }
    }
}
