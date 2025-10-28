using System;
using Microsoft.EntityFrameworkCore.Migrations;
using Npgsql.EntityFrameworkCore.PostgreSQL.Metadata;

#nullable disable

namespace AeroRide.API.Migrations
{
    /// <inheritdoc />
    public partial class RecreateTables : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "FlightPlan");

            migrationBuilder.DropColumn(
                name: "Tax",
                table: "Airports");

            migrationBuilder.RenameColumn(
                name: "Price",
                table: "Reservations",
                newName: "TotalPrice");

            migrationBuilder.AddColumn<int>(
                name: "CompanyId",
                table: "Users",
                type: "integer",
                nullable: true);

            migrationBuilder.AddColumn<int>(
                name: "CompanyId",
                table: "Reservations",
                type: "integer",
                nullable: false,
                defaultValue: 0);

            migrationBuilder.AddColumn<double>(
                name: "PorcentPrice",
                table: "Reservations",
                type: "double precision",
                nullable: false,
                defaultValue: 0.0);

            migrationBuilder.AlterColumn<string>(
                name: "MiddleName",
                table: "PassengerDetails",
                type: "text",
                nullable: true,
                oldClrType: typeof(string),
                oldType: "text");

            migrationBuilder.AddColumn<int>(
                name: "CompanyId",
                table: "Flights",
                type: "integer",
                nullable: false,
                defaultValue: 0);

            migrationBuilder.AddColumn<double>(
                name: "DurationMinutes",
                table: "Flights",
                type: "double precision",
                nullable: false,
                defaultValue: 0.0);

            migrationBuilder.AddColumn<string>(
                name: "Status",
                table: "Flights",
                type: "text",
                nullable: false,
                defaultValue: "");

            migrationBuilder.AddColumn<bool>(
                name: "CanFlyInternational",
                table: "Aircrafts",
                type: "boolean",
                nullable: false,
                defaultValue: false);

            migrationBuilder.AddColumn<int>(
                name: "CompanyId",
                table: "Aircrafts",
                type: "integer",
                nullable: false,
                defaultValue: 0);

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
                    CreatedAt = table.Column<DateTime>(type: "timestamp with time zone", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Companies", x => x.Id);
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
                    CalculatedAt = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
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

            migrationBuilder.CreateIndex(
                name: "IX_Users_CompanyId",
                table: "Users",
                column: "CompanyId");

            migrationBuilder.CreateIndex(
                name: "IX_Reservations_CompanyId",
                table: "Reservations",
                column: "CompanyId");

            migrationBuilder.CreateIndex(
                name: "IX_Flights_CompanyId",
                table: "Flights",
                column: "CompanyId");

            migrationBuilder.CreateIndex(
                name: "IX_Aircrafts_CompanyId",
                table: "Aircrafts",
                column: "CompanyId");

            migrationBuilder.CreateIndex(
                name: "IX_FlightCharges_CompanyId",
                table: "FlightCharges",
                column: "CompanyId");

            migrationBuilder.CreateIndex(
                name: "IX_FlightCharges_FlightId",
                table: "FlightCharges",
                column: "FlightId",
                unique: true);

            migrationBuilder.AddForeignKey(
                name: "FK_Aircrafts_Companies_CompanyId",
                table: "Aircrafts",
                column: "CompanyId",
                principalTable: "Companies",
                principalColumn: "Id",
                onDelete: ReferentialAction.Cascade);

            migrationBuilder.AddForeignKey(
                name: "FK_Flights_Companies_CompanyId",
                table: "Flights",
                column: "CompanyId",
                principalTable: "Companies",
                principalColumn: "Id",
                onDelete: ReferentialAction.Cascade);

            migrationBuilder.AddForeignKey(
                name: "FK_Reservations_Companies_CompanyId",
                table: "Reservations",
                column: "CompanyId",
                principalTable: "Companies",
                principalColumn: "Id",
                onDelete: ReferentialAction.Cascade);

            migrationBuilder.AddForeignKey(
                name: "FK_Users_Companies_CompanyId",
                table: "Users",
                column: "CompanyId",
                principalTable: "Companies",
                principalColumn: "Id",
                onDelete: ReferentialAction.SetNull);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_Aircrafts_Companies_CompanyId",
                table: "Aircrafts");

            migrationBuilder.DropForeignKey(
                name: "FK_Flights_Companies_CompanyId",
                table: "Flights");

            migrationBuilder.DropForeignKey(
                name: "FK_Reservations_Companies_CompanyId",
                table: "Reservations");

            migrationBuilder.DropForeignKey(
                name: "FK_Users_Companies_CompanyId",
                table: "Users");

            migrationBuilder.DropTable(
                name: "FlightCharges");

            migrationBuilder.DropTable(
                name: "Companies");

            migrationBuilder.DropIndex(
                name: "IX_Users_CompanyId",
                table: "Users");

            migrationBuilder.DropIndex(
                name: "IX_Reservations_CompanyId",
                table: "Reservations");

            migrationBuilder.DropIndex(
                name: "IX_Flights_CompanyId",
                table: "Flights");

            migrationBuilder.DropIndex(
                name: "IX_Aircrafts_CompanyId",
                table: "Aircrafts");

            migrationBuilder.DropColumn(
                name: "CompanyId",
                table: "Users");

            migrationBuilder.DropColumn(
                name: "CompanyId",
                table: "Reservations");

            migrationBuilder.DropColumn(
                name: "PorcentPrice",
                table: "Reservations");

            migrationBuilder.DropColumn(
                name: "CompanyId",
                table: "Flights");

            migrationBuilder.DropColumn(
                name: "DurationMinutes",
                table: "Flights");

            migrationBuilder.DropColumn(
                name: "Status",
                table: "Flights");

            migrationBuilder.DropColumn(
                name: "CanFlyInternational",
                table: "Aircrafts");

            migrationBuilder.DropColumn(
                name: "CompanyId",
                table: "Aircrafts");

            migrationBuilder.RenameColumn(
                name: "TotalPrice",
                table: "Reservations",
                newName: "Price");

            migrationBuilder.AlterColumn<string>(
                name: "MiddleName",
                table: "PassengerDetails",
                type: "text",
                nullable: false,
                defaultValue: "",
                oldClrType: typeof(string),
                oldType: "text",
                oldNullable: true);

            migrationBuilder.AddColumn<double>(
                name: "Tax",
                table: "Airports",
                type: "double precision",
                nullable: false,
                defaultValue: 0.0);

            migrationBuilder.CreateTable(
                name: "FlightPlan",
                columns: table => new
                {
                    Id = table.Column<int>(type: "integer", nullable: false)
                        .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityByDefaultColumn),
                    FlightId = table.Column<int>(type: "integer", nullable: false),
                    ActualArrivalTime = table.Column<DateTime>(type: "timestamp with time zone", nullable: true),
                    ActualDepartureTime = table.Column<DateTime>(type: "timestamp with time zone", nullable: true),
                    DelayReason = table.Column<string>(type: "text", nullable: true),
                    DistanceKm = table.Column<double>(type: "double precision", nullable: true),
                    DurationMinutes = table.Column<int>(type: "integer", nullable: true),
                    Status = table.Column<string>(type: "text", nullable: false),
                    UpdatedAt = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    WeatherCondition = table.Column<string>(type: "text", nullable: true)
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
                name: "IX_FlightPlan_FlightId",
                table: "FlightPlan",
                column: "FlightId",
                unique: true);
        }
    }
}
