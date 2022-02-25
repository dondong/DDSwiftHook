//
//  MetadataValue.swift
//  DDSwiftHookDemo
//
//  Created by dondong on 2022/2/21.
//

import Foundation

typealias RelativeContextPointer=Int32
typealias RelativeDirectPointer=Int32
typealias Pointer=uintptr_t
// MARK: -
// MARK: HeapObject
/***
 * MetadataKind
 ***/
let MetadataKindIsNonType: UInt32 = 0x400;
let MetadataKindIsNonHeap: UInt32 = 0x200;
let MetadataKindIsRuntimePrivate: UInt32 = 0x100;
enum MetadataKind : UInt32 {
    case Class = 0;
    case Struct = 0x200;  //  0 | MetadataKindIsNonHeap
    case Enum = 0x201;  // 1 | MetadataKindIsNonHeap
    case Optional = 0x202;  // 2 | MetadataKindIsNonHeap)
    case ForeignClass = 0x203;  // 3 | MetadataKindIsNonHeap)
    case Opaque = 0x300;   // 0 | MetadataKindIsRuntimePrivate | MetadataKindIsNonHeap
    case Tuple = 0x301;  // 1 | MetadataKindIsRuntimePrivate | MetadataKindIsNonHeap
    case Function = 0x302;  // 2 | MetadataKindIsRuntimePrivate | MetadataKindIsNonHeap
    case Existential = 0x303;  // 3 | MetadataKindIsRuntimePrivate | MetadataKindIsNonHeap
    case Metatype = 0x304;   // 4 | MetadataKindIsRuntimePrivate | MetadataKindIsNonHeap
    case ObjCClassWrapper = 0x305;  // 5 | MetadataKindIsRuntimePrivate | MetadataKindIsNonHeap
    case ExistentialMetatype = 0x306;  // 6 | MetadataKindIsRuntimePrivate | MetadataKindIsNonHeap
    case HeapLocalVariable = 0x400;   // 0 | MetadataKindIsNonType
    case HeapGenericLocalVariable = 0x500;  // 0 | MetadataKindIsNonType | MetadataKindIsRuntimePrivate
    case ErrorObject = 0x501;  // 1 | MetadataKindIsNonType | MetadataKindIsRuntimePrivate
    case Task = 0x502;  // 2 | MetadataKindIsNonType | MetadataKindIsRuntimePrivate
    case Job = 0x503;  // 3 | MetadataKindIsNonType | MetadataKindIsRuntimePrivate
}

extension MetadataKind {
    var isHeapMetadataKind: Bool { get { return (self.rawValue & MetadataKindIsNonHeap) == 0; } }
    var isTypeMetadataKind: Bool { get { return (self.rawValue & MetadataKindIsNonType) == 0; } }
    var isRuntimePrivateMetadataKind: Bool { get { return (self.rawValue & MetadataKindIsRuntimePrivate) != 0; } }
}

/***
 * ValueWitnessFlags
 ***/
struct ValueWitnessFlags {
    let data: UInt32;
}

extension ValueWitnessFlags {
    fileprivate static let AlignmentMask: UInt32       = 0x000000FF;
    fileprivate static let IsNonPOD: UInt32            = 0x00010000;
    fileprivate static let IsNonInline: UInt32         = 0x00020000;
    fileprivate static let HasSpareBits: UInt32        = 0x00080000;
    fileprivate static let IsNonBitwiseTakable: UInt32 = 0x00100000;
    fileprivate static let HasEnumWitnesses: UInt32    = 0x00200000;
    fileprivate static let Incomplete: UInt32          = 0x00400000;
    
    var alignmentMask: UInt32 { get { return self.data & ValueWitnessFlags.AlignmentMask; } }
    var alignment: UInt32 { get { return self.alignmentMask + 1; } }
    var isInlineStorage: Bool { get { return (self.data & ValueWitnessFlags.IsNonBitwiseTakable) == 0; } }
    var isPOD: Bool { get { return (self.data & ValueWitnessFlags.IsNonPOD) == 0; } }
    var isBitwiseTakable: Bool { get { return (self.data & ValueWitnessFlags.IsNonBitwiseTakable) == 0; } }
    var hasEnumWitnesses: Bool { get { return (self.data & ValueWitnessFlags.HasEnumWitnesses) != 0; } }
    var isIncomplete: Bool { get { return (self.data & ValueWitnessFlags.Incomplete) == 0; } }
}

