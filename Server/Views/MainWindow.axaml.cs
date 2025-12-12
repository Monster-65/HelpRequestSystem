using Avalonia.Controls;
using Server.Services;
using Server.ViewModels;

namespace Server.Views;

public partial class MainWindow : Window
{
    public MainWindow()
    {
        InitializeComponent();

        var vm = (MainWindowViewModel)DataContext!;
        var server = new HelpRequestServer(vm);

        server.Start();
    }
}
