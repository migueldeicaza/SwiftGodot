//
//  EditorExtensionMain.swift
//  
//
//  Created by Miguel de Icaza on 4/7/23.
//

import Foundation
import SwiftGodot

extension PackedStringArray {
    convenience init (_ values: [String]) {
        self.init ()
        for x in values {
            append(value: x)
        }
    }
}


class SwiftScript: ScriptExtension {
    var source: String
    
    public required init () {
        source = ""
        super.init ()
    }

    required init(nativeHandle: UnsafeRawPointer) {
        source = ""
        fatalError("init(nativeHandle:) has not been implemented")
    }
    
    func pm (_ data: String = "", functionName: String = #function) {
        print ("Script: \(functionName) \(data)")
    }
    
    public override func _isTool() -> Bool {
        //pm()
        return false
    }
    
    public override func _isValid() -> Bool {
        pm()
        return true
    }
    
    public override func _getMembers() -> VariantCollection<StringName> {
        pm ()
        return VariantCollection<StringName>()
    }
    
    public override func _getLanguage() -> ScriptLanguage {
        return SwiftLanguageIntegration.shared
    }
    
    public override func _getConstants() -> Dictionary {
        pm ()
        return Dictionary()
    }
    
    public override func _updateExports() {
        pm ()
    }
    
    public override func _canInstantiate() -> Bool {
        return true
    }
    
    public override func _getDocumentation() -> VariantCollection<Dictionary> {
        pm()
        return VariantCollection<Dictionary>()
    }
    
    public override func _getRpcConfig() -> Variant {
        pm ()
        return "Hello".toVariant()
    }
    
    /// Must return the script that provides the base class for this script.
    public override func _getBaseScript() -> Script? {
        pm ()
        
        return nil
    }
    
    public override func _getGlobalName() -> StringName {
        pm ()
        return "GlobalName"
    }
    
    public override func _getSourceCode() -> String {
        pm ()
        return source
    }
    
    public override func _hasSourceCode() -> Bool {
        pm ()
        return source != ""
    }
    
    public override func _hasMethod(method: StringName) -> Bool {
        pm (method.description)
        return true
    }
    
    public override func _reload(keepState: Bool) -> GodotError {
        pm ("\(keepState)")
        return .ok
    }
    
    public override func _instanceHas(object: Object?) -> Bool {
        pm ()
        return false
    }
    
    public override func _getInstanceBaseType() -> StringName {
        guard let regex = try? Regex ("class [A-Za-z_][A-Za-z0-9_]*\\s*:\\s*([A-Za-z_][A-Za-z0-9_]*)") else {
            pm ("Failed to compile poor man's swift parser regex")
            return ""
        }
        for line in source.split(separator: "\n") {
            let res = line.matches(of: regex)
            if res.count == 0 || res [0].count != 2 {
                continue
            }
            if let base = res [0][1].substring {
                pm ("Returning: \(base)")
                return StringName (String (base))
            }
        }
        pm ("Did not find a base type")
        return ""
    }
    
    public override func _getScriptMethodList() -> VariantCollection<Dictionary> {
        pm ()
        return VariantCollection<Dictionary>()
    }
    
    public override func _getScriptSignalList() -> VariantCollection<Dictionary> {
        pm ()
        return VariantCollection<Dictionary>()
    }
    
    public override func _getScriptPropertyList() -> VariantCollection<Dictionary> {
        pm ()
        return VariantCollection<Dictionary>()
    }
    
    public override func _inheritsScript(script: Script?) -> Bool {
        pm ()
        return false
    }
    
    public override func _isPlaceholderFallbackEnabled() -> Bool {
        pm ()
        return false
    }
    
    public override func _setSourceCode(code: String) {
        pm ()
        source = code
    }
    
    public override func _getMemberLine(member: StringName) -> Int32 {
        pm ()
        return 1
    }
    
    public override func _getMethodInfo(method: StringName) -> Dictionary {
        return Dictionary()
    }
    
    public override func _hasScriptSignal(signal: StringName) -> Bool {
        pm ()
        return false
    }
    
    public override func _editorCanReloadFromFile() -> Bool {
        pm ()
        return false
    }
    
    public override func _getPropertyDefaultValue(property: StringName) -> Variant {
        pm ("For property: \(property.description)")
        return false.toVariant()
    }
    
    public override func _hasPropertyDefaultValue(property: StringName) -> Bool {
        pm (" property is: \(property.description) -> false")
        return false
    }
}

class SwiftLanguageIntegration: ScriptLanguageExtension {
    static var shared = SwiftLanguageIntegration()
    
