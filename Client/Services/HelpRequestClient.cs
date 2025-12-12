using System.Net.Http;
using System.Threading.Tasks;
using System.Text;
using System.Text.Json;
using Client.Models;

namespace Client.Services;

public class HelpRequestClient
{
    private readonly HttpClient _http = new();

    public async Task Send(string serverIp, HelpRequest req)
    {
        var json = JsonSerializer.Serialize(req);
        var content = new StringContent(json, Encoding.UTF8, "application/json");

        await _http.PostAsync($"http://{serverIp}:5000/", content);
    }
}
