//
//  SignalRegistration.swift
//
//
//  Created by Padraig O Cinneide on 2023-10-18.
//

/// Describes a signal and its arguments.
/// - note: It is recommended to use the @Signal macro instead of using this directly.
@available(*, deprecated, message: "Use the @Signal macro instead.")
public struct SignalWithNoArguments {
    public let name: StringName
    public let arguments: [PropInfo] = [] // needed for registration in macro, but always []
    
    public init(_ signalName: String) {
        name = StringName(signalName)
    }
}

/// Describes a signal and its arguments.
/// - note: It is recommended to use the @Signal macro instead of using this directly.
@available(*, deprecated, message: "Use the @Signal macro instead.")
public struct SignalWith1Argument<Argument: _GodotBridgeable> {
    public let name: StringName
    public let arguments: [PropInfo]
    
    public init(
        _ signalName: String,
        argument1Name: String? = nil
    ) {
        name = StringName(signalName)
        arguments = [
            PropInfo(propertyType: Argument.self, propertyName: .init(argument1Name ?? "arg1"))
        ]
    }
}

/// Describes a signal and its arguments.
/// - note: It is recommended to use the @Signal macro instead of using this directly.
@available(*, deprecated, message: "Use the @Signal macro instead.")
public struct SignalWith2Arguments<
    Argument1: _GodotBridgeable,
    Argument2: _GodotBridgeable
> {
    public let name: StringName
    public let arguments: [PropInfo]
    
    public init(
        _ signalName: String,
        argument1Name: String? = nil,
        argument2Name: String? = nil
    ) {
        name = StringName(signalName)
        arguments = [
            PropInfo(propertyType: Argument1.self, propertyName: .init(argument1Name ?? "arg1")),
            PropInfo(propertyType: Argument2.self, propertyName: .init(argument2Name ?? "arg2")),
        ]
    }
}

/// Describes a signal and its arguments.
/// - note: It is recommended to use the @Signal macro instead of using this directly.
@available(*, deprecated, message: "Use the @Signal macro instead.")
public struct SignalWith3Arguments<
    Argument1: _GodotBridgeable,
    Argument2: _GodotBridgeable,
    Argument3: _GodotBridgeable
> {
    public let name: StringName
    public let arguments: [PropInfo]

    public init(
        _ signalName: String,
        argument1Name: String? = nil,
        argument2Name: String? = nil,
        argument3Name: String? = nil
    ) {
        name = StringName(signalName)
        arguments = [
            PropInfo(propertyType: Argument1.self, propertyName: .init(argument1Name ?? "arg1")),
            PropInfo(propertyType: Argument2.self, propertyName: .init(argument2Name ?? "arg2")),
            PropInfo(propertyType: Argument3.self, propertyName: .init(argument3Name ?? "arg3")),
        ]
    }
}

/// Describes a signal and its arguments.
/// - note: It is recommended to use the @Signal macro instead of using this directly.
@available(*, deprecated, message: "Use the @Signal macro instead.")
public struct SignalWith4Arguments<
    Argument1: _GodotBridgeable,
    Argument2: _GodotBridgeable,
    Argument3: _GodotBridgeable,
    Argument4: _GodotBridgeable
> {
    public let name: StringName
    public let arguments: [PropInfo]

    public init(
        _ signalName: String,
        argument1Name: String? = nil,
        argument2Name: String? = nil,
        argument3Name: String? = nil,
        argument4Name: String? = nil
    ) {
        name = StringName(signalName)
        arguments = [
            PropInfo(propertyType: Argument1.self, propertyName: .init(argument1Name ?? "arg1")),
            PropInfo(propertyType: Argument2.self, propertyName: .init(argument2Name ?? "arg2")),
            PropInfo(propertyType: Argument3.self, propertyName: .init(argument3Name ?? "arg3")),
            PropInfo(propertyType: Argument4.self, propertyName: .init(argument4Name ?? "arg4"))
        ]
    }
}

