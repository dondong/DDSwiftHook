//
//  ViewController.swift
//  DDSwiftHookDemo
//
//  Created by dondong on 2022/3/9.
//

import UIKit
import DDSwiftRuntime

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        print("ViewController.viewDidLoad");
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated);
        print("ViewController.viewDidAppear animated:\(animated)");
    }
}

