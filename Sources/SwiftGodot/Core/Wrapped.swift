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
    public var handle: UnsafeRawPointer
    public static var fcallbacks = OpaquePointer (UnsafeRawPointer (&Wrapped.frameworkTypeBindingCallback))
    public static var ucallbacks = OpaquePointer (UnsafeRawPointer (&Wrapped.userTypeBindingCallback))
    
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
        print ("SWARN: getVirtualDispatcher (\"\(name)\") reached Wrapped on class \(self)")
        return nil
    }
    
    static var userTypeBindingCallback = GDExtensionInstanceBindingCallbacks(
        create_callback: userTypeBindingCreate,
        free_callback: userTypeBindingFree,
        reference_callback: userTypeBindingReference)
    static var frameworkTypeBindingCallback = GDExtensionInstanceBindingCallbacks(
        create_callback: frameworkTypeBindingCreate,
        free_callback: frameworkTypeBindingFree,
        reference_callback: frameworkTypeBindingReference)
    
    /// For use by the framework, you should not need to call this.
    public required init (nativeHandle: UnsafeRawPointer) {
        handle = nativeHandle
    }
    
    public required init () {
        fatalError("This constructor should not be called")
    }

    /// Returns the Godot's class name as a `StringName`, returns the empty string on error
    public var godotClassName: StringName {
        var sc: StringName.ContentType = StringName.zero
        
        if gi.object_get_class_name (handle, library, &sc) != 0 {
            let sn = StringName(content: sc)
            return sn
        }
        return ""
    }
    
    /// The constructor chain that uses StringName is internal, and is triggered
    /// when a class is initialized with the empty constructor - this means that
    /// subclasses will have a diffrent name than the subclass.
    ///
    /// When subclassing, you should use the name of te l
    internal init (name: StringName) {
        let v = gi.classdb_construct_object (&name.content)
        
        if let r = UnsafeRawPointer (v) {
            handle = r
            let retain = Unmanaged.passRetained(self)
            
            // TODO: what happens if the user subclasses but the name conflicts with the Godot type?
            // say "class Sprite2D: Godot.Sprite2D"
            let thisTypeName = StringName (stringLiteral: String (describing: Swift.type(of: self)))
            let frameworkType = thisTypeName == name
            
            //print ("SWIFT: Wrapped(StringName) at \(handle) with retain=\(retain.toOpaque()), this is a class of type: \(Swift.type(of: self)) and it is: \(frameworkType ? "Builtin" : "User defined")")
            
            // This I believe should only be set for user subclasses, and not anything else.
            if frameworkType {
                //print ("SWIFT: Skipping object registration, this is a framework type")
            } else {
                //print ("SWIFT: Registering instance with Godot")
                withUnsafeMutablePointer(to: &thisTypeName.content) { ptr in
                    gi.object_set_instance (UnsafeMutableRawPointer (mutating: handle),
                                            ptr, retain.toOpaque())
                }
            }
            
            var callbacks: GDExtensionInstanceBindingCallbacks
            if frameworkType {
                callbacks = Wrapped.frameworkTypeBindingCallback
                liveFrameworkObjects [r] = self
            } else {
                callbacks = Wrapped.userTypeBindingCallback
                liveSubtypedObjects [r] = self
            }
            gi.object_set_instance_binding(UnsafeMutableRawPointer (mutating: handle), token, retain.toOpaque(), &callbacks);
        } else {
            fatalError("SWIFT: It was not possible to construct a \(name.description)")
        }
    }
}
    

func register<T:Wrapped> (type name: StringName, parent: StringName, type: T.Type) {
    func getVirtual(_ userData: UnsafeMutableRawPointer?, _ name: GDExtensionConstStringNamePtr?) ->  GDExtensionClassCallVirtual? {
        let typeAny = Unmanaged<AnyObject>.fromOpaque(userData!).takeUnretainedValue()
        guard let type  = typeAny as? Wrapped.Type else {
            print ("SWIFT: The wrapped value did not contain a type: \(typeAny)")
            return nil
        }
        return type.getVirtualDispatcher(name: StringName (fromPtr: name))
    }
    
    var info = GDExtensionClassCreationInfo ()
    info.create_instance_func = createFunc(_:)
    info.free_instance_func = freeFunc(_:_:)
    info.get_virtual_func = getVirtual
    info.notification_func = notificationFunc
    
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
    print("Registering \(typeStr) : \(superStr)")
    register (type: StringName (typeStr), parent: StringName (superStr), type: type)
}

/// Currently contains all instantiated objects, but might want to separate those
/// (or find a way of easily telling appart) framework objects from user subtypes
var liveFrameworkObjects: [UnsafeRawPointer:Wrapped] = [:]
var liveSubtypedObjects: [UnsafeRawPointer:Wrapped] = [:]

