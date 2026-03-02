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
    private readonly HelpRequestClientShare _client;
    
    public string User { get; set; } = "";
    public string Message { get; set; } = "";

    public MainWindowViewModel()
    {
        // Inizializza il client con cartella condivisa
        _client = new HelpRequestClientShare(AppConfig.Instance.SharePath);
        
        Logger.Log("📁 Client avviato - Modalità CARTELLA CONDIVISA");
        Logger.Log($"   Percorso: {AppConfig.Instance.SharePath}");
        Logger.Log($"📄 Log salvati in: {AppConfig.Instance.LogFilePath}");
    }

    public async void SendRequest()
    {
        try {
            if (string.IsNullOrWhiteSpace(User))
            {
                await ShowMessage("Inserisci il tuo nome!");
                return;
            }

            if (string.IsNullOrWhiteSpace(Message))
            {
                await ShowMessage("Inserisci un messaggio!");
                return;
            }

            Logger.Log($"Preparazione invio richiesta - User: {User}");

            var req = new HelpRequest
            {
                ComputerName = Environment.MachineName,
                User = User,
                Message = Message,
                Timestamp = DateTime.Now
            };

            // Invia scrivendo il file nella cartella condivisa
            _client.Send(req);

            Message = ""; // Svuota il messaggio
            this.RaisePropertyChanged(nameof(Message));
            
            Logger.Log("✓ Richiesta completata con successo");
            await ShowMessage("Richiesta inviata correttamente!");
        } catch (Exception ex) {
            Logger.LogError("Errore durante l'invio della richiesta", ex);
            await ShowMessage($"Errore durante l'invio:\n{ex.Message}");
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
