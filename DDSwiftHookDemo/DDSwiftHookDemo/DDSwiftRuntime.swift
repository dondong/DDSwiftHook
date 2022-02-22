//
//  DDSwiftRuntime.swift
//  DDSwiftHookDemo
//
//  Created by dondong on 2022/2/22.
//

import Foundation
import MachO

class DDSwiftRuntime {
    static func getData<T>(_ address: uintptr_t) -> UnsafePointer<T>? {
        return UnsafePointer<T>.init(OpaquePointer.init(bitPattern:address));
    }
    
    static func getObjcClass(_ cls: AnyClass) -> UnsafePointer<AnyClassMetadata> {
        let ptr = Unmanaged.passUnretained(cls as AnyObject).toOpaque();
        return UnsafePointer<AnyClassMetadata>.init(OpaquePointer.init(ptr));
    }
    
    static func getSwiftClass(_ cls: AnyClass) -> UnsafePointer<ClassMetadata>? {
        let opaquePtr = Unmanaged.passUnretained(cls as AnyObject).toOpaque();
        let ptr = UnsafePointer<AnyClassMetadata>.init(OpaquePointer.init(opaquePtr));
        if (ptr.pointee.isSwiftMetadata()) {
            return Optional(UnsafePointer<ClassMetadata>.init(OpaquePointer.init(opaquePtr)));
        } else {
            return nil;
        }
    }
}
extension ClassDescriptor {
    static func getName(_ data: UnsafePointer<ClassDescriptor>) -> String {
        let ptr = UnsafeRawPointer.init(OpaquePointer.init(data)!);
        let nameAddr = UInt(bitPattern:ptr) + 4 + UInt(ptr.load(fromByteOffset:4, as:Int32.self));
        let namePtr = UnsafePointer<CChar>.init(bitPattern:nameAddr)!;
        return String.init(cString:namePtr);
    }
}

extension AnyClassMetadata {
    func isSwiftMetadata() -> Bool {
        if (self.ro & (1<<1) > 0) {
            return true;
        } else {
            return false;
        }
    }
    
    func getIsaClass() -> UnsafePointer<AnyClassMetadata> {
        return DDSwiftRuntime.getData(self.isa)!;
    }
    
    func getSuperClass() -> UnsafePointer<AnyClassMetadata> {
        return DDSwiftRuntime.getData(self.superclass)!;
    }
    
    static func getName(_ cls: UnsafePointer<AnyClassMetadata>) -> String {
        let name = class_getName(cls as? AnyClass);
        return String.init(cString:name);
    }
    
//    fileprivate static func getClassName(_ ro: uintptr_t) ->String {
//        let mask: UInt64 = 0x00007ffffffffff8;
//        let addr = UInt64(ro) & mask;
//        let ptr = UnsafeRawPointer.init(bitPattern:UInt(addr))!;
//        let flags = ptr.load(as:UInt32.self);
//        var roPtr: UnsafeRawPointer = ptr;
//        if ((flags & (1<<31)) > 0) {
//            roPtr = UnsafeRawPointer.init(bitPattern:ptr.load(fromByteOffset:8, as:UInt.self))!;
//        }
//        let nameAddr = roPtr.advanced(by:5 * MemoryLayout.size(ofValue:UInt8.self)).load(as:UInt.self);
//        let namePtr = UnsafePointer<CChar>.init(bitPattern:nameAddr)!;
//        let cls = roPtr as? AnyClass;
//        return String.init(cString:namePtr);
//    }
}

extension ClassMetadata {
    func getIsaClass() -> UnsafePointer<AnyClassMetadata> {
        return DDSwiftRuntime.getData(self.kind)!;
    }
    
    func getSuperClass() -> UnsafePointer<AnyClassMetadata> {
        return DDSwiftRuntime.getData(self.superclass)!;
    }
    
    func getDescriptor() -> UnsafePointer<ClassDescriptor> {
        return DDSwiftRuntime.getData(self.description)!;
    }
}
