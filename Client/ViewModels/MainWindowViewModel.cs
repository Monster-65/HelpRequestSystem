using ReactiveUI;
using Avalonia;
using Avalonia.Controls;
using Avalonia.Controls.ApplicationLifetimes;
using Client.Models;
using Client.Services;
using System;
using System.Collections.ObjectModel;
using System.Threading.Tasks;

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
        try {
            var req = new HelpRequest
            {
                ComputerName = Environment.MachineName,
                User = User,
                Message = Message,
                Timestamp = DateTime.Now
            };

            await _client.Send(ServerIP, req);

            Message = ""; // Svuota il messaggio
            await ShowMessage("Richiesta inviata correttamente.");
        } catch (Exception ex) {
            await ShowMessage($"Errore durante l'invio della richiesta: {ex.Message}\n");
        }
    }

    public async Task ShowMessage(string text)
    {
        var dialog = new Window
        {
            Width = 300,
            Height = 150,
            Title = "Info",
            Content = new TextBlock { Text = text, Margin = new Thickness(20) }
        };

        if (Application.Current?.ApplicationLifetime is IClassicDesktopStyleApplicationLifetime desktop && desktop.MainWindow != null)
        {
            await dialog.ShowDialog(desktop.MainWindow);
        }
    }

}
