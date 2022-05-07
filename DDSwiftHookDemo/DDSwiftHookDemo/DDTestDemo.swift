//
//  DDTestDemo.swift
//  DDSwiftHookDemo
//
//  Created by dondong on 2022/5/7.
//

import Foundation


class DDTestDemo {
    func myFunction() {
        print("DDTestDemo.myFunction");
    }
    
    func myFunction2(a: Int) {
        print("DDTestDemo.myFunction2  a:\(a)");
    }
}

class DDTestNewDemo: DDTestDemo {
    override func myFunction() {
        super.myFunction();
        print("DDTestNewDemo.myFunction");
    }
}
