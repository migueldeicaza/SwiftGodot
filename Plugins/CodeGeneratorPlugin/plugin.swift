//
// Generator's Plugin definition.swift
//
//
//  Created by Miguel de Icaza on 4/4/23.
//

import Foundation
import PackagePlugin

/// Generates the API for the SwiftGodot from the Godot exported Json API
@main struct SwiftCodeGeneratorPlugin: BuildToolPlugin {
    func createBuildCommands(context: PluginContext, target: Target) throws -> [Command] {
        // The per-module class distribution is data, not code: it lives in
        // ModuleClasses.json next to this plugin so the same lists can be
        // consumed by tests (see ClassDistributionTests) without duplication.
        let moduleClassesURL = context.package.directoryURL
            .appending(["Plugins", "CodeGeneratorPlugin", "ModuleClasses.json"])
        let lists = try ModuleClassLists(contentsOf: moduleClassesURL)

        guard let config = generationConfig(for: target.name, lists: lists) else {
            return []
        }

        let generator = try context.tool(named: "Generator").url

        let api = context.package.directoryURL
            .appending(["Sources", "ExtensionApi", "extension_api.json"])

        try FileManager.default.createDirectory(at: context.pluginWorkDirectoryURL, withIntermediateDirectories: true)

        let generatedSourcesDir = context.pluginWorkDirectoryURL
            .appending(path: "GeneratedSources")
            .appending(path: target.name)
        try FileManager.default.createDirectory(at: generatedSourcesDir, withIntermediateDirectories: true)

        let configurationDir = context.pluginWorkDirectoryURL.appending(path: "Configuration")
        try FileManager.default.createDirectory(at: configurationDir, withIntermediateDirectories: true)

        let classFilterFile = configurationDir.appending(path: "\(target.name)-classes.txt")
        let availableClassFilterFile = configurationDir.appending(path: "\(target.name)-available-classes.txt")
        let builtinFilterFile = configurationDir.appending(path: "\(target.name)-builtins.txt")

        if target.name == "SwiftGodot" {
            if config.generatedClassFiles.contains("Object.swift") {
                fatalError()
            }
        }
        try writeIfChanged(config.generatedClassFiles.joined(separator: "\n"), to: classFilterFile)
        try writeIfChanged(config.availableClassFiles.joined(separator: "\n"), to: availableClassFilterFile)
        try writeIfChanged(config.builtinFiles.joined(separator: "\n"), to: builtinFilterFile)

        var arguments = [api.path, generatedSourcesDir.path]
        var outputFiles: [URL] = []
        let supportsMultiProcess = (target as? SwiftSourceModuleTarget)?
            .compilationConditions
            .contains("SWIFTGODOT_WITH_MULTI_PROCESS") == true
#if os(Windows)
        let useCombinedOutput = true
#else
        let useCombinedOutput = shouldUseCombinedOutput()
#endif
        if useCombinedOutput {
            // Combine output to keep file counts low (always on Windows; opt-in via env var elsewhere).
            let letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
            for letter in letters {
                outputFiles.append(generatedSourcesDir.appending(path: "SwiftGodot\(letter).swift"))
            }
            arguments.append(context.package.directoryURL.appending(path: "doc").path)
            arguments.append("--combined")
        } else {
            outputFiles.append(contentsOf: config.builtinFiles.map { generatedSourcesDir.appending(["generated-builtin", $0]) })
            outputFiles.append(contentsOf: config.generatedClassFiles.map { generatedSourcesDir.appending(["generated", $0]) })
        }
        arguments.append(contentsOf: [
            "--class-filter", classFilterFile.path,
            "--available-class-filter", availableClassFilterFile.path,
            "--builtin-filter", builtinFilterFile.path
        ])
        for fallback in config.allowedClassFallbacks {
            arguments.append(contentsOf: ["--allowed-class-fallback", fallback])
        }
        arguments.append(supportsMultiProcess ? "--support-reinit" : "--enable-static-caches")

        var inputFiles: [URL] = [api, moduleClassesURL, classFilterFile, availableClassFilterFile, builtinFilterFile]

        if let preamble = config.preamble, !preamble.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            let preambleFile = configurationDir.appending(path: "\(target.name)-preamble.txt")
            try writeIfChanged(preamble, to: preambleFile)
            arguments.append(contentsOf: ["--preamble-file", preambleFile.path])
            inputFiles.append(preambleFile)
        }

