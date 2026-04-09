//
//  Wrapped.swift
//
//  Created by Miguel de Icaza on 3/28/23.
//
// This is the base class for all types that Godot calls "Classes", as
// opposed to their "Built-ins".   The built-ins are a mix of structs and
// classes that have all of their payload inlined - and just differ on
// their moving semantics.
//
// The generated Godot classes can be subclassed by the user, and their
// state is preserved if the object is passed to Godot, and later it is
// resurfaced to the Swift universe.
//
// We ensure that all Godot objects that are surfaced to Swift retain their
// identity.  So we keep a table of every surfaced Godot object into Swift.
//
#if canImport(AppKit) || canImport(UIKit)
import Foundation
#endif
import Foundation
import GDExtension

func pd (_ str: String) {
    #if false
    print("anothr")
    print ("SwiftGodot: \(str)")
    #endif
}
#if DEBUG_INSTANCES
var xmap: [UnsafeRawPointer: String] = [:]
#endif

/// Describes the role of a Swift wrapper.
///
/// This enum is about construction context, not pointer ownership.
/// It answers where the initialization request came from.
///
/// Use this to decide wrapper/binding setup behavior for a new instance.
/// Do not use it to infer whether the surfaced object pointer is borrowed,
/// comes from an owned `Ref<>`, or already carries a return-slot lifetime.
/// That is handled separately by ``ReturnedObjectOwnership``.
enum InitOrigin {
    /// Directly from Swift
    /// For example: `let object = Object()`
    ///
    /// Swift constructs the native object first and then wraps it.
    case swift
    
    /// The object surfaced from Godot and Swift is wrapping an existing native instance.
    ///
    /// This includes paths such as:
    /// - unwrapping a ``Variant``
    /// - receiving a method return value
    /// - adopting another engine-originated object pointer
    ///
    /// This case does not imply a single ownership policy; surfaced objects may
    /// still be borrowed, come from an owned `Ref<>`, or arrive through a normal
    /// Godot API return slot.
    case godot

    /// Constructed by Godot (from GDScript) in `createFunc`
    ///
    /// Godot is creating one of our registered Swift user types and calls back
    /// into Swift to materialize the wrapper and user instance.
    case gdscript
}

/// Opaque pointer representing Godot `Object *`
public typealias GodotNativeObjectPointer = UnsafeMutableRawPointer

/// Just pass it to `super.init`.
public struct InitContext {
    let handle: GodotNativeObjectPointer
    let origin: InitOrigin

    /// Creates a new object of the specified className and returns an InitContext that you can
    /// use to call your constructor
    public static func createObject(className: StringName) -> InitContext? {
        var copy = className
        guard let nativeHandle = gi.classdb_construct_object(&copy.content) else {
            return nil
        }
        return InitContext(handle: nativeHandle, origin: .swift)
    }
}

///
/// The base class for all class bindings in Godot, you should not have
/// to instantiate or subclass this class directly - there are better options
/// in the hierarchy.
///
/// Wrapped implements Equatable based on an identity based on the
/// pointer to the Godot native object and also implements the Identifiable
/// protocol using this pointer.
///
/// Wrapped manages the lifecycle of these objects, and in the event that an
/// object in the Godot world has been disposed, the handle in the Wrapped
/// object will be cleared - you can detect this condition by calling `isValid`
/// on the object.
///
/// # State Management
///
/// Wrapped manages the lifecycle of these objects, and in the event that an
/// object in the Godot world has been disposed, the handle in the Wrapped
/// object will be cleared - you can detect this condition by calling `isValid`
/// on the object.
///
/// Wrapped subclasses come in two forms: straight bindings to the Godot
/// API which are used to expose capabilities to developers.   These objects, referred
/// to as Framework types do not have any additional state associated in
/// Swift.
///
/// When user subclass Wrapped, they might have state associated with them,
/// so those objects are preserved and are not thrown away until they are
/// explicitly relinquished by both Godot and any references you might hold to
/// them.   These are known as User types.   Objects can be subclassed either
/// to attach additional runtime information, or to override methods (we follow
/// the Godot conventions and the methods are prefixed with an underscore).
///
/// # LifeCycle
///
/// Some special handling is done for different objects in the Godot hierarchy.
/// The way we now handle the lifecycle of Godot objects in Swift is the following:
/// If an object is not a RefCounted, we keep a strong reference to it, so that only
/// a call to the appropriate free method can delete the object.
///
/// If an object is a RefCounted, we keep track of the reference()/unreference() calls
/// to it, and we keep a weak reference to it if there are no references to it in Godot,
/// otherwise we keep a strong reference to it. This guarantees that the object can
/// still be deleted when no reference to it exists anymore, while making sure that
/// subtyped objects keep their state on the Swift side throughout the Godot object's
/// lifetime. As the Swift wrapper also increases the reference count of the
/// RefCounted, this means that once a RefCounted is passed to the Swift side, that
/// Godot object will always be destroyed by the Swift wrapper eventually.
///
/// # Type Registration
///
/// Any subclass ends up calling the Wrapped(StringName) constructor which
/// provides the name of the most-derived framework type, and this constructor
/// determines whether this is a Framework type or a user type.
///
/// To register User types with the framework make sure you call the
/// `register<T: Object> (type: T.Type)` method like this:
///
/// `register (type: MySpinningCube.self)`
///
/// If you do not call this method, many of the overloads that Godot would
/// call you back on will not be invoked.
open class Wrapped: Equatable, Identifiable, Hashable {
    /// Points to the underlying object
    public var handle: GodotNativeObjectPointer?
    
    weak var wrapper: WrappedReference?
    
    #if SWIFTGODOT_WITH_MULTI_PROCESS
    public static var fcallbacks = OpaquePointer (UnsafeRawPointer (&Wrapped.bindingCallback))
    public static var ucallbacks = OpaquePointer (UnsafeRawPointer (&Wrapped.bindingCallback))
    #else
    public static var fcallbacks = OpaquePointer (UnsafeRawPointer (&Wrapped.frameworkTypeBindingCallback))
    public static var ucallbacks = OpaquePointer (UnsafeRawPointer (&Wrapped.userTypeBindingCallback))
    #endif
    public static var deferred: Callable? = nil

    /// Conformance to Identifiable by using the native handle to the object
    public var id: Int { Int (bitPattern: handle) }
    
    public static func == (lhs: Wrapped, rhs: Wrapped) -> Bool {
        return lhs.handle == rhs.handle
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(handle)
    }
    
    /// This method returns the list of StringNames for methods that the class overwrites, and
    /// is necessary to ensure that Godot knows which methods have been overwritten, and which
    /// ones Godot will provide a default behavior for.
    ///
    /// This is necessary because the Godot overwrite method does not surface a "base" behavior
    /// that can be called into.  Instead Godot relies on the "Is the method implemented or not"
    /// to make this determination.
    ///
    /// If you are not using the `@Godot` macro, you should overwrite this function and return
    /// the StringNames for the functions you override, like in this example, where we indicate
    /// that we override the Godot `_has_point` method:
    ///
    /// ```
    /// open override func implementedOverrides() -> [StringName] {
    ///     return super.implementedOverrides + [StringName ("_has_point")]
    /// }
    /// ```
    open class func implementedOverrides() -> [StringName] {
        []
    }

