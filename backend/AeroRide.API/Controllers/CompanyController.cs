using AeroRide.API.Models.DTOs.Companies;
using AeroRide.API.Services.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace AeroRide.API.Controllers
{
    /// <summary>
    /// Controlador responsable de la gestión de empresas.
    /// Permite crear, consultar, actualizar y desactivar compañías registradas.
    /// </summary>
    [ApiController]
    [Route("api/[controller]")]
    [Authorize(Roles = "Admin")]
    public class CompanyController : ControllerBase
    {
        private readonly ICompanyService _companyService;

        public CompanyController(ICompanyService companyService)
        {
            _companyService = companyService;
        }

        // ======================================================
        // 1️⃣ GET: api/company
        // ======================================================
        [HttpGet]
        [ProducesResponseType(typeof(IEnumerable<CompanyResponseDto>), StatusCodes.Status200OK)]
        public async Task<IActionResult> GetAll()
        {
            var result = await _companyService.GetAllAsync();
            return Ok(result);
        }

        // ======================================================
        // 2️⃣ GET: api/company/{id}
        // ======================================================
        [HttpGet("{id}")]
        [ProducesResponseType(typeof(CompanyResponseDto), StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
        public async Task<IActionResult> GetById(int id)
        {
            var result = await _companyService.GetByIdAsync(id);
            return result == null ? NotFound(new { message = "Empresa no encontrada." }) : Ok(result);
        }

        // ======================================================
        // 3️⃣ POST: api/company
        // ======================================================
        [HttpPost]
        [ProducesResponseType(typeof(CompanyResponseDto), StatusCodes.Status201Created)]
        public async Task<IActionResult> Create([FromBody] CompanyCreateDto dto)
        {
            var created = await _companyService.CreateAsync(dto);
            return CreatedAtAction(nameof(GetById), new { id = created.Id }, created);
        }

        // ======================================================
        // 4️⃣ PUT: api/company/{id}
        // ======================================================
        [HttpPut("{id}")]
        [ProducesResponseType(typeof(CompanyResponseDto), StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
        public async Task<IActionResult> Update(int id, [FromBody] CompanyUpdateDto dto)
        {
            var updated = await _companyService.UpdateAsync(id, dto);
            return updated == null ? NotFound(new { message = "Empresa no encontrada." }) : Ok(updated);
        }

        // ======================================================
        // 5️⃣ DELETE: api/company/{id}
        // ======================================================
        [HttpDelete("{id}")]
        [ProducesResponseType(StatusCodes.Status204NoContent)]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
        public async Task<IActionResult> Delete(int id)
        {
            bool deleted = await _companyService.DeleteAsync(id);
            return deleted ? NoContent() : NotFound(new { message = "Empresa no encontrada." });
        }

        // ======================================================
        // 6️⃣ PATCH: api/company/{id}/reactivate
        // ======================================================
        [HttpPatch("{id}/reactivate")]
        [ProducesResponseType(StatusCodes.Status204NoContent)]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
        public async Task<IActionResult> Reactivate(int id)
        {
            bool reactivated = await _companyService.ReactivateAsync(id);
            return reactivated ? NoContent() : NotFound(new { message = "Empresa no encontrada." });
        }

    }
}
