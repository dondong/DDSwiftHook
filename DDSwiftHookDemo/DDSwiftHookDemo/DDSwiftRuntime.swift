//
//  DDSwiftRuntime.swift
//  DDSwiftHookDemo
//
//  Created by dondong on 2022/2/22.
//

import Foundation
import MachO

class DDSwiftRuntime {
    static func getData<T>(_ address: Pointer) -> UnsafePointer<T>? {
        return UnsafePointer<T>(OpaquePointer.init(bitPattern:address));
    }
    
    static func getData<T>(_ address: OpaquePointer) -> UnsafePointer<T>? {
        return UnsafePointer<T>(address);
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
    
    static func covert<T>(_ val: Any) -> T {
        var tmpVal = val;
        let tmpValPtr = withUnsafePointer(to: &tmpVal) { $0 };
        return UnsafeRawPointer.init(tmpValPtr).load(as:T.self);
    }
    
    static func getPointerFromRelativeDirectPointer(_ ptr: UnsafePointer<RelativeDirectPointer>) -> OpaquePointer? {
        if (0 != ptr.pointee) {
            return OpaquePointer(bitPattern:Int(bitPattern:ptr) + Int(ptr.pointee));
        } else {
            return nil;
        }
    }
}

extension ContextDescriptorFlags {
    var kind: ContextDescriptorKind { get { return ContextDescriptorKind(rawValue:UInt8(self.value & 0x1F)) ?? ContextDescriptorKind.Module; } }
    var isGeneric: Bool { get { return (self.value & 0x80) != 0; } }
    var isUnique: Bool { get { return (self.value & 0x40) != 0; } }
    var version: UInt8 { get { return UInt8((self.value >> 8) & 0xFF); } }
    var kindSpecificFlags: UInt16 { get { return UInt16((self.value >> 16) & 0xFFFF); } }
    var metadataInitialization: MetadataInitializationKind { get { return MetadataInitializationKind(rawValue:UInt8(self.kindSpecificFlags & 0x3)) ?? .NoMetadataInitialization } }
    var hasResilientSuperclass: Bool { get { return (self.kindSpecificFlags & 0x2000) != 0; } }
    var hasVTable: Bool { get { return (self.kindSpecificFlags & 0x8000) != 0; } }
    var hasOverrideTable: Bool { get { return (self.kindSpecificFlags & 0x4000) != 0; } }
}

extension MethodDescriptor {
    static func getImpl(_ data: UnsafePointer<MethodDescriptor>) -> OpaquePointer {
        return DDSwiftRuntime.getPointerFromRelativeDirectPointer(UnsafePointer<RelativeDirectPointer>(OpaquePointer(data)).advanced(by:1))!;
    }
}

extension MethodOverrideDescriptor {
    static func getClass(_ data: UnsafePointer<MethodOverrideDescriptor>) -> OpaquePointer {
        return DDSwiftRuntime.getPointerFromRelativeDirectPointer(UnsafePointer<RelativeDirectPointer>(OpaquePointer(data)))!;
    }
    static func getMethod(_ data: UnsafePointer<MethodOverrideDescriptor>) -> OpaquePointer {
        return DDSwiftRuntime.getPointerFromRelativeDirectPointer(UnsafePointer<RelativeDirectPointer>(OpaquePointer(data)).advanced(by:1))!;
    }
    static func getImpl(_ data: UnsafePointer<MethodOverrideDescriptor>) -> OpaquePointer {
        return DDSwiftRuntime.getPointerFromRelativeDirectPointer(UnsafePointer<RelativeDirectPointer>(OpaquePointer(data)).advanced(by:2))!;
    }
}

protocol TypeContextClassDescriptorKind {
    var flag: UInt32 { get };
    var parent: Int32 { get };
    var name: Int32 { get };
    var accessFunction: Int32 { get };
    var fieldDescriptor: Int32 { get };
}
extension TypeContextClassDescriptorKind {
    func getFlags() -> ContextDescriptorFlags {
        return ContextDescriptorFlags(value:self.flag);
    }
    
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
        if (data.pointee.getFlags().isGeneric) {
            let ptr = UnsafePointer<TypeGenericContextDescriptorHeader>(OpaquePointer(data.advanced(by:1)));
            offset = MemoryLayout<TypeGenericContextDescriptorHeader>.size + Int((ptr.pointee.base.numParams + 3) & ~UInt16(3)) + MemoryLayout<GenericRequirementDescriptor>.size * Int(ptr.pointee.base.numRequirements);
        }
        if (data.pointee.getFlags().hasResilientSuperclass) {
            offset += MemoryLayout<ResilientSuperclass>.size;
        }
        switch(data.pointee.getFlags().metadataInitialization) {
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
        if (data.pointee.getFlags().hasVTable) {
            let ptr = UnsafeRawPointer(OpaquePointer(data.advanced(by:1))).advanced(by:self._getVtableOffset(data)).assumingMemoryBound(to:VTableDescriptorHeader.self);
            let buffer = UnsafeBufferPointer(start:UnsafePointer<MethodDescriptor>(OpaquePointer(ptr.advanced(by:1))), count:Int(ptr.pointee.vTableSize));
            return Optional(buffer);
        } else {
            return nil;
        }
    }
    
