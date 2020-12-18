//
//  RequestAdapter.swift
//  HandyRequest_Example
//
//  Created by Tema.Tian on 2020/12/18.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import Foundation
import HandyRequest

class HandyRequestAdapter: RequestAdapter {
  func endpointClosureBuilder(target: MultiTarget) -> Endpoint {
    RestProvider.defaultEndpointMapping(for: target)
  }
  func requestClosureBuilder(endpoint: Endpoint, closure: RestProvider<MultiTarget>.RequestResultClosure) {
    RestProvider<MultiTarget>.defaultRequestMapping(for: endpoint, closure: closure)
  }
  func singleClosureBuilder(single: @escaping SingleResponse, result: RestCompletion) {
    switch result {
      case .success(let reponse):
        single(.success(HandyResponse(reponse)))
      case .failure(let error):
        single(.error(error))
    }
  }
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

