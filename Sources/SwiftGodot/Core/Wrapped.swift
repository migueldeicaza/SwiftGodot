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

@_implementationOnly import GDExtension

#if DEBUG_INSTANCES
import Foundation

var dbgWorkItem: DispatchWorkItem?
var pendingDbgLogs: [String] = []
var scopedDebugLog: ScopedDebugLog?

class ScopedDebugLog {
    weak var parent: ScopedDebugLog?
    
    let start = Date.now
    var duration = 0
    var children: [ScopedDebugLog] = []
    let message: String
    
    init(message: String) {
        self.message = message
        parent = scopedDebugLog
        parent?.children.append(self)
        scopedDebugLog = self
    }
    
    func finish() {
        duration = Int(Date.now.timeIntervalSince(start) * 1_000_000)
        
        if parent == nil {
            collect(0) { string in
                pendingDbgLogs.append(string)
            }
            
            pendingDbgLogs.append("")
        }
        
        scopedDebugLog = parent
    }
    
    func collect(_ depth: Int, body: (String) -> Void) {
        pendingDbgLogs.append("\(String(repeating:"-", count: depth))-\(message), in \(duration) μs")
        for child in children {
            child.collect(depth + 1, body: body)
        }
    }
}

@inline(__always)
fileprivate func dbglog(function: StaticString = #function, _ message: String) -> ScopedDebugLog {
    dbgWorkItem?.cancel()
    let item = DispatchWorkItem(block: {
        GD.print("\(pendingDbgLogs.joined(separator: "\n"))")
        pendingDbgLogs.removeAll()
    })
    
    let log = ScopedDebugLog(message: "\(function) \(message)")
        
    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0, execute: item)
    dbgWorkItem = item
    return log
}

#endif

/// This is a initialization context required for properly binding Swift and Godot world together.
/// Don't do anything with it except pass it to `super.init`
public struct InitContext {
    /// Instigator for initialization sequence
    enum Instigator {
        /// Godot constructs a Swift type from anew or lazily binds existing Godot `Object *` to Swift counterpart
        case godot
        
        /// Object is created by Swift code, aka `let obj = Object()`
        case swift
    }
    
    /// Opaque Godot Object pointer: `Object *`
    let pNativeObject: GDExtensionObjectPtr
    
    let instigator: Instigator
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
    /// Opaque Godot `Object *`
    var pNativeObject: GDExtensionObjectPtr?
    
    // ``ObjectBox`` managing this `Wrapped` instance
    weak var box: ObjectBox?
    
    public static var fcallbacks = OpaquePointer(UnsafeRawPointer(&Wrapped.frameworkTypeBindingCallback))
    public static var ucallbacks = OpaquePointer(UnsafeRawPointer(&Wrapped.userTypeBindingCallback))
    public static var deferred: Callable? = nil
    
