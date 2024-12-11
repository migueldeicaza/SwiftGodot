//
//  GD+Utils.swift
//
//
//  Created by Marquis Kurt on 5/16/23.
//

#if CUSTOM_BUILTIN_IMPLEMENTATIONS
#if canImport(Darwin)
import Darwin
#elseif os(Windows)
import ucrt
import WinSDK
#elseif canImport(Glibc)
import Glibc
#elseif canImport(Musl)
import Musl
#else
#error("Unable to identify your C library.")
#endif
#endif

private func system_acosf(_ x: Float) -> Float { acosf(x) }

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
        GD.pushError(arg1: Variant(GString(stringLiteral: finalMessage)))
    }

    /// Pushes a warning message to Godot's built-in debugger and to the OS terminal.
    /// - Parameter items: The items to print into the Godot console.
    /// - Parameter separator: The separator to insert between items. The default is a single space (" ").
    public static func pushWarning(_ items: Any..., separator: String = " ") {
        let transformedItems = items.map(String.init(describing:))
        let finalMessage = transformedItems.joined(separator: separator)
        GD.pushWarning(arg1: Variant(GString(stringLiteral: finalMessage)))
    }

    /// Converts one or more arguments of any type to string in the best way possible and prints them to the console.
    /// - Parameter items: The items to print into the Godot console.
    /// - Parameter separator: The separator to insert between items. The default is a single space (" ").
    public static func print(_ items: Any..., separator: String = " ") {
        let transformedItems = items.map(String.init(describing:))
        let finalMessage = transformedItems.joined(separator: separator)
        GD.print(arg1: Variant(GString(stringLiteral: finalMessage)))
    }

    /// Converts one or more arguments of any type to string in the best way possible and prints them to the console, with fileID, line, and function name of the calling function.
    /// - Parameter items: The items to print into the Godot console.
    /// - Parameter separator: The separator to insert between items. The default is a single space (" ").
    /// - Parameter fileID: the module/file of the caller
    /// - Parameter function: the calling function
    /// - Parameter line: the calling line
    public static func printDebug(_ items: Any..., separator: String = " ", fileID: StaticString = #fileID, function: StaticString = #function, line: UInt = #line) {
        guard OS.isDebugBuild() else { return }
        let transformedItems = items.map(String.init(describing:))
        let finalMessage = transformedItems.joined(separator: separator) + "\n   At: \(fileID):\(line) in \(function)"
        GD.print(arg1: Variant(GString(stringLiteral: finalMessage)))
    }

    /// Converts one or more arguments of any type to string in the best way possible and prints them to the console.
    /// - Parameter items: The items to print into the Godot console.
    /// - Parameter separator: The separator to insert between items. The default is a single space (" ").
    public static func printRich(_ items: Any..., separator: String = " ") {
        let transformedItems = items.map(String.init(describing:))
        let finalMessage = transformedItems.joined(separator: separator)
        GD.printRich(arg1: Variant(GString(stringLiteral: finalMessage)))
    }

    /// Converts one or more arguments of any type to string in the best way possible and prints them to the console.
    /// - Parameter items: The items to print into the Godot console.
    /// - Parameter separator: The separator to insert between items. The default is a single space (" ").
    public static func printErr(_ items: Any..., separator: String = " ") {
        let transformedItems = items.map(String.init(describing:))
        let finalMessage = transformedItems.joined(separator: separator)
        GD.printerr(arg1: Variant (finalMessage))
    }

    public static func isEqualApprox(_ a: Float, _ b: Float) -> Bool {
        // This is imported with Double arguments but we need it with Float arguments.

        // Check for exact equality first, required to handle "infinity" values.
        if a == b {
            return true
        }

        // Then check for approximate equality.
        var tolerance = Float(CMP_EPSILON) * a.magnitude
        if tolerance < Float(CMP_EPSILON) {
            tolerance = Float(CMP_EPSILON)
        }
        return (a - b).magnitude < tolerance
    }

    public static func isEqualApprox(_ a: Float, _ b: Float, tolerance: Float) -> Bool {
        // Godot doesn't export this three-argument version of isEqualApprox.

	// Check for exact equality first, required to handle "infinity" values.
	if a == b {
            return true
	}
	// Then check for approximate equality.
        return (a - b).magnitude < tolerance
    }

    public static func isZeroApprox(_ s: Float) -> Bool {
        return s.magnitude < Float(CMP_EPSILON)
    }

    public static func cubicInterpolate(from: Float, to: Float, pre: Float, post: Float, weight: Float) -> Float {
        let constTerm = 2 * from
        let linearTerm = (-pre + to) * weight
        let quadraticTerm = (2 * pre - 5 * from + 4 * to - post) * (weight * weight)
        let cubicTerm = (-pre + 3 * from - 3 * to + post) * (weight * weight * weight)
        return 0.5 * (constTerm + linearTerm + quadraticTerm + cubicTerm)
    }

    public static func cubicInterpolateInTime(from: Float, to: Float, pre: Float, post: Float, weight: Float, toT: Float, preT: Float, postT: Float) -> Float {
	/* Barry-Goldman method */
	let t = (0 as Float).lerp(to: toT, withoutClampingWeight: weight)
        let a1 = pre.lerp(to: from, withoutClampingWeight: preT == 0 ? 0 : (t - preT) / -preT)
	let a2 = from.lerp(to: to, withoutClampingWeight: toT == 0 ? 0.5 : t / toT)
        let a3 = to.lerp(to: post, withoutClampingWeight: postT - toT == 0 ? 1 : (t - toT) / (postT - toT))
        let b1 = a1.lerp(to: a2, withoutClampingWeight: toT - preT == 0 ? 0 : (t - preT) / (toT - preT))
	let b2 = a2.lerp(to: a3, withoutClampingWeight: postT == 0 ? 1 : t / postT)
        return b1.lerp(to: b2, withoutClampingWeight: toT == 0 ? 0.5 : t / toT)
    }

    public static func acosf(_ x: Float) -> Float {
        return x < -1 ? Float(Double.pi) : x > 1 ? 0 : system_acosf(x)
    }
}
