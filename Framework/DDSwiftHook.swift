//
//  DDSwiftHook.swift
//  DDSwiftHook
//
//  Created by dondong on 2022/5/7.
//

import Foundation
import DDSwiftRuntime

protocol DDSwiftHookable: AnyObject {
}

extension DDSwiftHookable {
    static func enableHook() {
        let ptr = unsafeBitCast(Self.self, to:UnsafePointer<ClassMetadata>.self);
        let superPtr = UnsafePointer<ClassMetadata>(OpaquePointer(ptr.pointee.superclass));
        
        // hook swift vtable method
        let offset = MemoryLayout<ClassMetadata>.size;
        let size = Int(superPtr.pointee.classSize) - MemoryLayout<OpaquePointer>.size - offset;
        let srcPtr = UnsafeRawPointer(ptr).advanced(by:offset);
        let dstPtr = UnsafeMutableRawPointer(OpaquePointer(superPtr)).advanced(by:offset);
        dstPtr.copyMemory(from:srcPtr, byteCount:size);
        
        // hook objective-c method
        let methodArray = ptr.pointee.ro.pointee.methodArray;
        for srcMethod in methodArray {
            let sel = method_getName(srcMethod);
            print(srcMethod, sel);
            if let dstMethod = class_getInstanceMethod(unsafeBitCast(superPtr, to:AnyClass.self), sel) {
                method_exchangeImplementations(dstMethod, srcMethod);
            } else if class_respondsToSelector(unsafeBitCast(superPtr, to:AnyClass.self), sel) {
                var dstMethod: Method? = nil;
                var cls: AnyClass = unsafeBitCast(superPtr, to:AnyClass.self);
                while (nil == dstMethod) {
                    cls = class_getSuperclass(cls)!;
                    dstMethod = class_getInstanceMethod(cls, sel);
                }
                class_addMethod(unsafeBitCast(superPtr, to:AnyClass.self), sel, method_getImplementation(dstMethod!), method_getTypeEncoding(dstMethod!));
                method_exchangeImplementations(dstMethod!, srcMethod);
            }
        }
//        var srcObjcSize: UInt32 = 0;
//        if let srcObjcMethodList = class_copyMethodList(unsafeBitCast(ptr, to:AnyClass.self), &srcObjcSize) {
//            for i in 0..<srcObjcSize {
//                let srcMethod = srcObjcMethodList.advanced(by:Int(i)).pointee;
//            }
//            free(srcObjcMethodList);
//            //
//            UnsafeMutablePointer<OpaquePointer>(OpaquePointer(ptr)).advanced(by:1).pointee = OpaquePointer(ptr);
//        }
    }
}
