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
// We recognize the difference between objects that are merely proxies to
// the Godot API, and act as bridges, but whose entire state resides in
// the Godot land, and we call those FrameworkTypes vs types that the user
// has subclassed and might have potentially added state that needs to be
// preserved.
//
// FrameworkTypes are recreated on demand if necessary from their handle
// as they are only a proxy for the Godot side of the code, there is no
// harm in creating different copies of it, and destroying them when they
// are no longer in use.   To support identity, we implement Equatable
// based on their handles.
//
// Subclassed types are those that the user might have created, and could
// potentially keep state, so we need to keep those objects alive until
// they are destroyed, and when the framework surfaces objects of this
// type, we need to find and locate the existing live object, rather than
// returning a new instance
//
// We ensure that all Godot

@_implementationOnly import GDExtension

func pd (_ str: String) {
    #if false
    print ("SwiftGodot: \(str)")
    #endif
}
#if DEBUG_INSTANCES
var xmap: [UnsafeRawPointer: String] = [:]
#endif

///
/// The base class for all class bindings in Godot, you should not have
/// to instantiate or subclass this class directly - there are better options
/// in the hierarchy.
///
/// Wrapped implements Equatable based on an identity based on the
/// pointer to the Godot native object and also implements the Identifiable
/// protocol using this pointer.
///
/// Wrapped subclasses come in two forms: straight bindings to the Godot
/// API which are used to expose capabilities to developers.   These objects, referred
/// to as Framework types do not have any additional state associated in
/// Swift, so they can be discarded or recreated as many times as it is needed.
///
/// When user subclass Wrapped, they might have state associated with them,
/// so those objects are preserved and are not thrown away until they are
/// explicitly relinquished by both Godot and any references you might hold to
/// them.   These are known as User types.
///
/// Any subclass ends up calling the Wrapped(StringName) constructor which
/// provides the name of the most-derived framework type, and this constructor
/// determines whether this is a Framework type or a user type.
///
/// To register User types with the framework make sure you call the
/// `register<T:Wrapped> (type: T.Type)` method like this:
///
/// `register (type: MySpinningCube.self)`
///
/// If you do not call this method, many of the overloads that Godot would
/// call you back on will not be invoked.
open class Wrapped: Equatable, Identifiable, Hashable {
    /// Points to the underlying object
    public var handle: UnsafeRawPointer?
    /// If this is true, we created the object, and we are responsible for its lifecyle, otherwise, we are not
    /// like when objects are surfaced from Godot-land, and all we do is provide a convenience to access
    /// it.
    var ownsHandle: Bool
    public static var fcallbacks = OpaquePointer (UnsafeRawPointer (&Wrapped.frameworkTypeBindingCallback))
    public static var ucallbacks = OpaquePointer (UnsafeRawPointer (&Wrapped.userTypeBindingCallback))
    
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

    class func getVirtualDispatcher(name: StringName) ->  GDExtensionClassCallVirtual? {
        pd ("SWARN: getVirtualDispatcher (\"\(name)\") reached Wrapped on class \(self)")
        return nil
    }

    deinit {
        if ownsHandle {
            if let handle {
#if DEBUG_INSTANCES
                let type = xmap[handle] ?? "unknown"
                let txt = "DEINIT for object=\(type) handle=\(handle)"
#endif

                if let res = self as? RefCounted {
                    if res.unreference() {
#if DEBUG_INSTANCES
                        print ("\(txt): dropped to zero, destroying rc=\(res.getReferenceCount())")
#endif
                        gi.object_destroy(UnsafeMutableRawPointer(mutating: handle))
                    } else {
#if DEBUG_INSTANCES
                        print ("\(txt): Unreferenced, but still have instances alive rc=\(res.getReferenceCount())")
#endif
                    }
                } else {
                    if let node = self as? Node {
                        // TODO: I seem to recall that Nodes that are added to a scene are managed by the scene
                        // and they are owned by the scene.   I do indeed not get leaks from those.
                        //
                        // The question is whether I should delete Nodes that were not added to a scene, and
                        // destroy them here, and if so, what is the criteria to do so - is it purely
                        // Node.getTree() returning nil an indicator that this is a loose node?
#if DEBUG_INSTANCES
                        print ("\(txt) is a node, Godot will release")
#endif
                    } else {
                        #if DEBUG_INSTANCES
                        print ("\(txt) plain object, destroying")
                        #endif
                        gi.object_destroy(UnsafeMutableRawPointer(mutating: handle))
                    }
                }
            }
        } else {
#if DEBUG_INSTANCES
            let txt: String
            if let handle {
                txt = xmap[handle] ?? "unknown"
            } else {
                txt = "NIL"
            }
            print ("deinit: we do not own this object, nothing to do: object=\(txt) handle=\(handle)")
#endif
        }
    }
    static var userTypeBindingCallback = GDExtensionInstanceBindingCallbacks(
        create_callback: userTypeBindingCreate,
        free_callback: userTypeBindingFree,
        reference_callback: userTypeBindingReference)

