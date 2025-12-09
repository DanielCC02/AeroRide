using System.Text;

namespace AeroRide.API.Helpers.Templates
{
    public static class EmptyLegsTemplate
    {
        public static string Build(
            string userName,
            string country,
            string legsListItemsHtml,
            string? ctaUrl = null
        )
        {
            var buttonHtml = string.IsNullOrWhiteSpace(ctaUrl)
                ? string.Empty
                : $@"
                <tr>
                    <td align=""center"" style=""padding: 20px 0 0 0;"">
                        <a href=""{ctaUrl}"" 
                           style=""background-color:#b91c1c;
                                  color:#ffffff;
                                  padding:12px 24px;
                                  border-radius:999px;
                                  text-decoration:none;
                                  font-weight:600;
                                  font-size:14px;
                                  display:inline-block;"">
                            Ver piernas vacías disponibles
                        </a>
                    </td>
                </tr>";

            var sb = new StringBuilder();

            sb.Append($@"
            <!DOCTYPE html>
            <html lang=""es"">
            <head>
                <meta charset=""UTF-8"" />
                <title>Nuevas piernas vacías disponibles</title>
            </head>
            <body style=""margin:0; padding:0; font-family:system-ui, -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif; background-color:#f3f4f6;"">
                <table width=""100%"" cellpadding=""0"" cellspacing=""0"" border=""0"">
                    <tr>
                        <td align=""center"" style=""padding:24px 12px;"">
                            <table width=""100%"" cellpadding=""0"" cellspacing=""0"" border=""0"" style=""max-width:600px; background-color:#ffffff; border-radius:16px; overflow:hidden; box-shadow:0 10px 25px rgba(15,23,42,0.08);"">
                                <tr>
                                    <td style=""background:linear-gradient(135deg,#7f1d1d,#b91c1c); padding:20px 24px; color:#fef2f2;"">
                                        <h1 style=""margin:0; font-size:20px; color:#fef2f2;"">
                                            Nuevas piernas vacías en {country}
                                        </h1>
                                        <p style=""margin:6px 0 0 0; font-size:13px; color:#fde2e2;"">
                                            Ofertas especiales de vuelo privado, sujetas a disponibilidad.
                                        </p>
                                    </td>
                                </tr>

                                <tr>
                                    <td style=""padding:20px 24px 8px 24px; font-size:14px; color:#111827;"">
                                        <p style=""margin:0 0 12px 0;"">
                                            Hola <strong>{System.Net.WebUtility.HtmlEncode(userName)}</strong>,
                                        </p>
                                        <p style=""margin:0 0 12px 0; line-height:1.5;"">
                                            Se han generado <strong>nuevas piernas vacías</strong> que salen desde aeropuertos de 
                                            <strong>{System.Net.WebUtility.HtmlEncode(country)}</strong>. 
                                            Estas rutas suelen tener tarifas especiales y disponibilidad limitada.
                                        </p>
                                        <p style=""margin:0 0 8px 0; font-weight:600; font-size:13px; text-transform:uppercase; color:#7f1d1d;"">
                                            Rutas disponibles:
                                        </p>
                                    </td>
                                </tr>

                                <tr>
                                    <td style=""padding:0 24px 16px 24px;"">
                                        <ul style=""margin:0; padding-left:18px; font-size:13px; color:#374151; line-height:1.6;"">
                                            {legsListItemsHtml}
                                        </ul>
                                        <p style=""margin:12px 0 0 0; font-size:12px; color:#9ca3af;"">
                                            * Los horarios están sujetos a cambios y se confirman al momento de la reserva.
                                        </p>
                                    </td>
                                </tr>

                                {buttonHtml}

                                <tr>
                                    <td style=""padding:20px 24px 16px 24px; font-size:11px; color:#9ca3af; border-top:1px solid #e5e7eb;"">
                                        <p style=""margin:0 0 4px 0;"">
                                            Estás recibiendo este correo porque tienes una cuenta activa en <strong>AeroCaribe</strong> 
                                            y te encuentras registrado en {System.Net.WebUtility.HtmlEncode(country)}.
                                        </p>
                                        <p style=""margin:0;"">
                                            Si no deseas recibir notificaciones de piernas vacías, por favor contacta al soporte de AeroCaribe.
                                        </p>
                                    </td>
                                </tr>
                            </table>
                        </td>
                    </tr>
                </table>
            </body>
            </html>");

            return sb.ToString();
        }
    }
}
