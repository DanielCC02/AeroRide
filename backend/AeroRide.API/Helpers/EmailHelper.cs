using AeroRide.API.Helpers.Templates;
using AeroRide.API.Models.Domain;
using SendGrid;
using SendGrid.Helpers.Mail;

namespace AeroRide.API.Helpers
{
    /// <summary>
    /// Helper general para enviar correos con SendGrid.
    /// Contiene métodos para envío genérico y casos específicos (verificación, recuperación, etc.).
    /// </summary>
    public static class EmailHelper
    {
        /// <summary>
        /// Envía un correo electrónico HTML usando SendGrid.
        /// </summary>
        public static async Task SendEmailAsync(
            string apiKey,
            string fromEmail,
            string fromName,
            string toEmail,
            string subject,
            string htmlContent)
        {
            var client = new SendGridClient(apiKey);
            var from = new EmailAddress(fromEmail, fromName);
            var to = new EmailAddress(toEmail);

            var msg = MailHelper.CreateSingleEmail(from, to, subject, "", htmlContent);
            var response = await client.SendEmailAsync(msg);

            Console.WriteLine($"📤 Email enviado a {toEmail}, estado: {response.StatusCode}");
        }

        // ======================================================
        // ✈️ ENVÍO DE CORREO DE VERIFICACIÓN DE CUENTA
        // ======================================================
        /// <summary>
        /// Envía el correo HTML de verificación de cuenta mediante SendGrid.
        /// </summary>
        public static async Task SendVerificationEmailAsync(User user, IConfiguration config, bool reenvio = false)
        {
            try
            {
                string apiKey = config["SendGrid:ApiKey"] ?? throw new Exception("Falta API Key de SendGrid");
                string fromEmail = config["SendGrid:FromEmail"]!;
                string fromName = config["SendGrid:FromName"]!;
                string baseUrl = config["SendGrid:VerificationBaseUrl"]!;

                string verificationLink = $"{baseUrl}{user.EmailVerificationToken}";
                string htmlContent = EmailVerificationTemplate.Build(user.Name, verificationLink);

                string subject = reenvio
                    ? "Verifica tu cuenta AeroRide ✈️ (reenviado)"
                    : "Verifica tu cuenta AeroRide ✈️";

                await SendEmailAsync(apiKey, fromEmail, fromName, user.Email, subject, htmlContent);

                Console.WriteLine(reenvio
                    ? $"📨 Correo de verificación reenviado a {user.Email}"
                    : $"✅ Correo de verificación enviado a {user.Email}");
            }
            catch (Exception ex)
            {
                Console.WriteLine($"⚠️ Error al enviar correo de verificación: {ex.Message}");
            }
        }

        public static async Task SendPilotAssignmentEmailAsync(User user, Flight flight, IConfiguration config)
        {
            try
            {
                string apiKey = config["SendGrid:ApiKey"]!;
                string fromEmail = config["SendGrid:FromEmail"]!;
                string fromName = config["SendGrid:FromName"]!;

                string subject = $"Nueva asignación de vuelo #{flight.Id} ✈️";

                string htmlContent = PilotAssignmentTemplate.Build(
                    user.Name,
                    flight.Id.ToString(),
                    flight.DepartureTime.ToString("f"),
                    flight.DepartureAirport.Name,
                    flight.ArrivalAirport.Name
                );

                await SendEmailAsync(apiKey, fromEmail, fromName, user.Email, subject, htmlContent);

                Console.WriteLine($"📨 Correo enviado al piloto {user.Email} sobre vuelo {flight.Id}");
            }
            catch (Exception ex)
            {
                Console.WriteLine($"❌ Error enviando correo de asignación: {ex.Message}");
            }
        }

    }
}