        return [
            Command.buildCommand(
                displayName: "Generating SwiftGodot API for \(target.name)",
                executable: generator,
                arguments: arguments,
                inputFiles: inputFiles,
                outputFiles: outputFiles
            )
        ]
    }

    private func generationConfig(for targetName: String, lists: ModuleClassLists) -> GenerationConfig? {
        let runtime = lists.runtime
        let core = lists.core
        let gltf = lists.gltf
        let twoD = lists.twoD
        let threeD = lists.threeD
        let controls = lists.controls
        let xr = lists.xr
        let visualShaderNodes = lists.visualShaderNodes
        let editor = lists.editor

        switch targetName {
        case "SwiftGodotRuntime":
            return GenerationConfig(
                classFiles: runtime.uniqued(),
                builtinFiles: lists.knownBuiltin,
                preamble: nil,
                allowedClassFallbacks: [
                    "MainLoop=Object",
                    "Node=Object",
                    "ScriptBacktrace=RefCounted",
                ]
            )


        // Remove this target when we are able to split things up, for now
        // this target produces everything like we used to.
        //
        // This means that we do not need to bring the SwiftGodotRuntime, we
        // just generate everything the same way
        case "SwiftGodot":
            return GenerationConfig(
                classFiles: (core + controls + threeD + gltf + twoD + xr + editor + visualShaderNodes).uniqued(),
                builtinFiles: [],
                preamble: """
@_exported import SwiftGodotRuntime
@_spi(SwiftGodotRuntimePrivate) import SwiftGodotRuntime
""",
                dependencyClassFiles: runtime
            )

        case "SwiftGodotCore":
            return GenerationConfig(
                classFiles: core.uniqued(),
                builtinFiles: [],
                preamble: """
@_exported import SwiftGodotRuntime
@_spi(SwiftGodotRuntimePrivate) import SwiftGodotRuntime
@_spi(SwiftGodotRuntimePrivate) import SwiftGodotRuntime
""",
                dependencyClassFiles: runtime
            )
        case "SwiftGodotControls":
            fallthrough
        case "SwiftGodot2D":
            fallthrough
        case "SwiftGodot3D":
            fallthrough
        case "SwiftGodotGLTF":
            fallthrough
        case "SwiftGodotXR":
            fallthrough
        case "SwiftGodotEditor":
            fallthrough
        case "SwiftGodotVisualShaderNodes":
            let classFiles: [String]
            let preamble: String
            let dependencyClassFiles: [String]
            switch targetName {
            case "SwiftGodotControls":
                classFiles = controls
                preamble = """
@_exported import SwiftGodotCore
@_spi(SwiftGodotRuntimePrivate) import SwiftGodotCore
"""
                dependencyClassFiles = core + runtime
            case "SwiftGodot2D":
                classFiles = twoD
                preamble = """
@_exported import SwiftGodotCore
@_spi(SwiftGodotRuntimePrivate) import SwiftGodotCore
"""
                dependencyClassFiles = core + runtime
            case "SwiftGodot3D":
                classFiles = threeD
                preamble = """
@_exported import SwiftGodotCore
@_spi(SwiftGodotRuntimePrivate) import SwiftGodotCore
"""
                dependencyClassFiles = core + runtime
            case "SwiftGodotGLTF":
                classFiles = gltf
                preamble = """
@_exported import SwiftGodotCore
@_spi(SwiftGodotRuntimePrivate) import SwiftGodotCore
"""
                dependencyClassFiles = core + runtime
            case "SwiftGodotXR":
                classFiles = xr
                preamble = """
@_exported import SwiftGodotCore
@_exported import SwiftGodotControls
@_exported import SwiftGodot3D
@_spi(SwiftGodotRuntimePrivate) import SwiftGodotCore
@_spi(SwiftGodotRuntimePrivate) import SwiftGodotControls
@_spi(SwiftGodotRuntimePrivate) import SwiftGodot3D
"""
                dependencyClassFiles = core + controls + threeD + runtime
            case "SwiftGodotVisualShaderNodes":
                classFiles = visualShaderNodes
                preamble = """
@_exported import SwiftGodotCore
@_spi(SwiftGodotRuntimePrivate) import SwiftGodotCore
"""
                dependencyClassFiles = core + runtime
            case "SwiftGodotEditor":
                classFiles = editor
                preamble = """
@_exported import SwiftGodotCore
@_exported import SwiftGodotControls
@_exported import SwiftGodot3D
@_exported import SwiftGodotGLTF
@_spi(SwiftGodotRuntimePrivate) import SwiftGodotCore
@_spi(SwiftGodotRuntimePrivate) import SwiftGodotControls
@_spi(SwiftGodotRuntimePrivate) import SwiftGodot3D
@_spi(SwiftGodotRuntimePrivate) import SwiftGodotGLTF
"""
                dependencyClassFiles = core + controls + threeD + gltf + runtime
            default:
                classFiles = []
                preamble = """
@_exported import SwiftGodotCore
@_spi(SwiftGodotRuntimePrivate) import SwiftGodotCore
"""
                dependencyClassFiles = core + runtime
            }
            return GenerationConfig(
                classFiles: classFiles.uniqued(),
                builtinFiles: [],
                preamble: preamble,
                dependencyClassFiles: dependencyClassFiles
            )
        default:
            return nil
        }
    }

    private func shouldUseCombinedOutput() -> Bool {
        if let value = ProcessInfo.processInfo.environment["SWIFTGODOT_COMBINED_OUTPUT"]?.lowercased() {
            return value == "1" || value == "true" || value == "yes" || value == "y"
        }
        return ProcessInfo.processInfo.environment["XCODE_VERSION_ACTUAL"] != nil
    }

    private func writeIfChanged(_ contents: String, to file: URL) throws {
        let data = Data(contents.utf8)
        if let existing = try? Data(contentsOf: file), existing == data {
            return
        }
        try data.write(to: file, options: [.atomic])
    }
}