/***
 * ValueWitnessTable
 ***/
struct ValueWitnessTable {
    let initializeBufferWithCopyOfBuffer: OpaquePointer;
    let destroy: OpaquePointer;
    let initializeWithCopy: OpaquePointer;
    let assignWithCopy: OpaquePointer;
    let initializeWithTake: OpaquePointer;
    let assignWithTake: OpaquePointer;
    let getEnumTagSinglePayload: OpaquePointer;
    let storeEnumTagSinglePayload: OpaquePointer;
    let size: size_t;
    let stride: size_t;
    let flags: ValueWitnessFlags;
    let extraInhabitantCount: UInt32;
    let getEnumTag: Pointer;
    let destructiveProjectEnumData: OpaquePointer;
    let destructiveInjectEnumTag: OpaquePointer;
}

extension ValueWitnessTable {
    var isIncomplete: Bool { get { self.flags.isIncomplete; } }
    var isValueInline: Bool { get { self.flags.isInlineStorage; } }
    var isPOD: Bool { get { self.flags.isPOD; } }
    var isBitwiseTakable: Bool { get { self.flags.isBitwiseTakable; } }
    var alignment: UInt32 { get { self.flags.alignment; } }
    var alignmentMask: UInt32 { get { self.flags.alignmentMask; } }
}

/***
 * HeapMetadata
 ***/
struct HeapMetadata {
    let kind: Pointer;
    private let _valueWitnesses: UnsafePointer<ValueWitnessTable>;
}

extension HeapMetadata {
    fileprivate static let LastEnumerated: UInt = 0x7FF;
    var metadataKind: MetadataKind {
        get {
            if (self.kind > HeapMetadata.LastEnumerated) {
                return .Class;
            }
            return MetadataKind(rawValue:UInt32(self.kind & HeapMetadata.LastEnumerated)) ?? .Class;
        }
    }
    var isClassObject: Bool { get { return self.metadataKind == .Class; } }
    var isAnyExistentialType: Bool {
        get {
            switch (self.metadataKind) {
            case .ExistentialMetatype, .Existential:
                return true;
            default:
                return false;
            }
        }
    }
    var isAnyClass: Bool {
        get {
            switch (self.metadataKind) {
            case .Class, .ObjCClassWrapper, .ForeignClass:
                return true;
            default:
                return false;
            }
        }
    }
    
    // valueWitnesses
    var valueWitnesses: UnsafePointer<ValueWitnessTable> { mutating get { return Self.getValueWitnesses(&self); } }
    static func getValueWitnesses(_ data: UnsafePointer<HeapMetadata>) -> UnsafePointer<ValueWitnessTable> {
        return data.advanced(by:-1).pointee._valueWitnesses;
    }
}

/***
 * HeapObject
 ***/
struct HeapObject {
    let metadata: UnsafePointer<HeapMetadata>;
    let refCounts: size_t;
}

// MARK: -
// MARK: ClassMetadata
/***
 * ContextDescriptorKind
 ***/
enum ContextDescriptorKind : UInt8 {
    /// This context descriptor represents a module.
    case Module = 0;
    /// This context descriptor represents an extension.
    case Extension = 1;
    /// This context descriptor represents an anonymous possibly-generic context
    /// such as a function body.
    case Anonymous = 2;
    /// This context descriptor represents a protocol context.
    case ProtocolType = 3;
    /// This context descriptor represents an opaque type alias.
    case OpaqueType = 4;
    /// First kind that represents a type of any sort.
    /// case Type_First = 16
    /// This context descriptor represents a class.
    case Class = 16;   // .Type_First
    /// This context descriptor represents a struct.
    case Struct = 17;  // .Type_First + 1
    /// This context descriptor represents an enum.
    case Enum = 18;    // .Type_First + 2
    /// Last kind that represents a type of any sort.
    case Type_Last = 31;
};

/***
 * MetadataInitializationKind
 ***/
enum MetadataInitializationKind : UInt8 {
    case NoMetadataInitialization = 0;
    case SingletonMetadataInitialization = 1;
    case ForeignMetadataInitialization = 2;
}

/***
 * MethodDescriptorKind
 ***/
