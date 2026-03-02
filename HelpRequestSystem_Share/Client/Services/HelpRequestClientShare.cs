using System;
using System.IO;
using System.Text.Json;
using Client.Models;

namespace Client.Services;

/// <summary>
/// Client per richieste di aiuto basato su cartella condivisa
/// Scrive file JSON invece di inviare richieste HTTP
/// </summary>
public class HelpRequestClientShare
{
    private readonly string _sharePath;
    
    public HelpRequestClientShare(string sharePath)
    {
        _sharePath = sharePath;
        Logger.Log($"📁 Client configurato con cartella condivisa: {_sharePath}");
    }
    
    /// <summary>
    /// Invia una richiesta scrivendo un file JSON nella cartella condivisa
    /// </summary>
    public void Send(HelpRequest req)
    {
        try
        {
            Logger.Log($"📤 Preparazione richiesta - User: {req.User}");
            
            // Valida la cartella condivisa
            if (!Directory.Exists(_sharePath))
            {
                Logger.Log($"❌ ERRORE: Cartella condivisa non accessibile: {_sharePath}");
                throw new DirectoryNotFoundException($"La cartella condivisa '{_sharePath}' non è accessibile. Verifica che:\n" +
                    "1. La cartella sia condivisa correttamente\n" +
                    "2. Hai i permessi di scrittura\n" +
                    "3. Il percorso sia corretto (es: //192.168.0.114/HelpRequests)");
            }
            
            // Genera nome file unico: richiesta_YYYYMMDD_HHmmss_ComputerName.json
            string timestamp = DateTime.Now.ToString("yyyyMMdd_HHmmss");
            string fileName = $"richiesta_{timestamp}_{req.ComputerName}.json";
            string filePath = Path.Combine(_sharePath, fileName);
            
            Logger.Log($"📝 Creazione file: {fileName}");
            
            // Serializza la richiesta in JSON
            string json = JsonSerializer.Serialize(req, new JsonSerializerOptions 
            { 
                WriteIndented = true 
            });
            
            // Scrivi il file nella cartella condivisa
            File.WriteAllText(filePath, json);
            
            Logger.Log($"✅ Richiesta salvata con successo!");
            Logger.Log($"   Percorso: {filePath}");
            Logger.Log($"   Dimensione: {json.Length} bytes");
        }
        catch (UnauthorizedAccessException ex)
        {
            Logger.Log($"❌ ERRORE: Permessi insufficienti per scrivere nella cartella condivisa");
            Logger.Log($"   Dettagli: {ex.Message}");
            throw new Exception($"Permessi insufficienti per accedere a '{_sharePath}'.\n" +
                "Verifica di avere i permessi di scrittura sulla cartella condivisa.", ex);
        }
        catch (IOException ex)
        {
            Logger.Log($"❌ ERRORE: Impossibile scrivere il file");
            Logger.Log($"   Dettagli: {ex.Message}");
            throw new Exception($"Errore di I/O durante la scrittura del file.\n" +
                "La cartella condivisa potrebbe non essere disponibile.", ex);
        }
        catch (Exception ex)
        {
            Logger.Log($"❌ ERRORE: {ex.Message}");
            Logger.Log($"   Tipo: {ex.GetType().Name}");
            Logger.Log($"   StackTrace: {ex.StackTrace}");
            throw new Exception($"Errore durante l'invio della richiesta: {ex.Message}", ex);
        }
    }
}
