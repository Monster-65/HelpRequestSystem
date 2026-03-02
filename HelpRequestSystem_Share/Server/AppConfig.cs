using System;
using System.IO;
using System.Text.Json;

namespace Server;

public class AppConfig
{
    // ═══════════════════════════════════════════════════════════
    // SERVER CON CARTELLA CONDIVISA
    // Questa versione monitora una cartella condivisa Windows per
    // ricevere le richieste, senza bisogno di porte di rete aperte
    // ═══════════════════════════════════════════════════════════
    
    // Percorso della cartella condivisa Windows
    // Esempi:
    //   Windows: "\\\\192.168.0.114\\HelpRequests" o "\\\\SERVER\\HelpRequests"
    //   Linux:   "/mnt/helprequests" o "//192.168.0.114/HelpRequests"
    public string SharePath { get; set; } = "//192.168.0.114/HelpRequests";
    
    // Intervallo di polling (secondi) - quanto spesso controllare nuovi file
    public int PollIntervalSeconds { get; set; } = 2;
    
    // Eliminazione automatica dei file processati
    public bool AutoDeleteProcessedFiles { get; set; } = true;
    
    // ═══════════════════════════════════════════════════════════
    // CONFIGURAZIONE LOG
    // ═══════════════════════════════════════════════════════════
    public string LogFilePath { get; set; } = "server_log.txt";
    public bool EnableFileLogging { get; set; } = true;
    public bool EnableConsoleLogging { get; set; } = true;

    // Singleton pattern
    private static AppConfig? _instance;
    private static readonly object _lock = new object();

    public static AppConfig Instance
    {
        get
        {
            if (_instance == null)
            {
                lock (_lock)
                {
                    if (_instance == null)
                    {
                        _instance = LoadConfig();
                    }
                }
            }
            return _instance;
        }
    }

    private static AppConfig LoadConfig()
    {
        var configPath = "server_config.json";
        
        if (File.Exists(configPath))
        {
            try
            {
                var json = File.ReadAllText(configPath);
                var config = JsonSerializer.Deserialize<AppConfig>(json);
                if (config != null)
                {
                    Console.WriteLine("Configurazione caricata da server_config.json");
                    return config;
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Errore caricamento config: {ex.Message}. Uso configurazione predefinita.");
            }
        }
        
        // Crea file di configurazione predefinito
        var defaultConfig = new AppConfig();
        try
        {
            var json = JsonSerializer.Serialize(defaultConfig, new JsonSerializerOptions { WriteIndented = true });
            File.WriteAllText(configPath, json);
            Console.WriteLine("Creato file di configurazione predefinito: server_config.json");
        }
        catch (Exception ex)
        {
            Console.WriteLine($"Impossibile creare config file: {ex.Message}");
        }
        
        return defaultConfig;
    }

    public void Save()
    {
        try
        {
            var json = JsonSerializer.Serialize(this, new JsonSerializerOptions { WriteIndented = true });
            File.WriteAllText("server_config.json", json);
            Console.WriteLine("Configurazione salvata");
        }
        catch (Exception ex)
        {
            Console.WriteLine($"Errore salvataggio config: {ex.Message}");
        }
    }
}
