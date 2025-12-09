using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using AeroRide.API.Data;
using AeroRide.API.Helpers;
using AeroRide.API.Helpers.Templates;
using AeroRide.API.Models.Domain;
using AeroRide.API.Services.Interfaces;
using Microsoft.EntityFrameworkCore;

public class EmptyLegNotificationService : IEmptyLegNotificationService
{
    private readonly AeroRideDbContext _db;
    private readonly IConfiguration _config;

    public EmptyLegNotificationService(
        AeroRideDbContext db,
        IConfiguration config)
    {
        _db = db;
        _config = config;
    }

    public async Task NotifyUsersForEmptyLegsAsync(IEnumerable<Flight> emptyLegs)
    {
        var legs = emptyLegs
            .Where(f => f.IsEmptyLeg)
            .ToList();

        if (!legs.Any())
            return;

        // Ids de aeropuertos involucrados en las empty legs
        var airportIds = legs
            .SelectMany(f => new[] { f.DepartureAirportId, f.ArrivalAirportId })
            .Distinct()
            .ToList();

        var airports = await _db.Airports
            .Where(a => airportIds.Contains(a.Id))
            .ToDictionaryAsync(a => a.Id);

        // Agrupar empty legs por país de aeropuerto de salida
        var legsByCountry = legs
            .Where(f => airports.ContainsKey(f.DepartureAirportId))
            .GroupBy(f => airports[f.DepartureAirportId].Country.Trim());

        var apiKey = _config["SendGrid:ApiKey"]
                     ?? throw new Exception("Falta SendGrid:ApiKey en configuración.");
        var fromEmail = _config["SendGrid:FromEmail"]
                        ?? throw new Exception("Falta SendGrid:FromEmail en configuración.");
        var fromName = _config["SendGrid:FromName"] ?? "AeroRide";

        // URL opcional hacia la pantalla de empty legs (frontend)
        var emptyLegsUrl = _config["Links:EmptyLegs"]; // ej: https://app.aeroride.com/empty-legs

        foreach (var group in legsByCountry)
        {
            var country = group.Key;

            // Base query de usuarios candidatos de ese país
            var baseQuery = _db.Users
                .Where(u =>
                    u.IsActive &&
                    u.IsVerified &&
                    u.Country != null &&
                    u.Country.Trim().ToLower() == country.ToLower());

            // 1️⃣ Contar usuarios elegibles
            var totalUsers = await baseQuery.CountAsync();
            if (totalUsers == 0)
                continue;

            // 2️⃣ Calcular 20% (redondeo hacia arriba) y asegurar mínimo 1
            var takeCount = (int)Math.Ceiling(totalUsers * 0.20);
            if (takeCount < 1)
                takeCount = 1;

            // 3️⃣ Tomar ese porcentaje de forma aleatoria
            var users = await baseQuery
                .OrderBy(u => Guid.NewGuid())   // random
                .Take(takeCount)
                .ToListAsync();

            if (!users.Any())
                continue;

            // 🔹 Armar el HTML de la lista <li>...</li> con las empty legs de ese país
            var listItemsBuilder = new StringBuilder();

            foreach (var flight in group)
            {
                var dep = airports[flight.DepartureAirportId];
                var arr = airports[flight.ArrivalAirportId];

                var depLocal = TimeHelper.ToLocalTime(flight.DepartureTime, dep.TimeZone);

                listItemsBuilder.AppendLine($@"
                <li style=""margin-bottom:8px;"">
                    <strong>{dep.City} ({dep.CodeIATA}) → {arr.City} ({arr.CodeIATA})</strong><br/>
                    <span style=""font-size:12px; color:#6b7280;"">
                        Salida: {depLocal:yyyy-MM-dd HH:mm} ({dep.TimeZone})
                    </span>
                </li>");
            }

            var legsListItemsHtml = listItemsBuilder.ToString();
            var subject = $"Nuevas piernas vacías disponibles en {country}";

            // 4️⃣ Enviar correo a cada usuario seleccionado
            foreach (var user in users)
            {
                try
                {
                    var htmlContent = EmptyLegsTemplate.Build(
                        user.Name,
                        country,
                        legsListItemsHtml,
                        emptyLegsUrl
                    );

                    await EmailHelper.SendEmailAsync(
                        apiKey,
                        fromEmail,
                        fromName,
                        user.Email,
                        subject,
                        htmlContent
                    );
                }
                catch (Exception ex)
                {
                    Console.WriteLine($"⚠️ Error enviando empty legs a {user.Email}: {ex.Message}");
                }
            }
        }
    }
}
