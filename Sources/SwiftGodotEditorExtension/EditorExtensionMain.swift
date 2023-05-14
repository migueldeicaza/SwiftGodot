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
        print ("Script: \(functionName) (data)")
    }
    
    public override func _isTool() -> Bool {
        pm()
        return true
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
        pm ()
        return SwiftLanguageIntegration()
    }
    
    public override func _getConstants() -> Dictionary {
        pm ()
        return Dictionary()
    }
    
    public override func _updateExports() {
        pm ()
    }
    
    public override func _canInstantiate() -> Bool {
        pm()
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
    
    public override func _getBaseScript() -> Script {
        pm ()
        return self
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
    
    public override func _instanceHas(object: Object) -> Bool {
        pm ()
        return false
    }
    
    public override func _getInstanceBaseType() -> StringName {
        pm ()
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
    
    public override func _inheritsScript(script: Script) -> Bool {
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
        pm ("For property: \(property)")
        return false.toVariant()
    }
    
    public override func _hasPropertyDefaultValue(property: StringName) -> Bool {
        pm ()
        return false
    }
}

class SwiftLanguageIntegration: ScriptLanguageExtension {
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
        pm()
        return "SwiftScript"
    }
    
    open override func _getExtension ()-> String {
        pm()
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
        pm()
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
        let s = SwiftScript ()
        s.sourceCode = "Here we should put the template for template: \(template) className: \(className), baseClassName: \(baseClassName)"
        print (s)
        return s
    }
    
    open override func _getBuiltInTemplates (object: StringName)-> VariantCollection<Dictionary> {
        pm()
        return VariantCollection<Dictionary>()
    }
    
    open override func _isUsingTemplates ()-> Bool {
        return true
    }
    
    open override func _validate (script: String, path: String, validateFunctions: Bool, validateErrors: Bool, validateWarnings: Bool, validateSafeLines: Bool)-> Dictionary {
        pm ();
        return Dictionary ()
    }
    
    open override func _validatePath (path: String)-> String {
        pm()
        print ("Got path: \(path), returning empty")
        return ""
    }
    
    open override func _createScript ()-> Object {
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
        pm()
        return false
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
    
    open override func _openInExternalEditor (script: Script, line: Int32, column: Int32)-> GodotError {
        pm()
        return .ok
    }
    
    open override func _overridesExternalEditor ()-> Bool {
        pm()
        return false
    }
    
    open override func _completeCode (code: String, path: String, owner: Object)-> Dictionary {
        pm()
        return Dictionary ()
    }
    
    open override func _lookupCode (code: String, symbol: String, path: String, owner: Object)-> Dictionary {
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
    
    open override func _reloadToolScript (script: Script, softReload: Bool) {
        pm()
    }
    
    open override func _getRecognizedExtensions ()-> PackedStringArray {
        pm()
        let r = PackedStringArray ()
        r.append(value: "swift")
        print ("returning array with \(r.count) values")
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
        pm("Type=\(type)")
        return false
    }
    
    open override func _getGlobalClassName (path: String)-> Dictionary {
        pm()
        return Dictionary ()
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
        print ("SwiftREsourceSaver: \(functionName) \(data)")
    }
    
    open override func _recognize(resource: Resource) -> Bool {
        print ("Got \(resource.resourceName) at \(resource.resourcePath)")
        return true
    }
    
    open override func _setUid(path: String, uid: Int) -> GodotError {
        pm ()
        print ("path: \(path) uid=\(uid)")
        return .ok
    }
    
    open override func _getRecognizedExtensions(resource: Resource) -> PackedStringArray {
        pm ()
        return PackedStringArray(["swift"])
    }
    
    open override func _recognizePath(resource: Resource, path: String) -> Bool {
        pm ("path: \(path) resource: \(resource.resourceName)");
        return true
    }

    open override func _save(resource: Resource, path: String, flags: UInt32) -> GodotError {
        pm ("res=\(resource.resourceName) path: \(path) flags: \(flags)")
        guard let script = resource as? SwiftScript else {
            print ("_save the resource did not cas to a SwiftScript")
            return .errFileUnrecognized
        }
        let file = FileAccess.open(path: path, flags: .write)
        file.storeString(string: script.source)
        let err = file.getError()
        if err != .ok {
            return err
        }
        
        return .ok
    }
}
func setupScene (level: GDExtension.InitializationLevel) {
    if level == .editor {
        var e: Engine = Engine.shared
        register(type: SwiftLanguageIntegration.self)
        register(type: SwiftScript.self)
        register(type: SwiftResourceFormatSaver.self)
        var language = SwiftLanguageIntegration()
        let script = SwiftScript()
        let f = SwiftResourceFormatSaver()
        ResourceSaver.shared.addResourceFormatSaver(formatSaver: f)
        
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
