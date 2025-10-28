using System;
using Microsoft.EntityFrameworkCore.Migrations;
using Npgsql.EntityFrameworkCore.PostgreSQL.Metadata;

#nullable disable

namespace AeroRide.API.Migrations
{
    /// <inheritdoc />
    public partial class AddMoreModule : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<DateTime>(
                name: "CreatedAt",
                table: "Reservations",
                type: "timestamp with time zone",
                nullable: false,
                defaultValue: new DateTime(1, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified));

            migrationBuilder.AddColumn<bool>(
                name: "IsRoundTrip",
                table: "Reservations",
                type: "boolean",
                nullable: false,
                defaultValue: false);

            migrationBuilder.AddColumn<string>(
                name: "Notes",
                table: "Reservations",
                type: "text",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "ReservationCode",
                table: "Reservations",
                type: "text",
                nullable: false,
                defaultValue: "");

            migrationBuilder.AddColumn<string>(
                name: "Status",
                table: "Reservations",
                type: "text",
                nullable: false,
                defaultValue: "");

            migrationBuilder.AddColumn<DateTime>(
                name: "UpdatedAt",
                table: "Reservations",
                type: "timestamp with time zone",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "Nationality",
                table: "PassengerDetails",
                type: "text",
                nullable: false,
                defaultValue: "");

            migrationBuilder.AddColumn<DateTime>(
                name: "CreatedAt",
                table: "Flights",
                type: "timestamp with time zone",
                nullable: false,
                defaultValue: new DateTime(1, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified));

            migrationBuilder.AddColumn<bool>(
                name: "IsInternational",
                table: "Flights",
                type: "boolean",
                nullable: false,
                defaultValue: false);

            migrationBuilder.AddColumn<string>(
                name: "TimeZone",
                table: "Airports",
                type: "text",
                nullable: false,
                defaultValue: "");

            migrationBuilder.AddColumn<double>(
                name: "CruisingSpeed",
                table: "Aircrafts",
                type: "double precision",
                nullable: false,
                defaultValue: 0.0);

            migrationBuilder.AddColumn<int>(
                name: "CurrentAirportId",
                table: "Aircrafts",
                type: "integer",
                nullable: true);

            migrationBuilder.AddColumn<DateTime>(
                name: "StatusLastUpdated",
                table: "Aircrafts",
                type: "timestamp with time zone",
                nullable: false,
                defaultValue: new DateTime(1, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified));

            migrationBuilder.CreateTable(
                name: "FlightPlan",
                columns: table => new
                {
                    Id = table.Column<int>(type: "integer", nullable: false)
                        .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityByDefaultColumn),
                    FlightId = table.Column<int>(type: "integer", nullable: false),
                    Status = table.Column<string>(type: "text", nullable: false),
                    WeatherCondition = table.Column<string>(type: "text", nullable: true),
                    DelayReason = table.Column<string>(type: "text", nullable: true),
                    ActualDepartureTime = table.Column<DateTime>(type: "timestamp with time zone", nullable: true),
                    ActualArrivalTime = table.Column<DateTime>(type: "timestamp with time zone", nullable: true),
                    DistanceKm = table.Column<double>(type: "double precision", nullable: true),
                    DurationMinutes = table.Column<int>(type: "integer", nullable: true),
                    UpdatedAt = table.Column<DateTime>(type: "timestamp with time zone", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_FlightPlan", x => x.Id);
                    table.ForeignKey(
                        name: "FK_FlightPlan_Flights_FlightId",
                        column: x => x.FlightId,
                        principalTable: "Flights",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateIndex(
                name: "IX_Aircrafts_CurrentAirportId",
                table: "Aircrafts",
                column: "CurrentAirportId");

            migrationBuilder.CreateIndex(
                name: "IX_FlightPlan_FlightId",
                table: "FlightPlan",
                column: "FlightId",
                unique: true);

            migrationBuilder.AddForeignKey(
                name: "FK_Aircrafts_Airports_CurrentAirportId",
                table: "Aircrafts",
                column: "CurrentAirportId",
                principalTable: "Airports",
                principalColumn: "Id");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_Aircrafts_Airports_CurrentAirportId",
                table: "Aircrafts");

            migrationBuilder.DropTable(
                name: "FlightPlan");

            migrationBuilder.DropIndex(
                name: "IX_Aircrafts_CurrentAirportId",
                table: "Aircrafts");

            migrationBuilder.DropColumn(
                name: "CreatedAt",
                table: "Reservations");

            migrationBuilder.DropColumn(
                name: "IsRoundTrip",
                table: "Reservations");

            migrationBuilder.DropColumn(
                name: "Notes",
                table: "Reservations");

            migrationBuilder.DropColumn(
                name: "ReservationCode",
                table: "Reservations");

            migrationBuilder.DropColumn(
                name: "Status",
                table: "Reservations");

            migrationBuilder.DropColumn(
                name: "UpdatedAt",
                table: "Reservations");

            migrationBuilder.DropColumn(
                name: "Nationality",
                table: "PassengerDetails");

            migrationBuilder.DropColumn(
                name: "CreatedAt",
                table: "Flights");

            migrationBuilder.DropColumn(
                name: "IsInternational",
                table: "Flights");

            migrationBuilder.DropColumn(
                name: "TimeZone",
                table: "Airports");

            migrationBuilder.DropColumn(
                name: "CruisingSpeed",
                table: "Aircrafts");

            migrationBuilder.DropColumn(
                name: "CurrentAirportId",
                table: "Aircrafts");

            migrationBuilder.DropColumn(
                name: "StatusLastUpdated",
                table: "Aircrafts");
        }
    }
}
