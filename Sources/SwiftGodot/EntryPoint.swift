//
//  EntryPoint.swift: This is where Godot calls initially into the plugin
//  
//  Created by Miguel de Icaza on 3/24/23.
//
//

@_implementationOnly import GDExtension

/// The pointer to the Godot Extension Interface
/// The library pointer we received at startup
var library: GDExtensionClassLibraryPtr!
var token: GDExtensionClassLibraryPtr! {
    return library
}

/// This variable is used to trigger a reloading of the method definitions in Godot, this is only needed
/// for scenarios where SwiftGodot is being used with multiple active Godot runtimes in the same process
public var swiftGodotLibraryGeneration: UInt16 = 0

var extensionInitCallbacks: [((GDExtension.InitializationLevel)->())] = []
var extensionDeInitCallbacks: [((GDExtension.InitializationLevel)->())] = []

func loadFunctions (loader: GDExtensionInterfaceGetProcAddress) {
    
}

///
/// This method is used to configure the extension interface for SwiftGodot to
/// operate.   It is only used when you use SwiftGodot embedded into an
/// application - as opposed to using SwiftGodot purely as an extension
///
public func setExtensionInterface (to: OpaquePointer?, library lib: OpaquePointer?) {
    guard let to else {
        print ("Expected a pointer to a GDExtensionInterfaceGetProcAddress")
        return
    }
    loadGodotInterface(unsafeBitCast(to, to: GDExtensionInterfaceGetProcAddress.self))
    library = GDExtensionClassLibraryPtr (lib)
}

// Extension initialization callback
func extension_initialize (userData: UnsafeMutableRawPointer?, l: GDExtensionInitializationLevel) {
    //print ("SWIFT: extension_initialize")
    let level = GDExtension.InitializationLevel(rawValue: Int64 (exactly: l.rawValue)!)!
    
    for cb in extensionInitCallbacks {
        cb (level)
    }
}

// Extension deinitialization callback
func extension_deinitialize (userData: UnsafeMutableRawPointer?, l: GDExtensionInitializationLevel) {
    //print ("SWIFT: extension_deinitialize")
    
    let level = GDExtension.InitializationLevel(rawValue: Int64 (exactly: l.rawValue)!)!
    for cb in extensionDeInitCallbacks {
        cb (level)
    }
}

/// Error types returned by Godot when invoking a method
public enum CallErrorType: Error {
    /// No error
    case ok
    case invalidMethod
    case invalidArgument
    case tooFewArguments
    case tooManyArguments
    case instanceIsNull
    case methodNotConst
    
    /// A new error was introduced into Godot, and the SwiftGodot bindings are out of sync
    case unknown
}

func toCallErrorType (_ godotCallError: GDExtensionCallErrorType) -> CallErrorType {
    switch godotCallError {
    case GDEXTENSION_CALL_OK:
        return .ok
    case GDEXTENSION_CALL_ERROR_INVALID_METHOD:
        return .invalidMethod
    case GDEXTENSION_CALL_ERROR_INVALID_ARGUMENT:
        return .invalidArgument
    case GDEXTENSION_CALL_ERROR_INSTANCE_IS_NULL:
        return .instanceIsNull
    case GDEXTENSION_CALL_ERROR_METHOD_NOT_CONST:
        return .methodNotConst
    case GDEXTENSION_CALL_ERROR_TOO_FEW_ARGUMENTS:
        return .tooFewArguments
    case GDEXTENSION_CALL_ERROR_TOO_MANY_ARGUMENTS:
        return .tooManyArguments
    default:
        return .unknown
    }
}

struct GodotInterface {
    let mem_alloc: GDExtensionInterfaceMemAlloc
    let mem_realloc: GDExtensionInterfaceMemRealloc
    let mem_free: GDExtensionInterfaceMemFree
    
