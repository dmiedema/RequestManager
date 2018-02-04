# RequestManager

Super simple & basic network request manager. (Hence the dumb name).

Ok, so how do you use it?

## Usage

``` swift
let request = Request(url: "https://bender.is.great")
RequestManager().send(request, completion: { (result) in 
  switch result {
  case .failure(let error):
    // Handle error some how
  case .success(_):
    // Yay we suceeded. What now?
})
```

Originally this was developed for my internal use, and then modified for [`AsyncKit`](https://github.com/yannickl/AwaitKit).
If you have some ideas on how to make it better, I'm definitely open to improvements.

So how do you use it with AsyncKit?
I've used it this way

``` swift
func doThingWith(otherThing: OtherThing) -> Promise<Bool> {
  return Promise { (resolve, reject) in
    let url = "https://bender.is.great/api/do/things/\(otherThing.id)"
    var request = Request(method: .delete, url: url)
    manager.send(request, completion: { (result) in
      switch result {
      case .failure(let error):
        reject(error)
      case .success(_):
        resolve(true)
      }
    })
  }
}
```

And some more complex examples would be

``` swift
// Paginated Requests
// Not provided by default in this framework because
// paginated requests are so different based on platform.
// So instead I'll just give you an example way to do it
extension RequestManager {
  func paginatedRequest(to: String, params: Parameters? = nil, maxRetries: Int = 3, update: @escaping ((_ finished: Bool, _ result: RequestResult<Any, Error>) -> Void)) {
    if maxRetries <= 0 {
      update(true, .failure(RequestErrorCode.maximumNumberOfRetries.error))
      return
    }
    let request = Request(url: to, parameters: params)
    send(request) { (result) in
      switch result {
      case .failure(let error):
        update(true, .failure(error))
      case .success(let data):
        if let json = data as? Dictionary<String, Any>,
          let results = json["results"] as? [Any] {
          if let nextPageURL = json["next"] as? String {
            self.paginatedRequest(to: nextPageURL, update: update)
            update(false, .success(results))
          } else {
            update(true, .success(results))
          }
        } else {
          self.paginatedRequest(to: to, params: params, maxRetries: (maxRetries - 1), update: update)
        }
      }
    }
  }
}
```

And to use it

``` swift
func bigListFor(someID id: String) -> Promise<[Thing]> {
  return Promise { (resolve, reject) in
    let url = "https://bender.is.great/api/partiesAttended"
    var results: [ [String: Any] ] = []
    manager.paginatedRequest(to: url, update: { (finished, result) in
      switch result {
      case .failure(let error):
        reject(error)
      case .success(let data):
        guard let json = data as? [ [String: Any] ] else {
          reject(RequestErrorCode.invalidResponseType.error)
          return }
        results += (json)
        if finished {
          do {
            // Assuming `thing` is `Codable`. Not the most elegant but it works. ¯\_(ツ)_/¯
            let things = try results.map({ (thingJSON) -> Thing in
              let data = try JSONSerialization.data(withJSONObject: thingJSON, options: .prettyPrinted)
              return try JSONDecoder().decode(Thing.self, from: data)
            })
            resolve(maps)
          } catch {
            reject(error)
          }
        }
      }
    })
  }
}
```


