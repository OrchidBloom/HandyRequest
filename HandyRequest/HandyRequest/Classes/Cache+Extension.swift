//
//  ICache+HandyRequest.swift
//  HandyRequest
//
//  Created by Tema on 2018/3/28.
//  Copyright © 2018 Tema.Tian. All rights reserved.
//

import Foundation
import Moya
import SwiftyJSON
import CommonCrypto

// MARK: - ApiType cache suppurt

extension ApiType {
  
  var description: String {
    if let cache = HandyService.shared.cache as? RequestCache {
      let url = URL.init(fileURLWithPath: cache.cacheBasePath().appendingPathComponent(fetchCacheKey()))
      return "\(baseCacheKey)>>>\(url)"
    }
    return baseCacheKey
  }
  
  var canCache: Bool {
    switch self.task {
    case .downloadDestination(_), .downloadParameters(parameters: _, encoding: _, destination: _): return false
    default: return true
    }
  }
  
  func fetchCacheKey() -> String {
    return cacheKey.md5()
  }
  
  private var baseCacheKey : String {
    return "[\(self.method)]\(self.baseURL.absoluteString)/\(self.path)"
  }
  
  var cacheKey: String {
    return baseCacheKey + parameters
  }
  
  private func sortedMapWithString(_ map: [String: Any]) -> String {
    var parametersArray = [String]()
    let sortedKeysMap = map.sorted(by: { $0.key.localizedStandardCompare($1.key) == ComparisonResult.orderedAscending })
    sortedKeysMap.forEach { (k,v) in
      if let value = v as? [String: Any] {
        parametersArray.append("\"\(k)\":\(sortedMapWithString(value))")
      } else if let values = v as? [[String: Any]] {
        values.forEach({ (map) in
          parametersArray.append("\"\(k)\":\(sortedMapWithString(map))")
        })
      } else if let value = v as? [Any] {
        parametersArray.append("\"\(k)\":\(value)")
      } else {
        parametersArray.append("\"\(k)\":\"\(v)\"")
      }
    }
    return"{\(parametersArray.joined(separator: ","))}"
  }
  
  private var parameters: String {
    var globalMap = [String: Any]()
    globalMap.merge(HandyService.shared.globalHeaders)
    globalMap.merge(HandyService.shared.globalParameters)
    globalMap.merge(headers ?? [:])
    switch self.task {
    case let .requestParameters(parameters, _):
      globalMap.merge(parameters)
    case let .requestCompositeParameters(bodyParameters, _, urlParameters):
      globalMap.merge(bodyParameters)
      globalMap.merge(urlParameters)
    case let .downloadParameters(parameters, _, _):
      globalMap.merge(parameters)
    case let .uploadCompositeMultipart(_, urlParameters):
      globalMap.merge(urlParameters)
    case let .requestCompositeData(_, urlParameters):
      globalMap.merge(urlParameters)
    default: break
    }
    guard globalMap.count > 0 else { return "" }
    if #available(iOS 11.0, *) {
      return globalMap.jsonString() ?? ""
    } else {
      return sortedMapWithString(globalMap)
    }
  }
}

extension String {
    func md5() -> String {
        let str = self.cString(using: String.Encoding.utf8)
        let strLen = CUnsignedInt(self.lengthOfBytes(using: String.Encoding.utf8))
        let digestLen = Int(CC_MD5_DIGEST_LENGTH)
        let result = UnsafeMutablePointer<CUnsignedChar>.allocate(capacity: digestLen)
        CC_MD5(str!, strLen, result)
        let hash = NSMutableString()
        for i in 0 ..< digestLen {
            hash.appendFormat("%02x", result[i])
        }
        result.deinitialize(count: digestLen)
        return String(format: hash as String)
    }
}
