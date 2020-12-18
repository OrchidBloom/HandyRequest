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

        Rest.launch(ExampleAPI.movies).subscribe { (response) in
          print(response)
        } onError: { (error) in
          print(error)
        }.disposed(by: bag)
    }
}

