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

enum MethodDescriptorKind : UInt8 {
    case Method = 0;
    case Init = 1;
    case Getter = 2;
    case Setter = 3;
    case ModifyCoroutine = 4;
    case ReadCoroutine = 5;
}

struct ContextDescriptorFlags {
    let value: UInt32;
}

struct TypeContextClassDescriptor {
    let flag: ContextDescriptorFlags;
    let parent: RelativeDirectPointer;
    let name: RelativeDirectPointer;
    let accessFunction: Int32;
    let fieldDescriptor: Int32;
};

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

struct MethodDescriptorFlags {
    let value: UInt32;
}

struct MethodDescriptor {
    let flags: MethodDescriptorFlags;
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
    // functin list
};
