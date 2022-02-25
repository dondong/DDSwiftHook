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


protocol TypeContextClassDescriptorKind {
    var flag: ContextDescriptorFlags { get };
    var parent: Int32 { get };
    var name: Int32 { get };
    var accessFunction: Int32 { get };
    var fieldDescriptor: Int32 { get };
}

extension TypeContextClassDescriptorKind {
    
    static func getParent<T : TypeContextClassDescriptorKind>(_ data: UnsafePointer<T>) -> UnsafePointer<TypeContextClassDescriptor>? {
        let ptr = DDSwiftRuntime.getPointerFromRelativeDirectPointer(UnsafePointer<RelativeDirectPointer>(OpaquePointer(data)).advanced(by:1));
        return UnsafePointer<TypeContextClassDescriptor>(ptr);
    }
    
    static func getName<T : TypeContextClassDescriptorKind>(_ data: UnsafePointer<T>) -> String {
        let ptr = DDSwiftRuntime.getPointerFromRelativeDirectPointer(UnsafePointer<RelativeDirectPointer>(OpaquePointer(data)).advanced(by:2))!;
        let namePtr = UnsafePointer<CChar>(ptr);
        guard let parent = self.getParent(data) else { return String(cString:namePtr) }
        let preName = self.getName(parent);
        return String(preName + "." + String(cString:namePtr));
    }
    
    static func getAccessFunction<T : TypeContextClassDescriptorKind>(_ data: UnsafePointer<T>) -> OpaquePointer? {
        return DDSwiftRuntime.getPointerFromRelativeDirectPointer(UnsafePointer<RelativeDirectPointer>(OpaquePointer(data)).advanced(by:3));
    }
    static func getFieldDescriptor<T : TypeContextClassDescriptorKind>(_ data: UnsafePointer<T>) -> OpaquePointer? {
        return DDSwiftRuntime.getPointerFromRelativeDirectPointer(UnsafePointer<RelativeDirectPointer>(OpaquePointer(data)).advanced(by:4));
    }
}
extension TypeContextClassDescriptor : TypeContextClassDescriptorKind {
}
extension ClassDescriptor : TypeContextClassDescriptorKind {
    fileprivate static func _getVtableOffset(_ data: UnsafePointer<ClassDescriptor>) -> Int {
        var offset = 0;
        if (data.pointee.flag.isGeneric) {
            let ptr = UnsafePointer<TypeGenericContextDescriptorHeader>(OpaquePointer(data.advanced(by:1)));
            offset = MemoryLayout<TypeGenericContextDescriptorHeader>.size + Int((ptr.pointee.base.numParams + 3) & ~UInt16(3)) + MemoryLayout<GenericRequirementDescriptor>.size * Int(ptr.pointee.base.numRequirements);
        }
        if (data.pointee.flag.hasResilientSuperclass) {
            offset += MemoryLayout<ResilientSuperclass>.size;
        }
        switch(data.pointee.flag.metadataInitialization) {
        case .ForeignMetadataInitialization:
            offset += MemoryLayout<ForeignMetadataInitialization>.size;
        case .SingletonMetadataInitialization:
            offset += MemoryLayout<SingletonMetadataInitialization>.size;
        case .NoMetadataInitialization:
            offset += 0;
        }
        return offset;
    }
    static func getVTable(_ data: UnsafePointer<ClassDescriptor>) -> UnsafeBufferPointer<MethodDescriptor>? {
        if (data.pointee.flag.hasVTable) {
            let ptr = UnsafeRawPointer(OpaquePointer(data.advanced(by:1))).advanced(by:self._getVtableOffset(data)).assumingMemoryBound(to:VTableDescriptorHeader.self);
            let buffer = UnsafeBufferPointer(start:UnsafePointer<MethodDescriptor>(OpaquePointer(ptr.advanced(by:1))), count:Int(ptr.pointee.vTableSize));
            return Optional(buffer);
        } else {
            return nil;
        }
    }
    
    fileprivate static func _getOverridetableOffset(_ data: UnsafePointer<ClassDescriptor>) -> Int {
        var offset = self._getVtableOffset(data);
        if (data.pointee.flag.hasVTable) {
            let ptr = UnsafeRawPointer(OpaquePointer(data.advanced(by:1))).advanced(by:offset).assumingMemoryBound(to:VTableDescriptorHeader.self);
            offset += MemoryLayout<VTableDescriptorHeader>.size;
            offset += MemoryLayout<MethodDescriptor>.size * Int(ptr.pointee.vTableSize);
        }
        return offset;
    }
    
    static func getOverridetable(_ data: UnsafePointer<ClassDescriptor>) -> UnsafeBufferPointer<MethodOverrideDescriptor>? {
        if (data.pointee.flag.hasOverrideTable) {
            let ptr = UnsafeRawPointer(OpaquePointer(data.advanced(by:1))).advanced(by:self._getOverridetableOffset(data)).assumingMemoryBound(to:OverrideTableHeader.self);
            let buffer = UnsafeBufferPointer(start:UnsafePointer<MethodOverrideDescriptor>(OpaquePointer(ptr.advanced(by:1))), count:Int(ptr.pointee.numEntries));
            return Optional(buffer);
        } else {
            return nil;
        }
    }
}

protocol ObjcClassKind {
    var isa: uintptr_t { get };
    var superclass: uintptr_t { get };
    var cache0: uintptr_t { get };
    var cache1: uintptr_t { get };
    var ro: uintptr_t { get };
}
extension ObjcClassKind {
    func isaClass<T : ObjcClassKind>() -> UnsafePointer<T> {
        return UnsafePointer<T>(bitPattern:self.isa)!;
    }
    func superClass<T : ObjcClassKind>() -> UnsafePointer<T> {
        return UnsafePointer<T>(bitPattern:self.superclass)!;
    }
    
    static func getName<T : ObjcClassKind>(_ cls: UnsafePointer<T>) -> String {
        return String.init(cString:class_getName(unsafeBitCast(cls, to:AnyClass.self)));
    }
}

extension AnyClassMetadata : ObjcClassKind {
    var isSwiftMetadata: Bool {
        get {
            if (self.ro & (1<<1) > 0) {
                return true;
            } else {
                return false;
            }
        }
    }
}

extension ClassMetadata : ObjcClassKind {
    var descriptor: UnsafePointer<ClassDescriptor> { get { return UnsafePointer<ClassDescriptor>(bitPattern:self.description)!; } }
    
    static func getFunctionTable(_ cls: UnsafePointer<ClassMetadata>) -> UnsafeBufferPointer<OpaquePointer> {
        let size = (cls.pointee.classSize - 80 - cls.pointee.classAddressPoint) / 8;
        return UnsafeBufferPointer.init(start:UnsafePointer<OpaquePointer>.init(OpaquePointer(cls.advanced(by:1))), count:Int(size));
    }
}
