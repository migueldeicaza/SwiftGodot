//
//  Created by Sam Deane on 25/10/2024.
//

/// Simple signal without arguments.
public typealias SimpleSignal = SignalWithArguments< /* no args */>

/// Signal support.
/// Use the ``connect(flags:_:)`` method to connect to the signal on the container object,
/// and ``disconnect(_:)`` to drop the connection.
/// Use the ``emit(...)`` method to emit a signal.
/// You can also await the ``emitted`` property for waiting for a single emission of the signal.
public struct SignalWithArguments<each T: _GodotBridgeable> {
    weak var target: Object?
    let signalName: StringName
    
    public init(target: Object, signalName: String) {
        self.target = target
        self.signalName = StringName(signalName)
    }

    /// Register this signal with the Godot runtime.
    // TODO: the @Signal macro could optionally accept a list of argument names, so that we could register them as well.
    public static func register<C: Object>(_ signalName: String, info: ClassInfo<C>) {
        info.registerSignal(name: StringName(signalName), arguments: argumentPropInfos)
    }
    
    /// Register ``SignalWithArguments`` with a set of arguments inferred from generic clause as a signal named `signalName` in a class named `className`.
    public static func register(as signalName: StringName, in className: StringName) {
        _registerSignal(signalName, in: className, arguments: argumentPropInfos)
    }

    /// Expand a list of argument types into a list of PropInfo objects
    static var argumentPropInfos: [PropInfo] {
        var arguments = [PropInfo]()
        var i = 1
        
        for argument in repeat (each T)._argumentPropInfo(name: "arg\(i)") {
            arguments.append(argument)
            i += 1
        }
        
        return arguments
    }
    
    /// Connects the signal to the specified callback
    /// To disconnect, call the disconnect method, with the returned token on success
    ///
    /// - Parameters:
    /// - callback: the method to invoke when this signal is raised
    /// - flags: Optional, can be also added to configure the connection's behavior (see ``Object/ConnectFlags`` constants).
    /// - Returns: ``Callable`` that can be used to ``disconnect(_:)`` from the signal. Or ignored altogether.
    ///
    /// ### Example
    /// ```
    /// // someSignal: SignalWithArguments<String, Bool>
    /// someSignal.connect { string, bool in
    ///      // do something
    /// }
    /// ```
    @discardableResult
    public func connect(flags: Object.ConnectFlags = [], _ callback: @escaping (_ t: repeat each T) -> Void) -> Callable {
        let callable = Callable(callback)
        let error = target?.connect(signal: signalName, callable: callable, flags: UInt32(flags.rawValue))
        return callable
    }

    /// Disconnects a signal that was previously connected, the return value from calling
    /// ``connect(flags:_:)``
    public func disconnect(_ token: Callable) {
        target?.disconnect(signal: signalName, callable: token)
    }

    /// Emit the signal (with required arguments, if there are any)
    @discardableResult /* discardable per discardableList: Object, emit_signal */
    public func emit(_ t: repeat each T) -> GodotError {
        // NOTE:
        // Ideally we should be able to expand the arguments and pass them
        // into a call to the native emitSignal; something like this:
        //   emitSignal(signalName, repeat Variant(each t))
        //
        // Unfortunately, expanding arguments as opposed to types
        // (t, as opposed to T), doesn't seem to support this pattern.
        //
        // The only thing we can do with them is iterate them,
        // which means that we can build up an array of them, so we
        // then use callv to call the emit_signal method.
        let args = VariantArray()
        args.append(Variant(signalName))
        for arg in repeat each t {
            args.append(arg.toVariant())
        }
        
        guard let target else {
            return GodotError.failed
        }
        let result = target.callv(method: "emit_signal", argArray: args)
        guard let result else { return .ok }
        guard let errorCode = Int(result) else { return .ok }
        return GodotError(rawValue: Int64(errorCode))!
    }

    /// You can await this property to wait for the signal to be emitted once.
    @available(*, deprecated, message: "This is inherently unsafe because if the signal never fires the coroutine state of `async` function leaks, capturing all its context required for next continuation forever, use callbacks instead")
    public var emitted: Void {
        get async {
            await withCheckedContinuation { c in
                let signalProxy = SignalProxy()
                signalProxy.proxy = { _ in c.resume() }
                let callable = Callable(object: signalProxy, method: SignalProxy.proxyName)
                
                guard let target else {
                    c.resume()
                    return
                }
                
                let r = target.connect(signal: signalName, callable: callable, flags: UInt32(Object.ConnectFlags.oneShot.rawValue))
                if r != .ok { print("Warning, error connecting to signal, code: \(r)") }
            }
        }
    }
}
