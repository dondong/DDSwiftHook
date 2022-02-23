//
//  DDSwiftHook.swift
//  DDSwiftHookDemo
//
//  Created by dondong on 2022/2/20.
//

import Foundation
import MachO

class Base {
    func test() {
        print("base");
    }
}

class Test: Base {
     override func test() {
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
        print("vtable");
        let tt = ClassDescriptor.getVTable(des!);
        for i in 0..<Int(tt?.count ?? 0) {
            let p = UnsafePointer<MethodDescriptor>(tt!.baseAddress!).advanced(by:i);
            print("\(i) ", tt![i].flags, tt![i].impl);
            print("\(i) ", String(format:"%x", tt![i].flags), MethodDescriptor.getImpl(p));
        }
        print("overridetable");
        let ott = ClassDescriptor.getOverridetable(des!);
        for i in 0..<Int(ott?.count ?? 0) {
            let p = UnsafePointer<MethodOverrideDescriptor>(ott!.baseAddress!).advanced(by:i);
            print("\(i) ", ott![i].cls, ott![i].method, ott![i].impl);
            print("\(i) ", MethodOverrideDescriptor.getClass(p), MethodOverrideDescriptor.getMethod(p), MethodOverrideDescriptor.getImpl(p));
            let ptr = MethodOverrideDescriptor.getClass(p);
            let c: UnsafePointer<ClassMetadata> = DDSwiftRuntime.getData(ptr)!;
            print(ClassMetadata.getName(c));
        }
        
//        print("function");
//        let fun1 = Test.test;
//        let fun2 = Test.testArg;
//        let ptr: OpaquePointer = DDSwiftRuntime.covert(Test.test);
//        print(ptr);
//        print("----------------");
//        let table = ClassMetadata.getFunctionTable(data!);
//        for i in 0..<table.count {
//            print(table[i]);
//        }
        
    }
}