    @inline(never)
    public static func attemptToUseObjectFreedByGodot() {
        fatalError ("Wrapped.handle was nil, which indicates the object was cleared by Godot")
    }
    @_spi(SwiftGodotRuntimePrivate) open class func getVirtualDispatcher(name: StringName) ->  GDExtensionClassCallVirtual? {
        pd ("SWARN: getVirtualDispatcher (\"\(name)\") reached Wrapped on class \(self)")
        return nil
    }

    // Override this to add some custom logic to the class initialization of @Godot annotated classes.
    // This function will only be called if the class in question is annotated with @Godot
    public class func initClass() {
    }

    deinit {
        // Use the following to catch the deinit happening and then the free framework
        // code running - we have no way of notifying that code that we are dead.
        #if DEBUG_DEINIT
        let opaque: UnsafeMutableRawPointer = Unmanaged.passUnretained(self).toOpaque()
        print ("Wrapped.deinit \(String(describing: opaque)) handle=\(handle)")
        if let so = self as? Object {
            if so.isValid {
                print ("   -> \(so)")
            } else {
                print("    -> \(type(of:self)) [DIED BEFORE DEINIT]")
            }
        }
        #endif
        if let handle {
            guard extensionInterface.objectShouldDeinit(object: self) else { return }
#if DEBUG_INSTANCES
            let type = xmap[handle] ?? "unknown"
            let txt = "DEINIT for object=\(type) handle=\(handle)"
#endif

            if self is RefCounted {
                // Godot may already have consumed the final native reference before
                // the Swift wrapper is torn down, especially for editor-managed resources.
                if let refCounted = self as? RefCounted, refCounted.getReferenceCount() <= 0 {
		    print("RefCounted: it was already zero, flagging as deinited.");
                    extensionInterface.objectDeinited(object: self)
                    return
                }
                var queue = false
                freeLock.withLockVoid {
                    if Wrapped.deferred == nil {
                        Wrapped.deferred = Callable ({ (args: borrowing Arguments) in
                            releasePendingObjects()
                            return nil
                        })
                    }
                    #if SWIFTGODOT_WITH_MULTI_PROCESS
                    let id = extensionInterface.getCurrenDomain()
                    pendingReleaseHandles[id, default: []].append(handle)
                    if pendingReleaseHandles[id]?.count == 1 {
                        queue = true
                    }
                    #else
                    pendingReleaseHandles.append(handle)
                    if pendingReleaseHandles.count == 1 {
                        queue = true
                    }
                    #endif
                }
                if queue {
                    Wrapped.deferred?.callDeferred()
                }
            }
        }
        extensionInterface.objectDeinited(object: self)
    }
    #if SWIFTGODOT_WITH_MULTI_PROCESS
    static var bindingCallback = GDExtensionInstanceBindingCallbacks(
        create_callback: bindingCreate,
        free_callback: bindingFree,
        reference_callback: bindingReference)
    #else
    static var userTypeBindingCallback = GDExtensionInstanceBindingCallbacks(
        create_callback: userTypeBindingCreate,
        free_callback: userTypeBindingFree,
        reference_callback: userTypeBindingReference)

    static var frameworkTypeBindingCallback = GDExtensionInstanceBindingCallbacks(
        create_callback: frameworkTypeBindingCreate,
        free_callback: frameworkTypeBindingFree,
        reference_callback: frameworkTypeBindingReference)
    #endif

    /// Returns the Godot's class name as a `StringName`, returns the empty string on error
    public var godotClassName: StringName {
        var sc: StringName.ContentType = StringName.zero
        
        if gi.object_get_class_name (handle, extensionInterface.getLibrary(), &sc) != 0 {
            let sn = StringName(takingOver: sc)
            return sn
        }
        return ""
    }

    /// This method is posted by Godot, you can override this method and
    /// be notified of interesting events, the values for this notification are declared on various
    /// different types, like the constants in Object or Node.
    ///
    /// For example `Node.notificationProcess`
    open func _notification(code: Int, reversed: Bool) {
    }

    ///  Called whenever Godot retrieves value of property. Allows to customize existing properties.
    /// Return true if you made changes to the PropInfo value you got
    open func _validateProperty(_ property: inout PropInfo) -> Bool {
        return false
    }

    /// Checks if this object has a script with the given method.
    /// - Parameter method: StringName identifying the method.
    /// - Returns: `true` if the object has a script and that script has a method with the given name.
    /// `false` if the object has no script.
    public func hasScript (method: StringName) -> Bool {
        gi.object_has_script_method(handle, &method.content) != 0
    }
    
    /// Invokes the specified method on the object
    /// - Parameters:
    ///  - method: the method to invoke on the target
    ///  - arguments: variable list of arguments
    /// - Returns: if there is an error, this function raises an error, otherwise, a Variant with the result is returned
    public func callScript (method: StringName, _ arguments: Variant?...) throws -> Variant? {
        var args: [UnsafeRawPointer?] = []
        let cptr = UnsafeMutableBufferPointer<Variant.ContentType>.allocate(capacity: arguments.count)
        defer { cptr.deallocate () }
        
        for idx in 0..<arguments.count {
            cptr [idx] = arguments[idx].content
            args.append (cptr.baseAddress! + idx)
        }
        var result = Variant.zero
        var error = GDExtensionCallError()
        gi.object_call_script_method(&handle, &method.content, &args, Int64(args.count), &result, &error)
        if error.error != GDEXTENSION_CALL_OK {
            throw toCallErrorType(error.error)
        }
        
        return Variant(takingOver: result)
    }
    
    /// For use by the framework, you should not need to call this.
    public required init(_ context: InitContext) {
        handle = context.handle
        extensionInterface.objectInited(object: self)
        #if SWIFTGODOT_WITH_MULTI_PROCESS
        bindSwiftObject(self, context)
        #else
        bindSwiftObject(self, toGodot: context.handle)
        #endif
    }
    
    /// This property indicates if the instance is valid or not.
    ///
    /// In Godot, some objects can be freed manually, and in particular
    /// when you call the ``Node/queueFree()`` which might queue the object
    /// for disposal
    public var isValid: Bool {
        return handle != nil
    }

