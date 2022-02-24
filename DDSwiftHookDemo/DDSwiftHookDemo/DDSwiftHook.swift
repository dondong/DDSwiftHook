//
//  DDSwiftHook.swift
//  DDSwiftHookDemo
//
//  Created by dondong on 2022/2/20.
//

import Foundation
import MachO
import Darwin

class Base {
    func test() {
        print("base");
    }
}

class Test: Base {
     override func test() {
         super.test();
        print("test");
    }
    
    func testArg(_ str: String) {
        print("test  ", str);
    }
}

class DDSwiftHook {
    public static func swizzleMethod() -> Bool {
        return false;
    }
    
    public static func test() {
        let data = DDSwiftRuntime.getSwiftClass(Test.self);
        let des = data?.pointee.descriptor;
        print("vtable");
        let tt = ClassDescriptor.getVTable(des!);
        for i in 0..<Int(tt?.count ?? 0) {
            let p = UnsafePointer<MethodDescriptor>(tt!.baseAddress!).advanced(by:i);
            print("\(i) ", tt![i].flags.kind, MethodDescriptor.getImpl(p));
            var info = Dl_info(dli_fname: nil, dli_fbase: nil, dli_sname: nil, dli_saddr: nil);
            dladdr(UnsafeRawPointer(MethodDescriptor.getImpl(p)), &info);
            print(String(cString:info.dli_sname));
        }
        print("overridetable");
        let ott = ClassDescriptor.getOverridetable(des!);
        for i in 0..<Int(ott?.count ?? 0) {
            let p = UnsafePointer<MethodOverrideDescriptor>(ott!.baseAddress!).advanced(by:i);
            print("\(i) ", MethodOverrideDescriptor.getClass(p), MethodOverrideDescriptor.getMethod(p), MethodOverrideDescriptor.getImpl(p));
            let ptr = MethodOverrideDescriptor.getClass(p);
            print(ClassDescriptor.getName(UnsafePointer<ClassDescriptor>(ptr)));
            var info1 = Dl_info(dli_fname: nil, dli_fbase: nil, dli_sname: nil, dli_saddr: nil);
            dladdr(UnsafeRawPointer(MethodOverrideDescriptor.getMethod(p)), &info1);
            print(String(cString:info1.dli_sname));

            var info2 = Dl_info(dli_fname: nil, dli_fbase: nil, dli_sname: nil, dli_saddr: nil);
            dladdr(UnsafeRawPointer(MethodOverrideDescriptor.getImpl(p)), &info2);
            print(String(cString:info2.dli_sname));
        }
        print("function");
        let fun1 = Test.test;
        let fun2 = Test.testArg;
        let ptr: OpaquePointer = DDSwiftRuntime.covert(Test.test);
        var info = Dl_info(dli_fname: nil, dli_fbase: nil, dli_sname: nil, dli_saddr: nil);
        dladdr(UnsafeRawPointer(ptr), &info);
        print(String(cString:info.dli_sname));
        print(ptr);
        print("----------------");
        let table = ClassMetadata.getFunctionTable(data!);
        for i in 0..<table.count {
            print(table[i]);
        }
    }
}