enum MethodDescriptorKind : UInt8 {
    case Method = 0;
    case Init = 1;
    case Getter = 2;
    case Setter = 3;
    case ModifyCoroutine = 4;
    case ReadCoroutine = 5;
}

/***
 * ContextDescriptorFlags
 ***/
struct ContextDescriptorFlags {
    let value: UInt32;
}

extension ContextDescriptorFlags {
    var kind: ContextDescriptorKind { get { return ContextDescriptorKind(rawValue:UInt8(self.value & 0x1F)) ?? .Module; } }
    var isGeneric: Bool { get { return (self.value & 0x80) != 0; } }
    var isUnique: Bool { get { return (self.value & 0x40) != 0; } }
    var version: UInt8 { get { return UInt8((self.value >> 8) & 0xFF); } }
    var kindSpecificFlags: UInt16 { get { return UInt16((self.value >> 16) & 0xFFFF); } }
    var metadataInitialization: MetadataInitializationKind { get { return MetadataInitializationKind(rawValue:UInt8(self.kindSpecificFlags & 0x3)) ?? .NoMetadataInitialization } }
    var hasResilientSuperclass: Bool { get { return (self.kindSpecificFlags & 0x2000) != 0; } }
    var hasVTable: Bool { get { return (self.kindSpecificFlags & 0x8000) != 0; } }
    var hasOverrideTable: Bool { get { return (self.kindSpecificFlags & 0x4000) != 0; } }
}

/***
 * TypeContextClassDescriptor
 ***/
protocol TypeContextClassDescriptorKind {
}

extension TypeContextClassDescriptorKind {
    // parent
    var parent: UnsafePointer<TypeContextClassDescriptor>? { mutating get { return Self.getParent(&self); } }
    static func getParent<T : TypeContextClassDescriptorKind>(_ data: UnsafePointer<T>) -> UnsafePointer<TypeContextClassDescriptor>? {
        let ptr = DDSwiftRuntime.getPointerFromRelativeDirectPointer(UnsafePointer<RelativeDirectPointer>(OpaquePointer(data)).advanced(by:1));
        return UnsafePointer<TypeContextClassDescriptor>(ptr);
    }
    // name
    var name: String { mutating get { return Self.getName(&self); } }
    static func getName<T : TypeContextClassDescriptorKind>(_ data: UnsafePointer<T>) -> String {
        let ptr = DDSwiftRuntime.getPointerFromRelativeDirectPointer(UnsafePointer<RelativeDirectPointer>(OpaquePointer(data)).advanced(by:2))!;
        let namePtr = UnsafePointer<CChar>(ptr);
        guard let parent = self.getParent(data) else { return String(cString:namePtr) }
        let preName = self.getName(parent);
        return String(preName + "." + String(cString:namePtr));
    }
    // accessFunction
    var accessFunction: OpaquePointer? { mutating get { Self.getAccessFunction(&self); } }
    static func getAccessFunction<T : TypeContextClassDescriptorKind>(_ data: UnsafePointer<T>) -> OpaquePointer? {
        return DDSwiftRuntime.getPointerFromRelativeDirectPointer(UnsafePointer<RelativeDirectPointer>(OpaquePointer(data)).advanced(by:3));
    }
    // fieldDescriptor
    var fieldDescriptor: OpaquePointer? { mutating get { return Self.getFieldDescriptor(&self); } }
    static func getFieldDescriptor<T : TypeContextClassDescriptorKind>(_ data: UnsafePointer<T>) -> OpaquePointer? {
        return DDSwiftRuntime.getPointerFromRelativeDirectPointer(UnsafePointer<RelativeDirectPointer>(OpaquePointer(data)).advanced(by:4));
    }
}

struct TypeContextClassDescriptor {
    let flag: ContextDescriptorFlags;
    fileprivate let _parent: RelativeDirectPointer;
    fileprivate let _name: RelativeDirectPointer;
    fileprivate let _accessFunction: RelativeDirectPointer;
    fileprivate let _fieldDescriptor: RelativeDirectPointer;
};

extension TypeContextClassDescriptor : TypeContextClassDescriptorKind {
}

/***
 * ClassDescriptor
 ***/
