using System;
using System.Collections.Generic;
using System.IO;
using System.Text.Json;
using System.Threading;
using System.Threading.Tasks;
using Server.Models;
using Server.ViewModels;

namespace Server.Services;

/// <summary>
/// Server per richieste di aiuto basato su cartella condivisa
/// Monitora la cartella e processa i file JSON ricevuti
/// </summary>
public class HelpRequestServerShare
{
    private readonly MainWindowViewModel _vm;
    private readonly string _sharePath;
    private readonly int _pollIntervalMs;
    private readonly bool _autoDeleteProcessed;
    private CancellationTokenSource? _cts;
    private Task? _monitorTask;
    private readonly HashSet<string> _processedFiles = new();
    
    public HelpRequestServerShare(MainWindowViewModel vm, string sharePath, int pollIntervalSeconds = 2, bool autoDeleteProcessed = true)
    {
        _vm = vm ?? throw new ArgumentNullException(nameof(vm));
        _sharePath = sharePath;
        _pollIntervalMs = pollIntervalSeconds * 1000;
        _autoDeleteProcessed = autoDeleteProcessed;
        
        Logger.Log($"📁 Server configurato con cartella condivisa: {_sharePath}");
        Logger.Log($"🔄 Intervallo polling: {pollIntervalSeconds} secondi");
        Logger.Log($"🗑️ Eliminazione automatica file processati: {_autoDeleteProcessed}");
    }
    
    /// <summary>
    /// Avvia il monitoraggio della cartella condivisa
    /// </summary>
    public void Start()
    {
        if (_monitorTask != null)
        {
            Logger.Log("⚠️ Server già in esecuzione");
            return;
        }
        
        try
        {
            // Valida la cartella condivisa
            if (!Directory.Exists(_sharePath))
            {
                Logger.Log($"❌ ERRORE: Cartella condivisa non accessibile: {_sharePath}");
                throw new DirectoryNotFoundException($"La cartella condivisa '{_sharePath}' non esiste o non è accessibile.\n" +
                    "Verifica che:\n" +
                    "1. La cartella sia condivisa correttamente\n" +
                    "2. Hai i permessi di lettura\n" +
                    "3. Il percorso sia corretto");
            }
            
            _cts = new CancellationTokenSource();
            _monitorTask = Task.Run(() => MonitorLoop(_cts.Token));
            
            Logger.Log($"✅ Server avviato - Monitoraggio cartella: {_sharePath}");
            Logger.Log($"👀 In attesa di richieste...");
        }
        catch (Exception ex)
        {
            Logger.Log($"❌ ERRORE durante l'avvio del server: {ex.Message}");
            Logger.Log($"   StackTrace: {ex.StackTrace}");
            throw;
        }
    }
    
    /// <summary>
    /// Ferma il monitoraggio della cartella
    /// </summary>
    public void Stop()
    {
        if (_cts == null || _monitorTask == null)
        {
            Logger.Log("⚠️ Server non in esecuzione");
            return;
        }
        
        try
        {
            Logger.Log("🛑 Arresto server...");
            _cts.Cancel();
            _monitorTask.Wait(5000); // Timeout 5 secondi
            
            _cts.Dispose();
            _cts = null;
            _monitorTask = null;
            
            Logger.Log("✅ Server arrestato correttamente");
        }
        catch (Exception ex)
        {
            Logger.Log($"⚠️ Errore durante l'arresto: {ex.Message}");
        }
    }
    
    /// <summary>
    /// Loop principale di monitoraggio
    /// </summary>
    private async Task MonitorLoop(CancellationToken token)
    {
        Logger.Log("🔄 Loop di monitoraggio avviato");
        
        while (!token.IsCancellationRequested)
        {
            try
            {
                // Cerca file JSON nella cartella condivisa
                var files = Directory.GetFiles(_sharePath, "richiesta_*.json");
                
                foreach (var filePath in files)
                {
                    // Salta file già processati
                    if (_processedFiles.Contains(filePath))
                        continue;
                    
                    try
                    {
                        await ProcessFile(filePath);
                        _processedFiles.Add(filePath);
                    }
                    catch (Exception ex)
                    {
                        Logger.Log($"❌ Errore processando {Path.GetFileName(filePath)}: {ex.Message}");
                    }
                }
                
                // Attendi prima del prossimo controllo
                await Task.Delay(_pollIntervalMs, token);
            }
            catch (OperationCanceledException)
            {
                // Normale interruzione
                break;
            }
            catch (Exception ex)
            {
                Logger.Log($"❌ Errore nel loop di monitoraggio: {ex.Message}");
                await Task.Delay(5000, token); // Attendi 5 sec prima di riprovare
            }
        }
        
        Logger.Log("🛑 Loop di monitoraggio terminato");
    }
    
    /// <summary>
    /// Processa un singolo file JSON
    /// </summary>
    private async Task ProcessFile(string filePath)
    {
        string fileName = Path.GetFileName(filePath);
        
        Logger.Log($"📨 File rilevato: {fileName}");
        
        try
        {
            // Attendi un attimo per assicurarsi che il file sia completamente scritto
            await Task.Delay(100);
            
            // Leggi il contenuto del file
            string json = await File.ReadAllTextAsync(filePath);
            
            Logger.Log($"📖 Lettura file completata ({json.Length} bytes)");
            
            // Deserializza la richiesta
            var req = JsonSerializer.Deserialize<HelpRequest>(json);
            
            if (req == null)
            {
                Logger.Log($"❌ File JSON non valido: impossibile deserializzare");
                return;
            }
            
            Logger.Log($"✓ Richiesta deserializzata correttamente");
            Logger.Log($"   Computer: {req.ComputerName}");
            Logger.Log($"   User: {req.User}");
            Logger.Log($"   Message: {req.Message}");
            Logger.Log($"   Timestamp: {req.Timestamp}");
            
            // Aggiungi alla lista del ViewModel
            _vm.AddRequest(req);
            
            Logger.Log($"✓ Richiesta aggiunta alla lista");
            
            // Elimina il file se configurato
            if (_autoDeleteProcessed)
            {
                File.Delete(filePath);
                Logger.Log($"🗑️ File eliminato: {fileName}");
            }
            else
            {
                // Rinomina il file per indicare che è stato processato
                string processedPath = filePath.Replace(".json", "_processed.json");
                File.Move(filePath, processedPath, overwrite: true);
                Logger.Log($"✓ File rinominato: {Path.GetFileName(processedPath)}");
            }
            
            Logger.Log($"✅ Richiesta processata con successo!");
        }
        catch (IOException ex)
        {
            Logger.Log($"⚠️ Errore I/O su file {fileName}: {ex.Message}");
            Logger.Log($"   Il file potrebbe essere in uso, riproverò al prossimo ciclo");
        }
        catch (JsonException ex)
        {
            Logger.Log($"❌ Errore JSON nel file {fileName}: {ex.Message}");
            Logger.Log($"   Il file potrebbe essere corrotto");
            
            // Sposta il file corrotto in una sottocartella
            try
            {
                string errorDir = Path.Combine(_sharePath, "errors");
                Directory.CreateDirectory(errorDir);
                string errorPath = Path.Combine(errorDir, fileName);
                File.Move(filePath, errorPath, overwrite: true);
                Logger.Log($"🗑️ File corrotto spostato in: errors/{fileName}");
            }
            catch { }
        }
    }
}
