//
//  ExampleAPIswift.swift
//  HandyRequest_Example
//
//  Created by Tema.Tian on 2020/12/18.
//  Copyright © 2020 CocoaPods. All rights reserved.
//
//

import Foundation
import HandyRequest

enum ExampleAPI {
    case movies
}

extension ExampleAPI: ApiType {

    var method: TaskMethod {
        return .get
    }

    var baseURL: URL {
        URL(string: "https://reactnative.dev")!
    }

    var path: String {
        "movies.json"
    }

    var task: Task {
        return .requestPlain
    }
}