    public static func == (lhs: Wrapped, rhs: Wrapped) -> Bool {
        return lhs.pNativeObject == rhs.pNativeObject
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(pNativeObject)
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
    
    func assertValidity() {
        if !isValid {
            fatalError("\(Self.self).pNativeObject is nil, which indicates the object was cleared by Godot")
        }
    }
    
    class func getVirtualDispatcher(name: StringName) ->  GDExtensionClassCallVirtual? {
        #if DEBUG_INSTANCES
        dbglog("reached Wrapped from \(self)")
            .finish()
        #endif
        return nil
    }

    deinit {
        #if DEBUG_INSTANCES
        let log = dbglog("\(Self.self)")
        defer { log.finish() }
        #endif
        if let pNativeObject {
            guard extensionInterface.objectShouldDeinit(handle: pNativeObject) else { return }

            if self is RefCounted {
                var queue = false
                freeLock.withLockVoid {
                    if Wrapped.deferred == nil {
                        Wrapped.deferred = Callable ({ (args: borrowing Arguments) in
                            releasePendingObjects()
                            return nil
                        })
                    }
                    pendingReleaseHandles.append(pNativeObject)
                    if pendingReleaseHandles.count == 1 {
                        queue = true
                    }
                }
                if queue {
                    Wrapped.deferred?.callDeferred()
                }
            }
        }
        extensionInterface.objectDeinited(object: self)
    }
    
    static var userTypeBindingCallback = GDExtensionInstanceBindingCallbacks(
        create_callback: userTypeBindingCreate,
        free_callback: userTypeBindingFree,
        reference_callback: userTypeBindingReference)

    static var frameworkTypeBindingCallback = GDExtensionInstanceBindingCallbacks(
        create_callback: frameworkTypeBindingCreate,
        free_callback: frameworkTypeBindingFree,
        reference_callback: frameworkTypeBindingReference)

    /// Returns the Godot's class name as a `StringName`, returns the empty string on error
    public var godotClassName: StringName {
        var sc: StringName.ContentType = StringName.zero
        
        if gi.object_get_class_name(pNativeObject, extensionInterface.getLibrary(), &sc) != 0 {
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
    public func hasScript(method: StringName) -> Bool {
        gi.object_has_script_method(pNativeObject, &method.content) != 0
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
        gi.object_call_script_method(&pNativeObject, &method.content, &args, Int64(args.count), &result, &error)
        if error.error != GDEXTENSION_CALL_OK {
            throw toCallErrorType(error.error)
        }
        
        return Variant(takingOver: result)
    }
        
    public required init(_ initContext: InitContext) {
        #if DEBUG_INSTANCES
        let log = dbglog("\(Self.self)")
        defer {
            log.finish()
        }
        #endif
        pNativeObject = initContext.pNativeObject
        extensionInterface.objectInited(object: self)
        
        guard let object = self as? Object else {
            fatalError("Wrapped can not be constructed directly")
        }
        
        bindSwiftObject(object, initContext: initContext)
    }
    
    /// This property indicates if the instance is valid or not.
    ///
    /// In Godot, some objects can be freed manually, and in particular
    /// when you call the ``Node/queueFree()`` which might queue the object
    /// for disposal
    public var isValid: Bool {
        return pNativeObject != nil
    }

    /// Use this to release objects that are neither Nodes or RefCounted subclasses.
    ///
    /// To release a ``Node`` or a Node subclass, call ``Node.queueFree()``,
    /// ``RefCounted`` objects are destroyed automatically when the last reference
    /// is gone, so it is not necessary to call ``free`` on those.
    public func free() {
        guard !(self is Node) else {
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

        gi.object_destroy(pNativeObject)
    }
    
    open class var godotClassName: StringName {
        fatalError("Subclasses of Wrapped must override godotClassName")
    }
    
    open class var classInitializer: Void { () }
}

extension _GodotBridgeable where Self: Object {
    /// Initialize a new instance
    ///
    /// ### Internal note
    /// Swift-registered types constructed from within Godot do not go via this path. See `bindGDExtensionObject` instead
    public init() {
        #if DEBUG_INSTANCES
        let log = dbglog("\(Self.self)")
        defer {
            log.finish()
        }
        #endif
        
        let _ = Self.classInitializer
        
        guard let pNativeObject = gi.classdb_construct_object(&Self.godotClassName.content) else {
            fatalError("SWIFT: It was not possible to construct a \(Self.godotClassName.description)")
        }
        
        let initContext = InitContext(pNativeObject: pNativeObject, instigator: .swift)
        self.init(initContext)
    }
}


/// Bind Godot `Object *` with Swift `instance`.
@discardableResult
func bindSwiftObject(_ swiftObject: some Object, initContext: InitContext) {
    #if DEBUG_INSTANCES
    let log = dbglog("\(type(of: swiftObject))")
    defer {
        log.finish()
    }
    #endif
    let pNativeObject = initContext.pNativeObject
    
    let name = swiftObject.godotClassName
        
    let thisTypeName = StringName(stringLiteral: String(describing: Swift.type(of: swiftObject)))
    let frameworkType = thisTypeName == name
    
    var callbacks: GDExtensionInstanceBindingCallbacks
    if frameworkType {
        callbacks = Wrapped.frameworkTypeBindingCallback
    } else {
        callbacks = Wrapped.userTypeBindingCallback
    }

    let box: ObjectBox
    if let refCounted = swiftObject as? RefCounted, refCounted.getReferenceCount() <= 1 {
        box = ObjectBox(swiftObject, strong: false)
    } else {
        box = ObjectBox(swiftObject, strong: true)
    }

    tableLock.withLockVoid {
        if frameworkType {
            liveFrameworkObjects[pNativeObject] = box
        } else {
            liveSubtypedObjects[pNativeObject] = box
        }
    }

    let unmanaged = Unmanaged<ObjectBox>.passUnretained(box)

    // This I believe should only be set for user subclasses, and not anything else.
    if frameworkType {
        //dbglog("Skipping object registration, this is a framework type")
    } else {
        //dbglog("Registering instance with Godot")
        // Retain an additional unmanaged reference that will be released in freeFunc().
        #if DEBUG_INSTANCES
        let log = dbglog("object_set_instance GDExtensionObjectPtr(\(pNativeObject)) → \(type(of: swiftObject))(\(Unmanaged.passUnretained(swiftObject).toOpaque()))")
        defer {
            log.finish()
        }
        #endif
        withUnsafePointer(to: &thisTypeName.content) { pClassName in
            gi.object_set_instance(pNativeObject, pClassName, unmanaged.retain().toOpaque())
        }
    }
    #if DEBUG_INSTANCES
    let bindingLog = dbglog("object_set_instance_binding GDExtensionObjectPtr(\(pNativeObject)) → \(type(of: swiftObject))(\(Unmanaged.passUnretained(swiftObject).toOpaque()))")
    defer {
        bindingLog.finish()
    }
    #endif
    gi.object_set_instance_binding(pNativeObject, extensionInterface.getLibrary(), unmanaged.toOpaque(), &callbacks)
    
    swiftObject.box = box
}

var userTypes: [String: Object.Type] = [:]

// @_spi(SwiftGodotTesting) public
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

    func getVirtualFunc(_ userData: UnsafeMutableRawPointer?, _ name: GDExtensionConstStringNamePtr?) -> GDExtensionClassCallVirtual? {
        let typeAny = Unmanaged<AnyObject>.fromOpaque(userData!).takeUnretainedValue()
        guard let type  = typeAny as? Object.Type else {
            #if DEBUG_INSTANCES
            dbglog("The wrapped value did not contain a type: \(typeAny)")
                .finish()
            #endif
            return nil
        }
        return type.getVirtualDispatcher(name: StringName(fromPtr: name))
    }
    
    var info = GDExtensionClassCreationInfo2()
    info.create_instance_func = createInstanceFunc(_:)
    info.free_instance_func = freeInstanceFunc(_:_:)
    info.get_virtual_func = getVirtualFunc
    info.notification_func = notificationFunc
    info.recreate_instance_func = recreateInstanceFunc
    info.validate_property_func = validatePropertyFunc
    info.is_exposed = 1
    
    userTypes[name.description] = T.self
    
    let retained = Unmanaged<AnyObject>.passRetained(type as AnyObject)
    info.class_userdata = retained.toOpaque()
    
    withUnsafePointer(to: &parent.content) { parentPtr in
        gi.classdb_register_extension_class(extensionInterface.getLibrary(), &nameContent, parentPtr, &info)
    }
}

final class ObjectBox {
    init(_ object: Object, strong: Bool = true) {
        self.object = object
        if strong {
            strongify()
        }
    }
    
    deinit {
        weakify()
    }
    
    func strongify() -> Self {
        if strong {
            return self
        }
        if let object {
            Unmanaged<Object>.passUnretained(object).retain()
        }
        strong = true
        return self
    }
    
    func weakify() -> Self {
        if !strong {
            return self
        }
        if let object {
            Unmanaged<Object>.passUnretained(object).release()
        }
        strong = false
        return self
    }
    
    func isStrong() -> Bool {
        return strong
    }
    
    private(set) weak var object: Object?
    private var strong: Bool = false
}

/// Registers the user-type specified with the Godot system, and allows it to
/// receive any of the calls from Godot virtual methods (those that are prefixed
/// with an underscore)
public func register<T: Object>(type: T.Type) {
    guard let superType = Swift._getSuperclass(type) else {
        print ("You can not register the root class")
        return
    }
    let typeStr = String (describing: type)
    let superStr = String(describing: superType)
    register(type: StringName (typeStr), parent: StringName (superStr), type: type)
}

public func unregister<T: Object>(type: T.Type) {
    let typeStr = String (describing: type)
    let name = StringName (typeStr)
    #if DEBUG_INSTANCES
    dbglog("Unregistering \(typeStr)")
        .finish()
    #endif
    withUnsafePointer (to: &name.content) { namePtr in
        gi.classdb_unregister_extension_class (extensionInterface.getLibrary(), namePtr)
    }
}

/// Currently contains all instantiated objects, but might want to separate those
/// (or find a way of easily telling appart) framework objects from user subtypes
var liveFrameworkObjects: [GDExtensionObjectPtr: ObjectBox] = [:]
var liveSubtypedObjects: [GDExtensionObjectPtr: ObjectBox] = [:]

public func printSwiftGodotStats() {
    print("User types: \(userTypes.count)")
    print("Framework: \(liveFrameworkObjects.count)")
    print("LiveSubTyped: \(liveSubtypedObjects.count)")

}

// Lock for accessing the above
var tableLock = NIOLock()

// Lock for the pending free list
var freeLock = NIOLock()
var pendingReleaseHandles: [UnsafeRawPointer] = []

/// Use this function to force the disposing of any objects that were queued for destruction
/// this is called automatically by Godot's main loop iteration, but it is expose for the sake
/// of the test suite that wants to release objects without waiting for Godot to run the queue
public func releasePendingObjects() {
    var result: Bool = false
    var copy: [UnsafeRawPointer] = []

    freeLock.withLock {
        copy = pendingReleaseHandles
        pendingReleaseHandles = []
    }
    for handle in copy {
        gi.object_method_bind_ptrcall(RefCounted.method_unreference, UnsafeMutableRawPointer(mutating: handle), nil, &result)
        if result {
            gi.object_destroy(UnsafeMutableRawPointer(mutating: handle))
        }
    }
}

func existingSwiftObject(boundTo pNativeObject: GDExtensionObjectPtr) -> Wrapped? {
    tableLock.withLock {
        if let o = (liveFrameworkObjects[pNativeObject]?.object ?? liveSubtypedObjects[pNativeObject]?.object) {
            return o
        }
        
        return nil
    }
}

/// See `harmonizeReferenceCounting` for details
enum RefTransferMode {
    /// Value is Godot `Ref<>`.
    case owned
    
    /// Value is raw `Object *`
    case unowned
    
    /// Value is Godot singleton
    case singleton
}

/// The following function makes the reference count of RefCounted objects consistent
/// with the semantics of Godot.
///
/// ### Rationale
/// - Every time godot returns a `RefCounted` object in a `Ref<>` wrapper for a ptrcall,
/// its reference count is incremeneted. As object identity results in the return of
/// the same Swift proxy for the same `RefCounted` object, this means that every subsequent
/// return should result in an `unreference()` call, so that the existence of the Swift proxy
/// object always results in a single increment of the reference count.
/// - On the other hand, if a `RefCounted` object was returned through a non`RefCounted`
/// static return type (e.g. as an `Object`), then Godot did not increment its reference
/// count. This means that on the first return of such an object, the reference count
/// should be incremented by a `reference()` call, so that similarly the existence of
/// the Swift proxy object always results in a single increment of the reference count.
/// - The `mode` parameter specifies if Godot can pass ownership of a Ref<> wrapper to
/// SwiftGodot, e.g. with a Ref<> return value of a ptrcall.
func harmonizeReferenceCounting<T: Wrapped>(
    staticType: T.Type,
    object: Wrapped,
    mode: RefTransferMode,
    unref: Bool
) {
    switch mode {
    case .unowned, .singleton:
        if !unref {
            if let refCounted = object as? RefCounted {
                refCounted.reference()
            }
        }
    case .owned:
        if let refCounted = object as? RefCounted {
            if staticType is RefCounted.Type {
                if unref {
                    refCounted.unreference()
                }
            } else {
                if !unref {
                    refCounted.reference()
                }
            }
        }
    }
}

func getOrInitSwiftObject<T>(
    ofType type: T.Type = T.self,
    boundTo pNativeObject: GDExtensionObjectPtr?,
    mode: RefTransferMode
) -> T? where T: Object {
    guard let pNativeObject else {
        return nil
    }
    
    if let swiftObject = existingSwiftObject(boundTo: pNativeObject) {
        harmonizeReferenceCounting(staticType: T.self, object: swiftObject, mode: mode, unref: true)
        return swiftObject as? T
    }
    
    var className: String = ""
    var sc: StringName.ContentType = StringName.zero
            
    if gi.object_get_class_name(pNativeObject, extensionInterface.getLibrary(), &sc) != 0 {
        let sn = StringName(content: sc)
        className = String(sn)
    } else {
        let _result: GString = GString()
        gi.object_method_bind_ptrcall(Object.method_get_class, pNativeObject, nil, &_result.content)
        className = _result.description
    }
    
    if let frameworkType = godotFrameworkCtors[className] {
        let result = frameworkType.init(InitContext(pNativeObject: pNativeObject, instigator: .godot))
        harmonizeReferenceCounting(staticType: T.self, object: result, mode: mode, unref: false)
        return result as? T
    }
    
    if let userType = userTypes[className] {
        let created = userType.init(InitContext(pNativeObject: pNativeObject, instigator: .godot))
        harmonizeReferenceCounting(staticType: T.self, object: created, mode: mode, unref: false)
        if let result = created as? T {
            return result
        } else {
            GD.print("Found a custom type for \(className) but the constructor failed to return an instance of it as a \(T.self)")
        }
    }

    let result = T(InitContext(pNativeObject: pNativeObject, instigator: .godot))
    harmonizeReferenceCounting(staticType: T.self, object: result, mode: mode, unref: false)
    return result
}

/// Path for Godot constructing a `Swift` type.
/// - A Swift object is initialized
/// - `ObjectBox` managing it is created and `strongify`-ed to avoid it being immediately destroyed after the scope ends
func initSwiftObject(ofType metatype: Object.Type, boundTo pNativeObject: GDExtensionObjectPtr) {
    #if DEBUG_INSTANCES
    let log = dbglog("\(metatype) GDExtensionObjectPtr(\(pNativeObject))")
    defer {
        log.finish()
    }
    #endif
    
    _ = metatype.classInitializer
    
    let initContext = InitContext(pNativeObject: pNativeObject, instigator: .godot)
    let swiftObject = metatype.init(initContext)        
        
    extensionInterface.objectInited(object: swiftObject)
        
    guard let box = swiftObject.box else {
        fatalError("\(swiftObject) should have a non-nil `box` after initialization")
    }

    /// We need to ask `box` to retain `swiftObject`, otherwise it will be immediately destroyed after this function ends
    box.strongify()
}

///
/// This one is invoked by Godot when an instance of one of our types is created, and we need
/// to instantiate it.   Notice that this is different that direct instantiation from our API
///
func createInstanceFunc(_ userData: UnsafeMutableRawPointer?) -> GDExtensionObjectPtr? {
    //print ("SWIFT: Creating object userData:\(String(describing: userData))")
    guard let userData else {
        print("SwiftGodot.createFunc: Got a nil userData")
        return nil
    }
    
    let metatype = Unmanaged<AnyObject>.fromOpaque(userData).takeUnretainedValue()
    guard let metatype = metatype as? Object.Type else {
        print("SwiftGodot.createFunc: The wrapped value did not contain a type: \(metatype)")
        return nil
    }
    
    #if DEBUG_INSTANCES
    let log = dbglog("\(metatype)")
    defer {
        log.finish()
    }
    #endif

    guard let pNativeObject = gi.classdb_construct_object(&metatype.godotClassName.content) else {
        fatalError("SWIFT: It was not possible to construct a \(metatype.godotClassName.description)")
    }
    
    initSwiftObject(ofType: metatype, boundTo: pNativeObject)
    
    return pNativeObject
}

func recreateInstanceFunc(_ userData: UnsafeMutableRawPointer?, pNativeObject: GDExtensionObjectPtr?) -> UnsafeMutableRawPointer? {
    guard let pNativeObject else {
        return nil
    }
        
    guard let userData else {
        print("Got a nil userData")
        return nil
    }
    
    let metatype = Unmanaged<AnyObject>.fromOpaque(userData).takeUnretainedValue()
    
    guard let metatype = metatype as? Object.Type else {
        print("SwiftGodot.recreateFunc: The wrapped value does not contain a known type: \(metatype)")
        return nil
    }
    
    #if DEBUG_INSTANCES
    let log = dbglog("\(metatype)")
    defer {
        log.finish()
    }
    #endif
    
    initSwiftObject(ofType: metatype, boundTo: pNativeObject)
    
    return pNativeObject
}

//
// This is invoked to release any Subtyped objects we created
//
func freeInstanceFunc(_ userData: UnsafeMutableRawPointer?, _ objectHandle: UnsafeMutableRawPointer?) {
    guard let userData else {
        fatalError("userData is nil")
    }
    
    let metatype = Unmanaged<AnyObject>.fromOpaque(userData).takeUnretainedValue()
    guard let metatype = metatype as? Object.Type else {
        fatalError("userData is not an Object.Type, but \(metatype)")
    }

    guard let objectHandle else { return }
    
    #if DEBUG_INSTANCES
    dbglog("\(metatype) ObjectBox(\(objectHandle))")
        .finish()
    #endif
    // Release the unmanaged reference that was retained in bindSwiftObject()
    Unmanaged<ObjectBox>.fromOpaque(objectHandle).release()
}

func notificationFunc (ptr: UnsafeMutableRawPointer?, code: Int32, reversed: UInt8) {
    guard let ptr else { return } 
    let original = Unmanaged<ObjectBox>.fromOpaque(ptr).takeUnretainedValue()
    guard let instance = original.object else { return }
    instance._notification(code: Int(code), reversed: reversed != 0)
}

func validatePropertyFunc(ptr: UnsafeMutableRawPointer?, _info: UnsafeMutablePointer<GDExtensionPropertyInfo>?) -> UInt8 {
    guard let ptr else { return 0 }
    let original = Unmanaged<ObjectBox>.fromOpaque(ptr).takeUnretainedValue()
    guard let instance = original.object else { return 0 }
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
        let native = pinfo.makeNativeStruct()
        _info?.pointee.usage = UInt32(pinfo.usage.rawValue)
        _info?.pointee.hint = UInt32(pinfo.hint.rawValue)
        _info?.pointee.type = GDExtensionVariantType(GDExtensionVariantType.RawValue (pinfo.propertyType.rawValue))

        return 1
    }
    return 0
}

func userTypeBindingCreate(_ token: UnsafeMutableRawPointer?, _ instance: UnsafeMutableRawPointer?) -> UnsafeMutableRawPointer? {
    // Godot-cpp does nothing for user types
    //print ("SWIFT: instanceBindingCreate")
    return nil
}

func userTypeBindingFree(_ token: UnsafeMutableRawPointer?, _ instance: GDExtensionObjectPtr?, _ binding: UnsafeMutableRawPointer?) {
    if let binding {
        let box = Unmanaged<ObjectBox>.fromOpaque(binding).takeUnretainedValue()
        
        guard let swiftObject = box.object else { return }

        tableLock.withLockVoid {
            if let pNativeObject = swiftObject.pNativeObject {
                let removed = liveSubtypedObjects.removeValue(forKey: pNativeObject)
                if removed == nil {
                    print("SWIFT ERROR: attempt to release user object we were not aware of: \(swiftObject))")
                }
            } else {
                print("SWIFT ERROR: the object being released already had a nil handle")
            }
        }

        // We use this opportunity to clear the handle on the object, to make sure we do not accidentally
        // invoke methods for objects that have been disposed by Godot.
        swiftObject.pNativeObject = nil
    }
}

// This is invoked to take a reference on the object and ensure our Swift-land object
// does not go away while the object is in use.
func userTypeBindingReference(_ token: UnsafeMutableRawPointer?, _ binding: UnsafeMutableRawPointer?, _ reference: UInt8) -> UInt8 {
    #if DEBUG_INSTANCES
    let log = dbglog("token: \(token), binding: \(binding), reference: \(reference)")
    defer {
        log.finish()
    }
    #endif
    guard let binding else { return 0 }
    let box = Unmanaged<ObjectBox>.fromOpaque(binding).takeUnretainedValue()
    weak var refCounted = box.object as? RefCounted

    guard let rc = refCounted?.getReferenceCount() else {
        // unreference() was called by Wrapped.deinit, so we allow the object to be destroyed.
        return 1
    }
    
    if reference != 0 {
        // In addition to a reference by SwiftGodot, Godot also retained a reference.
        if rc == 2 {
            if let refCounted, refCounted.pNativeObject != nil {
                box.strongify()
            }
        }
    } else {
        // Only SwiftGodot holds a reference, so we make the Wrapped's deinit available.
        if rc == 1 {
            if let refCounted, refCounted.pNativeObject != nil {
                box.weakify()
            }
        }
    }
    
    // As long as the Wrapped's deinit is not called, we do not allow the object to be destroyed.
    return 0
}

func frameworkTypeBindingReference(_ token: UnsafeMutableRawPointer?, _ binding: UnsafeMutableRawPointer?, _ reference: UInt8) -> UInt8 {
    guard let binding else { return 0 }

    let ref = Unmanaged<ObjectBox>.fromOpaque(binding).takeUnretainedValue()
    weak var refCounted = ref.object as? RefCounted
    guard let rc = refCounted?.getReferenceCount() else {
        // unreference() was called by Wrapper.deinit, so we allow the object to be destroyed.
        return 1
    }
    
    if reference != 0 {
        // In addition to a reference by SwiftGodot, Godot also retained a reference.
        if rc == 2 {
            if let refCounted, refCounted.pNativeObject != nil {
                ref.strongify()
            }
        }
    } else {
        // Only SwiftGodot holds a reference, so we make the Wrapped's deinit available.
        if rc == 1 {
            if let refCounted, refCounted.pNativeObject != nil {
                ref.weakify()
            }
        }
    }
    
    // As long as the Wrapped's deinit is not called, we do not allow the object to be destroyed.
    return 0
}

func frameworkTypeBindingCreate(_ token: UnsafeMutableRawPointer?, _ instance: UnsafeMutableRawPointer?) -> UnsafeMutableRawPointer? {
    // This is called from object_get_instance_binding
    return instance
}

func frameworkTypeBindingFree(_ token: UnsafeMutableRawPointer?, _ instance: UnsafeMutableRawPointer?, _ binding: UnsafeMutableRawPointer?) {
    if let binding {
        let box = Unmanaged<ObjectBox>.fromOpaque(binding).takeUnretainedValue()

        if let swiftObject = box.object {
            tableLock.withLockVoid {
                if let pNativeObject = swiftObject.pNativeObject {
                    let removed = liveFrameworkObjects.removeValue(forKey: pNativeObject)
                    if removed == nil {
                        print("SWIFT ERROR: attempt to release framework object we were not aware of: \(pNativeObject))")
                    }
                } else {
                    print("SWIFT ERROR: the object being released already had a nil handle")
                }
            }

            // We use this opportunity to clear the handle on the object, to make sure we do not accidentally
            // invoke methods for objects that have been disposed by Godot.
            swiftObject.pNativeObject = nil
        } else if let instance {
            // For RefCounted objects, the call to `reference.value` will already be nil,
            // we can just remove the handle.
            tableLock.withLockVoid {
                let removed = liveFrameworkObjects.removeValue(forKey: instance)
                if removed == nil {
                    print("SWIFT ERROR: attempt to release object we were not aware of: \(instance))")
                }
            }
        } else {
            print("frameworkTypeBindingFree: instance was nil")
        }
    }
}

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
public func getActiveHandles() -> ([UnsafeMutableRawPointer]) {
    var handles: [UnsafeMutableRawPointer] = []
    
    for x in liveFrameworkObjects {
        handles.append(x.key)
    }
    for x in liveSubtypedObjects {
        handles.append(x.key)
    }
    
    return handles
}

public func clearHandles(_ handles: [UnsafeMutableRawPointer]) {
    for handle in handles {
        if liveFrameworkObjects.removeValue(forKey: handle) == nil {
            liveSubtypedObjects.removeValue(forKey: handle)
        }
    }
}

/// Find existing Godot or User `Wrapped.Type` having a `className`
func typeOfClass(named className: String) -> Object.Type? {
    if let frameworkType = godotFrameworkCtors[className] {
        return frameworkType
    }
    
    if let userType = userTypes[className] {
        return userType
    }
    
    return nil
}
