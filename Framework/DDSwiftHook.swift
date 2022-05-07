//
//  DDSwiftHook.swift
//  DDSwiftHook
//
//  Created by dondong on 2022/5/7.
//

import Foundation
import DDSwiftRuntime

protocol DDSwiftHookable {
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
        var srcObjcSize: UInt32 = 0;
        if let srcObjcMethodList = class_copyMethodList(unsafeBitCast(ptr, to:AnyClass.self), &srcObjcSize) {
            for i in 0..<srcObjcSize {
                let srcMethod = srcObjcMethodList.advanced(by:Int(i)).pointee;
                let sel = method_getName(srcMethod);
                if let dstMethod = class_getInstanceMethod(unsafeBitCast(superPtr, to:AnyClass.self), sel) {
                    method_exchangeImplementations(dstMethod, srcMethod);
                }
            }
            free(srcObjcMethodList);
            UnsafeMutablePointer<OpaquePointer>(OpaquePointer(ptr)).advanced(by:1).pointee = OpaquePointer(ptr);
        }
    }
}
