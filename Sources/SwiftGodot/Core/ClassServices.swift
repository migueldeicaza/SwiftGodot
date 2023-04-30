//
//  File.swift
//  
//
//  Created by Miguel de Icaza on 4/13/23.
//

import Foundation
@_implementationOnly import GDExtension

/// Provides support to expose Swift methods and signals to the Godot runtime, making it callable
/// from its runtime and scripting language.
///
/// You create a ClassInfo object, with the name for your class, and then call the various
/// register methods.   You only need to do once per class, so it is recommended that you
/// perform this initialization with an idiom like this:
/// ```
/// class MyNode: Node {
///   func initClass() -> Bool {
///     let classInfo = ClassInfo<SpinningCube>(name: "MyNode")
///     // register things in classInfo here:
///     ...
///     return true
///   }
///
///   required init () {
///     super.init ()
///     let _ = initClass ()
///   }
///
/// ```
public class ClassInfo<T:Object> {
    var name: StringName
    
    /// Initializes a ClassInfo structure to register operations with Godot
    public init (name: StringName) {
        self.name = name
    }
    
    /// Registers a signal on this type with the specified name and with the specified arguments.  To trigger
    /// the signal, you need to invoke ``Object/emitSignal(signal:)`` with the matching arguments that
    /// you registered here.
    ///
    /// Users of your signal can then connect to the signal using the ``Object/connect(signal:callable:flags:)``
    /// method.
    /// 
    /// - Parameters:
    ///  - name: the name we want to use to register the signal
    ///  - arguments: an array of PropInfo structures that describe each argument that must be passed to the signal
    public func registerSignal (name: StringName, arguments propInfo: [PropInfo] = []) {
        let propPtr = UnsafeMutablePointer<GDExtensionPropertyInfo>.allocate(capacity: propInfo.count)
        var i = 0
        for prop in propInfo {
            propPtr [i] = prop.makeNativeStruct()
            i += 1
        }
        gi.classdb_register_extension_class_signal (library, UnsafeRawPointer (&self.name.content), UnsafeRawPointer(&name.content), propPtr, GDExtensionInt(propInfo.count))
        propPtr.deallocate()
    }
    
    // Here so we can box the function pointer
    class FunctionInfo {
        var function: (T) -> ([Variant]) -> Variant?
        var retType: Variant.GType?
        var ttype: T.Type
        
        init (_ function: @escaping (T) -> ([Variant]) -> Variant?, retType: Variant.GType?) {
            self.function = function
            self.retType = retType
            self.ttype = T.self
        }
    }
    
    /// Exposes a new method to the Godot world with the specific name
    ///
    /// This example shows how to register a method that takes an int parameter:
    /// ```
    /// class MyNode: Node {
    ///   func initClass() -> Bool {
    ///     let classInfo = ClassInfo<SpinningCube>(name: "MyNode")
    ///     let printArgs = [
    ///       PropInfo(
    ///         propertyType: .string,
    ///         propertyName: StringName ("numberToCheck"),
    ///         className: "MyNode",
    ///         hint: .flags,
    ///         hintStr: "Number of baddies to check",
    ///         usage: .propertyUsageDefault)
    ///     ]
    ///     classInfo.registerMethod (name: "checkBaddies", flags: .default, returnValue: .nil, arguments: [], function: MyNode.checkBaddies)
    ///     return true
    ///   }
    ///
    ///   required init () {
    ///     super.init ()
    ///     let _ = initClass ()
    ///   }
    ///
    ///   func checkBaddies (args: [Variant]) -> Variant? {
    ///     // We are getting one integer if called from Godot of type Int
    ///     // validate in case you called this directly from Swift
    ///     guard args.count > 0 else {
    ///       print ("MyNode: Not enough parameters to checkBaddies: \(args.count)")
    ///       return nil
    ///     }
    ///
    ///     guard let numberToCheck = Int (args [0]) else {
    ///       print ("MyNode: No string in vararg")
    ///       return nil
    ///     }
    ///     // Use `numberToCheck` here
    ///   }
    /// }
    /// ```
    /// - Parameters;
    ///  - name: Name to surface the method as
    ///  - flags: the flags that describe the method in detail
    ///  - returnValue: if nil, this method does not return a value, otherwise, the descritption of the return value as a PropInfo
    ///  - arguments: an array describing the parameters that this method takes
    ///  - function: this is a curried function that will be registered.   It will be invoked on the instance of your object
    public func registerMethod (name: StringName, flags: MethodFlags, returnValue: PropInfo?, arguments: [PropInfo], function: @escaping (T) -> ([Variant]) -> Variant?) {
        let argPtr = UnsafeMutablePointer<GDExtensionPropertyInfo>.allocate(capacity: arguments.count)
        let argMeta = UnsafeMutablePointer<GDExtensionClassMethodArgumentMetadata>.allocate(capacity: arguments.count)
        var i = 0
        for arg in arguments {
            argPtr [i] = arg.makeNativeStruct()
            argMeta [i] = GDExtensionClassMethodArgumentMetadata(GDEXTENSION_METHOD_ARGUMENT_METADATA_NONE.rawValue)
            i += 1
        }
        var returnMeta = GDExtensionClassMethodArgumentMetadata(GDEXTENSION_METHOD_ARGUMENT_METADATA_NONE.rawValue)
        var retInfo = GDExtensionPropertyInfo ()
        if let returnValue {
            retInfo = returnValue.makeNativeStruct()
        }
        let functionInfo = Unmanaged.passRetained(FunctionInfo (function, retType: returnValue?.propertyType))
        
        var info = GDExtensionClassMethodInfo (
            name: &name.content,
            method_userdata: functionInfo.toOpaque(),
            call_func: bind_call,
            ptrcall_func: nil, //ClassInfo.bind_call_ptr,
            method_flags: UInt32 (flags.rawValue),
            has_return_value: GDExtensionBool (returnValue != nil ? 1 : 0),
            return_value_info: &retInfo,
            return_value_metadata: returnMeta,
            argument_count: UInt32(arguments.count),
            arguments_info: argPtr,
            arguments_metadata: argMeta, // <#T##GDExtensionClassMethodArgumentMetadata#>
            default_argument_count: 0,
            default_arguments: nil) // <#T##GDExtensionVariantPtr#>)
        gi.classdb_register_extension_class_method (library, UnsafeRawPointer (&self.name.content), &info)
        argPtr.deallocate()
    }
}

