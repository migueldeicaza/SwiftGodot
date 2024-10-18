//
//  EntryPointGeneratorPlugin.swift
//  SwiftGodot
//
//  Created by Elijah Semyonov on 17/10/2024.
//

import Foundation
import PackagePlugin

@main struct EntryPointGeneratorPlugin: BuildToolPlugin {
    func createBuildCommands(context: PluginContext, target: Target) throws -> [Command] {
        guard let sourceFiles = target.sourceModule?.sourceFiles else {
            return []
        }
        
        let generatorPath = try context.tool(named: "EntryPointGenerator").path
        
        let output = context.pluginWorkDirectory.appending("GeneratedSources", "EntryPoint.generated.swift")
        
        let inputFiles = sourceFiles.map(\.path)
        
        let arguments = [
           "-o",
           output.string
        ] + inputFiles.map(\.string)
        
        return [
            Command.buildCommand(
                displayName: "Generating Godot entry point",
                executable: generatorPath,
                arguments: arguments,
                inputFiles: inputFiles,
                outputFiles: [output]
            )
        ]
    }
}
