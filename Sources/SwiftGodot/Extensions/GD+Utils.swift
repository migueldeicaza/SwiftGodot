//
//  GD+Utils.swift
//
//
//  Created by Marquis Kurt on 5/16/23.
//

extension GD {
    /// Loads a resource from the filesystem located at `path`.
    ///
    /// The resource is loaded on the method call (unless it's referenced already elsewhere, e.g. in another script or
    /// in the scene), which might cause slight delay, especially when loading scenes. To avoid unnecessary delays when
    /// loading something multiple times, either store the resource in a variable.
    ///
    /// - Note: Resource paths can be obtained by right-clicking on a resource in the FileSystem dock and choosing
    /// "Copy Path" or by dragging the file from the FileSystem dock into the script.
    ///
    /// - Important: The path must be absolute, a local path will just return `nil`. This method is a simplified
    /// version of `ResourceLoader.load`, which can be used for more advanced scenarios.
    /// 
    /// - Parameter path: Path of the `Resource` to load.
    /// - Returns: The loaded `Resource`.
    public static func load(path: String) -> Resource? {
        return ResourceLoader.load(path: path, cacheMode: .reuse)
    }

    /// Loads a resource from the filesystem located at `path`.
    ///
    /// The resource is loaded on the method call (unless it's referenced already elsewhere, e.g. in another script or
    /// in the scene), which might cause slight delay, especially when loading scenes. To avoid unnecessary delays when
    /// loading something multiple times, either store the resource in a variable.
    ///
    /// - Note: Resource paths can be obtained by right-clicking on a resource in the FileSystem dock and choosing
    /// "Copy Path" or by dragging the file from the FileSystem dock into the script.
    ///
    /// - Important: The path must be absolute, a local path will just return `nil`. This method is a simplified
    /// version of `ResourceLoader.load`, which can be used for more advanced scenarios.
    ///
    /// - Parameter path: Path of the `Resource` to load.
    /// - Returns: The loaded `Resource`.
    public static func load<T>(path: String) -> T? {
        return ResourceLoader.load(path: path, cacheMode: .reuse) as? T
    }

    /// Pushes an error message to Godot's built-in debugger and to the OS terminal.
    /// - Parameter items: The items to print into the Godot console.
    /// - Parameter separator: The separator to insert between items. The default is a single space (" ").
    public static func pushError(_ items: Any..., separator: String = " ") {
        let transformedItems = items.map(String.init(describing:))
        let finalMessage = transformedItems.joined(separator: separator)
        GD.pushError(arg1: GString(stringLiteral: finalMessage).toVariant())
    }

    /// Pushes a warning message to Godot's built-in debugger and to the OS terminal.
    /// - Parameter items: The items to print into the Godot console.
    /// - Parameter separator: The separator to insert between items. The default is a single space (" ").
    public static func pushWarning(_ items: Any..., separator: String = " ") {
        let transformedItems = items.map(String.init(describing:))
        let finalMessage = transformedItems.joined(separator: separator)
        GD.pushWarning(arg1: GString(stringLiteral: finalMessage).toVariant())
    }

    /// Converts one or more arguments of any type to string in the best way possible and prints them to the console.
    /// - Parameter items: The items to print into the Godot console.
    /// - Parameter separator: The separator to insert between items. The default is a single space (" ").
    public static func print(_ items: Any..., separator: String = " ") {
        let transformedItems = items.map(String.init(describing:))
        let finalMessage = transformedItems.joined(separator: separator)
        GD.print(arg1: GString(stringLiteral: finalMessage).toVariant())
    }

    /// Converts one or more arguments of any type to string in the best way possible and prints them to the console.
    /// - Parameter items: The items to print into the Godot console.
    /// - Parameter separator: The separator to insert between items. The default is a single space (" ").
    public static func printRich(_ items: Any..., separator: String = " ") {
        let transformedItems = items.map(String.init(describing:))
        let finalMessage = transformedItems.joined(separator: separator)
        GD.printRich(arg1: GString(stringLiteral: finalMessage).toVariant())
    }

    /// Converts one or more arguments of any type to string in the best way possible and prints them to the console.
    /// - Parameter items: The items to print into the Godot console.
    /// - Parameter separator: The separator to insert between items. The default is a single space (" ").
    public static func printErr(_ items: Any..., separator: String = " ") {
        let transformedItems = items.map(String.init(describing:))
        let finalMessage = transformedItems.joined(separator: separator)
        GD.printerr(arg1: Variant (finalMessage))
    }
}
