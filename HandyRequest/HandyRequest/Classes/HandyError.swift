//
//  ACERestError.swift
//  HandyRequest
//
//  Created by Tema on 2018/3/28.
//  Copyright © 2018 Tema.Tian. All rights reserved.
//

import Foundation

// MARK: - ResponseTransformFailed Error setup

public protocol HandyError: Error {
    /// error domain
    var errorDomain: String { get }

    /// error code
    var errorCode: String { get }

    /// error message
    var errorMessage: String { get }

    /// error userInfo
    var errorUserInfo: [String : Any] { get }
}

///ACEError default implement
extension HandyError {
    public var errorDomain: String { return "" }

    public var errorCode: String { return "" }

    public var errorMessage: String { return "" }

    public var errorUserInfo: [String : Any] { return [:] }
}


public enum ResponseTransformFailed: HandyError {
  case dataMapJson(message: String)
  case jsonTransformMap(message: String)
  case responseTransformJSON(message: String)
  case responseTransformMappable(message: String)
  case responseTransformMappableList(message: String)
  
  public static var errorDomain: String {
    return "kResponseTransformErrorDomain"
  }
  
  public var errorCode: String {
    switch self {
    case .dataMapJson(let message):
      return message
    case .jsonTransformMap(let message):
      return message
    case .responseTransformJSON(let message):
      return message
    case .responseTransformMappable(let message):
      return message
    case .responseTransformMappableList(let message):
      return message
    }
  }
}