    fileprivate static func _getOverridetableOffset(_ data: UnsafePointer<ClassDescriptor>) -> Int {
        var offset = 0;
        if (data.pointee.getFlags().isGeneric) {
            let ptr = UnsafePointer<TypeGenericContextDescriptorHeader>(OpaquePointer(data.advanced(by:1)));
            offset = MemoryLayout<TypeGenericContextDescriptorHeader>.size + Int((ptr.pointee.base.numParams + 3) & ~UInt16(3)) + MemoryLayout<GenericRequirementDescriptor>.size * Int(ptr.pointee.base.numRequirements);
        }
        if (data.pointee.getFlags().hasResilientSuperclass) {
            offset += MemoryLayout<ResilientSuperclass>.size;
        }
        switch(data.pointee.getFlags().metadataInitialization) {
        case .ForeignMetadataInitialization:
            offset += MemoryLayout<ForeignMetadataInitialization>.size;
        case .SingletonMetadataInitialization:
            offset += MemoryLayout<SingletonMetadataInitialization>.size;
        case .NoMetadataInitialization:
            offset += 0;
        }
        if (data.pointee.getFlags().hasVTable) {
            let ptr = UnsafeRawPointer(OpaquePointer(data.advanced(by:1))).advanced(by:offset).assumingMemoryBound(to:VTableDescriptorHeader.self);
            offset += MemoryLayout<VTableDescriptorHeader>.size;
            offset += MemoryLayout<MethodDescriptor>.size * Int(ptr.pointee.vTableSize);
        }
        return offset;
    }
    
    static func getOverridetable(_ data: UnsafePointer<ClassDescriptor>) -> UnsafeBufferPointer<MethodOverrideDescriptor>? {
        if (data.pointee.getFlags().hasOverrideTable) {
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
    func getIsaClass<T : ObjcClassKind>() -> UnsafePointer<T> {
        return DDSwiftRuntime.getData(self.isa)!;
    }
    func getSuperClass<T : ObjcClassKind>() -> UnsafePointer<T> {
        return DDSwiftRuntime.getData(self.superclass)!;
    }
    static func getName<T : ObjcClassKind>(_ cls: UnsafePointer<T>) -> String {
        return String.init(cString:class_getName(DDSwiftRuntime.covert(cls)));
    }
}

extension AnyClassMetadata : ObjcClassKind {
    func isSwiftMetadata() -> Bool {
        if (self.ro & (1<<1) > 0) {
            return true;
        } else {
            return false;
        }
    }
}

extension ClassMetadata : ObjcClassKind {
    func getDescriptor() -> UnsafePointer<ClassDescriptor> {
        return DDSwiftRuntime.getData(self.description)!;
    }
    
    static func getFunctionTable(_ cls: UnsafePointer<ClassMetadata>) -> UnsafeBufferPointer<OpaquePointer> {
        let size = (cls.pointee.classSize - 80 - cls.pointee.classAddressPoint) / 8;
        return UnsafeBufferPointer.init(start:UnsafePointer<OpaquePointer>.init(OpaquePointer(cls.advanced(by:1))), count:Int(size));
    }
}
