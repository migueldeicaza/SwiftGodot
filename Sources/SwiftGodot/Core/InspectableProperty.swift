//
//  File.swift
//  
//
//  Created by Marquis Kurt on 10/15/23.
//

/// A structure that houses a property that can be added to a Godot inspector.
public struct InspectableProperty<T> {
    /// A typealias for the the method type used to register a property to Godot for inspectors.
    public typealias RegisteredPropertyFunction = (T) -> ([Variant]) -> Variant?

    /// The host object the property derives from.
    public let hostObject: T.Type

    /// The getter function that gets the property.
    public let getter: RegisteredPropertyFunction

    /// The setter function that sets the property.
    public let setter: RegisteredPropertyFunction

    /// Creates an inspectable property suitable for registration.
    public init(_ hostObject: T.Type,
                getter: @escaping RegisteredPropertyFunction,
                setter: @escaping RegisteredPropertyFunction) {
        self.hostObject = hostObject
        self.getter = getter
        self.setter = setter
    }
}
