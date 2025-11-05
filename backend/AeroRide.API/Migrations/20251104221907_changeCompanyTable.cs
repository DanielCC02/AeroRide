using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace AeroRide.API.Migrations
{
    /// <inheritdoc />
    public partial class changeCompanyTable : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<double>(
                name: "AirportTaxPerPassenger",
                table: "Companies",
                type: "double precision",
                nullable: false,
                defaultValue: 0.0);

            migrationBuilder.AddColumn<double>(
                name: "DomesticOvernightCost",
                table: "Companies",
                type: "double precision",
                nullable: false,
                defaultValue: 0.0);

            migrationBuilder.AddColumn<double>(
                name: "DomesticWaitHourCost",
                table: "Companies",
                type: "double precision",
                nullable: false,
                defaultValue: 0.0);

            migrationBuilder.AddColumn<double>(
                name: "HandlingPerPassenger",
                table: "Companies",
                type: "double precision",
                nullable: false,
                defaultValue: 0.0);

            migrationBuilder.AddColumn<double>(
                name: "InternationalOvernightCost",
                table: "Companies",
                type: "double precision",
                nullable: false,
                defaultValue: 0.0);

            migrationBuilder.AddColumn<double>(
                name: "InternationalWaitHourCost",
                table: "Companies",
                type: "double precision",
                nullable: false,
                defaultValue: 0.0);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "AirportTaxPerPassenger",
                table: "Companies");

            migrationBuilder.DropColumn(
                name: "DomesticOvernightCost",
                table: "Companies");

            migrationBuilder.DropColumn(
                name: "DomesticWaitHourCost",
                table: "Companies");

            migrationBuilder.DropColumn(
                name: "HandlingPerPassenger",
                table: "Companies");

            migrationBuilder.DropColumn(
                name: "InternationalOvernightCost",
                table: "Companies");

            migrationBuilder.DropColumn(
                name: "InternationalWaitHourCost",
                table: "Companies");
        }
    }
}
