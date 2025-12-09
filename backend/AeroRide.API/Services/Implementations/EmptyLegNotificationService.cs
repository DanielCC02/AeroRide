using AeroRide.API.Data;
using AeroRide.API.Helpers;
using AeroRide.API.Helpers.Templates;
using AeroRide.API.Models.Domain;
using AeroRide.API.Services.Interfaces;
using Microsoft.EntityFrameworkCore;
using System.Text;

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
        Console.WriteLine("🟢 [EmptyLegNotification] Entrando a NotifyUsersForEmptyLegsAsync");

        var legs = emptyLegs
            .Where(f => f.IsEmptyLeg)
            .ToList();

        Console.WriteLine($"🟢 [EmptyLegNotification] Empty legs recibidas: {legs.Count}");

        if (!legs.Any())
        {
            Console.WriteLine("ℹ️ [EmptyLegNotification] No hay empty legs, no se notifica nada.");
            return;
        }

        // Ids de aeropuertos involucrados en las empty legs
        var airportIds = legs
            .SelectMany(f => new[] { f.DepartureAirportId, f.ArrivalAirportId })
            .Distinct()
            .ToList();

        Console.WriteLine($"🟢 [EmptyLegNotification] Aeropuertos involucrados: {string.Join(",", airportIds)}");

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
            Console.WriteLine($"🟢 [EmptyLegNotification] Grupo país: {country}, legs: {group.Count()}");

            // Usuarios candidatos de ese país (💯 100% de los elegibles)
            var users = await _db.Users
                .Where(u =>
                    u.IsActive &&
                    u.IsVerified &&
                    u.Country != null &&
                    u.Country.Trim().ToLower() == country.ToLower())
                .ToListAsync();

            Console.WriteLine($"🟢 [EmptyLegNotification] Usuarios elegibles en {country}: {users.Count}");

            if (!users.Any())
            {
                Console.WriteLine($"ℹ️ [EmptyLegNotification] No hay usuarios elegibles en {country}, se omite.");
                continue;
            }

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

            // Enviar correo a *todos* los usuarios seleccionados
            foreach (var user in users)
            {
                try
                {
                    Console.WriteLine($"📨 [EmptyLegNotification] Enviando correo a {user.Email} ({user.Name})");

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
                    Console.WriteLine($"⚠️ Error enviando empty legs a {user.Email}: {ex}");
                }
            }
        }

        Console.WriteLine("✅ [EmptyLegNotification] Proceso de notificación terminado.");
    }
}
