//
//  CoreGDUtilityFunctions.swift
//  SwiftGodot
//
//  Created by Miguel de Icaza on 10/16/25.
//

import SwiftGodotRuntime


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
}
