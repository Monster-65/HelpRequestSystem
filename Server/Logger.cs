using System;
using System.IO;

namespace Server;

public static class Logger
{
    private static readonly object _lock = new object();

    public static void Log(string message)
    {
        var timestamp = DateTime.Now.ToString("yyyy-MM-dd HH:mm:ss");
        var logMessage = $"[{timestamp}] {message}";

        lock (_lock)
        {
            // Console (se abilitato)
            if (AppConfig.Instance.EnableConsoleLogging)
            {
                Console.WriteLine(logMessage);
            }

            // File (se abilitato)
            if (AppConfig.Instance.EnableFileLogging)
            {
                try
                {
                    File.AppendAllText(AppConfig.Instance.LogFilePath, logMessage + Environment.NewLine);
                }
                catch
                {
                    // Fallback su console se il file non è scrivibile
                    Console.WriteLine($"[WARN] Impossibile scrivere nel file di log: {logMessage}");
                }
            }
        }
    }

    public static void LogError(string message, Exception? ex = null)
    {
        var errorMessage = ex != null ? $"ERRORE: {message} - {ex.Message}" : $"ERRORE: {message}";
        Log(errorMessage);
        
        if (ex != null && ex.StackTrace != null)
        {
            Log($"StackTrace: {ex.StackTrace}");
        }
    }
}
