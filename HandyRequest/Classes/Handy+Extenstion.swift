//
//  Extension.swift
//  HandyRequest
//
//  Created by Tema on 2018/3/28.
//  Copyright © 2018 Tema.Tian. All rights reserved.
//

import Foundation
import ObjectMapper
import SwiftyJSON
import CommonCrypto
import Moya
import RxSwift

// MARK: - IRequest default implement
public extension Request {
  func launch(_ target: ApiType, callbackQueue: DispatchQueue? = .main, progress: ProgressBlock? = .none) -> Single<HandyResponse> {
    return launch(target, callbackQueue: callbackQueue, progress: progress)
  }
  func launch(_ target: ApiType, alwaysFetchCache: Bool = false, callbackQueue: DispatchQueue? = DispatchQueue.main, progress: ProgressBlock? = .none) -> Observable<HandyResponse> {
    return launch(target, alwaysFetchCache: alwaysFetchCache, callbackQueue: callbackQueue, progress: progress)
  }
}

// MARK: - String suppurt
public extension String {
  
  var utf8Encoded: Data {
    return data(using: .utf8) ?? Data()
  }
}

// MARK: - Dictionary suppurt

public extension Dictionary {
  
  func jsonString() -> String? {
    if #available(iOS 11.0, *) {
      guard let data = try? JSONSerialization.data(withJSONObject: self, options: .sortedKeys) else {
        #if Debug
        print("data is nil")
        #endif
        return nil
      }
      return String(data: data, encoding: .utf8)
    } else {
      guard let data = try? JSONSerialization.data(withJSONObject: self, options: .prettyPrinted) else {
        #if Debug
        print("data is nil")
        #endif
        return nil
      }
      return String(data: data, encoding: .utf8)
    }
  }
  
  /// 返回T
  /// - 描述: 将response转换为T
  func mapObject<T: BaseMappable>(_ type: T.Type, context: MapContext? = nil) throws -> T {
    guard let rawString = self.jsonString(), let object = Mapper<T>(context: context).map(JSONString: rawString) else {
      throw ResponseTransformFailed.responseTransformMappable(message: "map json to Mappable Model failed")
    }
    return object
  }
  
  mutating func merge(_ dict: [Key: Value]) {
    self.merge(dict) { (_, new) in new }
  }
}

// MARK: - Array suppurt

public extension Array {
  
  var data: Data? {
    return try? JSONSerialization.data(withJSONObject: self, options: .prettyPrinted)
  }
  
  func jsonString() -> String? {
    guard let data = try? JSONSerialization.data(withJSONObject: self, options: .prettyPrinted) else {
      #if Debug
      print("data is nil")
      #endif
      return nil
    }
    return String(data: data, encoding: .utf8)
  }
  
  /// 返回T
  /// - 描述: 将response转换为T
  func mapObject<T: BaseMappable>(_ type: T.Type, context: MapContext? = nil) throws -> T {
    guard let rawString = self.jsonString(), let object = Mapper<T>(context: context).map(JSONString: rawString) else {
      throw ResponseTransformFailed.responseTransformMappable(message: "map json to Mappable Model failed")
    }
    return object
  }
}
