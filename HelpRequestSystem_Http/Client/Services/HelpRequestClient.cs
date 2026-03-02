using System;
using System.Net.Http;
using System.Threading.Tasks;
using System.Text;
using System.Text.Json;
using Client.Models;

namespace Client.Services;

public class HelpRequestClient
{
    private readonly HttpClient _http;

    public HelpRequestClient()
    {
        var config = AppConfig.Instance;
        _http = new HttpClient();
        _http.Timeout = TimeSpan.FromSeconds(config.RequestTimeoutSeconds);
    }

    public async Task Send(string serverIp, HelpRequest req)
    {
        try
        {
            var config = AppConfig.Instance;
            var url = config.GetServerUrl(serverIp);
            
            var json = JsonSerializer.Serialize(req);
            var content = new StringContent(json, Encoding.UTF8, "application/json");

            Logger.Log($"📤 Invio richiesta a: {url}");
            Logger.Log($"   Payload: {json}");

            var response = await _http.PostAsync(url, content);
            
            Logger.Log($"📥 Risposta ricevuta: {response.StatusCode}");
            
            if (!response.IsSuccessStatusCode)
            {
                throw new Exception($"Il server ha risposto con codice: {response.StatusCode}");
            }
            
            Logger.Log("✓ Richiesta inviata con successo");
        }
        catch (HttpRequestException ex)
        {
            Logger.LogError($"Errore di connessione al server {serverIp}", ex);
            throw new Exception($"Impossibile connettersi al server {serverIp}. Verifica che il server sia avviato e raggiungibile.", ex);
        }
        catch (TaskCanceledException)
        {
            Logger.LogError($"Timeout della connessione al server {serverIp}");
            throw new Exception($"Timeout della connessione. Il server {serverIp} non risponde.");
        }
    }
}
