//
//  DDDemo.swift
//  DDSwiftHookDemo
//
//  Created by dondong on 2022/5/10.
//

import Foundation

func testDemo() {
    // swift
    print("------- swift test -------");
    DDSwiftClassHook.enableHook();
    let swiftClass = DDSwiftClass(val:11);
    swiftClass.printVal();
    swiftClass.myArgFunction(arg:"Swift");
    print(swiftClass.myReturnStringFunction());
    swiftClass.testProtocol();
    let swiftProtol = swiftClass;
    swiftProtol.testProtocol();
    
    print("------- swift generic test -------");
    DDSwiftGenericClassHook.enableHook();
    let swiftGenericClass = DDSwiftGenericClass<String>(val:"generic");
    swiftGenericClass.printVal();
    swiftGenericClass.myArgFunction(arg:"Swift");
    print(swiftGenericClass.myReturnStringFunction());
    swiftGenericClass.testProtocol();
    let swiftGenericProtol = swiftGenericClass;
    swiftGenericProtol.testProtocol();
    
    
    // objc
    print("------- objc test -------");
    DDObjcClassHook.enableHook();
    let objcClass = DDObjcClass(val:22);
    objcClass.printVal();
    objcClass.myArgFunction(arg:"Objc");
    print(objcClass.myReturnStringFunction());
    objcClass.testProtocol();
    let objcProtol = objcClass;
    objcProtol.testProtocol();
}
