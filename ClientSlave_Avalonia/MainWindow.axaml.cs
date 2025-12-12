using Avalonia.Controls;
using System;
using System.Net.Http;
using System.Text.Json;
using System.Text;
using System.Threading.Tasks;

namespace ClientSlave_Avalonia;

public partial class MainWindow : Window
{
    public MainWindow()
    {
        InitializeComponent();
        SendButton.Click += OnSendClicked;
    }

    private async void OnSendClicked(object? sender, Avalonia.Interactivity.RoutedEventArgs e)
    {
        var user = UserTextBox.Text ?? "";
        var message = MessageTextBox.Text ?? "";

        if (string.IsNullOrWhiteSpace(user) || string.IsNullOrWhiteSpace(message))
        {
            await MessageBox.Show(this, "Compila tutti i campi.");
            return;
        }

        var request = new
        {
            ComputerName = Environment.MachineName,
            User = user,
            Message = message
        };

        string json = JsonSerializer.Serialize(request);

        try
        {
            using var client = new HttpClient();
            var content = new StringContent(json, Encoding.UTF8, "application/json");

            var response = await client.PostAsync("http://192.168.1.22:5000/api/helprequest", content);

            if (response.IsSuccessStatusCode)
                await MessageBox.Show(this, "Richiesta inviata.");
            else
                await MessageBox.Show(this, "Errore durante l'invio.");
        }
        catch (Exception ex)
        {
            await MessageBox.Show(this, "Errore: " + ex.Message);
        }
    }
}
