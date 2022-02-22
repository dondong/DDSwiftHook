//
//  DDSwiftHook.swift
//  DDSwiftHookDemo
//
//  Created by dondong on 2022/2/20.
//

import Foundation
import MachO

class Test {
    
}

class DDSwiftHook {
    public static func test() {
        let da = DDSwiftRuntime.getObjcClass(ViewController.self);
        print(AnyClassMetadata.getName(da));
        let data = DDSwiftRuntime.getSwiftClass(ViewController.self);
//        print(AnyClassMetadata.getName(data));
//        print("flags: ", data!.pointee.flags);
//        print("instanceSize: ",data!.pointee.instanceSize);
//        print("instanceAddressPoint: ",data!.pointee.instanceAddressPoint);
//        print("instanceAlignMask: ",data!.pointee.instanceAlignMask);
//        print("reserved: ",data!.pointee.reserved);
//        print("classSize: ",data!.pointee.classSize);
//        print("classAddressPoint: ",data!.pointee.classAddressPoint);
//        print("description: ",data!.pointee.description);
//        print("ivarDestroyer: ",data!.pointee.ivarDestroyer);
        let des = data?.pointee.getDescriptor();
        print(ClassDescriptor.getName(des!));
        print("\(String(describing: des?.pointee.flag))   \(des?.pointee.numFields)");
        
    }
}
