//
//  GD+Utils.swift
//
//
//  Created by Marquis Kurt on 5/16/23.
//

public extension GD {
    /// Pushes an error message to Godot's built-in debugger and to the OS terminal.
    /// - Parameter items: The items to print into the Godot console.
    /// - Parameter separator: The separator to insert between items. The default is a single space (" ").
    static func pushError(_ items: Any..., separator: String = " ") {
        let transformedItems = items.map(String.init(describing:))
        let finalMessage = transformedItems.joined(separator: separator)
        GD.pushError(arg1: Variant(GString(stringLiteral: finalMessage)))
    }

    /// Pushes a warning message to Godot's built-in debugger and to the OS terminal.
    /// - Parameter items: The items to print into the Godot console.
    /// - Parameter separator: The separator to insert between items. The default is a single space (" ").
    static func pushWarning(_ items: Any..., separator: String = " ") {
        let transformedItems = items.map(String.init(describing:))
        let finalMessage = transformedItems.joined(separator: separator)
        GD.pushWarning(arg1: Variant(GString(stringLiteral: finalMessage)))
    }

    /// Converts one or more arguments of any type to string in the best way possible and prints them to the console.
    /// - Parameter items: The items to print into the Godot console.
    /// - Parameter separator: The separator to insert between items. The default is a single space (" ").
    static func print(_ items: Any..., separator: String = " ") {
        let transformedItems = items.map(String.init(describing:))
        let finalMessage = transformedItems.joined(separator: separator)
        GD.print(arg1: Variant(GString(stringLiteral: finalMessage)))
    }

    /// Converts one or more arguments of any type to string in the best way possible and prints them to the console.
    /// - Parameter items: The items to print into the Godot console.
    /// - Parameter separator: The separator to insert between items. The default is a single space (" ").
    static func printRich(_ items: Any..., separator: String = " ") {
        let transformedItems = items.map(String.init(describing:))
        let finalMessage = transformedItems.joined(separator: separator)
        GD.printRich(arg1: Variant(GString(stringLiteral: finalMessage)))
    }

    /// Converts one or more arguments of any type to string in the best way possible and prints them to the console.
    /// - Parameter items: The items to print into the Godot console.
    /// - Parameter separator: The separator to insert between items. The default is a single space (" ").
    static func printErr(_ items: Any..., separator: String = " ") {
        let transformedItems = items.map(String.init(describing:))
        let finalMessage = transformedItems.joined(separator: separator)
        GD.printerr(arg1: Variant (finalMessage))
    }
}
