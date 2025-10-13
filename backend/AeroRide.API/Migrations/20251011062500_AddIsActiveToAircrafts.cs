using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace AeroRide.API.Migrations
{
    /// <inheritdoc />
    public partial class AddIsActiveToAircrafts : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<bool>(
                name: "IsActive",
                table: "Aircrafts",
                type: "boolean",
                nullable: false,
                defaultValue: false);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "IsActive",
                table: "Aircrafts");
        }
    }
}
