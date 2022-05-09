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
        let tempPtr = UnsafePointer<ClassMetadata>(OpaquePointer(ptr.pointee.superclass));
        let tempCls: AnyClass = unsafeBitCast(tempPtr, to:AnyClass.self);
        let superPtr = UnsafePointer<ClassMetadata>(OpaquePointer(tempPtr.pointee.superclass));
        let superCls: AnyClass = unsafeBitCast(superPtr, to:AnyClass.self);
        
        // hook swift vtable method
        let offset = MemoryLayout<ClassMetadata>.size;
        let size = Int(superPtr.pointee.classSize) - Int(superPtr.pointee.classAddressPoint) - offset;
        let srcPtr = UnsafeRawPointer(ptr).advanced(by:offset);
        let dstPtr = UnsafeMutableRawPointer(OpaquePointer(superPtr)).advanced(by:offset);
        dstPtr.copyMemory(from:srcPtr, byteCount:size);
        
        // hook objective-c method
        var srcObjcSize: UInt32 = 0;
        if let srcObjcMethodList = class_copyMethodList(cls, &srcObjcSize) {
            for i in 0..<srcObjcSize {
                let srcMethod = srcObjcMethodList.advanced(by:Int(i)).pointee;
                let sel = method_getName(srcMethod);
                if let dstMethod = class_getInstanceMethod(superCls, sel) {
                    if let tempMethod = class_getInstanceMethod(tempCls, sel) {
                        method_setImplementation(tempMethod,
                                                 method_getImplementation(dstMethod));
                    } else {
                        class_addMethod(tempCls,
                                        sel,
                                        method_getImplementation(dstMethod),
                                        method_getTypeEncoding(dstMethod));
                    }
                    method_setImplementation(dstMethod,
                                             method_getImplementation(srcMethod));
                } else if class_respondsToSelector(superCls, sel) {
                    var dstMethod: Method? = nil;
                    var tmpCls: AnyClass = superCls;
                    while (nil == dstMethod) {
                        tmpCls = class_getSuperclass(tmpCls)!;
                        dstMethod = class_getInstanceMethod(tmpCls, sel);
                    }
                    class_addMethod(superCls,
                                    sel,
                                    method_getImplementation(srcMethod),
                                    method_getTypeEncoding(srcMethod));
                    class_addMethod(tempCls,
                                    sel,
                                    method_getImplementation(dstMethod!),
                                    method_getTypeEncoding(dstMethod!));
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
//        let offset = MemoryLayout<ClassMetadata>.size;
//        let size = Int(superPtr.pointee.classSize) - Int(superPtr.pointee.classAddressPoint) - offset;
//        let srcPtr = UnsafeRawPointer(ptr).advanced(by:offset);
//        let dstPtr = UnsafeMutableRawPointer(OpaquePointer(superPtr)).advanced(by:offset);
//        dstPtr.copyMemory(from:srcPtr, byteCount:size);
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
//                        class_addMethod(fakeSuperCls,
//                                        sel,
//                                        method_getImplementation(dstMethod),
//                                        method_getTypeEncoding(dstMethod));
//                        method_setImplementation(dstMethod,
//                                                 method_getImplementation(srcMethod));
//                    } else if class_respondsToSelector(superCls, sel) {
//                        var dstMethod: Method? = nil;
//                        var tmpCls: AnyClass = superCls;
//                        while (nil == dstMethod) {
//                            tmpCls = class_getSuperclass(tmpCls)!;
//                            dstMethod = class_getInstanceMethod(tmpCls, sel);
//                        }
//                        class_addMethod(superCls, sel, method_getImplementation(srcMethod), method_getTypeEncoding(srcMethod));
//                        class_addMethod(fakeSuperCls,
//                                        sel,
//                                        method_getImplementation(dstMethod!),
//                                        method_getTypeEncoding(dstMethod!));
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
