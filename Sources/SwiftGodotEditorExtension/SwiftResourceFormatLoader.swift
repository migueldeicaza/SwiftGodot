//
//  SwiftResourceFormatLoader.swift
//  
//
//  Created by Miguel de Icaza on 9/22/23.
//

import Foundation
import SwiftGodot

class SwiftResourceFormatLoader: ResourceFormatLoader {
    var uids: [String:Int] = [:]
    var next = 0
    
    public required init () {
        super.init ()
    }

    required init(nativeHandle: UnsafeRawPointer) {
        fatalError("init(nativeHandle:) has not been implemented")
    }
    
    func pm (_ data: String = "", functionName: String = #function) {
        print ("SwiftResourceLoader: \(functionName) \(data)")
    }
    
    open override func _exists(path: String) -> Bool {
        pm ("Exists for \(path))")
        return true
    }
    
    open override func _getRecognizedExtensions() -> PackedStringArray {
        return PackedStringArray(["swift"])
    }
    
    open override func _handlesType(_ type: StringName) -> Bool {
        let ret = type.description == "Script"
        //pm ("ResourceFormatLoader: \(type.description) => \(ret)")
        return ret
    }
    
    open override func _getClassesUsed(path: String) -> PackedStringArray {
        pm ("Returnging empty for \(path)")
        return PackedStringArray()
    }
    
    open override func _getResourceUid(path: String) -> Int {
        if let v = uids [path] {
            return v
        }
        next += 1
        uids [path] = next
        return next
    }
    
    open override func _getResourceType(path: String) -> String {
        if path.hasSuffix(".swift") {
            return "SwiftScript"
        }
        pm("Returning empty for \(path)")
        return ""
    }
    
    open override func _recognizePath(_ path: String, type: StringName) -> Bool {
        if path.hasSuffix(".swift") {
            return true
        }
        pm ("Returning false for path=\(path) type=\(type)")
        return false
    }
    
    open override func _getResourceScriptClass(path: String) -> String {
        pm ("Returning empty for \(path)")
        return ""
    }
    
    open override func _renameDependencies(path: String, renames: GDictionary) -> GodotError {
        pm ("Request to rename \(path)")
        return .ok
    }
    
    open override func _getDependencies(path: String, addTypes: Bool) -> PackedStringArray {
        pm ("Returning empty path=\(path) addTypes=\(addTypes)")
        return PackedStringArray()
    }
    
    open override func _load(path: String, originalPath: String, useSubThreads: Bool, cacheMode: Int32) -> Variant {
        pm ("Request to load path=\(path) originalPath=\(originalPath) useSubthreads=\(useSubThreads) cacheMode=\(cacheMode)")
        var rootPath: String
        
        if path.hasPrefix("res://Sources/\(extensionName)/") || path == "res://Package.swift" {
            rootPath = ProjectSettings.globalizePath(path)
        } else {
            rootPath = ProjectSettings.globalizePath("res://Sources/\(extensionName)/\(path.dropFirst (6))")
        }
        pm ("RESOLVED PATH: \(rootPath)")
        guard let contents = try? String (contentsOfFile: rootPath) else {
            pm ("_LOAD: Failed to load the contents of \(rootPath)")
            return Variant (Int (GodotError.errCantOpen.rawValue))
        }
        let script = SwiftScript()
        script.resourcePath = path
        script.sourceCode = contents
        pm ("_LOAD: RETURNING SCRIPT")
        return Variant (script)
    }
}

