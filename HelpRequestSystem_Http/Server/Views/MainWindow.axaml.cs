using Avalonia.Controls;
using Server.Services;
using Server.ViewModels;
using System;

namespace Server.Views;

public partial class MainWindow : Window
{
    private HelpRequestServer? _server;

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
            _server = new HelpRequestServer(vm);
            _server.Start();
        }
    }
}