    let print_error: GDExtensionInterfacePrintError
    let print_error_with_message: GDExtensionInterfacePrintErrorWithMessage
    let print_warning: GDExtensionInterfacePrintWarning
    let print_warning_with_message: GDExtensionInterfacePrintWarningWithMessage
    let print_script_error: GDExtensionInterfacePrintScriptError
    let print_script_error_with_message: GDExtensionInterfacePrintScriptErrorWithMessage
    let string_new_with_utf8_chars: GDExtensionInterfaceStringNewWithUtf8Chars
    let string_to_utf8_chars: GDExtensionInterfaceStringToUtf8Chars
    
    let get_native_struct_size: GDExtensionInterfaceGetNativeStructSize
    
    let classdb_construct_object: GDExtensionInterfaceClassdbConstructObject
    let classdb_get_method_bind: GDExtensionInterfaceClassdbGetMethodBind
    let classdb_register_extension_class: GDExtensionInterfaceClassdbRegisterExtensionClass2
    let classdb_register_extension_class_signal: GDExtensionInterfaceClassdbRegisterExtensionClassSignal
    let classdb_register_extension_class_method: GDExtensionInterfaceClassdbRegisterExtensionClassMethod
    let classdb_register_extension_class_property: GDExtensionInterfaceClassdbRegisterExtensionClassProperty
    let classdb_register_extension_class_property_group: GDExtensionInterfaceClassdbRegisterExtensionClassPropertyGroup
    let classdb_register_extension_class_property_subgroup:
    GDExtensionInterfaceClassdbRegisterExtensionClassPropertySubgroup
    let classdb_unregister_extension_class: GDExtensionInterfaceClassdbUnregisterExtensionClass

    let object_set_instance: GDExtensionInterfaceObjectSetInstance
    let object_set_instance_binding: GDExtensionInterfaceObjectSetInstanceBinding
    let object_get_class_name: GDExtensionInterfaceObjectGetClassName
    
    let object_method_bind_ptrcall: GDExtensionInterfaceObjectMethodBindPtrcall
    let object_destroy: GDExtensionInterfaceObjectDestroy
    
    // @convention(c) (GDExtensionMethodBindPtr?, GDExtensionObjectPtr?, UnsafePointer<GDExtensionConstTypePtr?>?, GDExtensionTypePtr?) -> Void
    @inline(__always)
    func object_method_bind_ptrcall_v(
        _ method: GDExtensionMethodBindPtr?,
        _ object: GDExtensionObjectPtr?,
        _ result: GDExtensionTypePtr?,
        _ _args: UnsafeMutableRawPointer?...
    ) {
        object_method_bind_ptrcall(method, object, unsafeBitCast(_args, to: [UnsafeRawPointer?].self), result)
    }
    
    let global_get_singleton: GDExtensionInterfaceGlobalGetSingleton
    let ref_get_object: GDExtensionInterfaceRefGetObject
    let object_method_bind_call: GDExtensionInterfaceObjectMethodBindCall
    
    // @convention(c) (GDExtensionMethodBindPtr?, GDExtensionObjectPtr?, UnsafePointer<GDExtensionConstVariantPtr?>?, GDExtensionInt, GDExtensionUninitializedVariantPtr?, UnsafeMutablePointer<GDExtensionCallError>?) -> Void
    @inline(__always)
    func object_method_bind_call_v(
        _ method: GDExtensionMethodBindPtr?,
        _ object: GDExtensionObjectPtr?,
        _ result: GDExtensionUninitializedVariantPtr?,
        _ error: UnsafeMutablePointer<GDExtensionCallError>?,
        _ _args: UnsafeMutableRawPointer?...
    ) {
        object_method_bind_call(method, object, unsafeBitCast(_args, to: [UnsafeRawPointer?].self), GDExtensionInt(_args.count), result, error)
    }
    