    /// Use this to release objects that are neither Nodes or RefCounted subclasses.
    ///
    /// To release a ``Node`` or a Node subclass, call ``Node.queueFree()``,
    /// ``RefCounted`` objects are destroyed automatically when the last reference
    /// is gone, so it is not necessary to call ``free`` on those.
    public func free() {
        if let object = self as? Object, object.isClass("Node") {
            print ("SwiftGodot: Cannot call free() on Nodes; queueFree() should be used instead.")
            return
        }
        guard !(self is RefCounted) else  {
            print ("SwiftGodot: Cannot call free() on RefCounted; release all references to it instead.")
            return
        }
        guard isValid else {
            print ("SwiftGodot: free() called on an invalid object.")
            return
        }
        guard extensionInterface.objectShouldDeinit(object: self) else {
            print ("SwiftGodot: free() called with an invalid instance.")
            return
        }

        gi.object_destroy(handle)
    }
    
    open class var godotClassName: StringName {
        fatalError("Subclasses of Wrapped must override godotClassName")
    }
    
    open class var classInitializer: Void { () }
    
    /// Indicates during which engine initialization stage this class is registered. `.scene` is default. This value is taken into consideration when using `#initSwiftExtension(cdecl:types:)`  or `EntryPointGeneratorPlugin`.
    open class var classInitializationLevel: ExtensionInitializationLevel { .scene }
}

/// We can't simply extend `Wrapped`, because `convenience init` do not keep polymorphic `Self`.
public extension _GodotBridgeable where Self: Wrapped {
    /// Initialize a new object.
    init() {
        guard let nativeHandle = gi.classdb_construct_object(&Self.godotClassName.content) else {
            fatalError("SWIFT: It was not possible to construct a \(Self.godotClassName.description)")
        }
       
        self.init(InitContext(handle: nativeHandle, origin: .swift))
    }
    
    /// Delicate API.
    /// Initialize a new object from a raw handle.
    init(nativeHandle: GodotNativeObjectPointer) {
        self.init(InitContext(handle: nativeHandle, origin: .swift))
    }
}

#if SWIFTGODOT_WITH_MULTI_PROCESS
func bindSwiftObject(_ object: some Wrapped, _ context: InitContext) {
    let name = object.self.godotClassName
    let thisTypeName = StringName (stringLiteral: String (describing: Swift.type(of: object)))
    let frameworkType = thisTypeName == name

    var callbacks: GDExtensionInstanceBindingCallbacks = Wrapped.bindingCallback

    let reference: WrappedReference
    if let refCounted = object as? RefCounted, refCounted.getReferenceCount() < 1 {
        fatalError ("Attempting to create a RefCounted wrapper to an object that is not referenced")
    } else {
        reference = WrappedReference(object, strong: true)
    }

    object.wrapper = reference

    tableLock.withLockVoid {
        if let handle = object.handle {
            if frameworkType {
                liveFrameworkObjects[handle] = reference
            } else {
                liveSubtypedObjects[handle] = reference
            }
        }
    }

    let unmanaged = Unmanaged<WrappedReference>.passUnretained(reference)

    if !frameworkType {
        withUnsafeMutablePointer(to: &thisTypeName.content) { ptr in
            gi.object_set_instance(context.handle, ptr, unmanaged.retain().toOpaque())
        }
    }

    if context.origin == .swift || context.origin == .gdscript {
        gi.object_set_instance_binding(context.handle, extensionInterface.getLibrary(), unmanaged.toOpaque(), &callbacks)
    }
}
#else
func bindSwiftObject(_ instance: some Wrapped, toGodot handle: GodotNativeObjectPointer) {
    let name = instance.self.godotClassName
    let thisTypeName = StringName (stringLiteral: String (describing: Swift.type(of: instance)))
    let frameworkType = thisTypeName == name
    
    var callbacks: GDExtensionInstanceBindingCallbacks
    if frameworkType {
        callbacks = Wrapped.frameworkTypeBindingCallback
    } else {
        callbacks = Wrapped.userTypeBindingCallback
    }

    let reference: WrappedReference
    if let refCounted = instance as? RefCounted, refCounted.getReferenceCount() <= 1 {
        reference = WrappedReference(instance, strong: false)
    } else {
        reference = WrappedReference(instance, strong: true)
    }
    
    instance.wrapper = reference

    tableLock.withLockVoid {
        if frameworkType {
            liveFrameworkObjects[handle] = reference
        } else {
            liveSubtypedObjects[handle] = reference
        }
    }

    let unmanaged = Unmanaged<WrappedReference>.passUnretained(reference)

    // This I believe should only be set for user subclasses, and not anything else.
    if frameworkType {
        //pd ("Skipping object registration, this is a framework type")
    } else {
        //pd ("Registering instance with Godot")
        // Retain an additional unmanaged reference that will be released in freeFunc().
        withUnsafeMutablePointer(to: &thisTypeName.content) { ptr in
            gi.object_set_instance(handle, ptr, unmanaged.retain().toOpaque())
        }
    }
    
    gi.object_set_instance_binding(handle, extensionInterface.getLibrary(), unmanaged.toOpaque(), &callbacks)
}
#endif

var userTypes: [String: Object.Type] = [:]

@_spi(SwiftGodotRuntimePrivate) public
var duplicateClassNameDetected: (_ name: StringName, _ type: Object.Type) -> Void = { name, type in
    preconditionFailure(
                """
                Godot already has a class named \(name), so I cannot register \(type) using that name. This is a fatal error because the only way I can tell whether Godot is handing me a pointer to a class I'm responsible for is by checking the class name.
                """
    )
}

func register<T: Object>(type name: StringName, parent: StringName, type: T.Type) {
    var nameContent = name.content

    // The classdb_get_class_tag function is documented to return “a pointer uniquely identifying the given built-in class”. As of Godot 4.2.2, it also returns non-nil for types registered by extensions. If Godot is changed in the future to return nil for extension types, this will simply stop detecting duplicate class names. It won't break valid code.

    let existingClassTag = gi.classdb_get_class_tag(&nameContent)
    if existingClassTag != nil {
        duplicateClassNameDetected(name, type)
    }

    func getVirtual(_ userData: UnsafeMutableRawPointer?, _ name: GDExtensionConstStringNamePtr?) ->  GDExtensionClassCallVirtual? {
        let typeAny = Unmanaged<AnyObject>.fromOpaque(userData!).takeUnretainedValue()
        guard let type  = typeAny as? Object.Type else {
            pd ("The wrapped value did not contain a type: \(typeAny)")
            return nil
        }
        return type.getVirtualDispatcher(name: StringName (fromPtr: name))
    }
    
    var info = GDExtensionClassCreationInfo2 ()
    info.create_instance_func = createFunc(_:)
    info.free_instance_func = freeFunc(_:_:)
    info.get_virtual_func = getVirtual
    info.notification_func = notificationFunc
    info.recreate_instance_func = recreateFunc
    info.validate_property_func = validatePropertyFunc
    info.is_exposed = 1
    
    userTypes[name.description] = T.self
    
    let retained = Unmanaged<AnyObject>.passRetained(type as AnyObject)
    info.class_userdata = retained.toOpaque()
    
    gi.classdb_register_extension_class(extensionInterface.getLibrary(), &nameContent, &parent.content, &info)
    if var extensionInterface {
        if extensionInterface.classDBReady {
            _ = type.classInitializer
        } else {
            extensionInterface.pendingInitializers.append({ _ = type.classInitializer })
        }
    }
}

