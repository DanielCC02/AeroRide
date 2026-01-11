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
                            View available empty legs
                        </a>
                    </td>
                </tr>";

            var sb = new StringBuilder();

            sb.Append($@"
            <!DOCTYPE html>
            <html lang=""en"">
            <head>
                <meta charset=""UTF-8"" />
                <title>New empty legs available</title>
            </head>
            <body style=""margin:0; padding:0; font-family:system-ui, -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif; background-color:#f3f4f6;"">
                <table width=""100%"" cellpadding=""0"" cellspacing=""0"" border=""0"">
                    <tr>
                        <td align=""center"" style=""padding:24px 12px;"">
                            <table width=""100%"" cellpadding=""0"" cellspacing=""0"" border=""0"" style=""max-width:600px; background-color:#ffffff; border-radius:16px; overflow:hidden; box-shadow:0 10px 25px rgba(15,23,42,0.08);"">
                                <tr>
                                    <td style=""background:linear-gradient(135deg,#7f1d1d,#b91c1c); padding:20px 24px; color:#fef2f2;"">
                                        <h1 style=""margin:0; font-size:20px; color:#fef2f2;"">
                                            New empty legs in {country}
                                        </h1>
                                        <p style=""margin:6px 0 0 0; font-size:13px; color:#fde2e2;"">
                                            Special private flight offers, subject to availability.
                                        </p>
                                    </td>
                                </tr>

                                <tr>
                                    <td style=""padding:20px 24px 8px 24px; font-size:14px; color:#111827;"">
                                        <p style=""margin:0 0 12px 0;"">
                                            Hello <strong>{System.Net.WebUtility.HtmlEncode(userName)}</strong>,
                                        </p>
                                        <p style=""margin:0 0 12px 0; line-height:1.5;"">
                                            <strong>New empty legs</strong> have been generated departing from airports in
                                            <strong>{System.Net.WebUtility.HtmlEncode(country)}</strong>.
                                            These routes usually offer special fares and have limited availability.
                                        </p>
                                        <p style=""margin:0 0 8px 0; font-weight:600; font-size:13px; text-transform:uppercase; color:#7f1d1d;"">
                                            Available routes:
                                        </p>
                                    </td>
                                </tr>

                                <tr>
                                    <td style=""padding:0 24px 16px 24px;"">
                                        <ul style=""margin:0; padding-left:18px; font-size:13px; color:#374151; line-height:1.6;"">
                                            {legsListItemsHtml}
                                        </ul>
                                        <p style=""margin:12px 0 0 0; font-size:12px; color:#9ca3af;"">
                                            * Schedules are subject to change and will be confirmed at the time of booking.
                                        </p>
                                    </td>
                                </tr>

                                {buttonHtml}

                                <tr>
                                    <td style=""padding:20px 24px 16px 24px; font-size:11px; color:#9ca3af; border-top:1px solid #e5e7eb;"">
                                        <p style=""margin:0 0 4px 0;"">
                                            You are receiving this email because you have an active account with <strong>AeroCaribe</strong>
                                            and are registered in {System.Net.WebUtility.HtmlEncode(country)}.
                                        </p>
                                        <p style=""margin:0;"">
                                            If you no longer wish to receive empty leg notifications, please contact AeroCaribe support.
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
