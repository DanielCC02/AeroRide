using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace AeroRide.API.Migrations
{
    /// <inheritdoc />
    public partial class AddFlightLogs : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_FlightLogs_Flights_FlightId",
                table: "FlightLogs");

            migrationBuilder.DropForeignKey(
                name: "FK_FlightLogs_Reservations_ReservationId",
                table: "FlightLogs");

            migrationBuilder.DropForeignKey(
                name: "FK_FlightLogs_Users_UserId",
                table: "FlightLogs");

            migrationBuilder.DropColumn(
                name: "Image",
                table: "FlightLogs");

            migrationBuilder.RenameColumn(
                name: "UserId",
                table: "FlightLogs",
                newName: "PilotUserId");

            migrationBuilder.RenameColumn(
                name: "ReservationId",
                table: "FlightLogs",
                newName: "FlightId1");

            migrationBuilder.RenameIndex(
                name: "IX_FlightLogs_UserId",
                table: "FlightLogs",
                newName: "IX_FlightLogs_PilotUserId");

            migrationBuilder.RenameIndex(
                name: "IX_FlightLogs_ReservationId",
                table: "FlightLogs",
                newName: "IX_FlightLogs_FlightId1");

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

            migrationBuilder.AddColumn<DateTime>(
                name: "CreatedAt",
                table: "FlightLogs",
                type: "timestamp without time zone",
                nullable: false,
                defaultValue: new DateTime(1, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified));

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

            migrationBuilder.AddColumn<string>(
                name: "CrewRole",
                table: "FlightAssignments",
                type: "text",
                nullable: false,
                defaultValue: "");

            migrationBuilder.AddForeignKey(
                name: "FK_FlightLogs_Flights_FlightId",
                table: "FlightLogs",
                column: "FlightId",
                principalTable: "Flights",
                principalColumn: "Id",
                onDelete: ReferentialAction.Cascade);

            migrationBuilder.AddForeignKey(
                name: "FK_FlightLogs_Flights_FlightId1",
                table: "FlightLogs",
                column: "FlightId1",
                principalTable: "Flights",
                principalColumn: "Id");

            migrationBuilder.AddForeignKey(
                name: "FK_FlightLogs_Users_PilotUserId",
                table: "FlightLogs",
                column: "PilotUserId",
                principalTable: "Users",
                principalColumn: "Id",
                onDelete: ReferentialAction.Restrict);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_FlightLogs_Flights_FlightId",
                table: "FlightLogs");

            migrationBuilder.DropForeignKey(
                name: "FK_FlightLogs_Flights_FlightId1",
                table: "FlightLogs");

            migrationBuilder.DropForeignKey(
                name: "FK_FlightLogs_Users_PilotUserId",
                table: "FlightLogs");

            migrationBuilder.DropColumn(
                name: "BlockOff",
                table: "FlightLogs");

            migrationBuilder.DropColumn(
                name: "BlockOn",
                table: "FlightLogs");

            migrationBuilder.DropColumn(
                name: "CreatedAt",
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

            migrationBuilder.DropColumn(
                name: "CrewRole",
                table: "FlightAssignments");

            migrationBuilder.RenameColumn(
                name: "PilotUserId",
                table: "FlightLogs",
                newName: "UserId");

            migrationBuilder.RenameColumn(
                name: "FlightId1",
                table: "FlightLogs",
                newName: "ReservationId");

            migrationBuilder.RenameIndex(
                name: "IX_FlightLogs_PilotUserId",
                table: "FlightLogs",
                newName: "IX_FlightLogs_UserId");

            migrationBuilder.RenameIndex(
                name: "IX_FlightLogs_FlightId1",
                table: "FlightLogs",
                newName: "IX_FlightLogs_ReservationId");

            migrationBuilder.AddColumn<string>(
                name: "Image",
                table: "FlightLogs",
                type: "text",
                nullable: false,
                defaultValue: "");

            migrationBuilder.AddForeignKey(
                name: "FK_FlightLogs_Flights_FlightId",
                table: "FlightLogs",
                column: "FlightId",
                principalTable: "Flights",
                principalColumn: "Id",
                onDelete: ReferentialAction.Restrict);

            migrationBuilder.AddForeignKey(
                name: "FK_FlightLogs_Reservations_ReservationId",
                table: "FlightLogs",
                column: "ReservationId",
                principalTable: "Reservations",
                principalColumn: "Id",
                onDelete: ReferentialAction.SetNull);

            migrationBuilder.AddForeignKey(
                name: "FK_FlightLogs_Users_UserId",
                table: "FlightLogs",
                column: "UserId",
                principalTable: "Users",
                principalColumn: "Id",
                onDelete: ReferentialAction.Restrict);
        }
    }
}
