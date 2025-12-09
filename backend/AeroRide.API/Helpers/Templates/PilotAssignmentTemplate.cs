namespace AeroRide.API.Helpers.Templates
{
    public static class PilotAssignmentTemplate
    {
        public static string Build(string userName, string flightId, string departure, string origin, string destination)
        {
            return $@"
            <!DOCTYPE html>
            <html lang=""es"">
            <head>
                <meta charset=""UTF-8"" />
                <title>Asignación de vuelo</title>
            </head>

            <body style=""margin:0; padding:0; font-family:system-ui, -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif; background-color:#f3f4f6;"">

                <table width=""100%"" cellpadding=""0"" cellspacing=""0"">
                    <tr>
                        <td align=""center"" style=""padding:24px 12px;"">

                            <!-- CARD -->
                            <table width=""100%"" cellpadding=""0"" cellspacing=""0""
                                   style=""max-width:600px; background-color:#ffffff; border-radius:16px;
                                   overflow:hidden; box-shadow:0 10px 25px rgba(15,23,42,0.08);"">

                                <!-- HEADER -->
                                <tr>
                                    <td style=""background:linear-gradient(135deg,#7f1d1d,#b91c1c);
                                               padding:20px 24px; color:#fef2f2;"">
                                        <h1 style=""margin:0; font-size:20px; color:#fef2f2;"">
                                            Nueva asignación de vuelo
                                        </h1>
                                        <p style=""margin:6px 0 0 0; font-size:13px; color:#fde2e2;"">
                                            Has sido asignado a un vuelo operativo de AeroCaribe.
                                        </p>
                                    </td>
                                </tr>

                                <!-- BODY -->
                                <tr>
                                    <td style=""padding:20px 24px; font-size:14px; color:#111827;"">

                                        <p style=""margin:0 0 12px 0;"">
                                            Hola <strong>{System.Net.WebUtility.HtmlEncode(userName)}</strong>,
                                        </p>

                                        <p style=""margin:0 0 12px 0; line-height:1.6;"">
                                            Se te ha asignado el <strong>vuelo #{flightId}</strong>.  
                                            A continuación encontrarás los detalles principales:
                                        </p>

                                        <p style=""margin:0 0 12px 0; line-height:1.6;"">
                                            <strong>Salida:</strong> {departure}<br/>
                                            <strong>Origen:</strong> {System.Net.WebUtility.HtmlEncode(origin)}<br/>
                                            <strong>Destino:</strong> {System.Net.WebUtility.HtmlEncode(destination)}
                                        </p>

                                        <p style=""margin:0 0 12px 0; line-height:1.6;"">
                                            Por favor ingresa a la aplicación de <strong>AeroCaribe</strong> para revisar toda la información del vuelo y confirmar tu disponibilidad.
                                        </p>
                                    </td>
                                </tr>

                                <!-- FOOTER -->
                                <tr>
                                    <td style=""padding:20px 24px 16px 24px; font-size:11px; 
                                               color:#9ca3af; border-top:1px solid #e5e7eb;"">
                                        <p style=""margin:0 0 4px 0;"">
                                            Este mensaje fue enviado automáticamente por el sistema operativo de vuelos de <strong>AeroCaribe</strong>.
                                        </p>
                                        <p style=""margin:0;"">
                                            © {DateTime.UtcNow.Year} AeroCaribe. Todos los derechos reservados.
                                        </p>
                                    </td>
                                </tr>

                            </table>

                        </td>
                    </tr>
                </table>

            </body>
            </html>";
        }
    }
}