struct ClassDescriptor {
    let flag: ContextDescriptorFlags;
    fileprivate let _parent: RelativeDirectPointer;
    fileprivate let _name: RelativeDirectPointer;
    fileprivate let _accessFunction: RelativeDirectPointer;
    fileprivate let _fieldDescriptor: RelativeDirectPointer;
    let superclassType: RelativeDirectPointer;
    let metadataNegativeSizeInWords: UInt32;  // resilientMetadataBounds: RelativeDirectPointer
    let metadataPositiveSizeInWords: UInt32;  // extraClassFlags: UInt32
    let numImmediateMembers: UInt32;
    let numFields: UInt32;
    let fieldOffsetVectorOffset: UInt32;
    // TypeGenericContextDescriptorHeader
    // ResilientSuperclass
    // ForeignMetadataInitialization
    // SingletonMetadataInitialization
    // VTableDescriptorHeader
    // MethodDescriptor
    // OverrideTableHeader
    // MethodOverrideDescriptor
    // ObjCResilientClassStubInfo
    // CanonicalSpecializedMetadatasListCount
    // CanonicalSpecializedMetadatasListEntry
    // CanonicalSpecializedMetadataAccessorsListEntry
    // CanonicalSpecializedMetadatasCachingOnceToken
};

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
    // vtable
    var vtable: UnsafeBufferPointer<MethodDescriptor>? { mutating get { Self.getVTable(&self); } }
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
    // overridetable
    var overridetable: UnsafeBufferPointer<MethodOverrideDescriptor>? { mutating get { return Self.getOverridetable(&self); } }
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

/***
 * GenericContextDescriptorHeader
 ***/
struct GenericContextDescriptorHeader {
    let numParams: UInt16;
    let numRequirements: UInt16;
    let numKeyArguments: UInt16;
    let numExtraArguments: UInt16;
};

/***
 * TypeGenericContextDescriptorHeader
 ***/
struct TypeGenericContextDescriptorHeader {
    let instantiationCache: RelativeDirectPointer;
    let defaultInstantiationPattern: RelativeDirectPointer;
    let base: GenericContextDescriptorHeader;
};

/***
 * GenericRequirementDescriptor
 ***/
struct GenericRequirementDescriptor {
    let flags: UInt32;
    let param: RelativeDirectPointer;
    let layout: RelativeDirectPointer;
}

/***
 * ResilientSuperclass
 ***/
struct ResilientSuperclass {
    let superclass: RelativeDirectPointer;
};

/***
 * ForeignMetadataInitialization
 ***/
struct ForeignMetadataInitialization {
  /// The completion function.  The pattern will always be null.
    let completionFunction: RelativeDirectPointer;
};

/***
 * SingletonMetadataInitialization
 ***/
struct SingletonMetadataInitialization {
    let initializationCache: RelativeDirectPointer;
    let incompleteMetadata: RelativeDirectPointer;  // resilientPattern: RelativeDirectPointer;
    let completionFunction: RelativeDirectPointer;
}

/***
 * VTableDescriptorHeader
 ***/
struct VTableDescriptorHeader {
    let vTableOffset: UInt32;
    let vTableSize: UInt32;
};

/***
 * MethodDescriptorFlags
 ***/
struct MethodDescriptorFlags {
    let value: UInt32;
}

extension MethodDescriptorFlags {
    var kind: MethodDescriptorKind { get { return MethodDescriptorKind(rawValue:UInt8(self.value & 0x0F)) ?? .Method; } }
    var isDynamic: Bool { get { return (self.value & 0x20) != 0; } }
    var isInstance: Bool { get { return (self.value & 0x10) != 0; } }
    var isAsync: Bool { get { return (self.value & 0x40) != 0; } }
}

/***
 * MethodDescriptor
 ***/
struct MethodDescriptor {
    let flags: MethodDescriptorFlags;
    fileprivate let _impl: RelativeDirectPointer;
}

extension MethodDescriptor {
    // impl
    var impl: OpaquePointer { mutating get { MethodDescriptor.getImpl(&self); } }
    static func getImpl(_ data: UnsafePointer<MethodDescriptor>) -> OpaquePointer {
        return DDSwiftRuntime.getPointerFromRelativeDirectPointer(UnsafePointer<RelativeDirectPointer>(OpaquePointer(data)).advanced(by:1))!;
    }
}

/***
 * OverrideTableHeader
 ***/
struct OverrideTableHeader {
    let numEntries: UInt32;
};

/***
 * MethodOverrideDescriptor
 ***/
