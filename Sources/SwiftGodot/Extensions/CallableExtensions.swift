//
//  Callable+ClosureConstructor.swift
//  SwiftGodot
//
//  Created by Elijah Semyonov on 13/04/2025.
//

public extension Callable {
    /// Initialize ``Callable`` using Swift closure, for example:
    /// ```
    /// var callable = Callable { (a: Int, b: Int, c: String) -> String in
    ///     return [String](repeating: c, count: a + b).joined(separator: " ")
    /// }
    ///
    /// var result = callable.call(
    ///    1.toVariant(),
    ///    2.toVariant(),
    ///    "Amazing!".toVariant()
    /// )
    /// ```
    ///
    /// If arguments with which ``Callable`` was called didn't match the Swift ones, a error will be logged
    convenience init<each Argument, R>(
        _ callback: @escaping (repeat each Argument) -> R
    ) where repeat each Argument: _GodotBridgeable, R: _GodotBridgeable {
        self.init { arguments in
            proxyCallableToSwiftClosure(arguments: arguments, closure: callback)
        }
    }
    
    
    /// Initialize ``Callable`` using Swift closure returning `Void`, for example:
    /// ```
    /// var callable = Callable { (a: Int, b: Int) in
    ///     GD.print(a + b)
    /// }
    ///
    /// callable.call(
    ///    1.toVariant(),
    ///    2.toVariant(),
    /// )
    /// ```
    ///
    /// If arguments with which ``Callable`` was called didn't match the Swift ones, a error will be logged
    convenience init<each Argument>(
        _ callback: @escaping (repeat each Argument) -> Void
    ) where repeat each Argument: _GodotBridgeable {
        self.init { arguments in
            proxyCallableToSwiftClosure(arguments: arguments, closure: callback)
        }
    }
}

private func proxyCallableToSwiftClosure<each Argument, R>(
    arguments: borrowing Arguments,
    closure: (repeat each Argument) -> R
) -> Variant? where repeat each Argument: _GodotBridgeable, R: _GodotBridgeable {
    var index = 0
    
    do {
        let result = try closure(
            repeat (each Argument).fromArguments(arguments, incrementingIndex: &index)
        )
        
        return result.toVariant()
    } catch {
        GD.printErr("`Callable` invocation error: \(error.description)")
        return nil
    }
}

private func proxyCallableToSwiftClosure<each Argument>(
    arguments: borrowing Arguments,
    closure: (repeat each Argument) -> Void
) -> Variant? where repeat each Argument: _GodotBridgeable {
    var index = 0
    
    do {
        try closure(
            repeat (each Argument).fromArguments(arguments, incrementingIndex: &index)
        )
    } catch {
        GD.printErr("`Callable` invocation error: \(error.description)")
    }
    
    return nil
}

