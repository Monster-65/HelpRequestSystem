using System;

namespace Client.Models;

public class HelpRequest
{
    public string ComputerName { get; set; } = "";
    public string User { get; set; } = "";
    public string Message { get; set; } = "";
    public DateTime Timestamp { get; set; } = DateTime.Now;
}