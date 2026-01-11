namespace AeroRide.API.Helpers.Templates
{
    public static class PasswordResetTemplate
    {
        public static string Build(string userName, string resetLink)
        {
            return $@"
            <!DOCTYPE html>
            <html lang=""en"">
            <head>
                <meta charset=""UTF-8"" />
                <title>Reset password</title>
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
                                            Reset your password
                                        </h1>
                                        <p style=""margin:6px 0 0 0; font-size:13px; color:#fde2e2;"">
                                            Use the secure link to create a new password.
                                        </p>
                                    </td>
                                </tr>

                                <!-- BODY -->
                                <tr>
                                    <td style=""padding:20px 24px 8px 24px; font-size:14px; color:#111827;"">
                                        <p style=""margin:0 0 12px 0;"">
                                            Hello <strong>{System.Net.WebUtility.HtmlEncode(userName)}</strong>,
                                        </p>

                                        <p style=""margin:0 0 12px 0; line-height:1.6;"">
                                            We received a request to reset your <strong>AeroCaribe</strong> password.
                                        </p>

                                        <p style=""margin:0 0 12px 0; line-height:1.6;"">
                                            Click the button below to continue with the process:
                                        </p>
                                    </td>
                                </tr>

                                <!-- BUTTON -->
                                <tr>
                                    <td align=""center"" style=""padding: 0 0 20px 0;"">
                                        <a href=""{resetLink}""
                                           style=""background-color:#b91c1c;
                                                  color:#ffffff;
                                                  padding:12px 24px;
                                                  border-radius:999px;
                                                  text-decoration:none;
                                                  font-weight:600;
                                                  font-size:14px;
                                                  display:inline-block;"">
                                            Reset password
                                        </a>
                                    </td>
                                </tr>

                                <!-- BODY CONTINUES -->
                                <tr>
                                    <td style=""padding:0 24px 20px 24px; font-size:13px; color:#374151;"">
                                        <p style=""margin:0;"">
                                            This link will expire in <strong>30 minutes</strong>.
                                            If you did not request this change, you can safely ignore this message.
                                        </p>
                                    </td>
                                </tr>

                                <!-- FOOTER -->
                                <tr>
                                    <td style=""padding:20px 24px 16px 24px; font-size:11px; 
                                               color:#9ca3af; border-top:1px solid #e5e7eb;"">
                                        <p style=""margin:0 0 4px 0;"">
                                            You are receiving this email because you have an active account with <strong>AeroCaribe</strong>.
                                        </p>
                                        <p style=""margin:0;"">
                                            If you did not request a password reset, no further action is required.
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
