//
//  BaseResponse+HandyRequest.swift
//  HandyRequest
//
//  Created by Tema on 2018/3/28.
//  Copyright © 2018 Tema.Tian. All rights reserved.
//

import Foundation
import ObjectMapper
import SwiftyJSON
import RxSwift


// MARK: - BaseResponse map BaseMappable suppurt

extension HandyResponse {
  
  /// 返回Any
  /// - 描述: 将response转换为Any
  public func mapJSON(failsOnEmptyData: Bool = true) throws -> Any {
    do {
      return try response.mapJSON(failsOnEmptyData: failsOnEmptyData)
    } catch {
      if response.data.count < 1 && !failsOnEmptyData {
        return NSNull()
      }
      throw ResponseTransformFailed.dataMapJson(message: "response transform to jsonObject Failed")
    }
  }

  /// 返回T
  /// - 描述: 将response转换为T
  public func mapObject<T: BaseMappable>(_ type: T.Type, context: MapContext? = nil) throws -> T {
    guard let object = Mapper<T>(context: context).map(JSON: data) else {
      throw ResponseTransformFailed.responseTransformMappable(message: "map json to Mappable Model failed")
    }
    return object
  }
  
  /// 返回[T]
  /// - 描述: 将response转换为[T]
  public func mapArray<T: BaseMappable>(_ type: T.Type, context: MapContext? = nil) throws -> [T] {
    guard let array = data["data"] as? [[String : Any]] else {
      throw ResponseTransformFailed.responseTransformMappableList(message: "map json to Mappable List failed")
    }
    return Mapper<T>(context: context).mapArray(JSONArray: array)
  }
}

// MARK: - JSON map BaseMappable suppurt

extension JSON {
  /// 返回T
  /// - 描述: 将response转换为T
  public func mapObject<T: BaseMappable>(_ type: T.Type, context: MapContext? = nil) throws -> T {
    guard let rawString = self.rawString(), let object = Mapper<T>(context: context).map(JSONString: rawString) else {
      throw ResponseTransformFailed.responseTransformMappable(message: "map json to Mappable Model failed")
    }
    return object
  }
  
  /// 返回[T]
  /// - 描述: 将response转换为[T]
  public func mapArray<T: BaseMappable>(_ type: T.Type, context: MapContext? = nil) throws -> [T] {
    guard let rawString = self.rawString(), let array = Mapper<T>().mapArray(JSONString: rawString) else {
      throw ResponseTransformFailed.responseTransformMappableList(message: "map json to Mappable List failed")
    }
    return array
  }
  
  /// 返回[T]
  /// - 描述: 将response转换为[T]
  public func decodeObject<T: Codable>(_ type: T.Type) throws -> T {
    guard let object = try? JSONDecoder().decode(type, from: rawData()) else {
      throw ResponseTransformFailed.responseTransformMappable(message: "map json to Codable Model failed")
    }
    return object
  }
  
  /// 返回[T]
  /// - 描述: 将response转换为[T]
  public func decodeArray<T: Codable>(_ type: T.Type) throws -> [T] {
    guard let array = try? JSONDecoder().decode([T].self, from: rawData()) else {
      throw ResponseTransformFailed.responseTransformMappableList(message: "map json to Codable List failed")
    }
    return array
  }
}

// MARK: - RxSwift BaseResponse map BaseMappable suppurt

extension PrimitiveSequence where Trait == SingleTrait, Element == HandyResponse {
  
  /// 返回Single<Any>
  /// - 描述: 将response 转换为 JSON Serialization
  public func mapJSONObject() -> Single<Any> {
    return flatMap({ response ->Single<Any> in
      return Single.just(try response.mapJSON())
    })
  }
  
  /// 返回Single<JSON>
  /// - 描述: 将response 转换为 JSON
  public func mapJSON() -> Single<JSON> {
    return flatMap { .just( JSON($0.data) )}
  }
  
  /// 返回Single<JSON>
  /// - 参数: 需要从Dictionary取出对象的key
  public func mapJSONForKey(_ key: String) -> Single<JSON> {
    if key.contains(".") {
      return flatMap { response -> Single<JSON> in
        let keys = key.components(separatedBy: ".")
        var json = JSON(response.data)
        for k in keys {
          json = json[k]
        }
        return  Single.just(json)
      }
    }
    return flatMap { .just( JSON($0.data)[key])}
  }
  
  /// 返回Single<T>
  /// - 参数: 需要解析的BaseMappable,key
  public func mapObjectForKey<T: BaseMappable>(_ key: String, baseMappable: T.Type, context: MapContext? = nil) -> Single<T> {
    return mapJSONForKey(key).mapObject(baseMappable, context: context)
  }
  
