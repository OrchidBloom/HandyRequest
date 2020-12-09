//
//  Cache.swift
//  HandyRequest
//
//  Created by Tema on 2018/4/10.
//  Copyright © 2018 Tema.Tian. All rights reserved.
//

import Foundation
import Moya

// MARK: - Cache suppert

fileprivate struct CacheName {
  static let statusCode   = 9527
  static let MoyaResponse = "RequestCache"
  static let queueName    = "Handy.Cache.Queue"
}

// MARK: - Request Cache setup

struct RequestCache: Cache {
  
  private var queue : DispatchQueue!
  
  private var fileManager: FileManager {
    return FileManager.default
  }
  
  init() {
    queue = DispatchQueue.init(label: CacheName.queueName, qos: .background, attributes: [])
  }
  
  func cacheResponse(_ target: ApiType, response: RestResponse) {
    queue.async {
      self.cache(target, response: response)
    }
  }
  
  func fetchResponseCache(target: ApiType) -> RestResponse? {
    if !target.canCache { return nil }
    let url = URL.init(fileURLWithPath: cacheBasePath().appendingPathComponent(target.fetchCacheKey()))
    do {
      let data = try Data.init(contentsOf: url)
      return Response(statusCode: CacheName.statusCode, data: data)
    } catch let error {
      #if Debug
      print(error.localizedDescription)
      #endif
      return nil
    }
  }
  
  public func removeAllCache() {
    let path = cacheBasePath() as String
    var isDir: ObjCBool = ObjCBool(true)
    if fileManager.fileExists(atPath: path, isDirectory: &isDir) {
      if isDir.boolValue {
        do {
          try fileManager.removeItem(atPath: path)
        } catch let error {
          #if Debug
          print(error.localizedDescription)
          #endif
        }
      }
    }
  }
  
  private func cache(_ target: ApiType, response: RestResponse) {
    let url = URL.init(fileURLWithPath: cacheBasePath().appendingPathComponent(target.fetchCacheKey()))
    guard response.data.count > 1, target.canCache else { return }
    do {
      try response.data.write(to: url)
    } catch let error {
      #if Debug
      print(error.localizedDescription)
      #endif
    }
  }
  
  func cacheBasePath() -> NSString {
    let pathOfLibrary = NSSearchPathForDirectoriesInDomains(.libraryDirectory, .userDomainMask, true)[0] as NSString
    let path = pathOfLibrary.appendingPathComponent(CacheName.MoyaResponse)
    createDirectoryIfNeeded(path: path)
    return path as NSString
  }
  
  private func createDirectoryIfNeeded(path: String) {
    var isDir: ObjCBool = ObjCBool(true)
    if !fileManager.fileExists(atPath: path, isDirectory: &isDir) {
      createBaseDirectoryAtPath(path: path)
    } else {
      if !isDir.boolValue {
        do {
          try fileManager.removeItem(atPath: path)
        } catch let error {
          #if Debug
          print(error.localizedDescription)
          #endif
        }
        createBaseDirectoryAtPath(path: path)
      }
    }
  }
  
  private func createBaseDirectoryAtPath(path: String) {
    do {
      try fileManager.createDirectory(atPath: path, withIntermediateDirectories: true, attributes: nil)
    } catch let error {
      #if Debug
      print(error.localizedDescription)
      #endif
    }
    addDoNotBackupAttribute(path: path)
  }
  
  ///Ignore resource backup
  private func addDoNotBackupAttribute(path: String) {
    var url = NSURL.fileURL(withPath: path)
    url.setTemporaryResourceValue(true, forKey: .isExcludedFromBackupKey)
  }
}




