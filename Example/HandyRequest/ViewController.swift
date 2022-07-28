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

class ViewController: UIViewController {

     var bag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()

      Rest.requestAdapter = HandyRequestAdapter() // Set request adapter, Error handling can be customized

      Rest.launch(ExampleAPI.movies)
        .mapJSONForKey("movies")
        .decodeArray(Movie.self)
        .subscribe { (response) in
            print(response)
        } onFailure: { (error) in
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
    }
}

struct Movie: Codable {
  var title: String
  var id: String
  var releaseYear: String
}



