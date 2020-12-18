//
//  ACERestService.swift
//  HandyRequest
//
//  Created by Tema on 2018/3/28.
//  Copyright © 2018 Tema.Tian. All rights reserved.
//

import Foundation
import RxSwift
import Moya

public class HandyService {
  static let shared = HandyService()
  fileprivate(set) var _provider: MoyaProvider<MultiTarget>!
  fileprivate(set) var _cache: Cache!
  fileprivate(set) var _delegate: RequestErroreDelegate?
  fileprivate(set) var _timeoutInterval: TimeInterval = 60
  fileprivate(set) var _globalPlugins = [PluginType]()
  fileprivate(set) var _globalHeaders = [String : String]()
  fileprivate(set) var _globalParameters = [String : Any]()
  fileprivate(set) var _requestAdapter: RequestAdapter!

  init() {
    registerDependencyService()
  }
  
  func registerDependencyService() {
    _provider = MoyaProvider<MultiTarget>(endpointClosure: requestAdapter.endpointClosureBuilder, requestClosure: requestAdapter.requestClosureBuilder, callbackQueue: DispatchQueue.main, plugins: globalPlugins)
    _cache = RequestCache()
  }
}

extension HandyService: RequestConfig {
  public var requestAdapter: RequestAdapter {
    get {
      _requestAdapter == nil ? DefaultRequestAdapter() : _requestAdapter
    }
    set {
      _requestAdapter = newValue
    }
  }

  public var provider: MoyaProvider<MultiTarget> {
    return _provider
  }
  
  public var cache: Cache {
    return _cache
  }
  
  public var delegate: RequestErroreDelegate?  {
    get {
      return _delegate
    }
    set {
      _delegate = newValue
    }
  }
  
  public var timeoutInterval: TimeInterval {
    get {
      return _timeoutInterval
    }
    set {
      _timeoutInterval = newValue
    }
  }
  
  public var globalPlugins: [PluginType] {
    get {
      if _globalPlugins.count == 0 {
        #if DEBUG
        _globalPlugins = [NetworkHUDPlugin(), NetworkLoggerPlugin(configuration: NetworkLoggerPlugin.Configuration(logOptions: .verbose))]
        #else
        _globalPlugins = [NetworkHUDPlugin()]
        #endif
      }
      return _globalPlugins
    }
    set {
      _globalPlugins = newValue + globalPlugins

      rebuildProvider()
    }
  }
  
  public var globalHeaders: [String : String] {
    get {
      return _globalHeaders
    }
    set {
      _globalHeaders.merge(newValue)
    }
  }
  
  public var globalParameters: [String : Any] {
    get {
      return _globalParameters
    }
    set {
      _globalParameters.merge(newValue)
    }
  }

  func rebuildProvider() {
    _provider = MoyaProvider<MultiTarget>(endpointClosure: requestAdapter.endpointClosureBuilder, requestClosure: requestAdapter.requestClosureBuilder, callbackQueue: DispatchQueue.main, plugins: globalPlugins)
  }
}

extension HandyService: Request {
  
  public func launch(_ target: ApiType, callbackQueue: DispatchQueue?, progress: ProgressBlock?) -> Single<BaseResponse> {
    return Single.create {[weak self] single in
      guard let self = self else { return Disposables.create()}
      let task = self.provider.request(MultiTarget(target), callbackQueue: callbackQueue, progress: progress, completion: { (result) in
        switch result {
        case .success(let value):
          self.requestAdapter.singleClosureBuilder(single: single, result: .success(value))
        case .failure(let error):
          self.requestAdapter.singleClosureBuilder(single: single, result: .failure(error))
        }
      })
      return Disposables.create { task.cancel() }
    }
  }
  
  public func launch(_ target: ApiType, alwaysFetchCache: Bool, callbackQueue: DispatchQueue?, progress: ProgressBlock?) -> Observable<BaseResponse> {
    return Observable.create {[weak self] (observer) -> Disposable in
      guard let self = self else { return Disposables.create()}
      if alwaysFetchCache, let response = self.cache.fetchResponseCache(target: target) {
        let responseData = HandyResponse(response)
        if responseData.data.count > 0 {
          observer.onNext(responseData)
        }
      }
      let task = self.provider.request(MultiTarget(target), callbackQueue: callbackQueue, progress: progress, completion: { (result) in
        switch result {
        case .success(let value):
          if self.requestAdapter.observableClosureBuilder(observer: observer, result: .success(value)) {
            self.cache.cacheResponse(target, response: value)
          }
        case .failure(let error):
          _ = self.requestAdapter.observableClosureBuilder(observer: observer, result: .failure(error))
        }
      })
      return Disposables.create {task.cancel()}
    }
  }
}

// MARK: - IRestConfig Provider PluginType suppurt
private final class NetworkHUDPlugin: PluginType {
  
  func willSend(_ request: RequestType, target: ApiType) {
    UIApplication.shared.isNetworkActivityIndicatorVisible = true
  }
  
  func didReceive(_ result: Result<Moya.Response, MoyaError>, target: ApiType) {
    UIApplication.shared.isNetworkActivityIndicatorVisible = false
  }
}

private class DefaultRequestAdapter: RequestAdapter {

}