@_spi(SwiftGodotRuntimePrivate) public final class WrappedReference {
    public init(_ val: Wrapped, strong: Bool = true) {
        self.ref = val
        if strong {
            _ = strongify()
        }
    }
    
    deinit {
        _ = weakify()
    }

    @discardableResult
    public final func strongify() -> Self {
        if strong {
            return self
        }
        if let value {
            _ = Unmanaged<Wrapped>.passUnretained(value).retain()
        }
        strong = true
        return self
    }

    @discardableResult
    public final func weakify() -> Self {
        if !strong {
            return self
        }
        if let value {
            Unmanaged<Wrapped>.passUnretained(value).release()
        }
        strong = false
        return self
    }
    
    public final func isStrong() -> Bool {
        return strong
    }
    
    public var value: Wrapped? {
        return ref
    }

    private weak var ref: Wrapped?
    private var strong: Bool = false
}

/// Registers the user-type specified with the Godot system, and allows it to
/// receive any of the calls from Godot virtual methods (those that are prefixed
/// with an underscore)
public func register<T: Object>(type: T.Type) {
    guard let superType = Swift._getSuperclass (type) else {
        print ("You can not register the root class")
        return
    }
    let typeStr = String (describing: type)
    let superStr = String(describing: superType)
    register (type: StringName (typeStr), parent: StringName (superStr), type: type)
}

/// Register the enumeration, the enumeration must be nested into a type
public func registerEnum<T>(_ type: T.Type)
where T: RawRepresentable & CaseIterable, T.RawValue == Int64 {
    let fullname = String(reflecting: type)
    let split = fullname.split(separator: ".")
    if split.count != 3 {
        GD.print("Could not register enum \(fullname) it needs 3 components")
        return
    }

    var className = StringName(split[1])
    var enumName  = StringName(split[2])

    withUnsafePointer(to: &className.content) { classPtr in
        withUnsafePointer(to: &enumName.content) { enumPtr in
            for v in type.allCases {
                let keyString = String(describing: v)          // e.g. "foo", "bar"
                var key   = StringName(keyString)
                let value = v.rawValue                         // Int64

                withUnsafePointer(to: &key.content) { keyPtr in
                    gi.classdb_register_extension_class_integer_constant(
                        extensionInterface.getLibrary(),
                        classPtr,
                        enumPtr,
                        keyPtr,
                        value,
                        0)
                }
            }
        }
    }
}

/// Register the enumeration, the enumeration must be nested into a type
public func registerEnum<T>(_ type: T.Type)
where T: RawRepresentable & CaseIterable, T.RawValue == Int {
    let fullname = String(reflecting: type)
    let split = fullname.split(separator: ".")
    if split.count != 3 {
        GD.print("Could not register enum \(fullname) it needs 3 components")
        return
    }

    var className = StringName(split[1])
    var enumName  = StringName(split[2])

    withUnsafePointer(to: &className.content) { classPtr in
        withUnsafePointer(to: &enumName.content) { enumPtr in
            for v in type.allCases {
                let keyString = String(describing: v)          // e.g. "foo", "bar"
                var key   = StringName(keyString)
                let value = v.rawValue                         // Int64

                withUnsafePointer(to: &key.content) { keyPtr in
                    gi.classdb_register_extension_class_integer_constant(
                        extensionInterface.getLibrary(),
                        classPtr,
                        enumPtr,
                        keyPtr,
                        Int64(value),
                        0)
                }
            }
        }
    }
}

public func unregister<T: Object>(type: T.Type) {
    let typeStr = String (describing: type)
    let name = StringName (typeStr)
    pd ("Unregistering \(typeStr)")
    withUnsafePointer (to: &name.content) { namePtr in
        gi.classdb_unregister_extension_class(extensionInterface.getLibrary(), namePtr)
    }
}

/// Currently contains all instantiated objects, but might want to separate those
/// (or find a way of easily telling appart) framework objects from user subtypes
var liveFrameworkObjects: [GodotNativeObjectPointer: WrappedReference] = [:]
var liveSubtypedObjects: [GodotNativeObjectPointer: WrappedReference] = [:]

public func printSwiftGodotStats() {
    print("User types: \(userTypes.count)")
    print("Framework: \(liveFrameworkObjects.count)")
    print("LiveSubTyped: \(liveSubtypedObjects.count)")

}

// Lock for accessing the above
var tableLock = NIOLock()

// Lock for the pending free list
var freeLock = NIOLock()
#if SWIFTGODOT_WITH_MULTI_PROCESS
var pendingReleaseHandles: [UInt8: [GodotNativeObjectPointer]] = [:]
#else
var pendingReleaseHandles: [GodotNativeObjectPointer] = []
#endif

private func objectClassName(_ handle: GodotNativeObjectPointer) -> String {
    var sc: StringName.ContentType = StringName.zero
    if gi.object_get_class_name(handle, extensionInterface.getLibrary(), &sc) != 0 {
        return String(StringName(content: sc))
    }
    var result = GString()
    gi.object_method_bind_ptrcall(Object.method_get_class, handle, nil, &result.content)
    return result.description
}

private func currentRefCount(_ handle: GodotNativeObjectPointer) -> Int32? {
    let objectClass = objectClassName(handle)
    var className = FastStringName(objectClass)
    var methodName = FastStringName("get_reference_count")
    guard let bind = withUnsafePointer(to: &className.content, { classPtr in
        withUnsafePointer(to: &methodName.content) { methodPtr in
            gi.classdb_get_method_bind(classPtr, methodPtr, 3905245786)
        }
    }) else {
        return nil
    }
    var result: Int32 = 0
    gi.object_method_bind_ptrcall(bind, handle, nil, &result)
    return result
}

@inline(__always)
private func isTrackedHandle(_ handle: GodotNativeObjectPointer) -> Bool {
    tableLock.withLock {
        liveFrameworkObjects[handle] != nil || liveSubtypedObjects[handle] != nil
    }
}

@inline(__always)
private func removePendingReleaseHandle(_ handle: GodotNativeObjectPointer) {
    freeLock.withLockVoid {
        #if SWIFTGODOT_WITH_MULTI_PROCESS
        for key in pendingReleaseHandles.keys {
            pendingReleaseHandles[key]?.removeAll { $0 == handle }
            if pendingReleaseHandles[key]?.isEmpty == true {
                pendingReleaseHandles.removeValue(forKey: key)
            }
        }
        #else
        pendingReleaseHandles.removeAll { $0 == handle }
        #endif
    }
}