  /// 返回Single[T]
  /// - 参数: 需要解析的BaseMappable,key
  public func mapArrayForKey<T: BaseMappable>(_ key: String, baseMappable: T.Type, context: MapContext? = nil) -> Single<[T]> {
    return mapJSONForKey(key).mapArray(baseMappable, context: context)
  }
  
  /// 返回Single<T>
  /// - 参数: 需要解析的BaseMappable,key
  public func mapObjectForKey<T: Codable>(_ key: String, type: T.Type) -> Single<T> {
    return mapJSONForKey(key).decodeObject(type)
  }
  
  /// 返回Single[T]
  /// - 参数: 需要解析的BaseMappable,key
  public func mapArrayForKey<T: Codable>(_ key: String, type: T.Type) -> Single<[T]> {
    return mapJSONForKey(key).decodeArray(type)
  }
  
  /// 返回Single<T>
  /// - 参数: 需要解析的BaseMappable
  public func mapObject<T: BaseMappable>(_ type: T.Type, context: MapContext? = nil) -> Single<T> {
    return flatMap { response -> Single<T> in
      return Single.just(try response.mapObject(type))
    }
  }
  
  /// 返回Single<[T]
  /// - 参数: 需要解析的BaseMappable
  public func mapArray<T: BaseMappable>(_ type: T.Type, context: MapContext? = nil) -> Single<[T]> {
    return flatMap { response -> Single<[T]> in
      return Single.just(try response.mapArray(type, context: context))
    }
  }
}

// MARK: - RxSwift JSON map BaseMappable suppurt

extension PrimitiveSequence where Trait == SingleTrait, Element == JSON {
  
  /// Observable<JSON>
  /// - 参数: 需要解析的JSON key
  public func parseJSON(_ key: String = "") -> Single<JSON> {
    if !key.isEmpty {
      return flatMap { response -> Single<JSON> in
        return Single.just(JSON.init(parseJSON: response[key].stringValue))
      }
    }
    return flatMap { response -> Single<JSON> in
      return Single.just(JSON.init(parseJSON: response.stringValue))
    }
  }
  
  /// Single<JSON>
  /// - 参数: 需要解析的JSON key
  public func mapJSONForKey(_ key: String) -> Single<JSON> {
    if key.contains(".") {
      return flatMap { response -> Single<JSON> in
        let keys = key.components(separatedBy: ".")
        var json = response
        for k in keys {
          json = json[k]
        }
        return  Single.just(json)
      }
    }
    return flatMap { .just( $0[key] )}
  }
  
  /// 返回Single<T?>
  /// - 参数: 需要解析的BaseMappable
  public func mapObject<T: BaseMappable>(_ type: T.Type, context: MapContext? = nil) -> Single<T> {
    return flatMap { response -> Single<T> in
      return Single.just(try response.mapObject(type, context: context))
    }
  }
  
  /// 返回Single<[T]
  /// - 参数: 需要解析的BaseMappable
  public func mapArray<T: BaseMappable>(_ type: T.Type, context: MapContext? = nil) -> Single<[T]> {
    return flatMap { response -> Single<[T]> in
      return Single.just(try response.mapArray(type, context: context))
    }
  }
  
  /// 返回Single<T>
  /// - 参数: 需要解析的Codable
  public func decodeObject<T: Codable>(_ type: T.Type) -> Single<T> {
    return flatMap { response -> Single<T> in
      return Single.just(try response.decodeObject(type))
    }
  }
  
  /// 返回Single<[T]>
  /// - 参数: 需要解析的Codable
  public func decodeArray<T: Codable>(_ type: T.Type) -> Single<[T]> {
    return flatMap { response -> Single<[T]> in
      return Single.just(try response.decodeArray(type))
    }
  }
}

// MARK: - RxSwift BaseResponse ObservableType map BaseMappable suppurt

extension ObservableType where Element == HandyResponse {
  
  /// 返回Observable<Any>
  /// - 描述: 将response 转换为 JSON Serialization
  public func mapJSONObject() -> Observable<Any> {
    return flatMap { response -> Observable<Any> in
      return Observable.just(try response.mapJSON())
    }
  }
  
  /// 返回Observable<JSON>
  /// - 描述: 将response 转换为 JSON
  public func mapJSON() -> Observable<JSON> {
    return flatMap { response -> Observable<JSON> in
      return Observable.just( JSON(response.data))
    }
  }
  
