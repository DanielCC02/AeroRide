using AeroRide.API.Data;
using AeroRide.API.Mappings;
using AeroRide.API.Services.Implementations;
using AeroRide.API.Services.Interfaces;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;
using System.Security.Cryptography;
using System.Text;

/// <summary>
/// Punto de entrada principal de la aplicación AeroRide API.
/// 
/// Configura los servicios, dependencias, autenticación JWT, base de datos,
/// AutoMapper y middlewares globales para el correcto funcionamiento del backend.
/// </summary>
var builder = WebApplication.CreateBuilder(args);

// ======================================================
// 🧩 REGISTRO DE SERVICIOS (DEPENDENCY INJECTION)
// ======================================================

/// <summary>
/// Agrega controladores y soporte para Swagger (documentación automática).
/// </summary>
builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

/// <summary>
/// Configura AutoMapper para el mapeo entre entidades y DTOs.
/// </summary>
builder.Services.AddAutoMapper(AppDomain.CurrentDomain.GetAssemblies());

/// <summary>
/// Registra los servicios de la capa de negocio (inyección de dependencias).
/// </summary>
builder.Services.AddScoped<IAuthService, AuthService>();
builder.Services.AddScoped<IUserService, UserService>();
// 🔹 Aquí podrás registrar otros servicios en el futuro, como IFlightService, IReservationService, etc.

/// <summary>
/// Configura el contexto de base de datos PostgreSQL con soporte geoespacial (PostGIS).
/// </summary>
builder.Services.AddDbContext<AeroRideDbContext>(options =>
    options.UseNpgsql(
        builder.Configuration.GetConnectionString("AeroRideDB"),
        o => o.UseNetTopologySuite()
    )
);

// ======================================================
// 🔐 CONFIGURACIÓN DE AUTENTICACIÓN JWT
// ======================================================

/// <summary>
/// Lee los valores de configuración JWT desde appsettings.json.
/// </summary>
var jwtKey = builder.Configuration["Jwt:Key"]
    ?? throw new InvalidOperationException("JWT key missing");
var jwtIssuer = builder.Configuration["Jwt:Issuer"]
    ?? throw new InvalidOperationException("JWT issuer missing");
var jwtAudience = builder.Configuration["Jwt:Audience"]
    ?? throw new InvalidOperationException("JWT audience missing");

/// <summary>
/// Deriva bytes seguros de la clave JWT (corrige errores de codificación Base64 en .NET 8).
/// </summary>
var keyBytes = SHA256.HashData(Encoding.UTF8.GetBytes(jwtKey));
var securityKey = new SymmetricSecurityKey(keyBytes);

/// <summary>
/// Configura la autenticación basada en JWT.
/// Incluye validación de firma, issuer, audiencia y manejo de eventos personalizados.
/// </summary>
builder.Services.AddAuthentication(JwtBearerDefaults.AuthenticationScheme)
    .AddJwtBearer(options =>
    {
        options.RequireHttpsMetadata = false; // ⚠️ Solo para desarrollo
        options.SaveToken = true;

        options.TokenValidationParameters = new TokenValidationParameters
        {
            ValidateIssuer = true,
            ValidateAudience = true,
            ValidateLifetime = true,
            ValidateIssuerSigningKey = true,
            ValidIssuer = jwtIssuer,
            ValidAudience = jwtAudience,
            IssuerSigningKey = securityKey
        };

        // Eventos personalizados para depuración
        options.Events = new JwtBearerEvents
        {
            OnAuthenticationFailed = context =>
            {
                Console.WriteLine($"❌ JWT Error: {context.Exception.Message}");
                return Task.CompletedTask;
            },
            OnMessageReceived = context =>
            {
                var header = context.Request.Headers["Authorization"].ToString();
                if (header.StartsWith("Bearer ", StringComparison.OrdinalIgnoreCase))
                {
                    context.Token = header.Substring("Bearer ".Length).Trim();
                    Console.WriteLine($"✅ Token capturado correctamente: {context.Token.Substring(0, 25)}...");
                }
                else
                {
                    Console.WriteLine("⚠️ No se encontró un token Bearer válido en el header.");
                }

                return Task.CompletedTask;
            }
        };
    });

/// <summary>
/// Habilita políticas de autorización basadas en roles y autenticación previa.
/// </summary>
builder.Services.AddAuthorization();

// ======================================================
// ⚙️ CONSTRUCCIÓN DE LA APLICACIÓN
// ======================================================

var app = builder.Build();

/// <summary>
/// Middleware de diagnóstico para imprimir los encabezados de autorización recibidos.
/// Útil en desarrollo para verificar que los tokens JWT se envíen correctamente.
/// </summary>
app.Use(async (context, next) =>
{
    var authHeader = context.Request.Headers["Authorization"].ToString();
    Console.WriteLine($"🔍 Authorization header recibido: '{authHeader}'");
    await next();
});

// ======================================================
// 🌐 CONFIGURACIÓN DE PIPELINE DE MIDDLEWARES
// ======================================================

if (app.Environment.IsDevelopment())
{
    /// <summary>
    /// Activa Swagger y Swagger UI en entorno de desarrollo.
    /// </summary>
    app.UseSwagger();
    app.UseSwaggerUI();
}

/// <summary>
/// Fuerza HTTPS para todas las solicitudes entrantes.
/// </summary>
app.UseHttpsRedirection();

/// <summary>
/// Aplica autenticación y autorización a nivel global.
/// Es fundamental que la autenticación se ejecute antes de la autorización.
/// </summary>
app.UseAuthentication();
app.UseAuthorization();

/// <summary>
/// Mapea los controladores registrados en la API.
/// </summary>
app.MapControllers();

/// <summary>
/// Inicia la aplicación web.
/// </summary>
app.Run();
