//
//  DDSwiftHook.swift
//  DDSwiftHookDemo
//
//  Created by dondong on 2022/2/20.
//

import Foundation
import MachO

class BaseObject {
    func test() {
        print("base");
    }
}

class TestObject: BaseObject {
     override func test() {
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
    public static func test() {
        let t = TestObject.init();
        let o = unsafeBitCast(t, to:UnsafePointer<HeapObject>.self);
        print(o.pointee.metadata.pointee.enumeratedMetadataKind);
    }
}
