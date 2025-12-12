using Avalonia;
using Avalonia.Controls;
using Avalonia.Layout;
using System.Threading.Tasks;

namespace ClientSlave_Avalonia;

public class MessageBox : Window
{
    public MessageBox(string message)
    {
        Width = 300;
        Height = 150;
        Title = "Info";

        var panel = new StackPanel
        {
            Margin = new Thickness(10)
        };

        var text = new TextBlock
        {
            Text = message,
            Margin = new Thickness(0, 0, 0, 10)
        };

        var button = new Button
        {
            Content = "OK",
            Width = 80,
            HorizontalAlignment = HorizontalAlignment.Center
        };

        button.Click += (_, _) => Close();

        panel.Children.Add(text);
        panel.Children.Add(button);

        Content = panel;
    }

    public static async Task Show(Window owner, string message)
    {
        var box = new MessageBox(message);
        await box.ShowDialog(owner);
    }
}
