//
//  DDSwiftHook.swift
//  DDSwiftHookDemo
//
//  Created by dondong on 2022/2/20.
//

import Foundation
import MachO

class Test {
    func test() {
        print("test");
    }
    
    func testArg(_ str: String) {
        print("test  ", str);
    }
}

class DDSwiftHook {
    public static func test() {
        let data = DDSwiftRuntime.getSwiftClass(Test.self);
        let des = data?.pointee.getDescriptor();
        let tt = ClassDescriptor.getVTable(des!);
        for i in 0..<Int(tt?.count ?? 0) {
            let p = UnsafePointer<MethodDescriptor>(tt!.baseAddress!).advanced(by:i);
            print("\(i) ", String(format:"%x", tt![i].flags), MethodDescriptor.getImpl(p));
        }
        let fun1 = Test.test;
        let fun2 = Test.testArg;
        let ptr: OpaquePointer = DDSwiftRuntime.covert(Test.test);
        print(ptr);
        print("----------------");
        let table = ClassMetadata.getFunctionTable(data!);
        for i in 0..<table.count {
            print(table[i]);
        }
        
    }
}
