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
    let valueWitnesses: UnsafePointer<ValueWitnessTable>;
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
    
    var witnessTable: UnsafePointer<ValueWitnessTable> {
        mutating get {
            return HeapMetadata.getWitnessTable(&self);
        }
    }
    
    static func getWitnessTable(_ data: UnsafePointer<HeapMetadata>) -> UnsafePointer<ValueWitnessTable> {
        return data.advanced(by:-1).pointee.valueWitnesses;
    }
}

/***
 * HeapObject
 ***/
struct HeapObject {
    let metadata: UnsafePointer<HeapMetadata>;
    let refCounts: size_t;
}

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
struct TypeContextClassDescriptor {
    let flag: ContextDescriptorFlags;
    let parent: RelativeDirectPointer;
    let name: RelativeDirectPointer;
    let accessFunction: Int32;
    let fieldDescriptor: Int32;
};

/***
 * ClassDescriptor
 ***/
struct ClassDescriptor {
    let flag: ContextDescriptorFlags;
    let parent: RelativeDirectPointer;
    let name: RelativeDirectPointer;
    let accessFunction: RelativeDirectPointer;
    let fieldDescriptor: RelativeDirectPointer;
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
    let impl: RelativeDirectPointer;
}

extension MethodDescriptor {
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
    let cls: RelativeContextPointer;
    let method: RelativeContextPointer;  // base
    let impl: RelativeDirectPointer;    // override
}

extension MethodOverrideDescriptor {
    static func getClass(_ data: UnsafePointer<MethodOverrideDescriptor>) -> OpaquePointer {
        return DDSwiftRuntime.getPointerFromRelativeContextPointer(UnsafePointer<RelativeDirectPointer>(OpaquePointer(data)))!;
    }
    static func getMethod(_ data: UnsafePointer<MethodOverrideDescriptor>) -> OpaquePointer {
        return DDSwiftRuntime.getPointerFromRelativeContextPointer(UnsafePointer<RelativeDirectPointer>(OpaquePointer(data)).advanced(by:1))!;
    }
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

/***
 * AnyClassMetadata
 ***/
struct AnyClassMetadata {
    let isa: Pointer;
    let superclass: Pointer;
    let cache0: uintptr_t;
    let cache1: uintptr_t;
    let ro: uintptr_t;
};

/***
 * ClassMetadata
 ***/
struct ClassMetadata {
    let isa: Pointer;
    let superclass: Pointer;
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
