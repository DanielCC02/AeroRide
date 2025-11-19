using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace AeroRide.API.Migrations
{
    /// <inheritdoc />
    public partial class AddFlightLogs2 : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_FlightLogs_Flights_FlightId1",
                table: "FlightLogs");

            migrationBuilder.DropIndex(
                name: "IX_FlightLogs_FlightId1",
                table: "FlightLogs");

            migrationBuilder.DropColumn(
                name: "BlockOff",
                table: "FlightLogs");

            migrationBuilder.DropColumn(
                name: "BlockOn",
                table: "FlightLogs");

            migrationBuilder.DropColumn(
                name: "FlightId1",
                table: "FlightLogs");

            migrationBuilder.DropColumn(
                name: "FlightTime",
                table: "FlightLogs");

            migrationBuilder.DropColumn(
                name: "FuelUsed",
                table: "FlightLogs");

            migrationBuilder.DropColumn(
                name: "Observations",
                table: "FlightLogs");

            migrationBuilder.DropColumn(
                name: "PilotSignatureUrl",
                table: "FlightLogs");

            migrationBuilder.DropColumn(
                name: "Route",
                table: "FlightLogs");

            migrationBuilder.AddColumn<string>(
                name: "PdfUrl",
                table: "FlightLogs",
                type: "character varying(500)",
                maxLength: 500,
                nullable: false,
                defaultValue: "");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "PdfUrl",
                table: "FlightLogs");

            migrationBuilder.AddColumn<DateTime>(
                name: "BlockOff",
                table: "FlightLogs",
                type: "timestamp without time zone",
                nullable: false,
                defaultValue: new DateTime(1, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified));

            migrationBuilder.AddColumn<DateTime>(
                name: "BlockOn",
                table: "FlightLogs",
                type: "timestamp without time zone",
                nullable: false,
                defaultValue: new DateTime(1, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified));

            migrationBuilder.AddColumn<int>(
                name: "FlightId1",
                table: "FlightLogs",
                type: "integer",
                nullable: true);

            migrationBuilder.AddColumn<TimeSpan>(
                name: "FlightTime",
                table: "FlightLogs",
                type: "interval",
                nullable: false,
                defaultValue: new TimeSpan(0, 0, 0, 0, 0));

            migrationBuilder.AddColumn<string>(
                name: "FuelUsed",
                table: "FlightLogs",
                type: "character varying(50)",
                maxLength: 50,
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "Observations",
                table: "FlightLogs",
                type: "text",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "PilotSignatureUrl",
                table: "FlightLogs",
                type: "text",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "Route",
                table: "FlightLogs",
                type: "character varying(200)",
                maxLength: 200,
                nullable: true);

            migrationBuilder.CreateIndex(
                name: "IX_FlightLogs_FlightId1",
                table: "FlightLogs",
                column: "FlightId1");

            migrationBuilder.AddForeignKey(
                name: "FK_FlightLogs_Flights_FlightId1",
                table: "FlightLogs",
                column: "FlightId1",
                principalTable: "Flights",
                principalColumn: "Id");
        }
    }
}