    let variant_new_nil: GDExtensionInterfaceVariantNewNil
    let variant_new_copy: GDExtensionInterfaceVariantNewCopy
    let variant_evaluate: GDExtensionInterfaceVariantEvaluate
    let variant_hash: GDExtensionInterfaceVariantHash
    let variant_destroy: GDExtensionInterfaceVariantDestroy
    let variant_get_type: GDExtensionInterfaceVariantGetType
    let variant_stringify: GDExtensionInterfaceVariantStringify
    let variant_call: GDExtensionInterfaceVariantCall
    let variant_call_static: GDExtensionInterfaceVariantCallStatic
    let variant_get_indexed: GDExtensionInterfaceVariantGetIndexed
    let variant_set_indexed: GDExtensionInterfaceVariantSetIndexed
    
    let variant_get_ptr_constructor: GDExtensionInterfaceVariantGetPtrConstructor
    let variant_get_ptr_builtin_method: GDExtensionInterfaceVariantGetPtrBuiltinMethod
    let variant_get_ptr_operator_evaluator: GDExtensionInterfaceVariantGetPtrOperatorEvaluator
    let variant_get_ptr_utility_function:
    GDExtensionInterfaceVariantGetPtrUtilityFunction
    let variant_get_ptr_destructor: GDExtensionInterfaceVariantGetPtrDestructor
    let variant_get_ptr_indexed_getter: GDExtensionInterfaceVariantGetPtrIndexedGetter
    let variant_get_ptr_indexed_setter: GDExtensionInterfaceVariantGetPtrIndexedSetter
    let variant_get_ptr_keyed_checker: GDExtensionInterfaceVariantGetPtrKeyedChecker
    let variant_get_ptr_keyed_getter: GDExtensionInterfaceVariantGetPtrKeyedGetter
    let variant_get_ptr_keyed_setter: GDExtensionInterfaceVariantGetPtrKeyedSetter
    let get_variant_from_type_constructor: GDExtensionInterfaceGetVariantFromTypeConstructor
    let get_variant_to_type_constructor: GDExtensionInterfaceGetVariantToTypeConstructor
    
    let array_operator_index: GDExtensionInterfaceArrayOperatorIndex
    let array_set_typed: GDExtensionInterfaceArraySetTyped
    
    let packed_string_array_operator_index: GDExtensionInterfacePackedStringArrayOperatorIndex
    let packed_byte_array_operator_index: GDExtensionInterfacePackedByteArrayOperatorIndex
    let packed_color_array_operator_index: GDExtensionInterfacePackedColorArrayOperatorIndex
    let packed_float32_array_operator_index: GDExtensionInterfacePackedFloat32ArrayOperatorIndex
    let packed_float64_array_operator_index: GDExtensionInterfacePackedFloat64ArrayOperatorIndex
    let packed_int32_array_operator_index: GDExtensionInterfacePackedInt32ArrayOperatorIndex
    let packed_int64_array_operator_index: GDExtensionInterfacePackedInt64ArrayOperatorIndex
    let packed_vector2_array_operator_index: GDExtensionInterfacePackedVector2ArrayOperatorIndex
    let packed_vector3_array_operator_index: GDExtensionInterfacePackedVector3ArrayOperatorIndex
    
    let callable_custom_create: GDExtensionInterfaceCallableCustomCreate
}

var gi: GodotInterface!

