//
//  DDSwiftRuntime.swift
//  DDSwiftHookDemo
//
//  Created by dondong on 2022/2/22.
//

import Foundation
import MachO

class DDSwiftRuntime {
    static func getObjcClass(_ cls: AnyClass) -> UnsafePointer<AnyClassMetadata> {
        let ptr = Unmanaged.passUnretained(cls as AnyObject).toOpaque();
        return UnsafePointer<AnyClassMetadata>.init(OpaquePointer(ptr));
    }
    
    static func getSwiftClass(_ cls: AnyClass) -> UnsafePointer<ClassMetadata>? {
        let opaquePtr = Unmanaged.passUnretained(cls as AnyObject).toOpaque();
        let ptr = UnsafePointer<AnyClassMetadata>.init(OpaquePointer(opaquePtr));
        if (ptr.pointee.isSwiftMetadata) {
            return Optional(UnsafePointer<ClassMetadata>.init(OpaquePointer(opaquePtr)));
        } else {
            return nil;
        }
    }
    
    static func covert<T>(_ val: Any) -> T {
        var tmpVal = val;
        let tmpValPtr = withUnsafePointer(to: &tmpVal) { $0 };
        return UnsafeRawPointer.init(tmpValPtr).load(as:T.self);
    }
    
    static func getPointerFromRelativeContextPointer(_ ptr: UnsafePointer<RelativeContextPointer>) -> OpaquePointer? {
        if (0 != ptr.pointee) {
            if ((ptr.pointee & 1) != 0) {
                return UnsafePointer<OpaquePointer>(OpaquePointer(bitPattern:Int(bitPattern:ptr) + Int(ptr.pointee & ~1)))?.pointee;
            } else {
                return OpaquePointer(bitPattern:Int(bitPattern:ptr) + Int(ptr.pointee & ~1));
            }
        } else {
            return nil;
        }
    }
    
    static func getPointerFromRelativeDirectPointer(_ ptr: UnsafePointer<RelativeDirectPointer>, _ isPointer: Bool = false) -> OpaquePointer? {
        if (0 != ptr.pointee) {
            return OpaquePointer(bitPattern:Int(bitPattern:ptr) + Int(ptr.pointee));
        } else {
            return nil;
        }
    }
}
