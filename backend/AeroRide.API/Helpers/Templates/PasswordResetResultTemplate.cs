using System.Net;

namespace AeroRide.Helpers.Templates;

public static class PasswordResetResultTemplate
{
    // ======================================================
    // FORM (con error opcional)
    // ======================================================
    public static string Form(string token, string? errorMessage = null)
    {
        token = WebUtility.HtmlEncode(token);

        return $@"
            <!DOCTYPE html>
            <html lang=""en"">
            <head>
              <meta charset=""UTF-8"" />
              <meta name=""viewport"" content=""width=device-width, initial-scale=1.0"" />
              <title>Reset password</title>
            </head>
            <body style=""margin:0; padding:0; font-family:system-ui, -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif; background-color:#f3f4f6;"">
              <table width=""100%"" cellpadding=""0"" cellspacing=""0"">
                <tr>
                  <td align=""center"" style=""padding:48px 16px;"">
                    <table width=""100%"" cellpadding=""0"" cellspacing=""0""
                           style=""max-width:720px; background:#ffffff; border-radius:20px;
                                  overflow:hidden; box-shadow:0 20px 40px rgba(15,23,42,.12);"">

                      <!-- HEADER -->
                      <tr>
                        <td style=""background:linear-gradient(135deg,#7f1d1d,#b91c1c);
                                   padding:56px 40px; text-align:center; color:#fef2f2;"">
                          <h1 style=""margin:0; font-size:28px; font-weight:700;"">
                            Reset your password
                          </h1>
                          <p style=""margin:12px 0 0 0; font-size:15px; color:#fde2e2;"">
                            Choose a new secure password for your AeroCaribe account
                          </p>
                        </td>
                      </tr>

                      <!-- ERROR (ONLY FORM ERRORS) -->
                      {(!string.IsNullOrEmpty(errorMessage) ? $@"
                      <tr>
                        <td style=""padding:24px 48px 0 48px;"">
                          <div style=""
                            background:#fee2e2;
                            color:#7f1d1d;
                            padding:14px 18px;
                            border-radius:12px;
                            font-weight:600;
                            text-align:center;"">
                            {WebUtility.HtmlEncode(errorMessage)}
                          </div>
                        </td>
                      </tr>
                      " : "")}

                      <!-- FORM -->
                      <tr>
                        <td style=""padding:40px 48px; font-size:15px; color:#111827;"">
                          <form method=""post"" action=""/auth/reset-password"">
                            <input type=""hidden"" name=""token"" value=""{token}"" />

                            <label style=""font-weight:600;"">New password</label>
                            <input type=""password"" name=""newPassword"" required
                                   style=""width:100%; padding:14px; margin:8px 0 16px;
                                          border-radius:10px; border:1px solid #d1d5db;""/>

                            <p style=""margin:0 0 20px 0; font-size:13px; color:#6b7280;"">
                              Password must be at least 8 characters long.
                            </p>

                            <label style=""font-weight:600;"">Confirm password</label>
                            <input type=""password"" name=""confirmPassword"" required
                                   style=""width:100%; padding:14px; margin:8px 0 28px;
                                          border-radius:10px; border:1px solid #d1d5db;""/>

                            <button type=""submit""
                                    style=""width:100%; background:#b91c1c; color:#ffffff;
                                           border:none; padding:16px 24px;
                                           border-radius:999px; font-weight:700; cursor:pointer;"">
                              Update password
                            </button>
                          </form>
                        </td>
                      </tr>

                      <!-- FOOTER -->
                      <tr>
                        <td style=""padding:20px 48px; font-size:12px; color:#9ca3af;
                                   border-top:1px solid #e5e7eb;"">
                          AeroCaribe — Private aviation solutions.
                        </td>
                      </tr>

                    </table>
                  </td>
                </tr>
              </table>
            </body>
            </html>";
    }

    // ======================================================
    // SUCCESS PAGE
    // ======================================================
    public static string Success()
    {
        return FinalPage(
            "Password updated",
            "Your password has been successfully updated. You can now log in to AeroCaribe.",
            success: true
        );
    }

    // ======================================================
    // FINAL ERROR PAGE (TOKEN / SECURITY ERRORS)
    // ======================================================
    public static string ErrorFinal(string message)
    {
        return FinalPage(
            "Reset failed",
            message,
            success: false
        );
    }

    // ======================================================
    // SHARED FINAL PAGE
    // ======================================================
    private static string FinalPage(string title, string message, bool success)
    {
        var gradient = success
            ? "linear-gradient(135deg,#065f46,#16a34a)"
            : "linear-gradient(135deg,#7f1d1d,#b91c1c)";

        var icon = success ? "✅" : "❌";

        return $@"
            <!DOCTYPE html>
            <html lang=""en"">
            <head>
              <meta charset=""UTF-8"" />
              <meta name=""viewport"" content=""width=device-width, initial-scale=1.0"" />
              <title>{title}</title>
            </head>
            <body style=""margin:0; padding:0; font-family:system-ui; background:#f3f4f6;"">
              <table width=""100%"" cellpadding=""0"" cellspacing=""0"">
                <tr>
                  <td align=""center"" style=""padding:64px 16px;"">
                    <table style=""max-width:720px; background:#ffffff; border-radius:20px;
                                   overflow:hidden; box-shadow:0 20px 40px rgba(15,23,42,.12);"">
                      <tr>
                        <td style=""background:{gradient};
                                   padding:56px 40px; text-align:center; color:#ffffff;"">
                          <div style=""font-size:52px; margin-bottom:12px;"">{icon}</div>
                          <h1 style=""margin:0; font-size:28px; font-weight:700;"">{title}</h1>
                        </td>
                      </tr>
                      <tr>
                        <td style=""padding:40px 48px; text-align:center; color:#374151;"">
                          <p style=""margin:0 0 12px 0;"">
                            {WebUtility.HtmlEncode(message)}
                          </p>
                          <p style=""font-size:13px; color:#9ca3af;"">
                            You may now safely close this tab.
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
