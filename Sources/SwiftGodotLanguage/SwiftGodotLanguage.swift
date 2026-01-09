//
import SwiftGodot

let swiftLanguageName = "Swift"
let swiftLanguageType = "Swift"
let swiftLanguageExtension = "swift"

private let swiftReservedWords: Set<String> = [
    "actor", "associatedtype", "async", "await", "break", "case", "catch", "class", "continue", "convenience",
    "default", "defer", "deinit", "do", "else", "enum", "extension", "fallthrough", "false", "fileprivate",
    "final", "for", "func", "guard", "if", "import", "in", "init", "inout", "internal", "is", "lazy",
    "let", "nil", "nonisolated", "operator", "precedencegroup", "private", "protocol", "public", "repeat",
    "rethrows", "return", "self", "Self", "static", "struct", "subscript", "super", "switch", "throw",
    "throws", "true", "try", "typealias", "var", "where", "while"
]

private let swiftControlFlowKeywords: Set<String> = [
    "break", "case", "continue", "default", "defer", "do", "else", "fallthrough", "for", "guard", "if",
    "repeat", "return", "switch", "throw", "throws", "try", "while"
]

@Godot(.tool)
final class SwiftScriptLanguage: ScriptLanguageExtension {
    override class var classInitializationLevel: ExtensionInitializationLevel { .core }

    override func _getName() -> String {
        swiftLanguageName
    }

    override func _init() {
    }

    override func _getType() -> String {
        swiftLanguageType
    }

    override func _getExtension() -> String {
        swiftLanguageExtension
    }

    override func _getRecognizedExtensions() -> PackedStringArray {
        PackedStringArray([swiftLanguageExtension])
    }

    override func _finish() {
    }

    override func _getReservedWords() -> PackedStringArray {
        PackedStringArray(swiftReservedWords.sorted())
    }

    override func _isControlFlowKeyword(_ keyword: String) -> Bool {
        swiftControlFlowKeywords.contains(keyword)
    }

    override func _getCommentDelimiters() -> PackedStringArray {
        ["//", "/* */"]
    }

    override func _getDocCommentDelimiters() -> PackedStringArray {
        ["///", "/** */"]
    }

    override func _getStringDelimiters() -> PackedStringArray {
        ["\"", "\"\"\""]
    }

    override func _makeTemplate(_ template: String, className: String, baseClassName: String) -> Script? {
        let script = SwiftScript()
        let content = template.replacingOccurrences(of: "${CLASS_NAME}", with: className)
        script.sourceCode = content
        script.setBaseType(StringName(baseClassName))
        return script
    }

    override func _getBuiltInTemplates(object: StringName) -> TypedArray<VariantDictionary> {
        let templates = [
            makeTemplateDictionary(
                id: 1,
                name: "Swift Node",
                description: "Basic Swift Node with @Godot macro",
                baseClass: "Node",
                content: swiftTemplate(baseClass: "Node")
            ),
            makeTemplateDictionary(
                id: 2,
                name: "Swift Node2D",
                description: "2D Swift node with _ready and _process",
                baseClass: "Node2D",
                content: swiftTemplate(baseClass: "Node2D")
            ),
            makeTemplateDictionary(
                id: 3,
                name: "Swift Node3D",
                description: "3D Swift node with _ready and _process",
                baseClass: "Node3D",
                content: swiftTemplate(baseClass: "Node3D")
            )
        ]

        return TypedArray<VariantDictionary>(templates)
    }

    override func _isUsingTemplates() -> Bool {
        true
    }

    override func _validate(script: String, path: String, validateFunctions: Bool, validateErrors: Bool, validateWarnings: Bool, validateSafeLines: Bool) -> VariantDictionary {
        var result = VariantDictionary()
        setValue(&result, "valid", true)

        if validateFunctions {
            setValue(&result, "functions", PackedStringArray())
        }
        if validateErrors {
            setValue(&result, "errors", VariantArray())
        }
        if validateWarnings {
            setValue(&result, "warnings", VariantArray())
        }
        if validateSafeLines {
            setValue(&result, "safe_lines", PackedInt32Array())
        }

        return result
    }

    override func _validatePath(_ path: String) -> String {
        ""
    }

    override func _createScript() -> Object? {
        SwiftScript()
    }

    override func _hasNamedClasses() -> Bool {
        false
    }

    override func _supportsBuiltinMode() -> Bool {
        false
    }

    override func _supportsDocumentation() -> Bool {
        false
    }

    override func _canInheritFromFile() -> Bool {
        true
    }

    override func _findFunction(_ function: String, code: String) -> Int32 {
        -1
    }