/// Use this function to force the disposing of any objects that were queued for destruction
/// this is called automatically by Godot's main loop iteration, but it is expose for the sake
/// of the test suite that wants to release objects without waiting for Godot to run the queue
public func releasePendingObjects() {
    var copy: [GodotNativeObjectPointer] = []

    freeLock.withLock {
        #if SWIFTGODOT_WITH_MULTI_PROCESS
        let id = extensionInterface.getCurrenDomain()
        copy = pendingReleaseHandles[id] ?? []
        pendingReleaseHandles.removeValue(forKey: id)
        #else
        copy = pendingReleaseHandles
        pendingReleaseHandles = []
        #endif
    }
    for handle in copy {
        // During shutdown, Godot may destroy RefCounted objects before the deferred
        // queue is flushed; if so, our instance binding free callbacks will remove
        // the handle from the live tables. In that case, don't call back into Godot
        // with a stale pointer.
        guard isTrackedHandle(handle) else { continue }

#if DEBUG
	// Expensive, calls currentRefCount.
	// Editor-managed RefCounted objects can reach zero before the deferred flush runs.
        if let refCount = currentRefCount(handle), refCount <= 0 {
	    fatalError("We had a zero refCount handle here, this should not happen")
        }
#endif

        var result: Bool = false
        gi.object_method_bind_ptrcall(RefCounted.method_unreference, handle, nil, &result)
        if result {
            gi.object_destroy(handle)
        }
    }
}
 
 ///
 /// Looks into the liveSubtypedObjects table if we have an object registered for it,

///
/// Looks into the liveSubtypedObjects table if we have an object registered for it,
/// and if we do, we returned that existing instance.
///
/// The idioms is that we only need to look up subtyped objects, because those
/// are the only ones that would keep state
func lookupLiveObject (handleAddress: GodotNativeObjectPointer) -> Wrapped? {
    tableLock.withLock {
        return liveSubtypedObjects [handleAddress]?.value
    }
}

///
/// Looks into the liveSubtypedObjects table if we have an object registered for it,
/// and if we do, we returned that existing instance.
///
/// We are surfacing this, so that when we recreate an object resurfaced in a collection
/// we do not get the base type, but the most derived one
func lookupFrameworkObject (handleAddress: GodotNativeObjectPointer) -> Wrapped? {
    tableLock.withLock {
        return liveFrameworkObjects [handleAddress]?.value
    }
}

func existingSwiftObject(for nativeHandle: GodotNativeObjectPointer) -> Wrapped? {
    tableLock.withLock {
        if let o = (liveFrameworkObjects [nativeHandle]?.value ?? liveSubtypedObjects [nativeHandle]?.value) {
            return o
        }
        
        return nil
    }
}

/// Describes the lifetime contract of an object pointer surfaced to Swift.
///
/// This enum is about refcount behavior, not construction context.
/// It determines what is the native ownership for the pointer.
///
/// Use this when reconciling Swift wrapper identity with Godot native lifetime.
/// Do not use it to distinguish whether the wrapper was initialized from Swift,
/// from Godot, or from a GDScript-created user type. That is handled by
/// ``InitOrigin``.
public enum ReturnedObjectOwnership {
    /// The object pointer is borrowed, so a new Swift wrapper must retain its own native ref.
    case borrowed

    /// Godot returned an owned `Ref<T>` wrapper that SwiftGodot should consume.
    case refWrapper

    /// Godot returned an object pointer directly from the API return slot.
    ///
    /// Swift should adopt this lifetime as-is. In particular, this path should
    /// neither add a fresh native reference nor consume an extra owned `Ref<>`.
    case godotApiReturn
}

// The following function makes the reference count of RefCounted objects consistent
// with the semantics of the source that surfaced them to Swift:
// - borrowed: Swift must acquire a native reference when creating the first wrapper.
// - refWrapper: Godot returned an owned Ref<> wrapper that Swift must consume.
// - godotApiReturn: Godot returned the object through a standard API return slot, so
//   Swift should adopt that lifetime without adding or consuming another reference.
func handleReturnedObject<T: Wrapped>(
    staticType: T.Type,
    object: Wrapped?,
    ownership: ReturnedObjectOwnership,
    isExistingWrapper: Bool
) {
    switch ownership {
    case .godotApiReturn:
        return

    case .borrowed:
        if !isExistingWrapper, let refCounted = object as? RefCounted {
            refCounted.reference()
        }

    case .refWrapper:
        guard let refCounted = object as? RefCounted else { return }

        if staticType is RefCounted.Type {
            refCounted.unreference()
        } else if !isExistingWrapper {
            refCounted.reference()
        }
    }
}

/// Get an existing Swift object which is bound to Godot `nativeHandle` or initialize a new one and bind it
// @_spi(SwiftGodotRuntimePrivate)
#if SWIFTGODOT_WITH_MULTI_PROCESS
final class ReferenceArray<Element> {
    var items: [Element]

    init(_ items: [Element] = []) {
        self.items = items
    }
}

let SwiftGodot_has_instance_binding = "SwiftGodot_has_instance_binding"

public func getOrInitSwiftObject<T: Object>(nativeHandle: GodotNativeObjectPointer, ownership: ReturnedObjectOwnership) -> T? {
    var hasInstanceBinding = Foundation.Thread.current.threadDictionary.object(forKey: SwiftGodot_has_instance_binding) as? ReferenceArray<Bool>
    if hasInstanceBinding == nil {
        hasInstanceBinding = ReferenceArray<Bool>()
        Foundation.Thread.current.threadDictionary[SwiftGodot_has_instance_binding] = hasInstanceBinding
    }
    hasInstanceBinding?.items.append(true)

    guard let binding = gi.object_get_instance_binding(nativeHandle, extensionInterface.getLibrary(), &Wrapped.bindingCallback) else {
        return nil
    }

    let reference = Unmanaged<WrappedReference>.fromOpaque(binding).takeUnretainedValue()
    let object = reference.value

    guard let exists = hasInstanceBinding?.items.popLast() else {
        fatalError("Corrupt has_instance_binding.")
    }
    handleReturnedObject(staticType: T.self, object: object, ownership: ownership, isExistingWrapper: exists)

    if let refCounted = object as? RefCounted, refCounted.getReferenceCount() <= 1 {
        reference.weakify()
    }

    return object as? T
}

