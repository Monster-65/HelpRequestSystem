// ===============================================
// CLIENTSLAVE - ApiClient.cs
// ===============================================
using System.Net.Http;
using System.Text;
using System.Text.Json;
using System.Threading.Tasks;


public class ApiClient
{
private readonly HttpClient _client = new HttpClient();
private readonly string _endpoint;


public ApiClient(string endpoint) => _endpoint = endpoint;


public Task<HttpResponseMessage> SendHelpRequest(string pc, string user, string msg)
{
var json = JsonSerializer.Serialize(new { ComputerName = pc, User = user, Message = msg });
var content = new StringContent(json, Encoding.UTF8, "application/json");
return _client.PostAsync(_endpoint, content);
}
}
