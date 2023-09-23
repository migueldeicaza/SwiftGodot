//
//  SwiftResourceFormatSaver.swift
//  
//
//  Created by Miguel de Icaza on 9/22/23.
//

import Foundation
import SwiftGodot

class SwiftResourceFormatSaver: ResourceFormatSaver {
    public required init () {
        super.init ()
    }

    required init(nativeHandle: UnsafeRawPointer) {
        fatalError("init(nativeHandle:) has not been implemented")
    }
    
    func pm (_ data: String = "", functionName: String = #function) {
        print ("SwiftResourceSaver: \(functionName) \(data)")
    }
    
    open override func _recognize(resource: Resource?) -> Bool {
        if resource is SwiftScript {
            return true
        } else {
            print ("_recognize, can not handle this: method on Resource \(resource?.resourceName) at \(resource?.resourcePath)")
            return false
        }
    }
    
    open override func _setUid(path: String, uid: Int) -> GodotError {
        pm ()
        print ("path: \(path) uid=\(uid)")
        return .ok
    }
    
    open override func _getRecognizedExtensions(resource: Resource?) -> PackedStringArray {
        if let resource {
            print ("  -> resourceName=\(resource.resourceName)")
            print ("  -> resourcePath=\(resource.resourcePath)")
        }
        return PackedStringArray(["swift"])
    }
    
    open override func _recognizePath(resource: Resource?, path: String) -> Bool {
        pm ("path: \(path) resource: \(resource?.resourceName)");
        return true
    }

    
    open override func _save(resource: Resource?, path: String, flags: UInt32) -> GodotError {
        var rootPath = ProjectSettings.shared.globalizePath(path: "res://")
        let swiftSourceDir = "\(rootPath)/Sources/\(extensionName)"

        func ensureDirectory () -> Bool {
            if !FileManager.default.fileExists(atPath: swiftSourceDir) {
                do {
                    try FileManager.default.createDirectory(atPath: swiftSourceDir, withIntermediateDirectories: true)
                } catch {
                    print ("Failed to create source directory at \(error)")
                    return false
                }
            }
            return true
        }
        ensureDirectory()
        pm ("res=\(resource?.resourceName) path: \(path) flags: \(flags)")
        guard let script = resource as? SwiftScript else {
            print ("_save the resource did not cast to a SwiftScript")
            return .errFileUnrecognized
        }
        path.dropFirst(5)
        var actualPath = path.starts(with: "Sources/\(extensionName)/") ? path : "Sources/\(extensionName)/\(path.dropFirst(6))"
        print ("Going to save to [\(actualPath)]")
        guard let file = FileAccess.open(path: actualPath, flags: .write) else {
            return .errCantOpen
        }
        file.storeString(string: script.source)
        let err = file.getError()
        if err != .ok {
            print ("_save: Got an error from storing the string: \(err)")
            return err
        }
        file.close()
        return .ok
    }
}

