public class HelpRequest
{
    public int Id { get; set; }
    public required string ComputerName { get; set; }
    public required string User { get; set; }
    public required string Message { get; set; }
    public DateTime CreatedAt { get; set; }
}