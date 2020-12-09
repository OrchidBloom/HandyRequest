//
//  BaseResponse.swift
//  HandyRequest
//
//  Created by Tema on 2018/3/29.
//  Copyright © 2018 Tema.Tian. All rights reserved.
//

import Foundation

public protocol BaseResponse {
  
  /// request processed data, handle non-dictionary types
  var data: [String: Any] { get }
  
  /// Moya response
  var response: RestResponse { get }
}