  /// 返回Observable<JSON>
  /// - 参数: 需要从Dictionary取出对象的key
  public func mapJSONForKey(_ key: String) -> Observable<JSON> {
    if key.contains(".") {
      return flatMap { response -> Observable<JSON> in
        let keys = key.components(separatedBy: ".")
        var json = JSON(response.data)
        for k in keys {
          json = json[k]
        }
        return  Observable.just(json)
      }
    }
    return flatMap { response -> Observable<JSON> in
      return Observable.just( JSON(response.data)[key])
    }
  }
  
  /// 返回Observable<T>
  /// - 参数: 需要解析的BaseMappable,key
  public func mapObjectForKey<T: BaseMappable>(_ key: String, baseMappable: T.Type, context: MapContext? = nil) -> Observable<T> {
    return mapJSONForKey(key).mapObject(baseMappable, context: context)
  }
  
  /// 返回Observable[T]
  /// - 参数: 需要解析的BaseMappable,key
  public func mapArrayForKey<T: BaseMappable>(_ key: String, baseMappable: T.Type, context: MapContext? = nil) -> Observable<[T]> {
    return mapJSONForKey(key).mapArray(baseMappable, context: context)
  }
  
  /// 返回Observable<T>
  /// - 参数: 需要解析的BaseMappable,key
  public func mapObjectForKey<T: Codable>(_ key: String, type: T.Type) -> Observable<T> {
    return mapJSONForKey(key).decodeObject(type)
  }
  
  /// 返回Observable[T]
  /// - 参数: 需要解析的BaseMappable,key
  public func mapArrayForKey<T: Codable>(_ key: String, type: T.Type) -> Observable<[T]> {
    return mapJSONForKey(key).decodeArray(type)
  }
  
  /// 返回Observable<T?>
  /// - 参数: 需要解析的BaseMappable
  public func mapObject<T: BaseMappable>(_ type: T.Type, context: MapContext? = nil) -> Observable<T> {
    return flatMap { response -> Observable<T> in
      return Observable.just(try response.mapObject(type, context: context))
    }
  }
  
  /// 返回Observable<[T]
  /// - 参数: 需要解析的BaseMappable
  public func mapArray<T: BaseMappable>(_ type: T.Type, context: MapContext? = nil) -> Observable<[T]> {
    return flatMap { response -> Observable<[T]> in
      return Observable.just(try response.mapArray(type, context: context))
    }
  }
}

// MARK: - RxSwift JSON ObservableType map BaseMappable suppurt

extension ObservableType where Element == JSON {
  
  /// Observable<JSON>
  /// - 参数: 需要解析的JSON key
  public func parseJSON(_ key: String = "") -> Observable<JSON> {
    if !key.isEmpty {
      return flatMap { response -> Observable<JSON> in
        return Observable.just(JSON.init(parseJSON: response[key].stringValue))
      }
    }
    return flatMap { response -> Observable<JSON> in
      return Observable.just(JSON.init(parseJSON: response.stringValue))
    }
  }
  
  /// Observable<JSON>
  /// - 参数: 需要解析的JSON key
  public func mapJSONForKey(_ key: String) -> Observable<JSON> {
    if key.contains(".") {
      return flatMap { response -> Observable<JSON> in
        let keys = key.components(separatedBy: ".")
        var json = response
        for k in keys {
          json = json[k]
        }
        return  Observable.just(json)
      }
    }
    return flatMap { Observable.just( $0[key] )}
  }
  
  /// 返回Observable<T?>
  /// - 参数: 需要解析的BaseMappable
  public func mapObject<T: BaseMappable>(_ type: T.Type, context: MapContext? = nil) -> Observable<T> {
    return flatMap { response -> Observable<T> in
      return Observable.just(try response.mapObject(type, context: context))
    }
  }
  
  /// 返回Observable<[T]
  /// - 参数: 需要解析的BaseMappable
  public func mapArray<T: BaseMappable>(_ type: T.Type, context: MapContext? = nil) -> Observable<[T]> {
    return flatMap { response -> Observable<[T]> in
      return Observable.just(try response.mapArray(type, context: context))
    }
  }
  
  /// 返回Observable<T>
  /// - 参数: 需要解析的Codable
  public func decodeObject<T: Codable>(_ type: T.Type) -> Observable<T> {
    return flatMap { response -> Observable<T> in
      return Observable.just(try response.decodeObject(type))
    }
  }
  
  /// 返回Observable<[T]>
  /// - 参数: 需要解析的Codable
  public func decodeArray<T: Codable>(_ type: T.Type) -> Observable<[T]> {
    return flatMap { response -> Observable<[T]> in
      return Observable.just(try response.decodeArray(type))
    }
  }
}
