//
//  File.swift
//  
//
//  Created by Miguel de Icaza on 4/30/23.
//

import Foundation

/// This is a convenience object used as a helper for signals, all it does is
/// register a method with godot called `proxy` that will invoke
/// the callback defined in the public `proxy` variable here.
///
/// Usage:
/// ```
/// let demo = SignalProxy ()
/// demo.proxy = { print ("called back") }
///
/// // Let godot call `demo` and its proxy method.
/// invokeScript ("myDemo.proxy ()", params: ["myDemo", demo])
/// ```
public class SignalProxy: Object {
    public static var proxyName = StringName ("proxy")
    static var initClass: Bool = {
        register(type: SignalProxy.self)
        
        let s = ClassInfo<SignalProxy>(name: "SignalProxy")
        
        s.registerMethod(name: SignalProxy.proxyName, flags: .default, returnValue: nil, arguments: [], function: SignalProxy.proxyFunc)
        return true
    } ()
    
    /// The code invoked when Godot invokes the `proxy` method on this object.
    public var proxy: ([Variant]) -> () = { args in }
    
    public required init () {
        let _ = SignalProxy.initClass
        super.init()
    }
    
    public required init (nativeHandle: UnsafeRawPointer) {
        super.init (nativeHandle: nativeHandle)
    }
    
    func proxyFunc (args: [Variant]) -> Variant? {
        proxy (args)
        return nil
    }
}

extension GodotError: Error {}

/// The simple signal is used to raise signals that take no arguments and return no values
///
/// Subclasses that use this, implement singnals like this:
///
/// ```
/// class MyClass: Object {
///     // the `wakeup` signal
///     public var wakeup: SimpleSignal { SimpleSignal (self, "wakeup") }
/// }
/// ```
///
/// And to connect, you do:
/// ```
/// let myClass = MyClass ()
/// let token = myClass.wakeup.connect {
///    print ("wakeup triggered")
/// }
/// ```
///
/// Later on, to disconnect:
/// ```
/// myClass.wakeup.disconnect (token)
/// ```
public class SimpleSignal {
    var target: Object
    var signalName: StringName
    
    /// - Parameters:
    ///  - target: the object where we will be operating on, to connect or disconnect the signal
    ///  - name: the name of the signal
    public init (target: Object, signalName: StringName) {
        self.target = target
        self.signalName = signalName
    }
    
    /// Connects the signal to the specified callback.
    ///
    /// To disconnect, call the disconnect method, with the returned token on success
    ///
    /// - Parameters:
    ///  - callback: the method to invoke when the signal is raised
    ///  - flags: Optional, can be also added to configure the connection's behavior (see ``Object/ConnectFlags`` constants).
    /// - Returns: an object token that can be used to disconnect the object from the target.
    @discardableResult
    public func connect (_ callback: @escaping () -> (), flags: UInt32 = 0) -> Object {
        let signalProxy = SignalProxy()
        signalProxy.proxy = { args in
            callback ()
        }

        let callable = Callable(object: signalProxy, method: SignalProxy.proxyName)
        let r = target.connect(signal: signalName, callable: callable, flags: flags)
        if r != .ok {
            print ("Warning, error connecting to signal \(signalName.description): \(r)")
        }
        return signalProxy
    }
    
    /// Disconnects a signal that was previously connected (the return value from a successful call to Connect
    public func disconnect (_ token: Object) {
        target.disconnect(signal: signalName, callable: Callable (object: token, method: SignalProxy.proxyName))
    }
}
