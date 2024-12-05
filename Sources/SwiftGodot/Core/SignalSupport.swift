//
//  File.swift
//
//
//  Created by Miguel de Icaza on 4/30/23.
//

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
    public static var proxyName = StringName("proxy")
    static var initClass: Bool = {
        register(type: SignalProxy.self)

        let s = ClassInfo<SignalProxy>(name: "SignalProxy")

        s.registerMethod(name: SignalProxy.proxyName, flags: .default, returnValue: nil, arguments: [], function: SignalProxy.proxyFunc)
        return true
    }()

    /// The code invoked when Godot invokes the `proxy` method on this object.
    public typealias Proxy = (borrowing Arguments) -> ()
    public var proxy: Proxy?

    public required init() {
        let _ = SignalProxy.initClass
        super.init()
    }

    public required init(nativeHandle: UnsafeRawPointer) {
        super.init(nativeHandle: nativeHandle)
    }

    func proxyFunc(args: borrowing Arguments) -> Variant? {
        proxy?(args)
        return nil
    }
}
