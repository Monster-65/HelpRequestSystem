// ===============================================
// SERVERMASTER - Data/HelpRequestStore.cs
// ===============================================
using System.Collections.Concurrent;


public class HelpRequestStore
{
private readonly ConcurrentDictionary<int, HelpRequest> _requests = new();
private int _counter = 0;


public HelpRequest Add(HelpRequest req)
{
req.Id = ++_counter;
_requests[req.Id] = req;
return req;
}


public IEnumerable<HelpRequest> GetAll() => _requests.Values.OrderBy(r => r.CreatedAt);


public bool Remove(int id) => _requests.TryRemove(id, out _);
}