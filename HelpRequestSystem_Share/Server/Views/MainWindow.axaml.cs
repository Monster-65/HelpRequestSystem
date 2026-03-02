using Avalonia.Controls;
using Server.Services;
using Server.ViewModels;
using System;

namespace Server.Views;

public partial class MainWindow : Window
{
    private HelpRequestServerShare? _server;

    public MainWindow()
    {
        InitializeComponent();
        
        // Attendi che il DataContext sia impostato
        this.DataContextChanged += OnDataContextChanged;
    }

    private void OnDataContextChanged(object? sender, EventArgs e)
    {
        if (DataContext is MainWindowViewModel vm && _server == null)
        {
            Logger.Log("🔄 Avvio server - Modalità CARTELLA CONDIVISA");
            Logger.Log($"   Percorso: {AppConfig.Instance.SharePath}");
            Logger.Log($"   Intervallo polling: {AppConfig.Instance.PollIntervalSeconds}s");
            Logger.Log($"   Auto-elimina file: {AppConfig.Instance.AutoDeleteProcessedFiles}");
            
            _server = new HelpRequestServerShare(
                vm,
                AppConfig.Instance.SharePath,
                AppConfig.Instance.PollIntervalSeconds,
                AppConfig.Instance.AutoDeleteProcessedFiles
            );
            _server.Start();
        }
    }
}
