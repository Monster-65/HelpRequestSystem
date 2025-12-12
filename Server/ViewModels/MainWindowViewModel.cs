using ReactiveUI;
using System.Collections.ObjectModel;
using Server.Models;

namespace Server.ViewModels;

public class MainWindowViewModel : ReactiveObject
{
    public string Greeting { get; } = "Welcome to Avalonia! Soloniooooo!";

    public ObservableCollection<HelpRequest> Requests { get; } = new();

    private HelpRequest? _selectedRequest;
    public HelpRequest? SelectedRequest
    {
        get => _selectedRequest;
        set => this.RaiseAndSetIfChanged(ref _selectedRequest, value);
    }

    public void AddRequest(HelpRequest r)
    {
        Avalonia.Threading.Dispatcher.UIThread.Post(() =>
            Requests.Add(r));
    }

    public void RemoveSelected()
    {
        if (SelectedRequest != null)
            Requests.Remove(SelectedRequest);
    }
}
