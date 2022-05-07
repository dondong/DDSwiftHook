//
//  DDTestDemoHook.swift
//  DDSwiftHookDemo
//
//  Created by dondong on 2022/5/7.
//

import Foundation

class DDTestDemoHook : DDTestDemo, DDSwiftHookable {
    override func myFunction() {
        super.myFunction();
        print("DDTestDemoHook.myFunction");
    }
}

class ViewControllerHook: ViewController, DDSwiftHookable {
    override func viewDidLoad() {
        super.viewDidLoad()
        print("ViewControllerHook.viewDidLoad");
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated);
        print("ViewControllerHook.viewDidAppear animated:\(animated)");
        
    }
}
