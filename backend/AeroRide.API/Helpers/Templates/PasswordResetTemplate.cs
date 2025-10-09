namespace AeroRide.API.Helpers.Templates
{
    public static class PasswordResetTemplate
    {
        public static string Build(string userName, string resetLink)
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
                        color: #d32f2f;
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
                        background-color: #d32f2f;
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
                    <div class='header'>Restablecer tu contraseña 🔑</div>
                    <div class='content'>
                        <p>Hola <strong>{userName}</strong>,</p>
                        <p>Recibimos una solicitud para restablecer tu contraseña de AeroRide.</p>
                        <p>Haz clic en el siguiente botón para crear una nueva contraseña:</p>
                        <p style='text-align:center;'>
                            <a href='{resetLink}' class='button'>Restablecer contraseña</a>
                        </p>
                        <p>Este enlace expirará en 30 minutos. Si no solicitaste este cambio, ignora este mensaje.</p>
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
