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
///
public class SignalWithArguments<each T: VariantStorable> {
    var target: Object
    var signalName: StringName
    public init(target: Object, signalName: String) {
        self.target = target
        self.signalName = StringName(signalName)
    }

    /// Register this signal with the Godot runtime.
    // TODO: the @Signal macro could optionally accept a list of argument names, so that we could register them as well.
    public static func register<C: Object>(_ signalName: String, info: ClassInfo<C>) {
        let arguments = expandArguments(repeat (each T).self)
        info.registerSignal(name: StringName(signalName), arguments: arguments)
    }

    /// Expand a list of argument types into a list of PropInfo objects
    /// Note: it doesn't currently seem to be possible to constrain
    /// the type of the pack expansion to be ``VariantStorable.Type``, but
    /// we know that it always will be, so we can force cast it.
    static func expandArguments<each ArgType>(_ type: repeat each ArgType) -> [PropInfo] {
        var args = [PropInfo]()
        var argC = 1
        for arg in repeat each type {
            let a = arg as! any VariantStorable.Type
            args.append(a.propInfo(name: "arg\(argC)"))
            argC += 1

        }
        return args
    }

    /// Connects the signal to the specified callback
    /// To disconnect, call the disconnect method, with the returned token on success
    ///
    /// - Parameters:
    /// - callback: the method to invoke when this signal is raised
    /// - flags: Optional, can be also added to configure the connection's behavior (see ``Object/ConnectFlags`` constants).
    /// - Returns: an object token that can be used to disconnect the object from the target on success, or the error produced by Godot.
    ///
    @discardableResult
    public func connect(flags: Object.ConnectFlags = [], _ callback: @escaping (_ t: repeat each T) -> Void) -> Object {
        let signalProxy = SignalProxy()
        signalProxy.proxy = { args in
            var index = 0
            do {
                callback(repeat try args.unwrap(ofType: (each T).self, index: &index))
            } catch {
                print("Error unpacking signal arguments: \(error)")
            }
        }

        let callable = Callable(object: signalProxy, method: SignalProxy.proxyName)
        let r = target.connect(signal: signalName, callable: callable, flags: UInt32(flags.rawValue))
        if r != .ok { print("Warning, error connecting to signal, code: \(r)") }
        return signalProxy
    }

    /// Disconnects a signal that was previously connected, the return value from calling
    /// ``connect(flags:_:)``
    public func disconnect(_ token: Object) {
        target.disconnect(signal: signalName, callable: Callable(object: token, method: SignalProxy.proxyName))
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
        let args = GArray()
        args.append(Variant(signalName))
        for arg in repeat each t {
            args.append(Variant(arg))
        }
        let result = target.callv(method: "emit_signal", argArray: args)
        guard let result else { return .ok }
        guard let errorCode = Int(result) else { return .ok }
        return GodotError(rawValue: Int64(errorCode))!
    }

    /// You can await this property to wait for the signal to be emitted once.
    public var emitted: Void {
        get async {
            await withCheckedContinuation { c in
                let signalProxy = SignalProxy()
                signalProxy.proxy = { _ in c.resume() }
                let callable = Callable(object: signalProxy, method: SignalProxy.proxyName)
                let r = target.connect(signal: signalName, callable: callable, flags: UInt32(Object.ConnectFlags.oneShot.rawValue))
                if r != .ok { print("Warning, error connecting to signal, code: \(r)") }
            }

        }

    }

}

extension Arguments {
    enum UnpackError: Error {
        /// The argument could not be coerced to the expected type.
        case typeMismatch

        /// The argument was nil.
        case nilArgument
    }

    /// Unpack an argument as a specific type.
    /// We throw a runtime error if the argument is not of the expected type,
    /// or if there are not enough arguments to unpack.
    func unwrap<T: VariantStorable>(ofType type: T.Type, index: inout Int) throws -> T {
        let argument = try optionalVariantArgument(at: index)
        index += 1

        // if the argument was nil, throw error
        guard let argument else {
            throw UnpackError.nilArgument
        }

        // NOTE:
        // Ideally we could just call T.unpack(from: argument) here.
        // Unfortunately, T.unpack is dispatched statically, but we don't
        // have the full dynamic type information for T when we're compiling.
        // The only thing we know about type T is that it conforms to VariantStorable.
        // We don't know if inherits from Object, so the compiler will always pick the
        // default non-object implementation of T.unpack.

        // try to unpack the variant as the expected type
        let value: T?
        if (argument.gtype == .object) && (T.Representable.godotType == .object) {
            value = argument.asObject(Object.self) as? T
        } else {
            value = T(argument)
        }

        guard let value else {
            throw UnpackError.typeMismatch
        }

        return value
    }
}
