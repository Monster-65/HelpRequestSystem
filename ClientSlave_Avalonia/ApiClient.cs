using System.Net.Http;
using System.Text;
using System.Text.Json;
using System.Threading.Tasks;


public class ApiClient
{
    private readonly HttpClient _client = new HttpClient();
    private readonly string _endpoint;


    public ApiClient(string endpoint) => _endpoint = endpoint;


    public async Task SendHelpRequest(string pc, string user, string msg)
    {
        var payload = new { ComputerName = pc, User = user, Message = msg };
        var json = JsonSerializer.Serialize(payload);
        var content = new StringContent(json, Encoding.UTF8, "application/json");
        var resp = await _client.PostAsync(_endpoint, content);
        resp.EnsureSuccessStatusCode();
    }
}