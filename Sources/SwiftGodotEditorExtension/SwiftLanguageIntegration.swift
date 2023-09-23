//
//  SwiftLanguageIntegration.swift
//  
//
//  Created by Miguel de Icaza on 9/22/23.
//

import Foundation
import SwiftGodot

class SwiftLanguageIntegration: ScriptLanguageExtension {
    static var shared = SwiftLanguageIntegration()
    
    required public init () {
        super.init ()
        // NEED: EditorNode.addInitCallback
    }
    
    required public init (nativeHandle: UnsafeRawPointer) {
        fatalError("Not needed")
    }
    
    func pm (_ data: String = "", functionName: String = #function) {
        print ("Integration: \(functionName) \(data)")
    }
    
    open override func _getName ()-> String {
        return "Swift Language Integration"
    }
    
    open override func _init () {
        print ("SwiftLanguageIntegration called")
        // TODO: could define useful things here
    }
    
    open override func _getType ()-> String {
        //pm()
        return "SwiftScript"
    }
    
    open override func _getExtension ()-> String {
        //pm()
        return "swift"
    }
    
    open override func _finish () {
        pm()
    }
    
    static var reservedSwiftWords = [
        "associatedtype", "class", "deinit", "enum", "extension", "fileprivate", "func", "import", "init", "inout", "internal", "let", "open", "operator", "private", "precedencegroup", "protocol", "public", "rethrows", "static", "struct", "subscript", "typealias", "var",
        "break", "case", "catch", "continue", "default", "defer", "do", "else", "fallthrough", "for", "guard", "if", "in", "repeat", "return", "throw", "switch", "where", "while",
        "Any", "as", "await", "catch", "false", "is", "nil", "rethrows", "self", "Self", "super", "throw", "throws", "true", "try",
        "_",
        "#available", "#colorLiteral", "#elseif", "#else", "#endif", "#fileLiteral", "#if", "#imageLiteral", "#keyPath", "#selector", "#sourceLocation"
    ]
    
    open override func _getReservedWords ()-> PackedStringArray {
        return PackedStringArray (SwiftLanguageIntegration.reservedSwiftWords)
    }
    
    open override func _isControlFlowKeyword (_ keyword: String)-> Bool {
        switch keyword.description {
        case "if", "break", "continue", "do", "else", "guard", "repeat", "while", "repeat", "throw", "try",
            "return", "defer", "fallthrough", "for":
            return true
        default:
            return false
        }
    }
    
    open override func _getCommentDelimiters ()-> PackedStringArray {
        return PackedStringArray (["//", "/*"])
    }
    
    open override func _getStringDelimiters ()-> PackedStringArray {
        return PackedStringArray (["\" \"", "@\" \""])
    }
    
    open override func _makeTemplate (_ template: String, className: String, baseClassName: String)-> Script {
        pm ("template: \(template) className: \(className) baseClassName: \(baseClassName)")
        var s = SwiftScript ()
        s.sourceCode = template
            .replacing("_CLASS_", with: className)
            .replacing("_BASE_", with: baseClassName)
        return s
    }
    
    struct SwiftScriptTemplate {
        let inherit: String
        let name: String
        let description: String
        let id: String
        let origin: Int
        let content: String
        
        func toDictionary () -> Dictionary {
            var dict = Dictionary()
            
            dict [Variant ("inherit")] = Variant (inherit)
            dict [Variant ("name")] = Variant (name)
            dict [Variant ("description")] = Variant (description)
            dict [Variant ("content")] = Variant (content)
            
            // TODO what to fill here?
            dict [Variant ("id")] = Variant (id)
            dict [Variant ("origin")] = Variant ("\(origin)")
            return dict
        }
    }
    var templates: [String: SwiftScriptTemplate] = [
        "Object": SwiftScriptTemplate(
            inherit: "Object",
            name: "Empty",
            description: "Empty template suitable for all subclasses",
            id: "object", origin: 0,
            content:
"""
import SwiftGodot

class _CLASS_: _BASE_ {
    required init(nativeHandle: UnsafeRawPointer) { fatalError ("Not necessary") }
    public required init () {
        super.init ()
    }
}

"""),
        "Node": SwiftScriptTemplate(inherit: "Node", name: "Default", description: "Base template for Node with default Godot cycle methods", id: "node", origin: 0, content:
"""
import SwiftGodot

public class _CLASS_: _BASE_ {
    // Called when the node enters the scene tree for the first time.
    public override func _ready() {
    }

    // Called every frame. 'delta' is the elapsed time since the previous frame.
    public override func _process(delta: Double) {
    }
}

""")
    ]
    
    open override func _getBuiltInTemplates (object: StringName)-> VariantCollection<Dictionary> {
        var collection = VariantCollection<Dictionary> ()

        if let template = templates [object.description] {
            collection.append (value: Variant (template.toDictionary()))
        } else {
            print (">> Got a request for an object we do not know of: \(object.description)")
        }
        
        return collection
    }
    
    open override func _isUsingTemplates ()-> Bool {
        return true
    }
    
