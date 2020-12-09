//
//  Cache.swift
//  HandyRequest
//
//  Created by Tema on 2018/4/10.
//  Copyright © 2018 Tema.Tian. All rights reserved.
//

import Foundation
/// Cache
public protocol Cache {
  func cacheResponse(_ target: ApiType, response: RestResponse)
  func fetchResponseCache(target: ApiType) -> RestResponse?
  func removeAllCache()
}
