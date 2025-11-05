using System;
using Microsoft.EntityFrameworkCore.Migrations;
using Npgsql.EntityFrameworkCore.PostgreSQL.Metadata;

#nullable disable

namespace AeroRide.API.Migrations
{
    /// <inheritdoc />
    public partial class createScheduleTable : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_Aircrafts_Airports_CurrentAirportId",
                table: "Aircrafts");

            migrationBuilder.AddColumn<int>(
                name: "BaseAirportId",
                table: "Aircrafts",
                type: "integer",
                nullable: false,
                defaultValue: 0);

            migrationBuilder.CreateTable(
                name: "AircraftAvailabilities",
                columns: table => new
                {
                    Id = table.Column<int>(type: "integer", nullable: false)
                        .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityByDefaultColumn),
                    AircraftId = table.Column<int>(type: "integer", nullable: false),
                    StartTime = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    EndTime = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
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

            migrationBuilder.CreateIndex(
                name: "IX_Aircrafts_BaseAirportId",
                table: "Aircrafts",
                column: "BaseAirportId");

            migrationBuilder.CreateIndex(
                name: "IX_AircraftAvailabilities_AircraftId_StartTime_EndTime",
                table: "AircraftAvailabilities",
                columns: new[] { "AircraftId", "StartTime", "EndTime" });

            migrationBuilder.CreateIndex(
                name: "IX_AircraftAvailabilities_ReservationId",
                table: "AircraftAvailabilities",
                column: "ReservationId");

            migrationBuilder.CreateIndex(
                name: "IX_CompanyBases_AirportId",
                table: "CompanyBases",
                column: "AirportId");

            migrationBuilder.CreateIndex(
                name: "IX_CompanyBases_CompanyId",
                table: "CompanyBases",
                column: "CompanyId");

            migrationBuilder.AddForeignKey(
                name: "FK_Aircrafts_Airports_BaseAirportId",
                table: "Aircrafts",
                column: "BaseAirportId",
                principalTable: "Airports",
                principalColumn: "Id",
                onDelete: ReferentialAction.Restrict);

            migrationBuilder.AddForeignKey(
                name: "FK_Aircrafts_Airports_CurrentAirportId",
                table: "Aircrafts",
                column: "CurrentAirportId",
                principalTable: "Airports",
                principalColumn: "Id",
                onDelete: ReferentialAction.Restrict);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_Aircrafts_Airports_BaseAirportId",
                table: "Aircrafts");

            migrationBuilder.DropForeignKey(
                name: "FK_Aircrafts_Airports_CurrentAirportId",
                table: "Aircrafts");

            migrationBuilder.DropTable(
                name: "AircraftAvailabilities");

            migrationBuilder.DropTable(
                name: "CompanyBases");

            migrationBuilder.DropIndex(
                name: "IX_Aircrafts_BaseAirportId",
                table: "Aircrafts");

            migrationBuilder.DropColumn(
                name: "BaseAirportId",
                table: "Aircrafts");

            migrationBuilder.AddForeignKey(
                name: "FK_Aircrafts_Airports_CurrentAirportId",
                table: "Aircrafts",
                column: "CurrentAirportId",
                principalTable: "Airports",
                principalColumn: "Id");
        }
    }
}