/// Describes a signal and its arguments.
/// - note: It is recommended to use the @Signal macro instead of using this directly.
@available(*, deprecated, message: "Use the @Signal macro instead.")
public struct SignalWith5Arguments<
    Argument1: _GodotBridgeable,
    Argument2: _GodotBridgeable,
    Argument3: _GodotBridgeable,
    Argument4: _GodotBridgeable,
    Argument5: _GodotBridgeable
> {
    public let name: StringName
    public let arguments: [PropInfo]

    public init(
        _ signalName: String,
        argument1Name: String? = nil,
        argument2Name: String? = nil,
        argument3Name: String? = nil,
        argument4Name: String? = nil,
        argument5Name: String? = nil
    ) {
        name = StringName(signalName)
        arguments = [
            PropInfo(propertyType: Argument1.self, propertyName: .init(argument1Name ?? "arg1")),
            PropInfo(propertyType: Argument2.self, propertyName: .init(argument2Name ?? "arg2")),
            PropInfo(propertyType: Argument3.self, propertyName: .init(argument3Name ?? "arg3")),
            PropInfo(propertyType: Argument4.self, propertyName: .init(argument4Name ?? "arg4")),
            PropInfo(propertyType: Argument5.self, propertyName: .init(argument5Name ?? "arg5"))
        ]
    }
}

/// Describes a signal and its arguments.
/// - note: It is recommended to use the @Signal macro instead of using this directly.
@available(*, deprecated, message: "Use the @Signal macro instead.")
public struct SignalWith6Arguments<
    Argument1: _GodotBridgeable,
    Argument2: _GodotBridgeable,
    Argument3: _GodotBridgeable,
    Argument4: _GodotBridgeable,
    Argument5: _GodotBridgeable,
    Argument6: _GodotBridgeable
> {
    public let name: StringName
    public let arguments: [PropInfo]

    public init(
        _ signalName: String,
        argument1Name: String? = nil,
        argument2Name: String? = nil,
        argument3Name: String? = nil,
        argument4Name: String? = nil,
        argument5Name: String? = nil,
        argument6Name: String? = nil
    ) {
        name = StringName(signalName)
        arguments = [
            PropInfo(propertyType: Argument1.self, propertyName: .init(argument1Name ?? "arg1")),
            PropInfo(propertyType: Argument2.self, propertyName: .init(argument2Name ?? "arg2")),
            PropInfo(propertyType: Argument3.self, propertyName: .init(argument3Name ?? "arg3")),
            PropInfo(propertyType: Argument4.self, propertyName: .init(argument4Name ?? "arg4")),
            PropInfo(propertyType: Argument5.self, propertyName: .init(argument5Name ?? "arg5")),
            PropInfo(propertyType: Argument6.self, propertyName: .init(argument6Name ?? "arg6"))
        ]
    }
}

public extension Object {
    /// Emits a signal that was previously defined with the #signal macro.
    ///
    ///  - Example: emit(signal: Player.scored)
    @discardableResult
    func emit(signal: SignalWithNoArguments) -> GodotError {
        emitSignal(signal.name)
    }

    /// Connects a signal to a callable method
    /// - parameters:
    ///     - signal: a signal that was previously defined with the #signal macro.
    ///     - target: an Object that the method will be called on when the signal emits
    ///     - method: the name of a @Callable method defined on the `target` object.
    ///  - Example: connect(signal: Player.scored, to: self, method: "updateScore")
    @discardableResult
    @available(*, deprecated, message: "Use the @Signal macro instead.")
    func connect(signal: SignalWithNoArguments, to target: some Object, method: String) -> GodotError {
        connect(signal: signal.name, callable: .init(object: target, method: .init(method)))
    }

    /// Emits a signal that was previously defined with the #signal macro.
    /// The argument must match the type of the argument at that position in the signal.
    ///  - Example: emit(signal: Player.scored, 12)
    @discardableResult
    @available(*, deprecated, message: "Use the @Signal macro instead.")
    func emit<A: _GodotBridgeable>(signal: SignalWith1Argument<A>, _ argument: A) -> GodotError {
        emitSignal(signal.name, argument.toVariant())
    }

