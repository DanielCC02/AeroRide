using System.Text;

namespace AeroRide.API.Helpers.Templates
{
    /// <summary>
    /// HTML template for account email verification.
    /// </summary>
    public static class EmailVerificationTemplate
    {
        public static string Build(string userName, string verificationLink)
        {
            var sb = new StringBuilder();

            sb.Append($@"
            <!DOCTYPE html>
            <html lang=""en"">
            <head>
                <meta charset=""UTF-8"" />
                <title>Verify your account</title>
            </head>

            <body style=""margin:0; padding:0; font-family:system-ui, -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif; background-color:#f3f4f6;"">

                <table width=""100%"" cellpadding=""0"" cellspacing=""0"">
                    <tr>
                        <td align=""center"" style=""padding:24px 12px;"">

                            <!-- CARD -->
                            <table width=""100%"" cellpadding=""0"" cellspacing=""0"" style=""max-width:600px; background-color:#ffffff; border-radius:16px; overflow:hidden; box-shadow:0 10px 25px rgba(15,23,42,0.08);"">

                                <!-- HEADER -->
                                <tr>
                                    <td style=""background:linear-gradient(135deg,#7f1d1d,#b91c1c); padding:20px 24px; color:#fef2f2;"">
                                        <h1 style=""margin:0; font-size:20px; color:#fef2f2;"">
                                            Verify your AeroCaribe account
                                        </h1>
                                        <p style=""margin:6px 0 0 0; font-size:13px; color:#fde2e2;"">
                                            Activate your access to the private flight platform.
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
                                            Thank you for registering with <strong>AeroCaribe</strong>.
                                            To start using your account, please verify your email address by clicking the button below.
                                        </p>
                                    </td>
                                </tr>

                                <!-- BUTTON -->
                                <tr>
                                    <td align=""center"" style=""padding: 0 0 20px 0;"">
                                        <a href=""{verificationLink}""
                                           style=""background-color:#b91c1c;
                                                  color:#ffffff;
                                                  padding:12px 24px;
                                                  border-radius:999px;
                                                  text-decoration:none;
                                                  font-weight:600;
                                                  font-size:14px;
                                                  display:inline-block;"">
                                            Verify my account
                                        </a>
                                    </td>
                                </tr>

                                <!-- FOOTER -->
                                <tr>
                                    <td style=""padding:20px 24px 16px 24px; font-size:11px; color:#9ca3af; border-top:1px solid #e5e7eb;"">
                                        <p style=""margin:0 0 4px 0;"">
                                            You are receiving this email because you created an account on <strong>AeroCaribe</strong>.
                                        </p>
                                        <p style=""margin:0;"">
                                            If you did not create this account, you can safely ignore this message.
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
