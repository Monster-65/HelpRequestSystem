using System;
using System.IO;
using System.Net;
using System.Threading.Tasks;
using System.Text.Json;
using Server.Models;
using Server.ViewModels;

namespace Server.Services;

public class HelpRequestServer
{
    private readonly MainWindowViewModel _vm;
    private HttpListener? _listener;

    public HelpRequestServer(MainWindowViewModel vm)
    {
        _vm = vm;
    }

    public void Start()
    {
        Task.Run(() =>
        {
            try
            {
                var config = AppConfig.Instance;
                _listener = new HttpListener();
                _listener.Prefixes.Add(config.ListenerUrl);
                
                Logger.Log($"Avvio del server sulla porta {config.ServerPort}...");
                _listener.Start();
                Logger.Log($"✓ Server in ascolto su {config.ListenerUrl}");
                Logger.Log($"✓ Endpoint API: {config.ApiEndpoint}");
                Logger.Log("⚠ Assicurati di eseguire il server con privilegi amministrativi!");
                Logger.Log($"📄 Log salvati in: {config.LogFilePath}");

                while (_listener.IsListening)
                {
                    try
                    {
                        var ctx = _listener.GetContext();
                        Task.Run(() => HandleRequest(ctx));
                    }
                    catch (HttpListenerException)
                    {
                        // Il listener è stato fermato
                        break;
                    }
                }    
            }
            catch (HttpListenerException ex)
            {
                Logger.LogError("Errore HttpListener", ex);
                Logger.Log("SOLUZIONE: Esegui il server come amministratore:");
                Logger.Log("  - Linux/Mac: sudo dotnet run");
                Logger.Log("  - Windows: Esegui come amministratore");
            }
            catch (Exception ex)
            {
                Logger.LogError("Errore nel server", ex);
            }
        });
    }

    private void HandleRequest(HttpListenerContext ctx)
    {
        try
        {
            using var reader = new StreamReader(ctx.Request.InputStream);
            var json = reader.ReadToEnd();

            Logger.Log($"📨 Richiesta ricevuta da {ctx.Request.RemoteEndPoint}");
            Logger.Log($"   Payload: {json}");

            if (_vm == null)
            {
                Logger.LogError("ERRORE CRITICO: ViewModel è null!");
                ctx.Response.StatusCode = 500;
                ctx.Response.Close();
                return;
            }

            var req = JsonSerializer.Deserialize<HelpRequest>(json);

            if (req != null)
            {
                Logger.Log($"✓ Richiesta deserializzata correttamente");
                Logger.Log($"   Computer: {req.ComputerName}, User: {req.User}");
                
                _vm.AddRequest(req);
                Logger.Log($"✓ Richiesta aggiunta alla collection");
            }
            else
            {
                Logger.Log("⚠ Richiesta deserializzata è null");
            }

            ctx.Response.StatusCode = 200;
            ctx.Response.Close();
            Logger.Log("✓ Risposta 200 inviata al client");
        }
        catch (Exception ex)
        {
            Logger.LogError("Errore nella gestione della richiesta", ex);
            try
            {
                ctx.Response.StatusCode = 500;
                ctx.Response.Close();
            }
            catch
            {
                // Ignora errori nella chiusura della risposta
            }
        }
    }

    public void Stop()
    {
        Logger.Log("Arresto del server...");
        _listener?.Stop();
        _listener?.Close();
        Logger.Log("✓ Server arrestato");
    }
}