func loadGodotInterface (_ godotGetProcAddrPtr: GDExtensionInterfaceGetProcAddress) {
    
    func load<T> (_ name: String) -> T {
        let rawPtr = godotGetProcAddrPtr (name)
        
        guard let rawPtr else {
            fatalError("Can not load method \(name) from Godot's interface")
        }
        return unsafeBitCast(rawPtr, to: T.self)
//        
//        let ass = rawPtr.assumingMemoryBound(to: T.self).pointee
//        print ("For \(name) got the address \(rawPtr) and assigning \(ass)")
//        return rawPtr.assumingMemoryBound(to: T.self).pointee
    }
    
    gi = GodotInterface(
        mem_alloc: load ("mem_alloc"),
        mem_realloc: load ("mem_realloc"),
        mem_free: load ("mem_free"),
        
        print_error: load ("print_error"),
        print_error_with_message: load ("print_error_with_message"),
        print_warning: load ("print_warning"),
        print_warning_with_message: load ("print_warning_with_message"),
        print_script_error: load ("print_script_error"),
        print_script_error_with_message: load ("print_script_error_with_message"),
        
        string_new_with_utf8_chars: load ("string_new_with_utf8_chars"),
        string_to_utf8_chars: load ("string_to_utf8_chars"),
        
        get_native_struct_size: load ("get_native_struct_size"),
        
        classdb_construct_object: load ("classdb_construct_object"),
        classdb_get_method_bind: load ("classdb_get_method_bind"),
        classdb_register_extension_class: load ("classdb_register_extension_class2"),
        classdb_register_extension_class_signal: load ("classdb_register_extension_class_signal"),
        classdb_register_extension_class_method: load ("classdb_register_extension_class_method"),
        classdb_register_extension_class_property: load ("classdb_register_extension_class_property"),
        classdb_register_extension_class_property_group: load ("classdb_register_extension_class_property_group"),
        classdb_register_extension_class_property_subgroup: load ("classdb_register_extension_class_property_subgroup"),
        classdb_unregister_extension_class: load ("classdb_unregister_extension_class"),
        
        object_set_instance: load ("object_set_instance"),
        object_set_instance_binding: load ("object_set_instance_binding"),
        object_get_class_name: load ("object_get_class_name"),
        object_method_bind_ptrcall: load ("object_method_bind_ptrcall"),
        object_destroy: load ("object_destroy"),
        
        global_get_singleton: load ("global_get_singleton"),
        ref_get_object: load ("ref_get_object"),
        object_method_bind_call: load ("object_method_bind_call"),
        
        variant_new_nil: load ("variant_new_nil"),
        variant_new_copy: load ("variant_new_copy"),
        variant_evaluate: load ("variant_evaluate"),
        variant_hash: load ("variant_hash"),
        variant_destroy: load ("variant_destroy"),
        variant_get_type: load ("variant_get_type"),
        variant_stringify: load ("variant_stringify"),
        variant_call: load ("variant_call"),
        variant_call_static: load ("variant_call_static"),
        variant_get_indexed: load ("variant_get_indexed"),
        variant_set_indexed: load ("variant_set_indexed"),

        variant_get_ptr_constructor: load ("variant_get_ptr_constructor"),
        variant_get_ptr_builtin_method: load ("variant_get_ptr_builtin_method"),
        variant_get_ptr_operator_evaluator: load ("variant_get_ptr_operator_evaluator"),
        variant_get_ptr_utility_function: load ("variant_get_ptr_utility_function"),
        variant_get_ptr_destructor: load ("variant_get_ptr_destructor"),
        variant_get_ptr_indexed_getter: load ("variant_get_ptr_indexed_getter"),
        variant_get_ptr_indexed_setter: load ("variant_get_ptr_indexed_setter"),
        variant_get_ptr_keyed_checker: load ("variant_get_ptr_keyed_checker"),
        variant_get_ptr_keyed_getter: load ("variant_get_ptr_keyed_getter"),
        variant_get_ptr_keyed_setter: load ("variant_get_ptr_keyed_setter"),
        get_variant_from_type_constructor: load ("get_variant_from_type_constructor"),
        get_variant_to_type_constructor: load ("get_variant_to_type_constructor"),
        array_operator_index: load ("array_operator_index"),
        array_set_typed: load ("array_set_typed"),
        
        packed_string_array_operator_index: load ("packed_string_array_operator_index"),
        packed_byte_array_operator_index: load ("packed_byte_array_operator_index"),
        packed_color_array_operator_index: load ("packed_color_array_operator_index"),
        packed_float32_array_operator_index: load ("packed_float32_array_operator_index"),
        packed_float64_array_operator_index: load ("packed_float64_array_operator_index"),
        packed_int32_array_operator_index: load ("packed_int32_array_operator_index"),
        packed_int64_array_operator_index: load ("packed_int64_array_operator_index"),
        packed_vector2_array_operator_index: load ("packed_vector2_array_operator_index"),
        packed_vector3_array_operator_index: load ("packed_vector3_array_operator_index"),
        
        callable_custom_create: load ("callable_custom_create")
    )
}

