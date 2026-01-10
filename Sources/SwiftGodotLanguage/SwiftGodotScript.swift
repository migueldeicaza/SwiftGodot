import SwiftGodot

@Godot(.tool)
final class SwiftScript: ScriptExtension {
    private var storedSourceCode: String = ""
    private var baseType: StringName = StringName("Node")
    private var className: StringName = StringName()

    func setBaseType(_ type: StringName) {
        baseType = type
    }

    override func _editorCanReloadFromFile() -> Bool {
        true
    }

    override func _canInstantiate() -> Bool {
        false
    }

    override func _getBaseScript() -> Script? {
        nil
    }

    override func _getGlobalName() -> StringName {
        className
    }

    override func _inheritsScript(_ script: Script?) -> Bool {
        false
    }

    override func _getInstanceBaseType() -> StringName {
        baseType
    }

    override func _instanceCreate(forObject: Object?) -> OpaquePointer? {
        nil
    }

    override func _placeholderInstanceCreate(forObject: Object?) -> OpaquePointer? {
        nil
    }

    override func _instanceHas(object: Object?) -> Bool {
        false
    }

    override func _hasSourceCode() -> Bool {
        !storedSourceCode.isEmpty
    }

    override func _getSourceCode() -> String {
        storedSourceCode
    }

    override func _setSourceCode(_ code: String) {
        updateFromSource(code)
    }

    override func _reload(keepState: Bool) -> GodotError {
        .ok
    }

    override func _getDocClassName() -> StringName {
        StringName()
    }

    override func _getDocumentation() -> TypedArray<VariantDictionary> {
        TypedArray<VariantDictionary>()
    }

    override func _getClassIconPath() -> String {
        ""
    }

    override func _hasMethod(_ method: StringName) -> Bool {
        false
    }

    override func _hasStaticMethod(_ method: StringName) -> Bool {
        false
    }

    override func _getScriptMethodArgumentCount(method: StringName) -> Variant? {
        Variant(0)
    }

    override func _getMethodInfo(method: StringName) -> VariantDictionary {
        VariantDictionary()
    }

    override func _isTool() -> Bool {
        false
    }

    override func _isValid() -> Bool {
        !storedSourceCode.isEmpty
    }

    override func _isAbstract() -> Bool {
        false
    }

    override func _getLanguage() -> ScriptLanguage? {
        swiftLanguageInstance
    }

    override func _hasScriptSignal(_ signal: StringName) -> Bool {
        false
    }

    override func _getScriptSignalList() -> TypedArray<VariantDictionary> {
        TypedArray<VariantDictionary>()
    }

    override func _hasPropertyDefaultValue(property: StringName) -> Bool {
        false
    }

    override func _getPropertyDefaultValue(property: StringName) -> Variant? {
        Variant(0)
    }

    override func _updateExports() {
    }

    override func _getScriptMethodList() -> TypedArray<VariantDictionary> {
        TypedArray<VariantDictionary>()
    }

    override func _getScriptPropertyList() -> TypedArray<VariantDictionary> {
        TypedArray<VariantDictionary>()
    }

    override func _getMemberLine(member: StringName) -> Int32 {
        -1
    }

    override func _getConstants() -> VariantDictionary {
        VariantDictionary()
    }

    override func _getMembers() -> TypedArray<StringName> {
        TypedArray<StringName>()
    }

    override func _isPlaceholderFallbackEnabled() -> Bool {
        false
    }

    override func _getRpcConfig() -> Variant? {
        Variant(0)
    }

    func updateFromSource(_ source: String) {
        storedSourceCode = source
        if let metadata = SwiftScriptMetadata.parse(source: source) {
            className = StringName(metadata.className)
            baseType = StringName(metadata.baseType)
        }
    }
}
