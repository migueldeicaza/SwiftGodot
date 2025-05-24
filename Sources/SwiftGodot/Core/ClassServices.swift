//
//  ClassServices.swift
//
//
//  Created by Miguel de Icaza on 4/13/23.
//

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
    /// the signal, you need to invoke ``Object/emitSignal(signal:_:)`` with the matching arguments that
    /// you registered here.
    ///
    /// Users of your signal can then connect to the signal using the ``Object/connect(signal:callable:flags:)``
    /// method.
    ///
    /// - Parameters:
    ///  - name: the name we want to use to register the signal
    ///  - arguments: an array of PropInfo structures that describe each argument that must be passed to the signal
    public func registerSignal (name signalName: StringName, arguments: [PropInfo] = []) {
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
                
                gi.classdb_register_extension_class_signal (extensionInterface.getLibrary(), &name.content, &signalName.content, ptr, GDExtensionInt(arguments.count))
                bufferPtr.deinitialize()
            }
        }
    }
    
    // Here so we can box the function pointer
    struct FunctionInfo {
        var function: (T) -> (borrowing Arguments) -> Variant?
        var retType: Variant.GType?
        var ttype: T.Type
        
        init (_ function: @escaping (T) -> (borrowing Arguments) -> Variant?, retType: Variant.GType?) {
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
    ///         usage: .default)
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
    ///   func checkBaddies (args: borrowing Arguments) -> Variant? {
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
    public func registerMethod (name: StringName, flags: MethodFlags, returnValue: PropInfo?, arguments: [PropInfo], function: @escaping (T) -> (borrowing Arguments) -> Variant?) {
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
        let userdata = UnsafeMutablePointer<FunctionInfo>.allocate(capacity: 1)
        userdata.initialize(to: .init(function, retType: returnValue?.propertyType))
        
        withUnsafeMutablePointer(to: &name.content) { namePtr in
            withUnsafeMutablePointer(to: &retInfo) { retInfoPtr in
            var info = GDExtensionClassMethodInfo (
                name: namePtr,
                method_userdata: userdata,
                call_func: bind_call,
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
                withUnsafePointer(to: &self.name.content) { namePtr in
                    gi.classdb_register_extension_class_method (extensionInterface.getLibrary(), namePtr, &info)
                }
            }
        }
    }
    
    /// Starts a new property group for this class, all the properties declared after calling this method
    /// will be shown together in the UI under this group.
    ///
    public func addPropertyGroup (name: String, prefix: String) {
        let gname = GString(stringLiteral: name)
        let gprefix = GString(stringLiteral: prefix)
        
        gi.classdb_register_extension_class_property_group (extensionInterface.getLibrary(), &self.name.content, &gname.content, &gprefix.content)
    }
    
    /// Starts a new property sub-group, all the properties declared after calling this method
    /// will be shown together in the UI under this group.
    public func addPropertySubgroup (name: String, prefix: String) {
        let gname = GString(stringLiteral: name)
        let gprefix = GString(stringLiteral: prefix)
        
        gi.classdb_register_extension_class_property_subgroup (extensionInterface.getLibrary(), &self.name.content, &gname.content, &gprefix.content)
    }
    
    /// Registers the property in the class with the information provided in `info`.
    /// The `getter` and `setter` name corresponds to the names that were used to register the function
    /// with Godot in `registerMethod`
    ///
    /// - Parameters:
    ///  - info: PropInfo describing the property you wil register
    ///  - getter: the name of the method you have already registered and will provide the getter functionality
    ///  - setter: the name of the method you have already registered and will provide the setter functionality
    public func registerProperty (_ info: PropInfo, getter: StringName, setter: StringName) {
        var pinfo = GDExtensionPropertyInfo ()
        pinfo = info.makeNativeStruct()
        
        gi.classdb_register_extension_class_property (extensionInterface.getLibrary(), &self.name.content, &pinfo, &setter.content, &getter.content)
    }
    
    /// Registers the property in the class with the information provided in `info` and corresponding getter and setter functions.
    /// It's a convenience function that calls``registerProperty`` and ``registerMethod`` for getter and setter
    ///
    /// - Parameters:
    ///  - info: PropInfo describing the property you wil register
    ///  - getterName: the name of the method for providing getter functionality
    ///  - setterName: the name of the method for providing setter functionality
    ///  - getterFunction: Swift getter function
    ///  - setterFunction: Swift setter function
    public func registerPropertyWithGetterSetter(
        _ info: PropInfo,
        getterName: StringName,
        setterName: StringName,
        getterFunction: @escaping (T) -> (borrowing Arguments) -> Variant?,
        setterFunction: @escaping (T) -> (borrowing Arguments) -> Variant?
    ) {
        registerMethod(name: getterName, flags: .default, returnValue: info, arguments: [], function: getterFunction)
        registerMethod(name: setterName, flags: .default, returnValue: nil, arguments: [info], function: setterFunction)
        registerProperty(info, getter: getterName, setter: setterName)
    }
}

/// PropInfo structures describe arguments to signals, and methods as well as return values from methods.
///
/// The supported types are those that can be wrapped as a Godot Variant type.
public struct PropInfo: CustomDebugStringConvertible {
    /// The type of the property being defined
    public var propertyType: Variant.GType
    /// The name for the property
    public var propertyName: StringName
    /// The special identifier needed in some cases: class name for `.object` props, Array[typename] for typed Arrays, empty otherwise
    public var className: StringName
    /// Property Hint for this property
    public var hint: PropertyHint
    /// Human-readable hint
    public var hintStr: GString
    /// Describes how the property can be used.
    public var usage: PropertyUsageFlags
    
    public init(propertyType: Variant.GType, propertyName: StringName, className: StringName, hint: PropertyHint, hintStr: GString, usage: PropertyUsageFlags) {
        self.propertyType = propertyType
        self.propertyName = propertyName
        self.className = className
        self.hint = hint
        self.hintStr = hintStr
        self.usage = usage
    }
    
    // TODO: violates invariant
    /// ``withUnsafeMutablePointer`` doc says:
    /// Do not store or return the pointer for later use.
    func makeNativeStruct () -> GDExtensionPropertyInfo {
        withUnsafeMutablePointer(to: &propertyName.content) { propertyNamePtr in
            withUnsafeMutablePointer(to: &className.content) { classNamePtr in
                withUnsafeMutablePointer(to: &hintStr.content) { hintStrPtr in
                    GDExtensionPropertyInfo(
                        type: GDExtensionVariantType(GDExtensionVariantType.RawValue (propertyType.rawValue)),
                        name: propertyNamePtr,
                        class_name: classNamePtr,
                        hint: UInt32 (hint.rawValue),
                        hint_string: hintStrPtr,
                        usage: UInt32 (usage.rawValue))
                }
            }
        }
    }

    /// Provides a human-readable description of the property
    public var debugDescription: String {
        var hs = hintStr.description
        if hs != "" {
            hs = "hintStr: \"" + hs + "\", "
        }
        return "PropInfo (propertyType: \(propertyType), name: \"\(propertyName.description)\", className: \"\(className.description)\", hint: [\(hint)], \(hs)usage: \(usage))"
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
        
    let finfo = udata.assumingMemoryBound(to: ClassInfo.FunctionInfo.self).pointee
    let ref = Unmanaged<WrappedReference>.fromOpaque(classInstance).takeUnretainedValue()
    guard let object = ref.value as? Object else { return }

    
    let ret = withArguments(pargs: variantArgs, argc: argc) { arguments in
        let bound = finfo.function(object)
        return bound(arguments)
    }

    if let returnValue, let ret {
        // If returnValue is not nil and `retType` is ".nil", then it means we are expecting a `Variant` and don't care
        // which types are stored in it.
        // See https://github.com/godotengine/godot/issues/67544#issuecomment-1382229216
        if finfo.retType != .nil && ret.gtype != finfo.retType {
            print ("Function is expected to return \(String(describing: finfo.retType)), returned \(ret.gtype) instead")
            if let rError = r_error {
                rError.pointee.error = GDEXTENSION_CALL_ERROR_INVALID_METHOD
            }
            return
        }
        let retContent = returnValue.assumingMemoryBound(to: Variant.ContentType.self)
        retContent.pointee = ret.content
        
        // Since we are giving control to Godot of this variant, we need to make sure that
        // the destructor does not get invoked here.
        //
        // Another instance of the problem fixed here:
        // 5deb4affbc9cbaa7ca86066cac4a9d87f33e60e6
        ret.content = Variant.zero
    }
}

func bind_call_ptr () {
    fatalError("Not implemented")
}

/// Error indicating that a ``earlyChild`` is registered before ``lateParent`` due to ``classInitializationLevel`` requirement, despite ``lateParent`` is a super class of ``earlyChild``
public struct IncorrectInitializationOrderError: Error {
    public let earlyChild: String
    public let lateParent: String
}

extension [Object.Type] {
    /// Returns a topologically sorted array of the classes.
    /// Classes depending on others will be strictly later in the sequence.
    /// Duplicating entries will be removed.    
    public func topologicallySorted(
        onIncorrectInitializationOrder: (String, String) throws -> Void
    ) rethrows -> [Object.Type] {
        guard !isEmpty else {
            return []
        }
        
        func id(of type: AnyClass) -> ObjectIdentifier {
            ObjectIdentifier(type)
        }
        
        let idToType = Dictionary(
            uniqueKeysWithValues: map { (id(of: $0), $0) }
        )
        
        func type(with id: ObjectIdentifier) -> Object.Type {
            idToType[id]!
        }
        
        var remaining = Set(idToType.keys)
        let knownTypeIds = remaining
        var pending = [ObjectIdentifier]()
        var sorted = [ObjectIdentifier]()
        
        while remaining.count > 0 {            
            for typeId in remaining {
                let type = type(with: typeId)
                if let superType = _getSuperclass(type) {
                    guard let superType = superType as? Object.Type else {
                        fatalError("Unreachable")
                    }
                    
                    let superTypeId = id(of: superType)
                    
                    if knownTypeIds.contains(superTypeId) // unknown types (such as framework ones) are considered as registered
                        && superType.classInitializationLevel.rawValue > type.classInitializationLevel.rawValue {
                        // Super type is registered later than the child
                        try onIncorrectInitializationOrder("\(type)", "\(superType)")
                    }
                                        
                    if !remaining.contains(superTypeId) {
                        pending.append(typeId)
                    }
                } else {
                    pending.append(typeId)
                }
            }
            
            sorted.append(contentsOf: pending)
            for id in pending {
                remaining.remove(id)
            }
            pending.removeAll()
        }
        
        return sorted.map { type(with: $0) }
    }
    
    /// Returns a topologically sorted array of the classes.
    /// Classes depending on others will be strictly later in the sequence.
    /// Duplicating entries will be removed.
    public func topologicallySorted() -> [Object.Type] {
        topologicallySorted(onIncorrectInitializationOrder: { _, _ in
            // no-op
        })
    }
    
    /// Returns a topologically sorted array of the classes.
    /// Classes depending on others will be strictly later in the sequence.
    /// Duplicating entries will be removed.
    /// If the sorted sequence doesn't contain a strictly ascending `classInitializationLevel`, throws ``IncorrectInitializationOrderError``
    public func topologicallySortedCheckingInitializationOrder() throws -> [Object.Type] {
        try topologicallySorted(
            onIncorrectInitializationOrder: {
                throw IncorrectInitializationOrderError(earlyChild: $0, lateParent: $1)
            }
        )
    }
        
    /// Sort types topologically, ensuring that their initialization order is correct (see ``topologicallySortedCheckingInitializationOrder``)
    public func prepareForRegistration() throws -> [GDExtension.InitializationLevel: [Object.Type]] {
        let sorted = try topologicallySortedCheckingInitializationOrder()
        var result: [GDExtension.InitializationLevel: [Object.Type]] = [:]
        
        for type in sorted {
            result[type.classInitializationLevel, default: []].append(type)
        }
        
        return result
    }
}

public func minimumInitializationLevel(for registration: [GDExtension.InitializationLevel: [Object.Type]]) -> GDExtension.InitializationLevel {
    let nonEmptyLevels = registration.keys.filter { key in
        registration[key]?.isEmpty == false
    }
    
    let minOrNil = nonEmptyLevels.min { lhs, rhs in
        lhs.rawValue < rhs.rawValue
    }
    
    return minOrNil ?? .editor // .editor is max
}
    
