// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 16/10/24.
//  All code (c) 2024 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation
import PackagePlugin

/// Takes `.gdswift` files and generates `.gdextension` files from them.
@main struct ExtensionBuildingPlugin: BuildToolPlugin {
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
                displayName: "Generating .gdextension files",
                executable: builder,
                arguments: arguments,
                inputFiles: inputFiles,
                outputFiles: outputFiles
            )
        )

        return commands
    }
}