func createSwiftObject(nativeHandle: GodotNativeObjectPointer) -> Object? {
    var className: String = ""
    var sc: StringName.ContentType = StringName.zero
    if gi.object_get_class_name(nativeHandle, extensionInterface.getLibrary(), &sc) != 0 {
        let sn = StringName(content: sc)
        className = String(sn)
    } else {
        var result = GString()
        gi.object_method_bind_ptrcall(Object.method_get_class, nativeHandle, nil, &result.content)
        className = result.description
    }

    if let type = typeOfClass(named: className) {
        let created = type.init(InitContext(handle: nativeHandle, origin: .godot))
        return created
    }

    print("Object of class \(className) could not be created")
    return nil
}
#else
public func getOrInitSwiftObject<T: Object>(nativeHandle: GodotNativeObjectPointer, ownership: ReturnedObjectOwnership) -> T? {
    if let object = existingSwiftObject(for: nativeHandle) {
        handleReturnedObject(staticType: T.self, object: object, ownership: ownership, isExistingWrapper: true)
        return object as? T
    }
    
    var className: String = ""
    var sc: StringName.ContentType = StringName.zero
    if gi.object_get_class_name (nativeHandle, extensionInterface.getLibrary(), &sc) != 0 {
        let sn = StringName(content: sc)
        className = String(sn)
    } else {        
        let _result: GString = GString ()
        gi.object_method_bind_ptrcall (Object.method_get_class, nativeHandle, nil, &_result.content)
        className = _result.description
    }
    if let userType = userTypes[className] {
        let created = userType.init(InitContext(handle: nativeHandle, origin: .godot))
        handleReturnedObject(staticType: T.self, object: created, ownership: ownership, isExistingWrapper: false)
        if let result = created as? T {
            return result
        } else {
            print ("Found a custom type for \(className) but the constructor failed to return an instance of it as a \(T.self)")
        }
    }
    if let ctor = lookupGodotType(named: className) as? T.Type {
        let result = ctor.init(InitContext(handle: nativeHandle, origin: .godot))
        handleReturnedObject(staticType: T.self, object: result, ownership: ownership, isExistingWrapper: false)
        return result
    }

    // If we reached here, we could not fetch the most derived type
    // from either the user or the godot constructors, so we just
    // wrap what we know we can do: the type we have.
    //
    // So if we had say a "MyCamera3D" but we could not find it as a Godot
    // type or a user type, and we are being called as a Node3D, we will
    // return a Node3D (even if Camera3D would be a better match).
    //
    // This comment here for future generations that end up in this line
    // the real error is likely a registration issue.
    let result = T(InitContext(handle: nativeHandle, origin: .godot))
    handleReturnedObject(staticType: T.self, object: result, ownership: ownership, isExistingWrapper: false)
    return result
}
#endif

func referenceFunc(_ userData: UnsafeMutableRawPointer) {
    fatalError()
}

func unreferenceFunc(_ userData: UnsafeMutableRawPointer) {
    fatalError()
}

///
/// This one is invoked by Godot when an instance of one of our types is created, and we need
/// to instantiate it.   Notice that this is different that direct instantiation from our API
func createFunc(_ userData: UnsafeMutableRawPointer?) -> UnsafeMutableRawPointer? {
    //print ("SWIFT: Creating object userData:\(String(describing: userData))")
    guard let userData else {
        print ("SwiftGodot.createFunc: Got a nil userData")
        return nil
    }
    
    let typeAny = Unmanaged<AnyObject>.fromOpaque(userData).takeUnretainedValue()
    guard let type  = typeAny as? Wrapped.Type else {
        print ("SwiftGodot.createFunc: The wrapped value did not contain a type: \(typeAny)")
        return nil
    }
    
    guard let handle = gi.classdb_construct_object(&type.godotClassName.content) else {
        fatalError("SWIFT: It was not possible to construct a \(type.godotClassName.description)")
    }

    #if SWIFTGODOT_WITH_MULTI_PROCESS
    let object = type.init(InitContext(handle: handle, origin: .gdscript))
    object.wrapper?.strongify()
    #else
    let object = type.init(InitContext(handle: handle, origin: .gdscript))
    
    // We are the createFunc, and we have no other owner to this object but ourselves
    // we need to make this a strong reference, or it dies before we return
    guard let wrapper = object.wrapper else {
        fatalError("SwiftGodot.createFunc: wrapper should have been created during binding")
    }
    
    wrapper.strongify()
    #endif
    
    return handle
}

func recreateFunc(_ userData: UnsafeMutableRawPointer?, godotObjectHandle: UnsafeMutableRawPointer?) -> UnsafeMutableRawPointer? {
    //print ("SWIFT: Recreate object userData:\(String(describing: userData))")
    guard let userData else {
        print ("Got a nil userData")
        return nil
    }
    
    guard let godotObjectHandle else {
        return nil
    }
    
    let typeAny = Unmanaged<AnyObject>.fromOpaque(userData).takeUnretainedValue()
    guard let type  = typeAny as? Wrapped.Type else {
        print ("SwiftGodot.recreateFunc: The wrapped value did not contain a type: \(typeAny)")
        return nil
    }
    #if SWIFTGODOT_WITH_MULTI_PROCESS
    let object = type.init(InitContext(handle: godotObjectHandle, origin: .gdscript))
    object.wrapper?.strongify()
    #else
    let object = type.init(InitContext(handle: godotObjectHandle, origin: .gdscript))
    
    // Just line in the createFunc
    // we need to make this a strong reference, or it dies before we return
    guard let wrapper = object.wrapper else {
        fatalError("SwiftGodot.createFunc: wrapper should have been created during binding")
    }
    
    wrapper.strongify()
    #endif
    
    return godotObjectHandle
}

//
// This is invoked to release any Subtyped objects we created
//
func freeFunc (_ userData: UnsafeMutableRawPointer?, _ objectHandle: UnsafeMutableRawPointer?) {
//    #if true
//    // Just needed for debugging
//    let typeAny = Unmanaged<AnyObject>.fromOpaque(userData!).takeUnretainedValue()
//    guard let type  = typeAny as? Wrapped.Type else {
//        print ("SWIFT: FreeFunc wrapped value did not contain a type: \(typeAny)")
//        return
//    }
//    print ("SWIFT: Destroying object, userData: \(typeAny) objectHandle: \(objectHandle)")
//    #endif

    guard let objectHandle else { return }
    // Release the unmanaged reference that was retained in bindGodotInstance()
    Unmanaged<WrappedReference>.fromOpaque(objectHandle).release()
}

func notificationFunc (ptr: UnsafeMutableRawPointer?, code: Int32, reversed: UInt8) {
    guard let ptr else { return } 
    let original = Unmanaged<WrappedReference>.fromOpaque(ptr).takeUnretainedValue()
    guard let instance = original.value else { return }
    instance._notification(code: Int(code), reversed: reversed != 0)
}

