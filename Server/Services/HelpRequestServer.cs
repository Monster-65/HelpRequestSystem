using System;
using System.IO;
using System.Net;
using System.Net.Sockets;
using System.Threading.Tasks;
using System.Text.Json;
using Server.Models;
using Server.ViewModels;

namespace Server.Services;

public class HelpRequestServer
{
    private readonly MainWindowViewModel _vm;

    public HelpRequestServer(MainWindowViewModel vm)
    {
        _vm = vm;
    }

    public void Start()
    {
        Task.Run(() =>
        {
            var listener = new HttpListener();
            listener.Prefixes.Add("http://*:5000/");
            listener.Start();

            while (true)
            {
                var ctx = listener.GetContext();
                using var reader = new StreamReader(ctx.Request.InputStream);
                var json = reader.ReadToEnd();

                var req = JsonSerializer.Deserialize<HelpRequest>(json);

                if (req != null)
                    _vm.AddRequest(req);

                ctx.Response.StatusCode = 200;
                ctx.Response.Close();
            }
        });
    }
}
