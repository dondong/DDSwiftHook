//
//  DDTestDemoHook.swift
//  DDSwiftHookDemo
//
//  Created by dondong on 2022/5/7.
//

import Foundation
import UIKit

class DDTestDemoTemp : DDTestDemo {
}

class DDTestDemoHook : DDTestDemoTemp, DDSwiftHookable {
    override func myFunction() {
        super.myFunction();
        print("DDTestDemoHook.myFunction");
    }
}

class ViewControllerTemp : ViewController {
}

class ViewControllerHook: ViewControllerTemp, DDSwiftHookable {
    override func viewDidLoad() {
        super.viewDidLoad()
        print("ViewControllerHook.viewDidLoad");
    }
    
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated);
//        print("ViewControllerHook.viewWillAppear animated:\(animated)");
//    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated);
        print("ViewControllerHook.viewDidAppear animated:\(animated)");
    }
}

class AppDelegateTemp : AppDelegate {
}

class AppDelegateHook : AppDelegateTemp, DDSwiftHookable {
    override func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
         return super.application(application, didFinishLaunchingWithOptions: launchOptions);
    }
}
