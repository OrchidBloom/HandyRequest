//
//  ApiType.swift
//  HandyRequest
//
//  Created by Tema on 2018/3/28.
//  Copyright © 2018 Tema.Tian. All rights reserved.
//

import Foundation
import Moya
import RxSwift

/// Must be realized following attributes
public protocol ApiType: TargetType {
  
  /// The target's base `URL`.
  override var baseURL: URL { get }
  
  /// The path to be appended to `baseURL` to form the full `URL`.
  override var path: String { get }
  
  /// The HTTP method used in the request.
  override var method: TaskMethod { get }
  
  /// The type of HTTP task to be performed.
  override var task: Task { get }
}

/// Represents an HTTP method.
public typealias TaskMethod = Moya.Method
public typealias Task = Moya.Task
public typealias PluginType = Moya.PluginType

/// Choice of parameter encoding.
public typealias ParameterEncoding = Moya.ParameterEncoding
public typealias JSONEncoding = Moya.JSONEncoding
public typealias URLEncoding = Moya.URLEncoding

/// Multipart form.
public typealias RequestMultipartFormData = Moya.MultipartFormData

/// Multipart form data encoding result.
public typealias DownloadDestination = Moya.DownloadDestination
public typealias MultipartFormData = Moya.MultipartFormData
public typealias RestResponse = Moya.Response
public typealias RestResult = Result

public typealias RestProvider = Moya.MoyaProvider
public typealias MultiTarget = Moya.MultiTarget
public typealias EndpointClosure = (MultiTarget) -> Endpoint
public typealias RequestResultClosure = (RestResult<URLRequest, RestError>) -> Void
public typealias RequestClosure = (Endpoint, RestProvider<MultiTarget>.RequestResultClosure) -> Void

public typealias Endpoint = Moya.Endpoint
public typealias RestError = Moya.MoyaError

public typealias SingleResponse = ((SingleEvent<BaseResponse>) -> Void)
public typealias ObservableResponse = (AnyObserver<BaseResponse>)
public typealias RestCompletion = RestResult<RestResponse, RestError>
public typealias SingleClosure = (@escaping SingleResponse, RestCompletion) -> Void
public typealias ObservableClosure = (ObservableResponse, RestCompletion) -> Bool
