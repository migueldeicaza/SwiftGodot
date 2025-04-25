//
//  FastFunctionBridging.swift
//  SwiftGodot
//
//  Created by Elijah Semyonov on 16/04/2025.
//

@_implementationOnly import GDExtension

public typealias BridgedFunction = (
    UnsafeRawPointer?, // pInstance
    borrowing Arguments
) -> FastVariant?

struct BridgedFunctionInfo {
    let function: BridgedFunction
    let returnedType: Variant.GType?
}

/// Internal API.
public func _registerSignal(_ signalName: StringName, in className: StringName, arguments: [PropInfo] = []) {
    withUnsafeTemporaryAllocation(of: GDExtensionPropertyInfo.self, capacity: arguments.count) { bufferPtr in
        guard let ptr = bufferPtr.baseAddress else {
            GD.print("Swift.withUnsafeTemporaryAllocation failed at `ClassInfo.registerSignal`")
            return
        }
        
        withExtendedLifetime(arguments) {
            for (index, argument) in arguments.enumerated() {
                bufferPtr.initializeElement(at: index, to: argument.makeNativeStruct())
            }
            
            // without withExtendedLifetime compiler can eagerly drop `arguments` here, it's not aware of `makeNativeStruct` pointers
            
            gi.classdb_register_extension_class_signal (extensionInterface.getLibrary(), &className.content, &signalName.content, ptr, GDExtensionInt(arguments.count))
            bufferPtr.deinitialize()
        }
    }
}

/// Internal API.
public func _addPropertyGroup(className: StringName, name: String, prefix: String) {
    let gname = GString(stringLiteral: name)
    let gprefix = GString(stringLiteral: prefix)
    
    gi.classdb_register_extension_class_property_group(extensionInterface.getLibrary(), &className.content, &gname.content, &gprefix.content)
}

/// Internal API.
public func _addPropertySubgroup(className: StringName, name: String, prefix: String) {
    let gname = GString(stringLiteral: name)
    let gprefix = GString(stringLiteral: prefix)
    
    gi.classdb_register_extension_class_property_subgroup(extensionInterface.getLibrary(), &className.content, &gname.content, &gprefix.content)
}

/// Internal API.
public func _registerProperty(className: StringName, info: PropInfo, getter: StringName, setter: StringName) {
    var pinfo = GDExtensionPropertyInfo ()
    pinfo = info.makeNativeStruct()
    
    gi.classdb_register_extension_class_property(extensionInterface.getLibrary(), &className.content, &pinfo, &setter.content, &getter.content)
}

/// Internal API.
public func _registerPropertyWithGetterSetter(
    className: StringName,
    info: PropInfo,
    getterName: StringName,
    setterName: StringName,
    getterFunction: @escaping BridgedFunction,
    setterFunction: @escaping BridgedFunction
) {
    _registerMethod(className: className, name: getterName, flags: .default, returnValue: info, arguments: [], function: getterFunction)
    _registerMethod(className: className, name: setterName, flags: .default, returnValue: nil, arguments: [info], function: setterFunction)
    _registerProperty(className: className, info: info, getter: getterName, setter: setterName)
}
/// Internal API.
public func _registerMethod(
    className: StringName,
    name: StringName,
    flags: MethodFlags,
    returnValue: PropInfo?,
    arguments: [PropInfo],
    function: @escaping BridgedFunction
) {
    let argPtr = UnsafeMutablePointer<GDExtensionPropertyInfo>.allocate(capacity: arguments.count)
    defer { argPtr.deallocate() }
    let argMeta = UnsafeMutablePointer<GDExtensionClassMethodArgumentMetadata>.allocate(capacity: arguments.count)
    defer { argMeta.deallocate() }
    var i = 0
    for arg in arguments {
        argPtr [i] = arg.makeNativeStruct()
        argMeta [i] = GDExtensionClassMethodArgumentMetadata(GDEXTENSION_METHOD_ARGUMENT_METADATA_NONE.rawValue)
        i += 1
    }
    let returnMeta = GDExtensionClassMethodArgumentMetadata(GDEXTENSION_METHOD_ARGUMENT_METADATA_NONE.rawValue)
    var retInfo = GDExtensionPropertyInfo ()
    if let returnValue {
        retInfo = returnValue.makeNativeStruct()
    }
    
    // TODO: leaks, never deallocated
    let userdata = UnsafeMutablePointer<BridgedFunctionInfo>.allocate(capacity: 1)
    userdata.initialize(to: .init(function: function, returnedType: returnValue?.propertyType))
    
    withUnsafeMutablePointer(to: &name.content) { namePtr in
        withUnsafeMutablePointer(to: &retInfo) { retInfoPtr in
        var info = GDExtensionClassMethodInfo (
            name: namePtr,
            method_userdata: userdata,
            call_func: call_func,
            ptrcall_func: nil, //ClassInfo.bind_call_ptr,
            method_flags: UInt32 (flags.rawValue),
            has_return_value: GDExtensionBool (returnValue != nil ? 1 : 0),
            return_value_info: retInfoPtr,
            return_value_metadata: returnMeta,
            argument_count: UInt32(arguments.count),
            arguments_info: argPtr,
            arguments_metadata: argMeta, // GDExtensionClassMethodArgumentMetadata
            default_argument_count: 0,
            default_arguments: nil) // GDExtensionVariantPtr)
            withUnsafePointer(to: &className.content) { namePtr in
                gi.classdb_register_extension_class_method (extensionInterface.getLibrary(), namePtr, &info)
            }
        }
    }
}

/// Internal API.
/// Unwraps an `Object` from a native Godot object pointer.
@inline(__always)
public func _unwrap<T: Object>(
    _ type: T.Type = T.self,
    pInstance: UnsafeRawPointer?
) -> T? {
    guard let pInstance else {
        return nil
    }
    
    let ref = Unmanaged<WrappedReference>.fromOpaque(pInstance).takeUnretainedValue()
    guard let object = ref.value as? T else {
        return nil
    }
    
    return object
}

private func call_func(
    _ udata: UnsafeMutableRawPointer?,
    classInstance: UnsafeMutableRawPointer?,
    variantArgs: UnsafePointer<UnsafeRawPointer?>?,
    argc: Int64,
    returnValue: UnsafeMutableRawPointer?,
    r_error: UnsafeMutablePointer<GDExtensionCallError>?
) {
    guard let udata else { return }
    guard let classInstance else { return }
        
    let finfo = udata.assumingMemoryBound(to: BridgedFunctionInfo.self).pointee
    
    let ret = withArguments(pargs: variantArgs, argc: argc) { arguments in
        finfo.function(classInstance, arguments)
    }

    if let returnValue, var ret {
        // If returnValue is not nil and `retType` is ".nil", then it means we are expecting a `Variant` and don't care
        // which types are stored in it.
        // See https://github.com/godotengine/godot/issues/67544#issuecomment-1382229216
        if finfo.returnedType != .nil && ret.gtype != finfo.returnedType {
            print ("Function is expected to return \(String(describing: finfo.returnedType)), returned \(ret.gtype) instead")
            if let rError = r_error {
                rError.pointee.error = GDEXTENSION_CALL_ERROR_INVALID_METHOD
            }
            return
        }
        let retContent = returnValue.assumingMemoryBound(to: VariantContent.self)
        retContent.pointee = ret.content
        
        // Ownership over variant is transferred to Godot
        ret.unsafelyForget()
    }
}
