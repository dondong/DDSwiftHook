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

struct HeapMetadata {
    let kind: Pointer;
}

struct HeapObject {
    let metadata: UnsafePointer<HeapMetadata>;
}

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

enum MetadataInitializationKind : UInt8 {
    case NoMetadataInitialization = 0;
    case SingletonMetadataInitialization = 1;
    case ForeignMetadataInitialization = 2;
}

struct ContextDescriptorFlags {
    let value: UInt32;
}

struct TypeContextClassDescriptor {
    let flag: UInt32;
    let parent: RelativeDirectPointer;
    let name: RelativeDirectPointer;
    let accessFunction: Int32;
    let fieldDescriptor: Int32;
};

struct ClassDescriptor {
    let flag: UInt32;
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

struct GenericContextDescriptorHeader {
    let numParams: UInt16;
    let numRequirements: UInt16;
    let numKeyArguments: UInt16;
    let numExtraArguments: UInt16;
};

struct TypeGenericContextDescriptorHeader {
    let instantiationCache: RelativeDirectPointer;
    let defaultInstantiationPattern: RelativeDirectPointer;
    let base: GenericContextDescriptorHeader;
};

struct GenericRequirementDescriptor {
    let flags: UInt32;
    let param: RelativeDirectPointer;
    let layout: RelativeDirectPointer;
}

struct ResilientSuperclass {
    let superclass: RelativeDirectPointer;
};

struct ForeignMetadataInitialization {
  /// The completion function.  The pattern will always be null.
    let completionFunction: RelativeDirectPointer;
};

struct SingletonMetadataInitialization {
    let initializationCache: RelativeDirectPointer;
    let incompleteMetadata: RelativeDirectPointer;  // resilientPattern: RelativeDirectPointer;
    let completionFunction: RelativeDirectPointer;
}

struct VTableDescriptorHeader {
    let vTableOffset: UInt32;
    let vTableSize: UInt32;
};

struct MethodDescriptor {
    let flags: UInt32;
    let impl: RelativeDirectPointer;
}

struct OverrideTableHeader {
    let numEntries: UInt32;
};

struct MethodOverrideDescriptor {
    let cls: RelativeContextPointer;
    let method: RelativeContextPointer;  // base
    let impl: RelativeDirectPointer;    // override
}

struct ObjCResilientClassStubInfo {
    let stub: RelativeDirectPointer;
};

struct CanonicalSpecializedMetadatasListCount {
    let count: UInt32;
}

struct CanonicalSpecializedMetadatasListEntry {
    let metadata: RelativeDirectPointer;
}

struct CanonicalSpecializedMetadataAccessorsListEntry {
    let accessor: RelativeDirectPointer;
};

struct CanonicalSpecializedMetadatasCachingOnceToken {
    let token: RelativeDirectPointer;
};

struct AnyClassMetadata {
    let isa: Pointer;
    let superclass: Pointer;
    let cache0: uintptr_t;
    let cache1: uintptr_t;
    let ro: uintptr_t;
};

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
};
