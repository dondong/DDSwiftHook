//
//  DDSwiftClass.swift
//  DDSwiftHookDemo
//
//  Created by dondong on 2022/5/10.
//

import Foundation

class DDSwiftBaseClass {
    var val: Int;
    init(val: Int) {
        self.val = val;
    }
    
    
    func printVal() {
        print("DDSwiftBaseClass.printVal \(self.val)");
    }
    
    func myArgFunction(arg: String) {
        print("DDSwiftBaseClass.myArgFunction \(arg)");
    }
    
    func myReturnStringFunction() -> String {
        return "DDSwiftBaseClass.myReturnStringFunction";
    }
}


class DDSwiftClass : DDSwiftBaseClass, DDSwiftProtocol {
    override var val: Int {
        get {
            return super.val + 90000;
        }
        set {
            super.val = newValue;
        }
    }
    
    override func myArgFunction(arg: String) {
        super.myArgFunction(arg:arg)
        print("DDSwiftClass.myArgFunction \(arg)");
    }
    
    override func myReturnStringFunction() -> String {
        return "DDSwiftClass.myReturnStringFunction";
    }
    
    func testProtocol() {
        print("DDSwiftClass.testProtocol");
    }
}


class DDSwiftChildClass : DDSwiftClass {
    
    override func myReturnStringFunction() -> String {
        return "DDSwiftChildClass.myReturnStringFunction";
    }
}

class DDSwiftClassTemp : DDSwiftClass {
}
class DDSwiftClassHook : DDSwiftClassTemp, DDSwiftHookable {
    override init(val: Int) {
        super.init(val:val);
    }
    
    override var val: Int {
        get {
            return super.val + 900000;
        }
        set {
            super.val = newValue;
        }
    }
    
    override func printVal() {
        super.printVal();
        print("DDSwiftClassHook.printVal \(self.val)");
    }
    
    override func myArgFunction(arg: String) {
        super.myArgFunction(arg:arg);
        print("DDSwiftClassHook.myArgFunction \(arg)");
    }
    
    override func myReturnStringFunction() -> String {
        return super.myReturnStringFunction() + ".Hook";
    }
    
    override func testProtocol() {
        super.testProtocol();
        print("DDSwiftClassHook.testProtocol");
    }
}