///
/// For use in extensions created for a Godot project
///
/// Call this function from your declared Swift entry point passing the three
/// pointers that you receive from Godot and passing a method that will
/// be invoked during the various stages of the initialization.
///
/// This routine takes OpaquePointers to help you simplify the declaration of
/// your Swift entry point, which can look like this:
///
/// ```
/// @cdecl ("swift_entry_point")
/// public func swift_entry_point (i: OpaquePointer?, l: OpaquePointer?, e: OpaquePointer?) -> UInt8 {
///     guard let iface, let lib, let ext else {
///         return 0
///     }
///     initializeSwiftModule (iface, lib, ext, initHook: myInit, deInitHook: myDeinit)
///     return 1
/// }
///
/// func myInit (level: GDExtension.InitializationLevel) {
///    if level == .scene {
///       registerType (MySpinningCube.self)
///    }
/// }
///
/// func myDeInit (level: GDExtension.InitializationLevel) {
///     if level == .scene {
///         print ("Deinitialized")
///     }
/// }
/// ```
/// - Parameters:
///  - godotGetProcAddrPtr: the first parameter you got on your entry point, it points to the API in Godot to request pointers to the engine functions.
///  - libraryPtr: the second parameter you entry point gets, it is of type GDExtensionClassLibraryPtr
///  - extensionPtr: the third parameter you get, it is of type GDExtensionInitialization and it is filled with our callbacks
///  - initHook: this method is invoked repeatedly during the various stages of the extension
///  initialization
///  - deInitHook: this method is invoked repeatedly when various stages of the extension are wrapped up
public func initializeSwiftModule (
    _ godotGetProcAddrPtr: OpaquePointer,
    _ libraryPtr: OpaquePointer,
    _ extensionPtr: OpaquePointer,
    initHook: @escaping (GDExtension.InitializationLevel)->(),
    deInitHook: @escaping (GDExtension.InitializationLevel)->())
{
    loadGodotInterface (unsafeBitCast(godotGetProcAddrPtr, to: GDExtensionInterfaceGetProcAddress.self)
    )

    // For now, we will only initialize the library once, so all of the SwiftGodot
    // modules are bundled together.   This is not optimal, see this bug 
    // with a description of what we should be doing:
    // https://github.com/migueldeicaza/SwiftGodot/issues/72
    if library == nil {
        library = GDExtensionClassLibraryPtr(libraryPtr)
    }
    extensionInitCallbacks = [initHook]
    extensionDeInitCallbacks = [deInitHook]
    let initialization = UnsafeMutablePointer<GDExtensionInitialization> (extensionPtr)
    initialization.pointee.deinitialize = extension_deinitialize
    initialization.pointee.initialize = extension_initialize
    initialization.pointee.minimum_initialization_level = GDEXTENSION_INITIALIZATION_SCENE
}

/*
 Cannot assign value of type 'UnsafePointer<GDExtensionInterfaceVariantGetPtrConstructor>'  to type 'GDExtensionInterfaceVariantGetPtrConstructor'
 
 (aka '@convention(c) (GDExtensionVariantType, Int32) -> Optional<@convention(c) (Optional<UnsafeMutableRawPointer>, Optional<UnsafePointer<Optional<UnsafeRawPointer>>>) -> ()>')
 */

func withArgPointers(_ _args: UnsafeMutableRawPointer?..., body: ([UnsafeRawPointer?]) -> Void) {
    body(unsafeBitCast(_args, to: [UnsafeRawPointer?].self))
}
