// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 16/10/24.
//  All code (c) 2024 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation
import PackagePlugin

/// Takes `.gdswift` files and generates `.gdextension` files from them.
@main struct ExtensionBuilderCommandPlugin: CommandPlugin {
    func performCommand(context: PluginContext, arguments: [String]) async throws {
        // Extract the target arguments (if there are none, we assume all).
        var argExtractor = ArgumentExtractor(arguments)
        let targetNames = argExtractor.extractOption(named: "target")
        let targets =
            targetNames.isEmpty
            ? context.package.targets
            : try context.package.targets(named: targetNames)

        let builder = try context.tool(named: "ExtensionBuilder").path

        // Iterate over the targets we've been asked to format.
        for target in targets {
            // Skip any type of target that doesn't have source files.
            // Note: We could choose to instead emit a warning or error here.
            guard let target = target.sourceModule else { continue }

            let inputFiles = target.sourceFiles.filter({ $0.path.extension == "gdswift" }).map { $0.path }
            if inputFiles.isEmpty {
                Diagnostics.warning("No .gdswift files found for \(target.name).")
                continue
            }

            let settings = try await GodotConfigFile(URL(fileURLWithPath: inputFiles.first!.string))
            let result = try packageManager.build(
                .target(target.name),
                parameters: .init(configuration: .debug, logging: .concise, echoLogs: true)
            )
            if result.succeeded {
                for artifact in result.builtArtifacts.filter({ $0.kind != .executable }) {
                    settings.set("macos.debug", artifact.path.string, section: "libraries")
                    settings.set("macos.release", artifact.path.string.replacing("debug", with: "release"), section: "libraries")
                }
            } else {
                Diagnostics.warning("Couldn't build \(target.name).")
            }

            let url = URL(fileURLWithPath: context.package.directory.appending("\(target.name).gdextension").string)
            try await settings.write(to: url)
            // var arguments = [context.package.directory, target.directory, context.package.directory]
            // arguments.append(contentsOf: inputFiles)
            // print(arguments)

            // // Invoke `sometool` on the target directory, passing a configuration
            // // file from the package directory.
            // let sometoolExec = URL(fileURLWithPath: builder.string)
            // let process = try Process.run(sometoolExec, arguments: arguments.map { $0.string })
            // process.waitUntilExit()

            // // Check whether the subprocess invocation was successful.
            // if process.terminationReason == .exit && process.terminationStatus == 0 {
            //     print("Exported gdextension file for \(target.name).")
            // } else {
            //     let problem = "\(process.terminationReason):\(process.terminationStatus)"
            //     Diagnostics.error("Exported gdextension failed: \(problem)")
            // }
        }

    }
}