struct GenerationConfig {
    let classFiles: [String]
    let builtinFiles: [String]
    let preamble: String?
    let dependencyClassFiles: [String]
    let allowedClassFallbacks: [String]

    init(
        classFiles: [String],
        builtinFiles: [String],
        preamble: String?,
        dependencyClassFiles: [String] = [],
        allowedClassFallbacks: [String] = []
    ) {
        self.classFiles = classFiles
        self.builtinFiles = builtinFiles
        self.preamble = preamble
        self.dependencyClassFiles = dependencyClassFiles
        self.allowedClassFallbacks = allowedClassFallbacks
    }

    var generatedClassFiles: [String] {
        let dependencies = Set(dependencyClassFiles)
        return classFiles.filter { !dependencies.contains($0) }.uniqued()
    }

    var availableClassFiles: [String] {
        (classFiles + dependencyClassFiles).uniqued()
    }
}

private extension Array where Element == String {
    func uniqued() -> [String] {
        var seen: Set<String> = []
        return self.filter { seen.insert($0).inserted }
    }
}

/// The hand-maintained mapping of Godot classes to the Swift module each one is
/// generated into. This is *data*, loaded from `ModuleClasses.json` (which lives
/// next to this plugin), so the exact same lists can be referenced by tests
/// without duplicating them or parsing this source file. When Godot adds a class
/// it must be added to one of these arrays in the JSON.
struct ModuleClassLists: Decodable {
    let runtime: [String]
    let core: [String]
    let gltf: [String]
    let twoD: [String]
    let threeD: [String]
    let controls: [String]
    let xr: [String]
    let visualShaderNodes: [String]
    let editor: [String]
    let knownBuiltin: [String]

    init(contentsOf url: URL) throws {
        let data = try Data(contentsOf: url)
        self = try JSONDecoder().decode(ModuleClassLists.self, from: data)
    }
}

extension URL {
    func appending(_ paths: [String]) -> URL {
        return paths.reduce(self) { $0.appending(path: $1) }
    }
}
