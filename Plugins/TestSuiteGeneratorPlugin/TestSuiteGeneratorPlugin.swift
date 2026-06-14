//
//  TestSuiteGeneratorPlugin.swift
//  SwiftGodot
//
//  Build-time plugin that scans a target's sources for @SwiftGodotTestSuite
//  classes and generates the TestRunnerNode.generatedSuites array.
//

import Foundation
import PackagePlugin

@main struct TestSuiteGeneratorPlugin: BuildToolPlugin {
    func createBuildCommands(context: PluginContext, target: Target) throws -> [Command] {
        guard let sourceFiles = target.sourceModule?.sourceFiles else {
            return []
        }

        let generatorPath = try context.tool(named: "TestSuiteGenerator").url

        let output = context.pluginWorkDirectoryURL
            .appending(path: "GeneratedSources")
            .appending(path: "TestSuites.generated.swift")

        let inputFiles = sourceFiles
            .filter { $0.url.pathExtension == "swift" }
            .map(\.url)

        let arguments =
            [
                "-o",
                output.path,
            ] + inputFiles.map(\.path)

        return [
            Command.buildCommand(
                displayName: "Generating SwiftGodot test suite list",
                executable: generatorPath,
                arguments: arguments,
                inputFiles: inputFiles,
                outputFiles: [output]
            )
        ]
    }
}
