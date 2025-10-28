using AeroRide.API.Data;
using AeroRide.API.Models.Domain;
using AeroRide.API.Models.DTOs.Companies;
using AeroRide.API.Services.Interfaces;
using AutoMapper;
using Microsoft.EntityFrameworkCore;

namespace AeroRide.API.Services.Implementations
{
    /// <summary>
    /// Servicio que implementa la lógica de negocio para la gestión de empresas.
    /// </summary>
    public class CompanyService : ICompanyService
    {
        private readonly AeroRideDbContext _db;
        private readonly IMapper _mapper;

        public CompanyService(AeroRideDbContext db, IMapper mapper)
        {
            _db = db;
            _mapper = mapper;
        }

        // ======================================================
        // 1️⃣ LISTAR TODAS LAS EMPRESAS
        // ======================================================
        public async Task<IEnumerable<CompanyResponseDto>> GetAllAsync()
        {
            var companies = await _db.Companies
                .OrderBy(c => c.Id)
                .AsNoTracking()
                .ToListAsync();

            return _mapper.Map<IEnumerable<CompanyResponseDto>>(companies);
        }

        // ======================================================
        // 2️⃣ OBTENER EMPRESA POR ID
        // ======================================================
        public async Task<CompanyResponseDto?> GetByIdAsync(int id)
        {
            var company = await _db.Companies.FindAsync(id);
            return company == null ? null : _mapper.Map<CompanyResponseDto>(company);
        }

        // ======================================================
        // 3️⃣ CREAR EMPRESA
        // ======================================================
        public async Task<CompanyResponseDto> CreateAsync(CompanyCreateDto dto)
        {
            if (await _db.Companies.AnyAsync(c => c.Name == dto.Name))
                throw new Exception("Ya existe una empresa con ese nombre.");

            var company = _mapper.Map<Company>(dto);
            _db.Companies.Add(company);
            await _db.SaveChangesAsync();

            return _mapper.Map<CompanyResponseDto>(company);
        }

        // ======================================================
        // 4️⃣ ACTUALIZAR EMPRESA
        // ======================================================
        public async Task<CompanyResponseDto?> UpdateAsync(int id, CompanyUpdateDto dto)
        {
            var company = await _db.Companies.FirstOrDefaultAsync(c => c.Id == id);
            if (company == null) return null;

            _mapper.Map(dto, company);
            await _db.SaveChangesAsync();

            return _mapper.Map<CompanyResponseDto>(company);
        }

        // ======================================================
        // 5️⃣ DESACTIVAR EMPRESA (Soft Delete)
        // ======================================================
        public async Task<bool> DeleteAsync(int id)
        {
            var company = await _db.Companies.FirstOrDefaultAsync(c => c.Id == id);
            if (company == null) return false;

            company.IsActive = false;
            await _db.SaveChangesAsync();
            return true;
        }

        // ======================================================
        // 6️⃣ REACTIVAR EMPRESA
        // ======================================================
        public async Task<bool> ReactivateAsync(int id)
        {
            var company = await _db.Companies.FirstOrDefaultAsync(c => c.Id == id);
            if (company == null)
                return false;

            if (company.IsActive)
                return true; // Ya está activa

            company.IsActive = true;
            await _db.SaveChangesAsync();
            return true;
        }

    }
}