func validatePropertyFunc(ptr: UnsafeMutableRawPointer?, _info: UnsafeMutablePointer<GDExtensionPropertyInfo>?) -> UInt8 {
    guard let ptr else { return 0 }
    let original = Unmanaged<WrappedReference>.fromOpaque(ptr).takeUnretainedValue()
    guard let instance = original.value else { return 0 }
    guard let info = _info?.pointee else { return 0 }
    guard let namePtr = info.name,
          let classNamePtr = info.class_name,
          let infoHintPtr = info.hint_string else {
        return 0
    }
    guard let ptype = Variant.GType(rawValue: Int64(info.type.rawValue)) else { return 0 }
    let pname = StringName(fromPtr: namePtr)
    let className = StringName(fromPtr: classNamePtr)
    let hint = PropertyHint(rawValue: Int64(info.hint)) ?? .none
    let hintStr = GString(content: infoHintPtr.load(as: Int64.self))
    let usage = PropertyUsageFlags(rawValue: Int(info.usage))

    var pinfo = PropInfo(propertyType: ptype, propertyName: pname, className: className, hint: hint, hintStr: hintStr, usage: usage)
    if instance._validateProperty(&pinfo) {
        // The problem with the code below is that it does not make a copy of the StringName and String,
        // and passes a reference that we will destroy right away when `pinfo` goes out of scope.
        //
        // For now, we just update the usage, type and hint but we need to find a solution for those other fields
        //let native = pinfo.makeNativeStruct()
        _info?.pointee.usage = UInt32(pinfo.usage.rawValue)
        _info?.pointee.hint = UInt32(pinfo.hint.rawValue)
        _info?.pointee.type = GDExtensionVariantType(GDExtensionVariantType.RawValue (pinfo.propertyType.rawValue))

        return 1
    }
    return 0
}

#if SWIFTGODOT_WITH_MULTI_PROCESS
// This is invoked to take a reference on the object and ensure our Swift-land object
// does not go away while the object is in use.
func bindingReference(_ token: UnsafeMutableRawPointer?, _ binding: UnsafeMutableRawPointer?, _ reference: UInt8) -> UInt8 {
    guard let binding else { return 0 }
    let ref = Unmanaged<WrappedReference>.fromOpaque(binding).takeUnretainedValue()
    weak var refCounted = ref.value as? RefCounted

    guard let rc = refCounted?.getReferenceCount() else {
        // unreference() was called by Wrapped.deinit, so we allow the object to be destroyed.
        return 1
    }
    
    if reference != 0 {
        // In addition to a reference by SwiftGodot, Godot also retained a reference.
        if rc == 2 {
            if let refCounted, refCounted.handle != nil {
                ref.strongify()
            }
        }
    } else {
        // Only SwiftGodot holds a reference, so we make the Wrapped's deinit available.
        if rc == 1 {
            if let refCounted, refCounted.handle != nil {
                ref.weakify()
            }
        }
    }
    
    // As long as the Wrapped's deinit is not called, we do not allow the object to be destroyed.
    return 0
}

func bindingCreate (_ token: UnsafeMutableRawPointer?, _ instance: UnsafeMutableRawPointer?) -> UnsafeMutableRawPointer? {
    guard let instance else { return nil }
    guard let object = createSwiftObject(nativeHandle: instance) else { return nil }
    guard let reference = object.wrapper else {
        fatalError("WrappedReference is not created for object.")
    }

    if let handle = object.handle {
        let frameworkType = String(describing: type(of: object)) == object.godotClassName.description
        tableLock.withLockVoid {
            if frameworkType {
                liveFrameworkObjects[handle] = reference
            } else {
                liveSubtypedObjects[handle] = reference
            }
        }
    }

    guard let hasInstanceBinding = Foundation.Thread.current.threadDictionary.object(forKey: SwiftGodot_has_instance_binding) as? ReferenceArray<Bool> else {
        fatalError("has_instance_binding is not found.")
    }
    hasInstanceBinding.items[hasInstanceBinding.items.count - 1] = false

    return Unmanaged<WrappedReference>.passUnretained(reference).toOpaque()
}

func bindingFree (_ token: UnsafeMutableRawPointer?, _ instance: UnsafeMutableRawPointer?, _ binding: UnsafeMutableRawPointer?) {
    guard let binding else { return }
    let reference = Unmanaged<WrappedReference>.fromOpaque(binding).takeUnretainedValue()

    if let obj = reference.value {
        if let handle = obj.handle {
            tableLock.withLockVoid {
                if liveFrameworkObjects.removeValue(forKey: handle) == nil {
                    _ = liveSubtypedObjects.removeValue(forKey: handle)
                }
            }
            removePendingReleaseHandle(handle)
        }
        obj.handle = nil
    } else if let instance {
        tableLock.withLockVoid {
            if liveFrameworkObjects.removeValue(forKey: instance) == nil {
                _ = liveSubtypedObjects.removeValue(forKey: instance)
            }
        }
        removePendingReleaseHandle(instance)
    } else {
        print("bindingFree: instance was nil")
    }
}
#else
func userTypeBindingCreate (_ token: UnsafeMutableRawPointer?, _ instance: UnsafeMutableRawPointer?) -> UnsafeMutableRawPointer? {
    // Godot-cpp does nothing for user types
    //print ("SWIFT: instanceBindingCreate")
    return nil
}

func userTypeBindingFree (_ token: UnsafeMutableRawPointer?, _ instance: UnsafeMutableRawPointer?, _ binding: UnsafeMutableRawPointer?) {
    if let binding {
        let reference = Unmanaged<WrappedReference>.fromOpaque(binding).takeUnretainedValue()
        guard let obj = reference.value else { return }
        let handle = obj.handle

        tableLock.withLockVoid {
            if let handle {
                let removed = liveSubtypedObjects.removeValue(forKey: handle)
                if removed == nil {
                    print ("SWIFT ERROR: attempt to release user object we were not aware of: \(obj))")
                }
            } else {
                print ("SWIFT ERROR: the object being released already had a nil handle")
            }
        }

	// If the object was queued for destruction, remove it from that queue
        if let handle {
            removePendingReleaseHandle(handle)
        }
        obj.handle = nil
    }
}

// This is invoked to take a reference on the object and ensure our Swift-land object
// does not go away while the object is in use.
func userTypeBindingReference(_ token: UnsafeMutableRawPointer?, _ binding: UnsafeMutableRawPointer?, _ reference: UInt8) -> UInt8 {
    guard let binding else { return 0 }
    let ref = Unmanaged<WrappedReference>.fromOpaque(binding).takeUnretainedValue()
    weak var refCounted = ref.value as? RefCounted

    guard let rc = refCounted?.getReferenceCount() else {
        // unreference() was called by Wrapped.deinit, so we allow the object to be destroyed.
        return 1
    }
    
    if reference != 0 {
        // In addition to a reference by SwiftGodot, Godot also retained a reference.
        if rc == 2 {
            if let refCounted, refCounted.handle != nil {
                ref.strongify()
            }
        }
    } else {
        // Only SwiftGodot holds a reference, so we make the Wrapped's deinit available.
        if rc == 1 {
            if let refCounted, refCounted.handle != nil {
                ref.weakify()
            }
        }
    }
    
    // As long as the Wrapped's deinit is not called, we do not allow the object to be destroyed.
    return 0
}