/// PropInfo structures describe arguments to signals, and methods as well as return values from methods.
///
/// The supported types are those that can be wrapped as a Godot Variant type.
public struct PropInfo {
    /// The type of the property being defined
    public let propertyType: Variant.GType
    /// The name for the property
    public let propertyName: StringName
    /// The class name where this is defined
    public let className: StringName
    /// Property Hint for this property
    public let hint: PropertyHint
    /// Human-readable hint
    public let hintStr: GString
    /// Describes how the property can be used.
    public let usage: PropertyUsageFlags
    
    public init(propertyType: Variant.GType, propertyName: StringName, className: StringName, hint: PropertyHint, hintStr: GString, usage: PropertyUsageFlags) {
        self.propertyType = propertyType
        self.propertyName = propertyName
        self.className = className
        self.hint = hint
        self.hintStr = hintStr
        self.usage = usage
    }
    func makeNativeStruct () -> GDExtensionPropertyInfo {
        GDExtensionPropertyInfo(
            type: GDExtensionVariantType(UInt32 (propertyType.rawValue)),
            name: &propertyName.content,
            class_name: &className.content,
            hint: UInt32 (hint.rawValue),
            hint_string: &hintStr.content,
            usage: UInt32 (usage.rawValue))
    }
}

func bind_call (_ udata: UnsafeMutableRawPointer?,
                classInstance: UnsafeMutableRawPointer?,
                variantArgs: UnsafePointer<UnsafeRawPointer?>?,
                argc: Int64,
                returnValue: UnsafeMutableRawPointer?,
                r_error: UnsafeMutablePointer<GDExtensionCallError>?){
    guard let udata else { return }
    guard let classInstance else { return }
    
    let finfoPtr: Unmanaged<ClassInfo.FunctionInfo> = Unmanaged.fromOpaque(udata)
    let finfo = finfoPtr.takeUnretainedValue()
    let target : Unmanaged<Object> = Unmanaged.fromOpaque(classInstance)
    
    var args: [Variant] = []
    
    if let variantArgs {
        for i in 0..<Int (argc) {
            guard let va = variantArgs [i] else {
                args.append (Variant())
                continue
            }
            let ct = va.assumingMemoryBound(to: Variant.ContentType.self)
            args.append (Variant (fromContent: ct.pointee))
        }
    }
    let bound = finfo.function (target.takeUnretainedValue())
    print ("Got: \(bound)")
    let ret = bound (args)
    print ("Got: \(bound)")
    if let returnValue, let ret {
        if ret.gtype != finfo.retType {
            fatalError ("Your declared function should return the type originally set \(finfo.retType)")
        }
        let retContent = returnValue.assumingMemoryBound(to: Variant.ContentType.self)
        retContent.pointee = ret.content
    }
}

func bind_call_ptr () {
    fatalError("Not implemented")
}

