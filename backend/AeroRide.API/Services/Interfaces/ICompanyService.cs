using AeroRide.API.Models.DTOs.Companies;

namespace AeroRide.API.Services.Interfaces
{
    /// <summary>
    /// Define las operaciones disponibles para la gestión de empresas en el sistema.
    /// </summary>
    public interface ICompanyService
    {
        Task<IEnumerable<CompanyResponseDto>> GetAllAsync();
        Task<CompanyResponseDto?> GetByIdAsync(int id);
        Task<CompanyResponseDto> CreateAsync(CompanyCreateDto dto);
        Task<CompanyResponseDto?> UpdateAsync(int id, CompanyUpdateDto dto);
        Task<bool> DeleteAsync(int id);
        Task<bool> ReactivateAsync(int id);

    }
}
