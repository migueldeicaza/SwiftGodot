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
    lazy var projectBaseDir: String = {
        if let dir = _projectBaseDir { return dir }
        return ProjectSettings.globalizePath("res://")
    } ()
    
    lazy var packageSwiftFile: String = {
        projectBaseDir + "/Package.swift"
    } ()
    
    lazy var packageContents: String = {
        packageTemplate.replacing("@EXT_NAME@", with: extensionName)
    } ()
    
    func ensurePackageSwift () throws {
        if FileManager.default.fileExists(atPath: packageSwiftFile) {
            return
        }
        try packageContents.write(toFile: packageSwiftFile, atomically: true, encoding: .utf8)
    }
    
    public override func _build() -> Bool {
        pm ("Starting build \(getpid())")
        defer {
            pm ("Completed build \(getpid())")
        }
        do {
            try ensurePackageSwift()
        } catch {
            pm ("Failed to ensurePackageSwift \(error)")
            return false
        }
        do {
            let p = try Process.run(URL (filePath: "/usr/bin/swift"), arguments: ["build", "--package-path", projectBaseDir])
            p.waitUntilExit()
        } catch {
            pm ("Failed to run swift build: \(error)")
            return false
        }
        return true
    }
    
    public override func _clear() {
        do {
            try ensurePackageSwift()
        } catch {
            pm ("Failed to ensurePackageSwift \(error)")
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
            dependencies: ["SwiftGodot"],
            swiftSettings: [.unsafeFlags (["-suppress-warnings"])],
            linkerSettings: [.unsafeFlags (
                ["-Xlinker", "-undefined",
                 "-Xlinker", "dynamic_lookup"])]),
    ])
"""
    
}