func frameworkTypeBindingReference(_ token: UnsafeMutableRawPointer?, _ binding: UnsafeMutableRawPointer?, _ reference: UInt8) -> UInt8 {
    guard let binding else { return 0 }

    let ref = Unmanaged<WrappedReference>.fromOpaque(binding).takeUnretainedValue()
    weak var refCounted = ref.value as? RefCounted
    guard let rc = refCounted?.getReferenceCount() else {
        // unreference() was called by Wrapper.deinit, so we allow the object to be destroyed.
        return 1
    }
    
    if reference != 0 {
        // In addition to a reference by SwiftGodot, Godot also retained a reference.
        if rc == 2 {
            if let refCounted, refCounted.handle != nil {
                ref.strongify()
            }
        }
    } else {
        // Only SwiftGodot holds a reference, so we make the Wrapped's deinit available.
        if rc == 1 {
            if let refCounted, refCounted.handle != nil {
                ref.weakify()
            }
        }
    }
    
    // As long as the Wrapped's deinit is not called, we do not allow the object to be destroyed.
    return 0
}

func frameworkTypeBindingCreate (_ token: UnsafeMutableRawPointer?, _ instance: UnsafeMutableRawPointer?) -> UnsafeMutableRawPointer? {
    // This is called from object_get_instance_binding
    return instance
}

func frameworkTypeBindingFree (_ token: UnsafeMutableRawPointer?, _ instance: UnsafeMutableRawPointer?, _ binding: UnsafeMutableRawPointer?) {
    if let binding {
        let reference = Unmanaged<WrappedReference>.fromOpaque(binding).takeUnretainedValue()

        if let obj = reference.value {
            let handle = obj.handle
            tableLock.withLockVoid {
                if let handle {
                    let removed = liveFrameworkObjects.removeValue(forKey: handle)
                    if removed == nil {
                        print ("SWIFT ERROR: attempt to release framework object we were not aware of: \(obj))")
                    }
                } else {
                    print ("SWIFT ERROR: the object being released already had a nil handle")
                }
            }

            // We use this opportunity to clear the handle on the object, to make sure we do not accidentally
            // invoke methods for objects that have been disposed by Godot.
            if let handle {
                removePendingReleaseHandle(handle)
            }
            obj.handle = nil
        } else if let instance {
            // For RefCounted objects, the call to `reference.value` will already be nil,
            // we can just remove the handle.
            tableLock.withLockVoid {
                let removed = liveFrameworkObjects.removeValue(forKey: instance)
                if removed == nil {
                    print ("SWIFT ERROR: attempt to release object we were not aware of: \(instance))")
                }
            }
            removePendingReleaseHandle(instance)
        } else {
            print("frameworkTypeBindingFree: instance was nil")
        }
    }
}
#endif

/// This function is called by Godot to invoke our callable, and contains our context in `userData`,
/// pointer to Variants, an argument count, and a way of returing an error.
/// We extract the arguments and call  the CallableWrapper.invoke.
func invokeWrappedCallable(wrapperPtr: UnsafeMutableRawPointer?, pargs: UnsafePointer<UnsafeRawPointer?>?, argc: Int64, retPtr: UnsafeMutableRawPointer?, err: UnsafeMutablePointer<GDExtensionCallError>?) {
    guard let wrapperPtr else { return }
    
    withArguments(pargs: pargs, argc: argc) { arguments in
        wrapperPtr
            .assumingMemoryBound(to: CallableWrapper.self)
            .pointee
            .invoke(arguments: arguments, retPtr: retPtr, err: err)
    }
}

func freeCallableWrapper(wrapperPtr: UnsafeMutableRawPointer?) {
    guard let wrapperPtr = wrapperPtr?.assumingMemoryBound(to: CallableWrapper.self) else { return }
    wrapperPtr.deinitialize(count: 1)
    wrapperPtr.deallocate()
}

struct CallableWrapper {
    let function: (borrowing Arguments) -> Variant?
        
    func invoke(arguments: borrowing Arguments, retPtr: UnsafeMutableRawPointer?, err: UnsafeMutablePointer<GDExtensionCallError>?) {
        if let methodRet = function(arguments) {
            gi.variant_new_copy(retPtr, &methodRet.content)            
        }
        err?.pointee.error = GDEXTENSION_CALL_OK
    }
    
    @available(*, deprecated, message: "Use version taking `@escaping (borrowing Arguments) -> Variant?` instead.")    
    static func callableVariantContent(wrapping function: @escaping ([Variant?]) -> Variant?) -> Callable.ContentType {
        callableVariantContent { (arguments: borrowing Arguments) in
            let array = Array(arguments)
            let result = function(array)
            return result
        }
    }
    
    static func callableVariantContent(wrapping function: @escaping (borrowing Arguments) -> Variant?) -> Callable.ContentType {
        let wrapperPtr = UnsafeMutablePointer<Self>.allocate(capacity: 1)
        wrapperPtr.initialize(to: Self(function: function))
        
        var cci = GDExtensionCallableCustomInfo(
            callable_userdata: wrapperPtr,
            token: extensionInterface.getLibrary(),
            object_id: 0,
            call_func: invokeWrappedCallable,
            is_valid_func: nil,
            free_func: freeCallableWrapper,
            hash_func: nil,
            equal_func: nil,
            less_than_func: nil,
            to_string_func: nil)
        var content: Callable.ContentType = Callable.zero
        gi.callable_custom_create(&content, &cci);
        return content
    }
}

// This is a temporary hack until we get proper WeakReference support
// so we can clear the internal dictionaries when a domain is shut down.
///
public func getActiveHandles() -> [GodotNativeObjectPointer] {
    var handles: [GodotNativeObjectPointer] = []
    for x in liveFrameworkObjects {
        handles.append(x.key)
    }
    for x in liveSubtypedObjects {
        handles.append(x.key)
    }
    return handles
}

public func clearHandles(_ handles: [GodotNativeObjectPointer]) {
    for handle in handles {
        if liveFrameworkObjects.removeValue(forKey: handle) == nil {
            liveSubtypedObjects.removeValue(forKey: handle)
        }
    }
}

/// Looks up the class at runtime
fileprivate func lookupGodotType(named className: String) -> AnyClass? {
    // The format is:
    // MODULE: LENGHT + String
    // Type: LENGHT + String
    // C
    //
    // So "SwiftGodot.Node" becomes "10SwiftGodot4NodeC":
    //
    let candidates: [String] = [
        "10SwiftGodot\(className.count)\(className)C",
        "17SwiftGodotRuntime\(className.count)\(className)C",
    ]
    for typeCode in candidates {
#if canImport(UIKit) || canImport(AppKit)
        if let ctor = NSClassFromString(typeCode) {
            return ctor
        }
#else
        if let ctor = _typeByName(typeCode) {
            return ctor as? AnyClass
        }
#endif
    }
    return nil
}
/// Find existing Godot or User `Wrapped.Type` having a `className`
func typeOfClass(named className: String) -> Object.Type? {
    if let userType = userTypes[className] {
        return userType
    }
    if let type = lookupGodotType(named: className) as? Object.Type {
        return type
    }
    return nil
}
