// ===============================================
// SERVERMASTER - Controllers/HelpRequestController.cs
// ===============================================
using Microsoft.AspNetCore.Mvc;


[ApiController]
[Route("api/[controller]")]
public class HelpRequestController : ControllerBase
{
private readonly HelpRequestStore _store;
public HelpRequestController(HelpRequestStore store) => _store = store;


[HttpPost]
public IActionResult Create(HelpRequest req)
{
var created = _store.Add(req);
return Ok(created);
}


[HttpGet]
public IActionResult List() => Ok(_store.GetAll());


[HttpDelete("{id}")]
public IActionResult Delete(int id)
{
var removed = _store.Remove(id);
return removed ? Ok() : NotFound();
}
}