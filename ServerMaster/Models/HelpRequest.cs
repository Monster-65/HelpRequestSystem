// ===============================================
// SERVERMASTER - Models/HelpRequest.cs
// ===============================================
public class HelpRequest
{
public int Id { get; set; }
public string ComputerName { get; set; }
public string User { get; set; }
public string Message { get; set; }
public DateTime CreatedAt { get; set; } = DateTime.Now;
}
