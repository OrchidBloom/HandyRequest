# HandyRequest

[![Version](https://img.shields.io/cocoapods/v/HandyRequest.svg?style=flat)](https://cocoapods.org/pods/HandyRequest)
[![License](https://img.shields.io/cocoapods/l/HandyRequest.svg?style=flat)](https://cocoapods.org/pods/HandyRequest)
[![Platform](https://img.shields.io/cocoapods/p/HandyRequest.svg?style=flat)](https://cocoapods.org/pods/HandyRequest)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

## Installation

HandyRequest is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'HandyRequest'
```

## Example

### Example API Definition

```
import HandyRequest

enum ExampleAPI {
    case movies
}

extension ExampleAPI: ApiType {

    var method: TaskMethod {
        return .get
    }

    var baseURL: URL {
        URL(string: "https://reactnative.dev")!
    }

    var path: String {
        "movies.json"
    }

    var task: Task {
        return .requestPlain
    }
}
```

### You can set the data parsing interceptor or not.
```
class HandyRequestAdapter: RequestAdapter {
  func endpointClosureBuilder(target: MultiTarget) -> Endpoint {
    RestProvider.defaultEndpointMapping(for: target)
  }
  func requestClosureBuilder(endpoint: Endpoint, closure: RestProvider<MultiTarget>.RequestResultClosure) {
    RestProvider<MultiTarget>.defaultRequestMapping(for: endpoint, closure: closure)
  }
  // Return success or failure according to your requirements
  func singleClosureBuilder(single: @escaping SingleResponse, result: RestCompletion) {
    switch result {
      case .success(let reponse):
        single(.success(HandyResponse(reponse)))
      case .failure(let error):
        single(.error(error))
    }
  }
  // If there is a cache, return success or failure according to your own requirements
  func observableClosureBuilder(observer: ObservableResponse, result: RestCompletion) -> Bool {
    switch result {
      case .success(let reponse):
        observer.onNext(HandyResponse(reponse))
        observer.onCompleted()
        return true
      case .failure(let error):
        observer.onError(error)
        return false
    }
  }
}

```

### Set Request Adapter
 
 ```
Rest.requestAdapter = HandyRequestAdapter() // Set request adapter, Error handling can be customized

 ```
### Start Request

###### Support Coable to parse data
 
```
  Rest.launch(ExampleAPI.movies) 
    .mapJSONForKey("movies")
    .decodeArray(Movie.self)
    .subscribe { (response) in
      print(response)
    } onError: { (error) in
      print(error)
    }.disposed(by: bag)
```

###### Support ObjectMapper to parse data
 
```
Rest.launch(ExampleAPI.movies) to parse data
.mapArrayForKey("movies", baseMappable: Movie1.self)
.subscribe { (response) in
  print(response)
} onError: { (error) in
  print(error)
}.disposed(by: bag)
```
###### Support cache & Coable to parse data
 
```
Rest.launch(ExampleAPI.movies, alwaysFetchCache: true)
.mapJSONForKey("movies")
.decodeArray(Movie.self)
.subscribe { (response) in
  print(response)
} onError: { (error) in
  print(error)
}.disposed(by: bag)
```
###### Support cache & ObjectMapper to parse data
 
```    
Rest.launch(ExampleAPI.movies, alwaysFetchCache: true)
.mapArrayForKey("movies", baseMappable: Movie1.self)
.subscribe { (response) in
  print(response)
} onError: { (error) in
  print(error)
}.disposed(by: bag)
```


## Author

Tema.Tian

## License

HandyRequest is available under the MIT license. See the LICENSE file for more info.
