//
//  DDSwiftGenericClass.swift
//  DDSwiftHookDemo
//
//  Created by dondong on 2022/5/10.
//

import Foundation

class DDSwiftGenericBaseClass<T> {
    var val: T;
    init(val: T) {
        self.val = val;
    }
    
    
    func printVal() {
        print("DDSwiftGenericBaseClass.printVal \(self.val)");
    }
    
    func myArgFunction(arg: T) {
        print("DDSwiftGenericBaseClass.myArgFunction \(arg)");
    }
    
    func myReturnStringFunction() -> String {
        return "DDSwiftGenericBaseClass.myReturnStringFunction";
    }
}


class DDSwiftGenericClass<T> : DDSwiftGenericBaseClass<T> {
    override func myArgFunction(arg: T) {
        super.myArgFunction(arg:arg)
        print("DDSwiftGenericClass.myArgFunction \(arg)");
    }
    
    override func myReturnStringFunction() -> String {
        return "DDSwiftGenericClass.myReturnStringFunction";
    }
    
    func testProtocol() {
        print("DDSwiftGenericClass.testProtocol");
    }
}


class DDSwiftGenericChildClass<T> : DDSwiftGenericClass<T> {
    
    override func myReturnStringFunction() -> String {
        return "DDSwiftGenericChildClass.myReturnStringFunction";
    }
}

class DDSwiftGenericClassTemp : DDSwiftGenericClass<String> {
}
class DDSwiftGenericClassHook : DDSwiftGenericClassTemp, DDSwiftHookable {
    override init(val: String) {
        super.init(val:val);
    }
    
    override func printVal() {
        super.printVal();
        print("DDSwiftGenericClassHook.printVal \(self.val)");
    }
    
    override func myArgFunction(arg: String) {
        super.myArgFunction(arg:arg);
        print("DDSwiftGenericClassHook.myArgFunction \(arg)");
    }
    
    override func myReturnStringFunction() -> String {
        return super.myReturnStringFunction() + ".Hook";
    }
    
    override func testProtocol() {
        super.testProtocol();
        print("DDSwiftGenericClassHook.testProtocol");
    }
}
