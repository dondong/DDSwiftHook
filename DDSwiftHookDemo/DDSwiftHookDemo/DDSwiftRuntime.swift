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
        return UnsafePointer<AnyClassMetadata>.init(OpaquePointer(ptr));
    }
    
    static func getSwiftClass(_ cls: AnyClass) -> UnsafePointer<ClassMetadata>? {
        let opaquePtr = Unmanaged.passUnretained(cls as AnyObject).toOpaque();
        let ptr = UnsafePointer<AnyClassMetadata>.init(OpaquePointer(opaquePtr));
        if (ptr.pointee.isSwiftMetadata()) {
            return Optional(UnsafePointer<ClassMetadata>.init(OpaquePointer(opaquePtr)));
        } else {
            return nil;
        }
    }
}
extension ClassDescriptor {
    static func getName(_ data: UnsafePointer<ClassDescriptor>) -> String {
        let ptr = UnsafeRawPointer(OpaquePointer.init(data)!);
        let nameAddr = UInt(bitPattern:ptr) + 4 + UInt(ptr.load(fromByteOffset:4, as:Int32.self));
        let namePtr = UnsafePointer<CChar>(bitPattern:nameAddr)!;
        return String(cString:namePtr);
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
        var clsVar = cls;
        let anyClassPtr = withUnsafePointer(to: &clsVar) { $0 };
        let name = class_getName(UnsafeRawPointer(anyClassPtr).load(as:AnyClass.self));
        return String(cString:name);
    }
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
    
    static func getName(_ cls: UnsafePointer<ClassMetadata>) -> String {
        var clsVar = cls;
        let anyClassPtr = withUnsafePointer(to: &clsVar) { $0 };
        let name = class_getName(UnsafeRawPointer.init(anyClassPtr).load(as:AnyClass.self));
        return String.init(cString:name);
    }
    
    static func getFunctionTable(_ cls: UnsafePointer<ClassMetadata>) -> UnsafeBufferPointer<OpaquePointer> {
        let size = (cls.pointee.classSize - 80 - cls.pointee.classAddressPoint) / 8;
        return UnsafeBufferPointer.init(start:UnsafePointer<OpaquePointer>.init(OpaquePointer(cls.advanced(by:1))), count:Int(size));
    }
}
