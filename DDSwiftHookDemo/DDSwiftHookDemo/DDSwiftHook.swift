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
}

class DDSwiftHook {
    public static func test() {
        let data = DDSwiftRuntime.getSwiftClass(Test.self);
        let des = data?.pointee.getDescriptor();
        ClassMetadata.getFunctionTable(data!);
        
    }
}
