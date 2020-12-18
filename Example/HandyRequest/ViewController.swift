//
//  ViewController.swift
//  HandyRequest
//
//  Created by Tema.Tian on 12/09/2020.
//  Copyright (c) 2020 Tema.Tian. All rights reserved.
//

import UIKit
import HandyRequest
import RxSwift
import ObjectMapper

class ViewController: UIViewController {

     var bag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()

      Rest.launch(ExampleAPI.movies)
        .mapJSONForKey("movies")
        .decodeArray(Movie.self)
        .subscribe { (response) in
          print(response)
        } onError: { (error) in
          print(error)
        }.disposed(by: bag)

      Rest.launch(ExampleAPI.movies)
        .mapArrayForKey("movies", baseMappable: Movie1.self)
        .subscribe { (response) in
          print(response)
        } onError: { (error) in
          print(error)
        }.disposed(by: bag)

      Rest.launch(ExampleAPI.movies, alwaysFetchCache: true)
        .mapJSONForKey("movies")
        .decodeArray(Movie.self)
        .subscribe { (response) in
          print(response)
        } onError: { (error) in
          print(error)
        }.disposed(by: bag)

      Rest.launch(ExampleAPI.movies, alwaysFetchCache: true)
        .mapArrayForKey("movies", baseMappable: Movie1.self)
        .subscribe { (response) in
          print(response)
        } onError: { (error) in
          print(error)
        }.disposed(by: bag)
    }
}

struct Movie: Codable {
  var title: String
  var id: String
  var releaseYear: String
}

struct Movie1: Mappable {

  init?(map: Map) {

  }

  mutating func mapping(map: Map) {
    title <- map["title"]
    id <- map["id"]
    releaseYear <- map["releaseYear"]
  }

  var title: String?
  var id: String?
  var releaseYear: String?
}

