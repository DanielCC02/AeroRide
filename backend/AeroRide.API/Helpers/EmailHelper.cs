using SendGrid;
using SendGrid.Helpers.Mail;

namespace AeroRide.API.Helpers
{
    /// <summary>
    /// Helper general para enviar correos con SendGrid.
    /// </summary>
    public static class EmailHelper
    {
        /// <summary>
        /// Envía un correo electrónico HTML usando SendGrid.
        /// </summary>
        /// <param name="apiKey">API Key de SendGrid.</param>
        /// <param name="fromEmail">Correo del remitente.</param>
        /// <param name="fromName">Nombre del remitente.</param>
        /// <param name="toEmail">Correo destinatario.</param>
        /// <param name="subject">Asunto del mensaje.</param>
        /// <param name="htmlContent">Contenido HTML del mensaje.</param>
        public static async Task SendEmailAsync(string apiKey, string fromEmail, string fromName, string toEmail, string subject, string htmlContent)
        {
            var client = new SendGridClient(apiKey);
            var from = new EmailAddress(fromEmail, fromName);
            var to = new EmailAddress(toEmail);

            var msg = MailHelper.CreateSingleEmail(from, to, subject, "", htmlContent);
            var response = await client.SendEmailAsync(msg);

            Console.WriteLine($"📤 Email enviado a {toEmail}, estado: {response.StatusCode}");
        }
    }
}
