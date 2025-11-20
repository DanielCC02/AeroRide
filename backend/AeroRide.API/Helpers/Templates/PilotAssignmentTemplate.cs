namespace AeroRide.API.Helpers.Templates
{
    public static class PilotAssignmentTemplate
    {
        public static string Build(string userName, string flightId, string departure, string origin, string destination)
        {
            return $@"
            <html>
            <head>
                <meta charset='utf-8'>
                <style>
                    body {{
                        font-family: 'Segoe UI', sans-serif;
                        background-color: #f4f7fa;
                        margin: 0;
                        padding: 0;
                    }}
                    .container {{
                        max-width: 600px;
                        margin: 40px auto;
                        background-color: #ffffff;
                        border-radius: 10px;
                        box-shadow: 0 4px 10px rgba(0, 0, 0, 0.1);
                        padding: 30px;
                    }}
                    .header {{
                        text-align: center;
                        color: #0d47a1;
                        font-size: 22px;
                        font-weight: bold;
                    }}
                    .content {{
                        color: #333;
                        font-size: 16px;
                        line-height: 1.6;
                        margin-top: 20px;
                    }}
                    .footer {{
                        text-align: center;
                        color: #777;
                        font-size: 13px;
                        margin-top: 30px;
                    }}
                </style>
            </head>
            <body>
                <div class='container'>
                    <div class='header'>Asignación de Vuelo AeroRide ✈️</div>

                    <div class='content'>
                        <p>Hola <strong>{userName}</strong>,</p>

                        <p>Has sido asignado al <strong>vuelo #{flightId}</strong>.</p>

                        <p>
                            <strong>Salida:</strong> {departure}<br/>
                            <strong>Origen:</strong> {origin}<br/>
                            <strong>Destino:</strong> {destination}
                        </p>

                        <p>Por favor ingresa a la app AeroRide para revisar los detalles del vuelo.</p>
                    </div>

                    <div class='footer'>
                        © {DateTime.UtcNow.Year} AeroRide. Todos los derechos reservados.
                    </div>
                </div>
            </body>
            </html>";
        }
    }
}