    static var frameworkTypeBindingCallback = GDExtensionInstanceBindingCallbacks(
        create_callback: frameworkTypeBindingCreate,
        free_callback: frameworkTypeBindingFree,
        reference_callback: nil) // frameworkTypeBindingReference)


    /// Returns the Godot's class name as a `StringName`, returns the empty string on error
    public var godotClassName: StringName {
        var sc: StringName.ContentType = StringName.zero
        
        if gi.object_get_class_name (handle, library, &sc) != 0 {
            let sn = StringName(content: sc)
            return sn
        }
        return ""
    }
    
    /// For use by the framework, you should not need to call this.
    public required init (nativeHandle: UnsafeRawPointer) {
        handle = nativeHandle
        ownsHandle = false
#if DEBUG_INSTANCES
        xmap [nativeHandle] = "\(self)"
        print ("Init Object From Handle: \(nativeHandle) -> \(self)")
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

    /// The constructor chain that uses StringName is internal, and is triggered
    /// when a class is initialized with the empty constructor - this means that
    /// subclasses will have a different name than the subclass.
    public required init () {
        guard let godotObject = bindingObject ?? gi.classdb_construct_object (&Self.godotClassName.content) else {
            fatalError("SWIFT: It was not possible to construct a \(Self.godotClassName.description)")
        }
        bindingObject = nil
        ownsHandle = true
        let handle = UnsafeRawPointer(godotObject)
        self.handle = handle
#if DEBUG_INSTANCES
        xmap[handle] = "\(Self.godotClassName.description)"
        if xmap[handle] == "InputEventMouseMotion" {
            print ("Fuck")
        }
#endif
        bindGodotInstance(instance: self, handle: handle)
        let _ = Self.classInitializer
    }
    
    open class var godotClassName: StringName {
        fatalError("Subclasses of Wrapped must override godotClassName")
    }
    
    open class var classInitializer: Void { () }
}
    
func bindGodotInstance(instance: some Wrapped, handle: UnsafeRawPointer) {
    let name = instance.self.godotClassName

    // TODO: what happens if the user subclasses but the name conflicts with the Godot type?
    // say "class Sprite2D: Godot.Sprite2D"
    let thisTypeName = StringName (stringLiteral: String (describing: Swift.type(of: instance)))
    let frameworkType = thisTypeName == name
    let retain = frameworkType ? Unmanaged.passUnretained(instance) : Unmanaged.passRetained(instance)

    // This I believe should only be set for user subclasses, and not anything else.
    if frameworkType {
        //pd ("Skipping object registration, this is a framework type")
    } else {
        //pd ("Registering instance with Godot")
        withUnsafeMutablePointer(to: &thisTypeName.content) { ptr in
            gi.object_set_instance (UnsafeMutableRawPointer (mutating: handle),
                                    ptr, retain.toOpaque())
        }
    }
    
    var callbacks: GDExtensionInstanceBindingCallbacks
    if frameworkType {
        callbacks = Wrapped.frameworkTypeBindingCallback
    } else {
        callbacks = Wrapped.userTypeBindingCallback
    }
    tableLock.withLockVoid {
        if frameworkType {
            // Speed optimization, I do not think that we need this
            //liveFrameworkObjects [handle] = instance
        } else {
            liveSubtypedObjects [handle] = instance
        }
    }
    
    gi.object_set_instance_binding(UnsafeMutableRawPointer (mutating: handle), token, retain.toOpaque(), &callbacks)
}

var userTypes: [String:(UnsafeRawPointer)->Wrapped] = [:]

func register<T:Wrapped> (type name: StringName, parent: StringName, type: T.Type) {
    func getVirtual(_ userData: UnsafeMutableRawPointer?, _ name: GDExtensionConstStringNamePtr?) ->  GDExtensionClassCallVirtual? {
        let typeAny = Unmanaged<AnyObject>.fromOpaque(userData!).takeUnretainedValue()
        guard let type  = typeAny as? Wrapped.Type else {
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
    info.is_exposed = 1
    userTypes [name.description] = { ptr in
        return type.init(nativeHandle: ptr)
    }
    
    let retained = Unmanaged<AnyObject>.passRetained(type as AnyObject)
    info.class_userdata = retained.toOpaque()
    
    withUnsafePointer(to: &name.content) { namePtr in
        withUnsafePointer(to: &parent.content) { parentPtr in
            gi.classdb_register_extension_class (library, namePtr, parentPtr, &info)
        }
    }
}

/// Registers the user-type specified with the Godot system, and allows it to
/// receive any of the calls from Godot virtual methods (those that are prefixed
/// with an underscore)
public func register<T:Wrapped> (type: T.Type) {
    guard let superType = Swift._getSuperclass (type) else {
        print ("You can not register the root class")
        return
    }
    let typeStr = String (describing: type)
    let superStr = String(describing: superType)
    register (type: StringName (typeStr), parent: StringName (superStr), type: type)
}

public func unregister<T:Wrapped> (type: T.Type) {
    let typeStr = String (describing: type)
    let name = StringName (typeStr)
    pd ("Unregistering \(typeStr)")
    withUnsafePointer (to: &name.content) { namePtr in
        gi.classdb_unregister_extension_class (library, namePtr)
    }
}

/// Currently contains all instantiated objects, but might want to separate those
/// (or find a way of easily telling appart) framework objects from user subtypes
var liveFrameworkObjects: [UnsafeRawPointer:Wrapped] = [:]
var liveSubtypedObjects: [UnsafeRawPointer:Wrapped] = [:]

// Lock for accessing the above
var tableLock = NIOLock()

// If not-nil, we are in the process of serially re-creating objects from Godot,
// this contains the handle to use, and prevents a new Godot object peer to
// be created
fileprivate var bindingObject: UnsafeMutableRawPointer? = nil
 
 ///
 /// Looks into the liveSubtypedObjects table if we have an object registered for it,

///
/// Looks into the liveSubtypedObjects table if we have an object registered for it,
/// and if we do, we returned that existing instance.
///
/// The idioms is that we only need to look up subtyped objects, because those
/// are the only ones that would keep state
func lookupLiveObject (handleAddress: UnsafeRawPointer) -> Wrapped? {
    tableLock.withLock {
        return liveSubtypedObjects [handleAddress]
    }
}

///
/// Looks into the liveSubtypedObjects table if we have an object registered for it,
/// and if we do, we returned that existing instance.
///
/// We are surfacing this, so that when we recreate an object resurfaced in a collection
/// we do not get the base type, but the most derived one
func lookupFrameworkObject (handleAddress: UnsafeRawPointer) -> Wrapped? {
    tableLock.withLock {
        return liveFrameworkObjects [handleAddress]
    }
}

func objectFromHandle (nativeHandle: UnsafeRawPointer) -> Wrapped? {
    tableLock.withLock {
        if let o = (liveFrameworkObjects [nativeHandle] ?? liveSubtypedObjects [nativeHandle]) {
            return o
        }
        
        return nil
    }
}

func lookupObject<T:GodotObject> (nativeHandle: UnsafeRawPointer) -> T? {
    if let a = objectFromHandle(nativeHandle: nativeHandle) {
        return a as? T
    }
    var className: String = ""
    var sc: StringName.ContentType = StringName.zero
    if gi.object_get_class_name (nativeHandle, library, &sc) != 0 {
        let sn = StringName(content: sc)
        className = String(sn)
    } else {
        let copy = nativeHandle
        let _result: GString = GString ()
        gi.object_method_bind_ptrcall (Object.method_get_class, UnsafeMutableRawPointer (mutating: copy), nil, &_result.content)
        className = _result.description
    }
    if let ctor = godotFrameworkCtors [className] {
        return ctor.init (nativeHandle: nativeHandle) as? T
    }
    if let userTypeCtor = userTypes [className] {
        if let created = userTypeCtor (nativeHandle) as? T {
            return created
        } else {
            print ("Found a custom type for \(className) but the constructor failed to return an instance of it as a \(T.self)")
        }
    } 
    
    return T.init (nativeHandle: nativeHandle)
}

func referenceFunc(_ userData: UnsafeMutableRawPointer) {
    fatalError()
}

func unreferenceFunc(_ userData: UnsafeMutableRawPointer) {
    fatalError()
}

///
/// This one is invoked by Godot when an instance of one of our types is created, and we need
/// to instantiate it.   Notice that this is different that direct instantiation from our API
///
func createFunc (_ userData: UnsafeMutableRawPointer?) -> UnsafeMutableRawPointer? {
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
    let o = type.init ()
    return UnsafeMutableRawPointer (mutating: o.handle)
}

func recreateFunc (_ userData: UnsafeMutableRawPointer?, godotObjecthandle: UnsafeMutableRawPointer?) -> UnsafeMutableRawPointer? {
    //print ("SWIFT: Recreate object userData:\(String(describing: userData))")
    guard let userData else {
        print ("Got a nil userData")
        return nil
    }
    let typeAny = Unmanaged<AnyObject>.fromOpaque(userData).takeUnretainedValue()
    guard let type  = typeAny as? Wrapped.Type else {
        print ("SwiftGodot.recreateFunc: The wrapped value did not contain a type: \(typeAny)")
        return nil
    }
    bindingObject = godotObjecthandle
    let o = type.init ()
    bindingObject = nil
    return UnsafeMutableRawPointer (mutating: o.handle)
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
    if let key = objectHandle {
        let original = Unmanaged<Wrapped>.fromOpaque(key).takeRetainedValue()
        tableLock.withLockVoid {
            if let handle = original.handle {
                let removed = liveSubtypedObjects.removeValue(forKey: handle)
                if removed == nil {
                    print ("SWIFT ERROR: attempt to release object we were not aware of: \(original) \(key)")
                } else {
                    //print ("SWIFT: Removed object from our live SubType list (type was: \(original.self)")
                }
            } else {
                print ("freeFunc: the object being released already had a nil handle")
            }
            original.handle = nil
        }
    }
}

func notificationFunc (ptr: UnsafeMutableRawPointer?, code: Int32, reversed: UInt8) {
    //print ("SWIFT: Notification \(code) on \(ptr)")
}

func userTypeBindingCreate (_ token: UnsafeMutableRawPointer?, _ instance: UnsafeMutableRawPointer?) -> UnsafeMutableRawPointer? {
    // Godot-cpp does nothing for user types
    //print ("SWIFT: instanceBindingCreate")
    return nil
}

func userTypeBindingFree (_ token: UnsafeMutableRawPointer?, _ instance: UnsafeMutableRawPointer?, _ binding: UnsafeMutableRawPointer?) {
    // Godot-cpp does nothing for user types
    // I do not think this is necessary, since we are handling the release in the
    // user-binding catch-all (that also covers the Godot-triggers invocations)
    // freeFunc above.
    pd ("SWIFT: instanceBindingFree token=\(String(describing: token)) instance=\(String(describing: instance)) binding=\(String(describing: binding))")
}

// This is invoked to take a reference on the object and ensure our Swift-land object
// does not go away while the object is in use.
func userTypeBindingReference(_ token: UnsafeMutableRawPointer?, _ binding: UnsafeMutableRawPointer?, _ reference: UInt8) -> UInt8{
    guard let binding else { return 0 }

    let wrapped = Unmanaged<Wrapped>.fromOpaque(binding)
    if reference == 0 {
        wrapped.retain()
    } else {
        wrapped.release()
    }
    // Success
    return 1
}

func frameworkTypeBindingCreate (_ token: UnsafeMutableRawPointer?, _ instance: UnsafeMutableRawPointer?) -> UnsafeMutableRawPointer? {
    // This is called from object_get_instance_binding
    return instance
}

func frameworkTypeBindingFree (_ token: UnsafeMutableRawPointer?, _ instance: UnsafeMutableRawPointer?, _ binding: UnsafeMutableRawPointer?) {
    // No longer needed
}

/// This function is called by Godot to invoke our callable, and contains our context in `userData`,
/// pointer to Variants, an argument count, and a way of returing an error
///
/// We extract the arguments and call  the CallableWrapper.method
///
func callableProxy (userData: UnsafeMutableRawPointer?, pargs: UnsafePointer<UnsafeRawPointer?>?, argc: Int64, retPtr: UnsafeMutableRawPointer?, err: UnsafeMutablePointer<GDExtensionCallError>?) {
    guard let userData else { return }
    let r: Unmanaged<CallableWrapper> = Unmanaged.fromOpaque(userData)
    let wrapper = r.takeUnretainedValue()
    var args: [Variant] = []
    if let pargs {
        for i in 0..<argc {
            let variant = Variant (fromContent: pargs [Int(i)]!.assumingMemoryBound(to: Variant.ContentType.self).pointee)
            args.append (variant)
        }
    }
    if let methodRet = wrapper.method (args) {
        retPtr!.storeBytes(of: methodRet.content, as: type (of: methodRet.content))
    }
    err?.pointee.error = GDEXTENSION_CALL_OK
}

func freeMethodWrapper (ptr: UnsafeMutableRawPointer?) {
    guard let ptr else { return }
    let r: Unmanaged<CallableWrapper> = Unmanaged.fromOpaque(ptr)
    r.release()
}

class CallableWrapper {
    var method: ([Variant])->Variant?
    init (method: @escaping ([Variant])->Variant?) {
        self.method = method
    }
    
    static func makeCallable (_ method: @escaping ([Variant])->Variant?) -> Callable.ContentType {
        let wrapper = CallableWrapper(method: method)
        let retained = Unmanaged.passRetained(wrapper)
        
        var cci = GDExtensionCallableCustomInfo(
            callable_userdata: retained.toOpaque(),
            token: token,
            object_id: 0,
            call_func: callableProxy,
            is_valid_func: nil,
            free_func: freeMethodWrapper,
            hash_func: nil,
            equal_func: nil,
            less_than_func: nil,
            to_string_func: nil)
        var content: Callable.ContentType = Callable.zero
        gi.callable_custom_create (&content, &cci);
        return content
    }
}