struct MethodOverrideDescriptor {
    fileprivate let _cls: RelativeContextPointer;
    fileprivate let _method: RelativeContextPointer;  // base
    fileprivate let _impl: RelativeDirectPointer;    // override
}

extension MethodOverrideDescriptor {
    // cls
    var cls: OpaquePointer { mutating get { Self.getClass(&self); } }
    static func getClass(_ data: UnsafePointer<MethodOverrideDescriptor>) -> OpaquePointer {
        return DDSwiftRuntime.getPointerFromRelativeContextPointer(UnsafePointer<RelativeDirectPointer>(OpaquePointer(data)))!;
    }
    // method
    var method: OpaquePointer { mutating get { Self.getMethod(&self); } }
    static func getMethod(_ data: UnsafePointer<MethodOverrideDescriptor>) -> OpaquePointer {
        return DDSwiftRuntime.getPointerFromRelativeContextPointer(UnsafePointer<RelativeDirectPointer>(OpaquePointer(data)).advanced(by:1))!;
    }
    // impl
    var impl: OpaquePointer { mutating get { Self.getImpl(&self); } }
    static func getImpl(_ data: UnsafePointer<MethodOverrideDescriptor>) -> OpaquePointer {
        return DDSwiftRuntime.getPointerFromRelativeDirectPointer(UnsafePointer<RelativeDirectPointer>(OpaquePointer(data)).advanced(by:2))!;
    }
}

/***
 * ObjCResilientClassStubInfo
 ***/
struct ObjCResilientClassStubInfo {
    let stub: RelativeDirectPointer;
};

/***
 * CanonicalSpecializedMetadatasListCount
 ***/
struct CanonicalSpecializedMetadatasListCount {
    let count: UInt32;
}

/***
 * CanonicalSpecializedMetadatasListEntry
 ***/
struct CanonicalSpecializedMetadatasListEntry {
    let metadata: RelativeDirectPointer;
}

/***
 * CanonicalSpecializedMetadataAccessorsListEntry
 ***/
struct CanonicalSpecializedMetadataAccessorsListEntry {
    let accessor: RelativeDirectPointer;
};

/***
 * CanonicalSpecializedMetadatasCachingOnceToken
 ***/
struct CanonicalSpecializedMetadatasCachingOnceToken {
    let token: RelativeDirectPointer;
};


protocol ObjcClassKind {
}
extension ObjcClassKind {
    // name
    var name: String { mutating get { Self.getName(&self); } }
    static func getName<T : ObjcClassKind>(_ cls: UnsafePointer<T>) -> String {
        return String.init(cString:class_getName(unsafeBitCast(cls, to:AnyClass.self)));
    }
}

/***
 * AnyClassMetadata
 ***/
struct AnyClassMetadata {
    let isa: OpaquePointer;
    let superclass: OpaquePointer;
    let cache0: uintptr_t;
    let cache1: uintptr_t;
    let ro: uintptr_t;
};

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

/***
 * ClassMetadata
 ***/
struct ClassMetadata {
    fileprivate let _isa: OpaquePointer;
    fileprivate let _superclass: OpaquePointer;
    let cache0: uintptr_t;
    let cache1: uintptr_t;
    let ro: uintptr_t;
    let flags: UInt32;
    let instanceAddressPoint: UInt32;
    let instanceSize: UInt32;
    let instanceAlignMask: UInt16;
    let reserved: UInt16;
    let classSize: UInt32;
    let classAddressPoint: UInt32;
    let description: Pointer;
    let ivarDestroyer: Pointer;
    // functin list
};

extension ClassMetadata : ObjcClassKind {
    var descriptor: UnsafePointer<ClassDescriptor> { get { return UnsafePointer<ClassDescriptor>(bitPattern:self.description)!; } }
    // functionTable
    var functionTable: UnsafeBufferPointer<OpaquePointer> { mutating get { return Self.getFunctionTable(&self); } }
    static func getFunctionTable(_ cls: UnsafePointer<ClassMetadata>) -> UnsafeBufferPointer<OpaquePointer> {
        let size = (cls.pointee.classSize - 80 - cls.pointee.classAddressPoint) / 8;
        return UnsafeBufferPointer.init(start:UnsafePointer<OpaquePointer>.init(OpaquePointer(cls.advanced(by:1))), count:Int(size));
    }
}