    /// Connects a signal to a callable method
    /// - parameters:
    ///     - signal: a signal that was previously defined with the #signal macro.
    ///     - target: an Object that the method will be called on when the signal emits
    ///     - method: the name of a @Callable method defined on the `target` object.
    ///  - Example: connect(signal: Player.scored, to: self, method: "updateScore")
    @discardableResult
    @available(*, deprecated, message: "Use the @Signal macro instead.")
    func connect(signal: SignalWith1Argument<some Any>, to target: some Object, method: String) -> GodotError {
        connect(signal: signal.name, callable: .init(object: target, method: .init(method)))
    }
    
    /// Emits a signal that was previously defined with the #signal macro.
    /// The argument must match the type of the argument at that position in the signal.
    ///  - Example: emit(signal: Player.scored, 12, "hooray")
    @discardableResult
    @available(*, deprecated, message: "Use the @Signal macro instead.")
    func emit<A: _GodotBridgeable, B: _GodotBridgeable>(
        signal: SignalWith2Arguments<A, B>,
        _ argument1: A,
        _ argument2: B
    ) -> GodotError {
        emitSignal(signal.name, argument1.toVariant(), argument2.toVariant())
    }

    /// Connects a signal to a callable method
    /// - parameters:
    ///     - signal: a signal that was previously defined with the #signal macro.
    ///     - target: an Object that the method will be called on when the signal emits
    ///     - method: the name of a @Callable method defined on the `target` object.
    ///  - Example: connect(signal: Player.scored, to: self, method: "updateScore")
    @discardableResult
    @available(*, deprecated, message: "Use the @Signal macro instead.")
    func connect(signal: SignalWith2Arguments<some Any, some Any>, to target: some Object, method: String) -> GodotError {
        connect(signal: signal.name, callable: .init(object: target, method: .init(method)))
    }

    /// Emits a signal that was previously defined with the #signal macro.
    /// The argument must match the type of the argument at that position in the signal.
    ///  - Example: emit(signal: Player.scored, 12, "hooray", self)
    @discardableResult
    @available(*, deprecated, message: "Use the @Signal macro instead.")
    func emit<A: _GodotBridgeable, B: _GodotBridgeable, C: _GodotBridgeable>(
        signal: SignalWith3Arguments<A, B, C>,
        _ argument1: A,
        _ argument2: B,
        _ argument3: C
    ) -> GodotError {
        emitSignal(signal.name, argument1.toVariant(), argument2.toVariant(), argument3.toVariant())
    }

    /// Connects a signal to a callable method
    /// - parameters:
    ///     - signal: a signal that was previously defined with the #signal macro.
    ///     - target: an Object that the method will be called on when the signal emits
    ///     - method: the name of a @Callable method defined on the `target` object.
    ///  - Example: connect(signal: Player.scored, to: self, method: "updateScore")
    @discardableResult
    @available(*, deprecated, message: "Use the @Signal macro instead.")
    func connect(
        signal: SignalWith3Arguments<some Any, some Any, some Any>,
        to target: some Object,
        method: String
    ) -> GodotError {
        connect(signal: signal.name, callable: .init(object: target, method: .init(method)))
    }

    /// Emits a signal that was previously defined with the #signal macro.
    /// The argument must match the type of the argument at that position in the signal.
    ///  - Example: emit(signal: Player.scored, 12, "hooray", self, 4)
    @discardableResult
    @available(*, deprecated, message: "Use the @Signal macro instead.")
    func emit<A: _GodotBridgeable, B: _GodotBridgeable, C: _GodotBridgeable, D: _GodotBridgeable>(
        signal: SignalWith4Arguments<A, B, C, D>,
        _ argument1: A,
        _ argument2: B,
        _ argument3: C,
        _ argument4: D
    ) -> GodotError {
        emitSignal(
            signal.name,
            argument1.toVariant(),
            argument2.toVariant(),
            argument3.toVariant(),
            argument4.toVariant()
        )
    }

