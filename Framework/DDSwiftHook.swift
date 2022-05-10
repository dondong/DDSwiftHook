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
        let cls = Self.self;
        let ptr = unsafeBitCast(cls, to: UnsafePointer<ClassMetadata>.self);
        let tempPtr = UnsafePointer<AnyClassMetadata>(OpaquePointer(ptr.pointee.superclass));
        let tempCls: AnyClass = unsafeBitCast(tempPtr, to:AnyClass.self);
        let superPtr = UnsafePointer<AnyClassMetadata>(OpaquePointer(tempPtr.pointee.superclass));
        let superCls: AnyClass = unsafeBitCast(superPtr, to:AnyClass.self);
        
        // hook swift vtable method
        if (false == superPtr.pointee.isPureObjC) {
            let superSwiftPtr = UnsafeMutablePointer<ClassMetadata>(OpaquePointer(superPtr));
            let vtableRanges = superSwiftPtr.pointee.vtableRanges;
            for range in vtableRanges {
                let srcPtr = UnsafeRawPointer(ptr).advanced(by:range.location);
                let dstPtr = UnsafeMutableRawPointer(OpaquePointer(superPtr)).advanced(by:range.location);
                dstPtr.copyMemory(from:srcPtr, byteCount:range.length * MemoryLayout<OpaquePointer>.size);
            }
        }
        
        // hook objective-c method
        var srcObjcSize: UInt32 = 0;
        if let srcObjcMethodList = class_copyMethodList(cls, &srcObjcSize) {
            for i in 0..<srcObjcSize {
                let srcMethod = srcObjcMethodList.advanced(by:Int(i)).pointee;
                let sel = method_getName(srcMethod);
                if let dstMethod = class_getInstanceMethod(superCls, sel) {
                    class_replaceMethod(tempCls,
                                        sel,
                                        method_getImplementation(dstMethod),
                                        method_getTypeEncoding(dstMethod));
                    class_replaceMethod(superCls,
                                        sel,
                                        method_getImplementation(srcMethod),
                                        method_getTypeEncoding(srcMethod));
                }
            }
            free(srcObjcMethodList);
        }
    }
}

//extension DDSwiftHookable {
//    static func enableHook() {
//        let cls = Self.self;
//        let ptr = unsafeBitCast(cls, to: UnsafePointer<ClassMetadata>.self);
//        let superPtr = UnsafePointer<ClassMetadata>(OpaquePointer(ptr.pointee.superclass));
//        let superCls: AnyClass = unsafeBitCast(superPtr, to:AnyClass.self);
//
//        // hook swift vtable method
//        if (false == superPtr.pointee.isPureObjC) {
//            let superSwiftPtr = UnsafeMutablePointer<ClassMetadata>(OpaquePointer(superPtr));
//            let vtableRanges = superSwiftPtr.pointee.vtableRanges;
//            for range in vtableRanges {
//                let srcPtr = UnsafeRawPointer(ptr).advanced(by:range.location);
//                let dstPtr = UnsafeMutableRawPointer(OpaquePointer(superPtr)).advanced(by:range.location);
//                dstPtr.copyMemory(from:srcPtr, byteCount:range.length * MemoryLayout<OpaquePointer>.size);
//            }
//        }
//
//        // hook objective-c method
//        var srcObjcSize: UInt32 = 0;
//        if let srcObjcMethodList = class_copyMethodList(cls, &srcObjcSize) {
//            let fakeName = String(format:"%s_fake", class_getName(cls));
//            if let fakeSuperCls = objc_allocateClassPair(superCls, fakeName.cString(using:.utf8)!, 0) {
//                for i in 0..<srcObjcSize {
//                    let srcMethod = srcObjcMethodList.advanced(by:Int(i)).pointee;
//                    let sel = method_getName(srcMethod);
//                    if let dstMethod = class_getInstanceMethod(superCls, sel) {
//                        class_replaceMethod(fakeSuperCls,
//                                            sel,
//                                            method_getImplementation(dstMethod),
//                                            method_getTypeEncoding(dstMethod));
//                        class_replaceMethod(superCls,
//                                            sel,
//                                            method_getImplementation(srcMethod),
//                                            method_getTypeEncoding(srcMethod));
//                    }
//                }
//                objc_registerClassPair(fakeSuperCls);
//                //
//                UnsafeMutablePointer<OpaquePointer>(OpaquePointer(ptr)).advanced(by:1).pointee = unsafeBitCast(fakeSuperCls, to: OpaquePointer.self);
//                let fakeSuperPtr = unsafeBitCast(fakeSuperCls, to:UnsafePointer<AnyClassMetadata>.self);
//                UnsafeMutablePointer<OpaquePointer>(OpaquePointer(ptr.pointee.isa)).advanced(by:1).pointee = OpaquePointer(fakeSuperPtr.pointee.isa);
//            }
//            free(srcObjcMethodList);
//        }
//    }
//}
