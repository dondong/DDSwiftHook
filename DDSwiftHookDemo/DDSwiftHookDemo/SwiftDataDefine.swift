//
//  MetadataValue.swift
//  DDSwiftHookDemo
//
//  Created by dondong on 2022/2/21.
//

import Foundation


//enum ContextDescriptorKind : UInt8 {
//    /// This context descriptor represents a module.
//    case Module = 0;
//    /// This context descriptor represents an extension.
//    case Extension = 1;
//    /// This context descriptor represents an anonymous possibly-generic context
//    /// such as a function body.
//    case Anonymous = 2;
//    /// This context descriptor represents a protocol context.
//    case ProtocolKind = 3;
//    /// This context descriptor represents an opaque type alias.
//    case OpaqueType = 4;
//    /// First kind that represents a type of any sort.
//    /// case Type_First = 16
//    /// This context descriptor represents a class.
//    case Class = 16;   // .Type_First
//    /// This context descriptor represents a struct.
//    case Struct = 17;  // .Type_First + 1
//    /// This context descriptor represents an enum.
//    case Enum = 18;    // .Type_First + 2
//    /// Last kind that represents a type of any sort.
//    case Type_Last = 31;
//};
//
//enum SwiftMethodKind : Int {
//    case Method = 0;
//    case Init = 1;
//    case Getter = 2;
//    case Setter = 3;
//    case ModifyCoroutine = 4;
//    case ReadCoroutine = 5;
//};
//
//enum SwiftMethodType : UInt32 {
//    case KindMask = 0x0F;                // 16 kinds should be enough for anybody
//    case IsInstanceMask = 0x10;
//    case IsDynamicMask = 0x20;
//    case IsAsyncMask = 0x40;
////    case ExtraDiscriminatorShift = 16;
//    case ExtraDiscriminatorMask = 0xFFFF0000;
//};
//
//struct SwiftType {
//    var Flag: UInt32;
//    var Parent: UInt32;
//};
//
//struct SwiftMethod {
//    var Flag: UInt32;
//    var Offset: UInt32;
//};
//
//struct SwiftOverrideMethod {
//    var OverrideClass: UInt32;
//    var OverrideMethod: UInt32;
//    var Method: UInt32;
//};
//
//struct SwiftBaseType {
//    var Flag: UInt32;
//    var Parent: UInt32;
//    var Name: Int32;
//    var AccessFunction: Int32;
//    var FieldDescriptor: Int32;
//};

struct ClassDescriptor {
    let flag: UInt32;
    let parent: Int32;
    let name: Int32;
    let accessFunction: Int32;
    let fieldDescriptor: Int32;
    let superclassType: Int32;
    let metadataNegativeSizeInWords: UInt32;
    let metadataPositiveSizeInWords: UInt32;
    let numImmediateMembers: UInt32;
    let numFields: UInt32;
    let fieldOffsetVectorOffset: UInt32;
};

struct AnyClassMetadata {
    let isa: uintptr_t;
    let superclass: uintptr_t;
    let cache0: uintptr_t;
    let cache1: uintptr_t;
    let ro: uintptr_t;
};

struct ClassMetadata {
    let kind: uintptr_t;
    let superclass: uintptr_t;
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
    let description: uintptr_t;
    let ivarDestroyer: uintptr_t;
    //----------------------------------
    //witnessTable[0]A
    //witnessTable[1]B
    //witnessTable[2]C
    //witnessTable[3]D
    //witnessTable[4]E
    //witnessTable[5]F
    //witnessTable[6]G
};
