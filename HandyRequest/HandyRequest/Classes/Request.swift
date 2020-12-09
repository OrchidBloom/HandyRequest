//
//  IRest.swift
//  HandyRequest
//
//  Created by Tema on 2018/3/28.
//  Copyright © 2018 Tema.Tian. All rights reserved.
//

import Foundation
import RxSwift
import Moya

let Rest: (RequestConfig & Request) = HandyService()

/// Service Config
public protocol RequestConfig: class {
  var provider: MoyaProvider<MultiTarget> { get }
  var cache: Cache { get }
  var delegate: RequestErroreDelegate? { set get }
  var timeoutInterval: TimeInterval { set get }
  var globalPlugins: [PluginType] { set get }
  var globalHeaders: [String : String] { set get }
  var globalParameters: [String : Any] { set get }
  var requestAdapter: RequestAdapter { set get }
}

/// HandleRestError Delegate
public protocol RequestErroreDelegate: class {
  func handleRestError(_ err: Error)
}

// Request Adapter
public protocol RequestAdapter: class {
    func endpointClosureBuilder(target: MultiTarget) -> Endpoint
    func requestClosureBuilder(endpoint: Endpoint, closure: RestProvider<MultiTarget>.RequestResultClosure)
    func singleClosureBuilder(single: @escaping SingleResponse, result: RestCompletion)
    func observableClosureBuilder(observer: ObservableResponse, result: RestCompletion) -> Bool
}

/// Request
public protocol Request {
  func launch(_ target: ApiType, callbackQueue: DispatchQueue?, progress: ProgressBlock?) -> Single<BaseResponse>
  func launch(_ target: ApiType, alwaysFetchCache: Bool, callbackQueue: DispatchQueue?, progress: ProgressBlock?) -> Observable<BaseResponse>
}
