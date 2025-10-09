namespace AeroRide.API.Helpers.Templates
{
    /// <summary>
    /// Plantilla HTML para el correo de verificación de cuenta.
    /// </summary>
    public static class EmailVerificationTemplate
    {
        public static string Build(string userName, string verificationLink)
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
                        color: #1a73e8;
                        font-size: 22px;
                        font-weight: bold;
                    }}
                    .content {{
                        color: #333;
                        font-size: 16px;
                        line-height: 1.6;
                        margin-top: 20px;
                    }}
                    .button {{
                        display: inline-block;
                        padding: 12px 25px;
                        margin: 30px 0;
                        background-color: #1a73e8;
                        color: white;
                        text-decoration: none;
                        border-radius: 6px;
                        font-weight: 600;
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
                    <div class='header'>Verifica tu cuenta AeroRide ✈️</div>
                    <div class='content'>
                        <p>Hola <strong>{userName}</strong>,</p>
                        <p>Gracias por registrarte en <strong>AeroRide</strong>.  
                        Antes de comenzar a disfrutar de nuestros vuelos, por favor verifica tu dirección de correo electrónico.</p>
                        <p style='text-align:center;'>
                            <a href='{verificationLink}' class='button'>Verificar mi cuenta</a>
                        </p>
                        <p>Si tú no creaste esta cuenta, puedes ignorar este correo.</p>
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