    open override func _validate (script: String, path: String, validateFunctions: Bool, validateErrors: Bool, validateWarnings: Bool, validateSafeLines: Bool)-> Dictionary {
        pm ();
        // The return needs to push the following values:
        // - "valid" if valid, nothing if not
        // - "functions": array of strings listing functions
        // - "errors": array of dictionary containing ("line" (Int), "column" (Int), "message" (String)
        // - "warnings": array of dictionary containtng:
        //         Int ("end_line"));
        //         Int ("leftmost_column"));
        //         Int ("rightmost_column"));
        //         Int ("code"));
        //         String ("string_code"));
        //         String ("message"));
        // - "safelines"
        
        var ret = Dictionary ()
        ret [Variant ("valid")] = Variant (true)
        return ret
    }
    
    // The goal of this method is to say if a path is acceptable to our plugin
    // it is called from the "Create Script" dialog box, every time the user
    // edits the file path
    open override func _validatePath (_ path: String)-> String {
        pm()
        print ("_validatePath: \(path), returning that we are ok with it")
        return ""
    }
    
    open override func _createScript ()-> Object {
        pm ()
        return SwiftScript ()
    }
    
    open override func _hasNamedClasses ()-> Bool {
        pm("-> true")
        return true
    }
    
    open override func _supportsBuiltinMode ()-> Bool {
        pm("-> true")
        return true
    }
    
    open override func _supportsDocumentation ()-> Bool {
        return true
    }
    
    open override func _canInheritFromFile ()-> Bool {
        pm()
        return false
    }
    
    open override func _findFunction (className: String, functionName: String)-> Int32 {
        pm()
        return 0
    }
    
    open override func _makeFunction (className: String, functionName: String, functionArgs: PackedStringArray)-> String {
        pm()
        return ""
    }
    
    open override func _openInExternalEditor (script: Script?, line: Int32, column: Int32)-> GodotError {
        pm()
        return .ok
    }
    
    open override func _overridesExternalEditor ()-> Bool {
        pm()
        return false
    }
    
    open func _instanceCreate (forObject: Object?)-> OpaquePointer? {
        pm ("The object is: \(forObject)")
        return nil
    }
    
    open override func _completeCode (_ code: String, path: String, owner: Object?)-> Dictionary {
        pm()
        return Dictionary ()
    }
    
    open override func _lookupCode (_ code: String, symbol: String, path: String, owner: Object?)-> Dictionary {
        pm()
        return Dictionary ()
    }
    
    open override func _autoIndentCode (_ code: String, fromLine: Int32, toLine: Int32)-> String {
        pm()
        return ""
    }
    
    open override func _addGlobalConstant (name: StringName, value: Variant) {
        pm()
    }
    
    open override func _addNamedGlobalConstant (name: StringName, value: Variant) {
        pm()
    }
    
    open override func _removeNamedGlobalConstant (name: StringName) {
        pm()
    }
    
    open override func _threadEnter () {
        pm()
    }
    
    open override func _threadExit () {
        pm()
    }
    
    open override func _debugGetError ()-> String {
        pm()
        return ""
    }
    
    open override func _debugGetStackLevelCount ()-> Int32 {
        pm()
        return 0
    }
    
    open override func _debugGetStackLevelLine (level: Int32)-> Int32 {
        pm()
        return 0
    }
    
    open override func _debugGetStackLevelFunction (level: Int32)-> String {
        pm()
        return ""
    }
    
    open override func _debugGetStackLevelLocals (level: Int32, maxSubitems: Int32, maxDepth: Int32)-> Dictionary {
        pm()
        return Dictionary ()
    }
    
    open override func _debugGetStackLevelMembers (level: Int32, maxSubitems: Int32, maxDepth: Int32)-> Dictionary {
        pm()
        return Dictionary ()
    }
    
    open override func _debugGetGlobals (maxSubitems: Int32, maxDepth: Int32)-> Dictionary {
        pm()
        return Dictionary ()
    }
    
    open override func _debugParseStackLevelExpression (level: Int32, expression: String, maxSubitems: Int32, maxDepth: Int32)-> String {
        pm()
        return ""
    }
    
    open override func _debugGetCurrentStackInfo ()-> VariantCollection<Dictionary> {
        pm()
        return VariantCollection<Dictionary>()
    }
    
    open override func _reloadAllScripts () {
        pm()
    }
    
    open override func _reloadToolScript (_ script: Script?, softReload: Bool) {
        pm()
    }
    
    open override func _getRecognizedExtensions ()-> PackedStringArray {
        let r = PackedStringArray (["swift"])
        return r
    }
    
    open override func _getPublicFunctions ()-> VariantCollection<Dictionary> {
        pm()
        return VariantCollection<Dictionary>()
    }
    
    open override func _getPublicConstants ()-> Dictionary {
        pm()
        return Dictionary ()
    }
    
    open override func _getPublicAnnotations ()-> VariantCollection<Dictionary> {
        pm()
        return VariantCollection<Dictionary>()
    }
    
    open override func _profilingStart () {
        pm()
    }
    
    open override func _profilingStop () {
        pm()
    }
    
    open override func _frame () {
        //pm()
    }
    
    open override func _handlesGlobalClassType (_ type: String)-> Bool {
        pm("Type=\(type) returning false")
        return false
    }
    
    /// Contents:
    /// - "name": String
    /// - "base_type": String
    /// - "icon_path": String
    open override func _getGlobalClassName (path: String)-> Dictionary {
        pm("For path: \(path), returning empty dictionary")
        return Dictionary ()
    }
}