    override func _makeFunction(className: String, functionName: String, functionArgs: PackedStringArray) -> String {
        let count = Int(functionArgs.size())
        let args = (0..<count).map { "\(functionArgs[$0]): <#Type#>" }.joined(separator: ", ")
        return "func \(functionName)(\(args)) {\n    <#code#>\n}"
    }

    override func _canMakeFunction() -> Bool {
        true
    }

    override func _openInExternalEditor(script: Script?, line: Int32, column: Int32) -> GodotError {
        .errUnavailable
    }

    override func _overridesExternalEditor() -> Bool {
        false
    }

    override func _preferredFileNameCasing() -> ScriptLanguage.ScriptNameCasing {
        .pascalCase
    }

    override func _completeCode(_ code: String, path: String, owner: Object?) -> VariantDictionary {
        var result = VariantDictionary()
        setValue(&result, "result", 0)
        setValue(&result, "options", VariantArray())
        setValue(&result, "force", false)
        setValue(&result, "call_hint", "")
        return result
    }

    override func _lookupCode(_ code: String, symbol: String, path: String, owner: Object?) -> VariantDictionary {
        var result = VariantDictionary()
        setValue(&result, "result", 0)
        setValue(&result, "type", 0)
        return result
    }

    override func _autoIndentCode(_ code: String, fromLine: Int32, toLine: Int32) -> String {
        code
    }

    override func _addGlobalConstant(name: StringName, value: Variant?) {
    }

    override func _addNamedGlobalConstant(name: StringName, value: Variant?) {
    }

    override func _removeNamedGlobalConstant(name: StringName) {
    }

    override func _threadEnter() {
    }

    override func _threadExit() {
    }

    override func _debugGetError() -> String {
        ""
    }

    override func _debugGetStackLevelCount() -> Int32 {
        0
    }

    override func _debugGetStackLevelLine(level: Int32) -> Int32 {
        -1
    }

    override func _debugGetStackLevelFunction(level: Int32) -> String {
        ""
    }

    override func _debugGetStackLevelSource(level: Int32) -> String {
        ""
    }

    override func _debugGetStackLevelLocals(level: Int32, maxSubitems: Int32, maxDepth: Int32) -> VariantDictionary {
        VariantDictionary()
    }

    override func _debugGetStackLevelMembers(level: Int32, maxSubitems: Int32, maxDepth: Int32) -> VariantDictionary {
        VariantDictionary()
    }

    override func _debugGetStackLevelInstance(level: Int32) -> OpaquePointer? {
        nil
    }

    override func _debugGetGlobals(maxSubitems: Int32, maxDepth: Int32) -> VariantDictionary {
        VariantDictionary()
    }

    override func _debugParseStackLevelExpression(level: Int32, expression: String, maxSubitems: Int32, maxDepth: Int32) -> String {
        ""
    }

    override func _debugGetCurrentStackInfo() -> TypedArray<VariantDictionary> {
        TypedArray<VariantDictionary>()
    }

    override func _reloadAllScripts() {
    }

    override func _reloadScripts(_ scripts: VariantArray, softReload: Bool) {
    }

    override func _reloadToolScript(_ script: Script?, softReload: Bool) {
    }

    override func _getPublicFunctions() -> TypedArray<VariantDictionary> {
        TypedArray<VariantDictionary>()
    }

    override func _getPublicConstants() -> VariantDictionary {
        VariantDictionary()
    }

    override func _getPublicAnnotations() -> TypedArray<VariantDictionary> {
        TypedArray<VariantDictionary>()
    }

    override func _profilingStart() {
    }

    override func _profilingStop() {
    }

    override func _profilingSetSaveNativeCalls(enable: Bool) {
    }

    override func _frame() {
    }

    override func _handlesGlobalClassType(_ type: String) -> Bool {
        false
    }

    override func _getGlobalClassName(path: String) -> VariantDictionary {
        VariantDictionary()
    }

    private func setValue<T: VariantConvertible>(_ dict: inout VariantDictionary, _ key: String, _ value: T) {
        dict[key] = value.toFastVariant()
    }

    private func makeTemplateDictionary(id: Int, name: String, description: String, baseClass: String, content: String) -> VariantDictionary {
        var dict = VariantDictionary()
        setValue(&dict, "inherit", baseClass)
        setValue(&dict, "name", name)
        setValue(&dict, "description", description)
        setValue(&dict, "content", content)
        setValue(&dict, "id", id)
        setValue(&dict, "origin", 0)
        return dict
    }

    private func swiftTemplate(baseClass: String) -> String {
        """
        import SwiftGodot

        @Godot
        final class ${CLASS_NAME}: \(baseClass) {
            override func _ready() {
            }

            override func _process(delta: Double) {
            }
        }
        """
    }
}