    required public init () {
        super.init ()
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
    
    open override func _getReservedWords ()-> PackedStringArray {
        pm()
        return PackedStringArray (["class", "func", "struct", "var"])
    }
    
    open override func _isControlFlowKeyword (keyword: String)-> Bool {
        pm(keyword)
        switch keyword.description {
        case "if", "break", "continue", "while", "repeat", "throw", "try",
            "return":
            return true
        default:
            return false
        }
    }
    
    open override func _getCommentDelimiters ()-> PackedStringArray {
        pm()
        return PackedStringArray (["//", "/*"])
    }
    
    open override func _getStringDelimiters ()-> PackedStringArray {
        pm()
        return PackedStringArray (["\" \"", "@\" \""])
    }
    
    open override func _makeTemplate (template: String, className: String, baseClassName: String)-> Script {
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
using SwiftGodot

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
    open override func _validatePath (path: String)-> String {
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
    
    open override func _completeCode (code: String, path: String, owner: Object?)-> Dictionary {
        pm()
        return Dictionary ()
    }
    
    open override func _lookupCode (code: String, symbol: String, path: String, owner: Object?)-> Dictionary {
        pm()
        return Dictionary ()
    }
    
    open override func _autoIndentCode (code: String, fromLine: Int32, toLine: Int32)-> String {
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
    
    open override func _reloadToolScript (script: Script?, softReload: Bool) {
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
    
    open override func _handlesGlobalClassType (type: String)-> Bool {
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

class SwiftResourceFormatLoader: ResourceFormatLoader {
    public required init () {
        super.init ()
    }

    required init(nativeHandle: UnsafeRawPointer) {
        fatalError("init(nativeHandle:) has not been implemented")
    }
    
    func pm (_ data: String = "", functionName: String = #function) {
        print ("SwiftResourceSaver: \(functionName) \(data)")
    }
    
    open override func _exists(path: String) -> Bool {
        pm ("Exists for \(path))")
        return true
    }
    
    open override func _getRecognizedExtensions() -> PackedStringArray {
        return PackedStringArray(["swift"])
    }
    
    open override func _handlesType(type: StringName) -> Bool {
        let ret = type.description == "Script"
        pm ("ResourceFormatLoader: \(type.description) => \(ret)")
        return ret
    }
    
    open override func _getClassesUsed(path: String) -> PackedStringArray {
        pm ("Returnging empty for \(path)")
        return PackedStringArray()
    }
    
    open override func _getResourceUid(path: String) -> Int {
        pm ("Returning 1 for \(path)")
        return 1
    }
    
    open override func _getResourceType(path: String) -> String {
        if path.hasSuffix(".swift") {
            return "SwiftScript"
        }
        pm("Returning empty for \(path)")
        return ""
    }
    
    open override func _recognizePath(path: String, type: StringName) -> Bool {
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
    
    open override func _renameDependencies(path: String, renames: Dictionary) -> GodotError {
        pm ("Request to rename \(path)")
        return .ok
    }
    
    open override func _getDependencies(path: String, addTypes: Bool) -> PackedStringArray {
        pm ("Returning empty path=\(path) addTypes=\(addTypes)")
        return PackedStringArray()
    }
    
    open override func _load(path: String, originalPath: String, useSubThreads: Bool, cacheMode: Int32) -> Variant {
        pm ("Request to load path=\(path) originalPath=\(originalPath) useSubthreads=\(useSubThreads) cacheMode=\(cacheMode) -> RETURNING 1")
        var rootPath = ProjectSettings.shared.globalizePath(path: path)
        guard let contents = try? String (contentsOfFile: rootPath) else {
            return Variant (Int (GodotError.errCantOpen.rawValue))
        }
        let script = SwiftScript()
        script.resourcePath = path
        script.sourceCode = contents
        return Variant (script)
    }
}

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
        
        pm ("res=\(resource?.resourceName) path: \(path) flags: \(flags)")
        guard let script = resource as? SwiftScript else {
            print ("_save the resource did not cast to a SwiftScript")
            return .errFileUnrecognized
        }
        guard let file = FileAccess.open(path: path, flags: .write) else {
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
func setupScene (level: GDExtension.InitializationLevel) {
    if level == .editor {
        var e: Engine = Engine.shared
        register(type: SwiftLanguageIntegration.self)
        register(type: SwiftScript.self)
        register(type: SwiftResourceFormatSaver.self)
        register(type: SwiftResourceFormatLoader.self)
        var language = SwiftLanguageIntegration()
        let script = SwiftScript()
        let f = SwiftResourceFormatSaver()
        ResourceSaver.shared.addResourceFormatSaver(formatSaver: f)
        let l = SwiftResourceFormatLoader ()
        ResourceLoader.shared.addResourceFormatLoader(formatLoader: l, atFront: false)
        
        e.registerScriptLanguage(language: language)
    }
}
@_cdecl ("swift_godot_editor_exension_main")
public func swift_entry_point(
    interfacePtr: OpaquePointer?,
    libraryPtr: OpaquePointer?,
    extensionPtr: OpaquePointer?) -> UInt8
{
    print ("SwiftGodotEditorExtension: Starting up")
    guard let interfacePtr, let libraryPtr, let extensionPtr else {
        return 0
    }
    initializeSwiftModule(interfacePtr, libraryPtr, extensionPtr, initHook: setupScene, deInitHook: { x in })
    return 1
}
