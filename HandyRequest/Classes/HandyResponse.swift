//
//  ACEResponse.swift
//  HandyRequest
//
//  Created by Tema on 2018/3/29.
//  Copyright © 2018 Tema.Tian. All rights reserved.
//

import Foundation
import Moya

// MARK: - ACEResponse setup

public struct HandyResponse: BaseResponse {
  
  private var _data: [String: Any]!
  /// Moya response
  private var _response: RestResponse!
  
  public var data: [String: Any] {
    if _data == nil {
      return [:]
    }
    return _data
  }
  
  public var response: RestResponse {
    return _response
  }

  public init(_ response: Response) {
    
    _response = response
    
    var dict: Any?
    
    do {
      
      dict = try mapJSON()
      
    } catch let error {
      #if Debug
      print(error.localizedDescription)
      #endif
    }
    if let map = dict as? [String : Any] {
      
      _data = map
      
    } else if let dataList = dict as? [Any] {
      
      _data = ["data" : dataList]
      
    }
  }
}

