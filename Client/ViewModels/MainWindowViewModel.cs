using ReactiveUI;
using Client.Models;
using Client.Services;
using System;
using System.Collections.ObjectModel;

namespace Client.ViewModels;

public class MainWindowViewModel : ReactiveObject
{
    public string Greeting { get; } = "Welcome to Avalonia!";

    private readonly HelpRequestClient _client = new();

    public string ServerIP { get; set; } = "192.168.1.22";
    public string User { get; set; } = "";
    public string Message { get; set; } = "";

    public async void SendRequest()
    {
        var req = new HelpRequest
        {
            ComputerName = Environment.MachineName,
            User = User,
            Message = Message,
            Timestamp = DateTime.Now
        };

        await _client.Send(ServerIP, req);
    }
}
