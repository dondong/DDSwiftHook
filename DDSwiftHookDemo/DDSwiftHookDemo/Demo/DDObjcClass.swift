//
//  DDObjcClass.swift
//  DDSwiftHookDemo
//
//  Created by dondong on 2022/5/10.
//

import Foundation

class DDObjcBaseClass : NSObject {
    @objc var val: Int;
    @objc init(val: Int) {
        self.val = val;
    }
    
    @objc func printVal() {
        print("DDObjcBaseClass.printVal \(self.val)");
    }
    
    @objc func myArgFunction(arg: String) {
        print("DDObjcBaseClass.myArgFunction \(arg)");
    }
    
    func myReturnStringFunction() -> String {
        return "DDObjcBaseClass.myReturnStringFunction";
    }
}


class DDObjcClass : DDObjcBaseClass, DDSwiftProtocol {
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
        print("DDObjcClass.myArgFunction \(arg)");
    }
    
    override func myReturnStringFunction() -> String {
        return "DDObjcClass.myReturnStringFunction";
    }
    
    func testProtocol() {
        print("DDSwiftClass.testProtocol");
    }
}


class DDObjcChildClass : DDObjcClass {
    override var val: Int {
        get {
            return super.val + 200000;
        }
        set {
            super.val = newValue;
        }
    }
    
    override func myReturnStringFunction() -> String {
        return "DDObjcChildClass.myReturnStringFunction";
    }
}

class DDObjcClassTemp : DDObjcClass {
}
class DDObjcClassHook : DDObjcClassTemp, DDSwiftHookable {
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
        print("DDObjcClassHook.printVal \(self.val)");
    }
    
    override func myArgFunction(arg: String) {
        super.myArgFunction(arg:arg);
        print("DDObjcClassHook.myArgFunction \(arg)");
    }
    
    override func myReturnStringFunction() -> String {
        return super.myReturnStringFunction() + ".Hook";
    }
    
    override func testProtocol() {
        super.testProtocol();
        print("DDObjcClassHook.testProtocol");
    }
}
