//
// SwiftEditorPlugin.swift: this implement the editor plugin component
// that gets invoked for build/clean operations.
//
//
//  Created by Miguel de Icaza on 9/22/23.
//

import Foundation
import SwiftGodot

let extensionName = "SwiftExtension"
let extensionEntryPoint = "created_swift_entry"
let gdExtensionName = "swiftextension"

class SwiftEditorPlugin: EditorPlugin {
    static var shared: SwiftEditorPlugin = {
        SwiftEditorPlugin ()
    }()
    
    static func registerPlugin () {
        shared.requestNotifyEditorInit()
    }
    
    var editorInterface: EditorInterface?
    var editorBaseControl: Control?
    var editorSettings: EditorSettings?
    var errorDialog: AcceptDialog?
    var confirmCreateDialog: ConfirmationDialog?
    
    public required init () {
        super.init ()
        pm ("Created")
    }
    
    required init(nativeHandle: UnsafeRawPointer) {
        fatalError("init(nativeHandle:) has not been implemented")
    }
    
    func pm (_ data: String = "", functionName: String = #function) {
        print ("EditorPlugin: \(functionName) \(data)")
    }
    
    var _projectBaseDir: String?
    
    /// The full path to the project directory
    lazy var projectBaseDir: String = {
        if let dir = _projectBaseDir { return dir }
        return ProjectSettings.globalizePath("res://")
    } ()
    
    /// The path of the generated Package.swift file
    lazy var packageSwiftFile: String = {
        projectBaseDir + "/Package.swift"
    } ()
    
    /// The filename where we generate the Swift dynamic library type initialization
    lazy var typeRegistrationFile: String = {
        projectBaseDir + "Sources/\(extensionName)/_Startup.swift"
    }()
    
    /// Points to the directory where the Swift source files are stored
    lazy var swiftSourcesDir: String = {
        projectBaseDir + "Sources/\(extensionName)/"
    }()
    
    lazy var packageContents: String = {
        packageTemplate.replacing("@EXT_NAME@", with: extensionName)
    }()
    
    /// Points to the generated `.gdextension` file for the swift extension that contains all of our Swift types
    lazy var gdExtensionFile: String = {
        "\(projectBaseDir)/\(gdExtensionName).gdextension"
    }()
    
    func ensurePackageSwift () throws {
        if FileManager.default.fileExists(atPath: packageSwiftFile) {
            return
        }
        try packageContents.write(toFile: packageSwiftFile, atomically: true, encoding: .utf8)
    }
    
    func ensureTypeRegistration () throws {
        let files = try FileManager.default.contentsOfDirectory(atPath: swiftSourcesDir)
        var typeList = ""
        
        
        for file in files {
            guard file != "_Startup.swift" else { continue }
            guard file.hasSuffix(".swift") else { continue }
            let basename = String (file.dropLast (6))
            if typeList != "" {
                typeList.append(", ")
            }
            
            typeList.append ("\(basename).self")
        }

        let typeInit =
    """
    import SwiftGodot
    import SwiftGodotMacros
        
    #initSwiftExtension (cdecl: "\(extensionEntryPoint)", types: [\(typeList)])
    """
        try typeInit.write(toFile: typeRegistrationFile, atomically: false, encoding: .utf8)
    }
    
    func ensureSwiftExtension () throws {
        let extensionContents = """
    [configuration]
    entry_symbol = "\(extensionEntryPoint)"
    compatibility_minimum = 4.2
    
    [libraries]
    macos.debug = "res://bin/libSwiftExtension.dylib"
    macos.release = "res://bin/libSwiftExtension.dylib"
    """
        
        try extensionContents.write(toFile: gdExtensionFile, atomically: false, encoding: .utf8)
    }
    
    func ensureBaseline () throws {
        try ensurePackageSwift()
        try ensureTypeRegistration()
        try ensureSwiftExtension()
    }
    
    public override func _build() -> Bool {
        pm ("Starting build \(getpid())")
        defer {
            pm ("Completed build \(getpid())")
        }
        do {
            try ensureBaseline ()
        } catch {
            pm ("Failed to ensureBaseline \(error)")
            return false
        }
        do {
            let p = try Process.run(URL (filePath: "/usr/bin/swift"), arguments: ["build", "--package-path", projectBaseDir])
            p.waitUntilExit()
        } catch {
            pm ("Failed to run swift build: \(error)")
            return false
        }
        // TODO: for Apple platforms, I should lipo the binaries into a single one
        for platform in ["x86_64-apple-macosx", "arm64-apple-macosx"] {
            for kind in ["debug", "release"] {
                for library in ["SwiftGodot", "SwiftExtension", "SwiftGodotMacros"] {
                    // TODO: add support for Windows and Linux (dll and .so) but will need to
                    for ext in ["dylib"] {
                        let file = "lib\(library).\(ext)"
                        let source = "\(projectBaseDir)/.build/\(platform)/\(kind)/\(file)"
                        let target = "\(projectBaseDir)/bin/\(file)"
                        print ("Copying \(source) to \(target)")
                        try? FileManager.default.copyItem(atPath: source, toPath: target)
                    }
                }
            }
        }
        return true
    }
    
    public override func _clear() {
        do {
            try ensureBaseline()
        } catch {
            pm ("Failed to ensureBaseline \(error)")
            return
        }
        do {
            let p = try Process.run(URL (filePath: "/usr/bin/swift"), arguments: ["package", "clean", "--package-path", projectBaseDir])
            p.waitUntilExit()
        } catch {
            pm ("Failed to run swift build: \(error)")
        }
    }
    
    public override func _editorInit() {
        register()
        _enablePlugin()
    }
    
    public override func _enablePlugin() {
        super._enablePlugin()
        pm ()
        projectSettingsChanged.connect {
            self.pm ("Need to find the new project location")
        }
        
        editorInterface = self.getEditorInterface()
        
        editorBaseControl = editorInterface?.getBaseControl()
        editorSettings = editorInterface?.getEditorSettings()
        
        var errorDialog = AcceptDialog()
        editorBaseControl?.addChild(node: errorDialog)
        self.errorDialog = errorDialog
        
        var confirmCreateDialog = ConfirmationDialog ()
        editorBaseControl?.addChild(node: confirmCreateDialog)
        confirmCreateDialog.confirmed.connect {
            self.pm ("Must create the Package.swift file")
        }
        self.confirmCreateDialog = confirmCreateDialog
        
        var exportPlugin = EditorExportPlugin()
        addExportPlugin(exportPlugin)
    }
    
    public override func _disablePlugin() {
        super._disablePlugin()
        pm ()
    }

    // @EXT_NAME@
    //
    let packageTemplate = """
// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "@EXT_NAME@",
    platforms: [
        .macOS(.v13),
        .iOS ("16.0")
    ],
    products: [
        .library(
            name: "@EXT_NAME@",
            type: .dynamic,
            targets: ["@EXT_NAME@"]),
    ],
    dependencies: [
        .package(url: "https://github.com/migueldeicaza/SwiftGodot", branch: "editor-plugin"),
    ],
    targets: [
        .target(
            name: "@EXT_NAME@",
            dependencies: ["SwiftGodot", .product (name: "SwiftGodotMacros", package: "SwiftGodot")],
            swiftSettings: [.unsafeFlags (["-suppress-warnings"])],
            linkerSettings: [.unsafeFlags (
                ["-Xlinker", "-undefined",
                 "-Xlinker", "dynamic_lookup"])]),
    ])
"""
    
}
