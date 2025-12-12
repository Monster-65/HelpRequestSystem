// ===============================================
// CLIENTSLAVE - MainForm.cs
// ===============================================
using System;
using System.Windows.Forms;


public class MainForm : Form
{
private TextBox txtUser;
private TextBox txtMessage;
private Button btnSend;
private ApiClient api = new ApiClient("http://192.168.1.22:5000/api/helprequest");


public MainForm()
{
Text = "Richiesta Aiuto";
Width = 350;
Height = 250;


Label lblUser = new Label { Text = "Utente", Top = 20, Left = 10, Width = 100 };
txtUser = new TextBox { Top = 20, Left = 120, Width = 180 };


Label lblMessage = new Label { Text = "Messaggio", Top = 60, Left = 10, Width = 100 };
txtMessage = new TextBox { Top = 60, Left = 120, Width = 180, Height = 60, Multiline = true };


btnSend = new Button { Text = "Invia richiesta", Top = 140, Left = 120, Width = 180 };
btnSend.Click += SendRequest;


Controls.Add(lblUser);
Controls.Add(txtUser);
Controls.Add(lblMessage);
Controls.Add(txtMessage);
Controls.Add(btnSend);
}


private async void SendRequest(object sender, EventArgs e)
{
await api.SendHelpRequest(Environment.MachineName, txtUser.Text, txtMessage.Text);
MessageBox.Show("Richiesta inviata.");
}
}