///
/// Looks into the liveSubtypedObjects table if we have an object registered for it,
/// and if we do, we returned that existing instance.
///
/// The idioms is that we only need to look up subtyped objects, because those
/// are the only ones that would keep state
func lookupLiveObject (handleAddress: UnsafeRawPointer) -> Wrapped? {
    return liveSubtypedObjects [handleAddress]
}

///
/// Looks into the liveSubtypedObjects table if we have an object registered for it,
/// and if we do, we returned that existing instance.
///
/// We are surfacing this, so that when we recreate an object resurfaced in a collection
/// we do not get the base type, but the most derived one
func lookupFrameworkObject (handleAddress: UnsafeRawPointer) -> Wrapped? {
    return liveFrameworkObjects [handleAddress]
}

func objectFromHandle (nativeHandle: UnsafeRawPointer) -> Wrapped? {
    if let o = (liveFrameworkObjects [nativeHandle] ?? liveSubtypedObjects [nativeHandle]) {
        return o
    }
    
    return nil
}

func lookupObject<T:GodotObject> (nativeHandle: UnsafeRawPointer) -> T? {
    if let a = objectFromHandle(nativeHandle: nativeHandle) {
        return a as? T
    }
    let _result: GString = GString ()
    let copy = nativeHandle
    gi.object_method_bind_ptrcall (Object.method_get_class, UnsafeMutableRawPointer (mutating: copy), nil, &_result.content)
    if let ctor = godotFrameworkCtors [_result.description] {
        return ctor.init (nativeHandle: nativeHandle) as? T
    }
    print ("Could not find class \(_result.description), fallback to creating a \(T.self)")
    return T.init (nativeHandle: nativeHandle)
}

///
/// This one is invoked by Godot when an instance of one of our types is created, and we need
/// to instantiate it.   Notice that this is different that direct instantiation from our API
///
func createFunc (_ userData: UnsafeMutableRawPointer?) -> UnsafeMutableRawPointer? {
    print ("SWIFT: Creating object userData:\(String(describing: userData))")
    guard let userData else {
        print ("Got a nil userData")
        return nil
    }
    let typeAny = Unmanaged<AnyObject>.fromOpaque(userData).takeUnretainedValue()
    guard let type  = typeAny as? Wrapped.Type else {
        print ("SWIFT: The wrapped value did not contain a type: \(typeAny)")
        return nil
    }
    let o = type.init ()
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
        let removed = liveSubtypedObjects.removeValue(forKey: original.handle)
        if removed == nil {
            print ("SWIFT ERROR: attempt to release object we were not aware of: \(original) \(key)")
        } else {
            print ("SWIFT: Removed object from our live SubType list (type was: \(original.self)")
        }
    }
}

func notificationFunc (ptr: UnsafeMutableRawPointer?, code: Int32) {
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
    print ("SWIFT: instanceBindingFree token=\(String(describing: token)) instance=\(String(describing: instance)) binding=\(String(describing: binding))")
}

func userTypeBindingReference(_ x: UnsafeMutableRawPointer?, _ y: UnsafeMutableRawPointer?, _ z: UInt8) -> UInt8{
    // No clue what this is used for, but godot-cpp returns 1
    return 1
}

func frameworkTypeBindingCreate (_ token: UnsafeMutableRawPointer?, _ instance: UnsafeMutableRawPointer?) -> UnsafeMutableRawPointer? {
    // This is called from object_get_instance_binding
    print ("SWIFT: TODO frameworkBindingCreate, why is this called?")
    //fatalError()
    return instance
}

func frameworkTypeBindingFree (_ token: UnsafeMutableRawPointer?, _ instance: UnsafeMutableRawPointer?, _ binding: UnsafeMutableRawPointer?) {
    print ("SWIFT: frameworkBindingFree instance=\(String(describing: instance)) binding=\(String(describing: binding)) token=\(String(describing: token))")
    if let key = instance  {
        if let removed = liveFrameworkObjects.removeValue(forKey: key) {
            print ("SWIFT: Removed from our live Objects with key \(key), removed: \(removed)")
        } else {
            print ("SWIFT ERROR: attempt to release framework object we were not aware of: \(String(describing: instance))")
        }
    }
    if let binding {
        Unmanaged<Wrapped>.fromOpaque(binding).release()
    }
}

func frameworkTypeBindingReference(_ x: UnsafeMutableRawPointer?, _ y: UnsafeMutableRawPointer?, _ z: UInt8) -> UInt8 {
    // No clue what this is used for, but godot-cpp returns 1
    return 1
}

