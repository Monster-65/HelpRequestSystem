// ===============================================
// SERVERMASTER - Program.cs (ASP.NET Web API)
// ===============================================
using Microsoft.AspNetCore.Builder;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;


var builder = WebApplication.CreateBuilder(args);
builder.Services.AddControllers();
builder.Services.AddSingleton<HelpRequestStore>();
var app = builder.Build();
app.MapControllers();
app.Run();
