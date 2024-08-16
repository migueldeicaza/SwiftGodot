import SwiftGodotMacroLibrary
import SwiftSyntaxMacros

let allMacros: [String : any Macro.Type] = [
    "Callable": GodotCallable.self,
    "Export": GodotExport.self,
    "Godot": GodotMacro.self,
    "NativeHandleDiscarding": NativeHandleDiscardingMacro.self,
    "PickerNameProvider": PickerNameProviderMacro.self,
    "SceneTree": SceneTreeMacro.self,
    "exportGroup": GodotMacroExportGroup.self,
    "exportSubgroup": GodotMacroExportSubgroup.self,
    "initSwiftExtension": InitSwiftExtensionMacro.self,
    "signal": SignalMacro.self,
    "texture2DLiteral": Texture2DLiteralMacro.self,
]
