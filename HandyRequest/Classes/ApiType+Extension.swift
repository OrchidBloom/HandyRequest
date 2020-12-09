//
//  ApiType+HandyRequest.swift
//  HandyRequest
//
//  Created by Tema on 2018/3/28.
//  Copyright © 2018 Tema.Tian. All rights reserved.
//

import Foundation
import Moya
import SwiftyJSON

// MARK: - ApiType suppurt

public extension ApiType {
  var sampleData: Data {
    return "".utf8Encoded
  }

  var validationType: ValidationType {
    return ValidationType.customCodes(Array(200..<600))
  }

  var headers: [String : String]? {
    return [:]
  }
  
  func mapParameters(_ parameters: [String: Any]) -> Task {
    return Task.requestParameters(parameters: parameters, encoding: URLEncoding.default)
  }

  func arrayParameters(_ parameterArray: [Any]) -> Task {
    return Task.requestData(parameterArray.data ?? Data())
  }

  func jsonParameters(_ parameters: [String: Any]) -> Task {
    return Task.requestParameters(parameters: parameters, encoding: JSONEncoding.default)
  }
}

// MARK: - ApiType Task suppurt

extension Task {
  
  func defaultEcoding(_ addition: [String: Any]) -> Task {
    var current = addition
    switch self {
    case let .requestParameters(parameters, parameterEncoding):
      current.merge(parameters)
      return .requestParameters(parameters: current, encoding: parameterEncoding)
    case let .uploadCompositeMultipart(formData, urlParameters):
      current.merge(urlParameters)
      return .uploadCompositeMultipart(formData, urlParameters: current)
    case let .requestCompositeData(bodyData: bodyData, urlParameters: urlParameters):
      current.merge(urlParameters)
      return .requestCompositeData(bodyData: bodyData, urlParameters: current)
    case let .requestCompositeParameters(bodyParameters: bodyParameters, bodyEncoding: bodyParameterEncoding, urlParameters: urlParameters):
      current.merge(urlParameters)
      return .requestCompositeParameters(bodyParameters: bodyParameters, bodyEncoding: bodyParameterEncoding, urlParameters: current)
    default: return self
    }
  }
}





