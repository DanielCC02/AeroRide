using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace AeroRide.API.Migrations
{
    /// <inheritdoc />
    public partial class FixRefreshTokensFK : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_RefreshTokens_Users_UserId1",
                table: "RefreshTokens");

            migrationBuilder.DropIndex(
                name: "IX_RefreshTokens_UserId1",
                table: "RefreshTokens");

            migrationBuilder.DropColumn(
                name: "UserId1",
                table: "RefreshTokens");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<int>(
                name: "UserId1",
                table: "RefreshTokens",
                type: "integer",
                nullable: true);

            migrationBuilder.CreateIndex(
                name: "IX_RefreshTokens_UserId1",
                table: "RefreshTokens",
                column: "UserId1");

            migrationBuilder.AddForeignKey(
                name: "FK_RefreshTokens_Users_UserId1",
                table: "RefreshTokens",
                column: "UserId1",
                principalTable: "Users",
                principalColumn: "Id");
        }
    }
}
