//
//  DDSwiftHook.swift
//  DDSwiftHookDemo
//
//  Created by dondong on 2022/2/20.
//

import Foundation
import MachO
import Darwin

class BaseObject {
    func test() {
        print("base");
    }
}

class TestObject: BaseObject {
     override func test() {
         super.test();
        print("test");
    }
    
    func testArg(_ str: String) {
        print("test  ", str);
    }
}

struct TestStruct {
    var a: Int;
    var b: Int;
}

class DDSwiftHook {
    public static func swizzleMethod() -> Bool {
        return false;
    }
    
    public static func test() {
        let t = TestObject.init();
        let o = unsafeBitCast(t, to:UnsafePointer<HeapObject>.self);
        let v = UnsafeMutablePointer<HeapMetadata>(OpaquePointer(o.pointee.metadata)).pointee.valueWitnesses;
        print(v);
        print(HeapMetadata.getValueWitnesses(o.pointee.metadata));
//        print("isBitwiseTakable: ", v.pointee.flags.isBitwiseTakable);
//        print("isPOD: ", v.pointee.flags.isPOD);
//        print("isIncomplete: ", v.pointee.flags.isIncomplete);
//        print("isInlineStorage: ", v.pointee.flags.isInlineStorage);
//        print("hasEnumWitnesses: ", v.pointee.flags.hasEnumWitnesses);
//        print("alignment: ", v.pointee.flags.alignment);
//        print("alignmentMask: ", v.pointee.flags.alignmentMask);
    }
}