    /// Connects a signal to a callable method
    /// - parameters:
    ///     - signal: a signal that was previously defined with the #signal macro.
    ///     - target: an Object that the method will be called on when the signal emits
    ///     - method: the name of a @Callable method defined on the `target` object.
    ///  - Example: connect(signal: Player.scored, to: self, method: "updateScore")
    @discardableResult
    @available(*, deprecated, message: "Use the @Signal macro instead.")
    func connect(
        signal: SignalWith4Arguments<some Any, some Any, some Any, some Any>,
        to target: some Object,
        method: String
    ) -> GodotError {
        connect(signal: signal.name, callable: .init(object: target, method: .init(method)))
    }
    
    /// Emits a signal that was previously defined with the #signal macro.
    /// The argument must match the type of the argument at that position in the signal.
    ///  - Example: emit(signal: Player.scored, 12, "hooray", self, 4, "another_one")
    @discardableResult
    @available(*, deprecated, message: "Use the @Signal macro instead.")
    func emit<A: _GodotBridgeable, B: _GodotBridgeable, C: _GodotBridgeable, D: _GodotBridgeable, E: _GodotBridgeable>(
        signal: SignalWith5Arguments<A, B, C, D, E>,
        _ argument1: A,
        _ argument2: B,
        _ argument3: C,
        _ argument4: D,
        _ argument5: E
    ) -> GodotError {
        emitSignal(
            signal.name,
            argument1.toVariant(),
            argument2.toVariant(),
            argument3.toVariant(),
            argument4.toVariant(),
            argument5.toVariant()
        )
    }

    /// Connects a signal to a callable method
    /// - parameters:
    ///     - signal: a signal that was previously defined with the #signal macro.
    ///     - target: an Object that the method will be called on when the signal emits
    ///     - method: the name of a @Callable method defined on the `target` object.
    ///  - Example: connect(signal: Player.scored, to: self, method: "updateScore")
    @discardableResult
    @available(*, deprecated, message: "Use the @Signal macro instead.")
    func connect(
        signal: SignalWith5Arguments<some Any, some Any, some Any, some Any, some Any>,
        to target: some Object,
        method: String
    ) -> GodotError {
        connect(signal: signal.name, callable: .init(object: target, method: .init(method)))
    }
    
    /// Emits a signal that was previously defined with the #signal macro.
    /// The argument must match the type of the argument at that position in the signal.
    ///  - Example: emit(signal: Player.scored, 12, "hooray", self, 4, reason)
    @discardableResult
    @available(*, deprecated, message: "Use the @Signal macro instead.")
    func emit<A: _GodotBridgeable, B: _GodotBridgeable, C: _GodotBridgeable, D: _GodotBridgeable, E: _GodotBridgeable, F: _GodotBridgeable>(
        signal: SignalWith6Arguments<A, B, C, D, E, F>,
        _ argument1: A,
        _ argument2: B,
        _ argument3: C,
        _ argument4: D,
        _ argument5: E,
        _ argument6: F
    ) -> GodotError {
        emitSignal(
            signal.name,
            argument1.toVariant(),
            argument2.toVariant(),
            argument3.toVariant(),
            argument4.toVariant(),
            argument5.toVariant(),
            argument6.toVariant()
        )
    }

    /// Connects a signal to a callable method
    /// - parameters:
    ///     - signal: a signal that was previously defined with the #signal macro.
    ///     - target: an Object that the method will be called on when the signal emits
    ///     - method: the name of a @Callable method defined on the `target` object.
    ///  - Example: connect(signal: Player.scored, to: self, method: "updateScore")
    @discardableResult
    @available(*, deprecated, message: "Use the @Signal macro instead.")
    func connect(
        signal: SignalWith6Arguments<some Any, some Any, some Any, some Any, some Any, some Any>,
        to target: some Object,
        method: String
    ) -> GodotError {
        connect(signal: signal.name, callable: .init(object: target, method: .init(method)))
    }
}

extension PropInfo {
    fileprivate init(
        propertyType: (some _GodotBridgeable).Type,
        propertyName: StringName
    ) {
        self.init(
            propertyType: propertyType._variantType,
            propertyName: propertyName,
            className: propertyType._variantType == .object ? .init(String(describing: propertyType.self)) : "",
            hint: .none,
            hintStr: "",
            usage: .default
        )
    }
}
