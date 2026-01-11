using System.Net;
using System.Text;

namespace AeroRide.Helpers.Templates;

public static class EmailVerificationResultTemplate
{
    public static string Success(string message)
    {
        message = WebUtility.HtmlEncode(message);

        var sb = new StringBuilder();

        sb.Append($@"
                <!DOCTYPE html>
                <html lang=""en"">
                <head>
                    <meta charset=""UTF-8"" />
                    <meta name=""viewport"" content=""width=device-width, initial-scale=1.0"" />
                    <title>Account verified</title>
                </head>
                <body style=""margin:0; padding:0; font-family:system-ui, -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif; background-color:#f3f4f6;"">
                    <table width=""100%"" cellpadding=""0"" cellspacing=""0"">
                        <tr>
                            <td align=""center"" style=""padding:40px 16px;"">
                                <table width=""100%"" cellpadding=""0"" cellspacing=""0""
                                       style=""max-width:720px; background-color:#ffffff; border-radius:20px;
                                              overflow:hidden; box-shadow:0 20px 40px rgba(15,23,42,0.12);"">

                                    <!-- HERO HEADER -->
                                    <tr>
                                        <td style=""background:linear-gradient(135deg,#7f1d1d,#b91c1c);
                                                   padding:48px 32px; text-align:center; color:#fef2f2;"">
                                            <div style=""font-size:48px; line-height:1;"">✅</div>
                                            <h1 style=""margin:16px 0 8px 0; font-size:28px; font-weight:700;"">
                                                Account verified
                                            </h1>
                                            <p style=""margin:0; font-size:15px; color:#fde2e2;"">
                                                Your AeroCaribe account is now active
                                            </p>
                                        </td>
                                    </tr>

                                    <!-- MAIN CONTENT -->
                                    <tr>
                                        <td style=""padding:40px 40px 32px 40px; color:#111827; font-size:16px;"">
                                            <p style=""margin:0 0 16px 0; line-height:1.6;"">
                                                <strong>Success!</strong>
                                            </p>
                                            <p style=""margin:0 0 20px 0; line-height:1.6;"">
                                                {message}
                                            </p>
                                            <p style=""margin:0; line-height:1.6; color:#374151;"">
                                                You can now safely close this tab and return to the AeroCaribe application.
                                                Your account is fully verified and ready to use.
                                            </p>
                                        </td>
                                    </tr>

                                    <!-- INFO STRIP -->
                                    <tr>
                                        <td style=""padding:20px 40px; background-color:#f9fafb; color:#374151; font-size:14px;"">
                                            <p style=""margin:0;"">
                                                If you did not request this verification, please contact AeroCaribe support immediately.
                                            </p>
                                        </td>
                                    </tr>

                                    <!-- FOOTER -->
                                    <tr>
                                        <td style=""padding:24px 40px; font-size:12px; color:#9ca3af;
                                                   border-top:1px solid #e5e7eb;"">
                                            <p style=""margin:0;"">
                                                Thank you for choosing <strong>AeroCaribe</strong> — Private aviation solutions.
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

    public static string Error(string message)
    {
        message = WebUtility.HtmlEncode(message);

        var sb = new StringBuilder();

        sb.Append($@"
<!DOCTYPE html>
<html lang=""en"">
<head>
    <meta charset=""UTF-8"" />
    <meta name=""viewport"" content=""width=device-width, initial-scale=1.0"" />
    <title>Verification error</title>
</head>
<body style=""margin:0; padding:0; font-family:system-ui, -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif; background-color:#f3f4f6;"">
    <table width=""100%"" cellpadding=""0"" cellspacing=""0"">
        <tr>
            <td align=""center"" style=""padding:40px 16px;"">
                <table width=""100%"" cellpadding=""0"" cellspacing=""0""
                       style=""max-width:720px; background-color:#ffffff; border-radius:20px;
                              overflow:hidden; box-shadow:0 20px 40px rgba(15,23,42,0.12);"">

                    <!-- HEADER -->
                    <tr>
                        <td style=""background:linear-gradient(135deg,#7f1d1d,#b91c1c);
                                   padding:48px 32px; text-align:center; color:#fef2f2;"">
                            <div style=""font-size:48px; line-height:1;"">❌</div>
                            <h1 style=""margin:16px 0 8px 0; font-size:28px; font-weight:700;"">
                                Verification failed
                            </h1>
                            <p style=""margin:0; font-size:15px; color:#fde2e2;"">
                                We could not verify your account
                            </p>
                        </td>
                    </tr>

                    <!-- CONTENT -->
                    <tr>
                        <td style=""padding:40px; color:#111827; font-size:16px;"">
                            <p style=""margin:0 0 16px 0; line-height:1.6;"">
                                {message}
                            </p>
                            <p style=""margin:0; line-height:1.6; color:#374151;"">
                                Please request a new verification email or contact AeroCaribe support for assistance.
                            </p>
                        </td>
                    </tr>

                    <!-- FOOTER -->
                    <tr>
                        <td style=""padding:24px 40px; font-size:12px; color:#9ca3af;
                                   border-top:1px solid #e5e7eb;"">
                            <p style=""margin:0;"">
                                AeroCaribe — Private aviation solutions.
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
