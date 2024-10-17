// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 16/10/24.
//  All code (c) 2024 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation
import PackagePlugin

/// Generates the API for the SwiftGodot from the Godot exported Json API
@main struct SwiftCodeGeneratorPlugin: BuildToolPlugin {
    func createBuildCommands(context: PluginContext, target: Target) throws -> [Command] {

        guard let target = target.sourceModule else { return [] }
        var commands: [Command] = []
        let genSourcesDir = context.pluginWorkDirectory.appending("GeneratedSources")

        let builder = try context.tool(named: "ExtensionBuilder").path
        let inputFiles = target.sourceFiles.filter({ $0.path.extension == "gdswift" }).map { $0.path }
        var arguments = [context.package.directory, target.directory, genSourcesDir]
        arguments.append(contentsOf: inputFiles)
        let outputFiles = inputFiles.map { genSourcesDir.appending("\($0.stem).gdextension") }
        commands.append(
            Command.buildCommand(
                displayName: "Generating gdextension file",
                executable: builder,
                arguments: arguments,
                inputFiles: inputFiles,
                outputFiles: outputFiles
            )
        )

        return commands
    }
}
