// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 16/10/24.
//  All code (c) 2024 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation
import PackagePlugin

/// Generates/updates `.gdextension` files for library targets.
@main struct ExtensionBuilderCommandPlugin: CommandPlugin {
    func performCommand(context: PluginContext, arguments: [String]) async throws {
        // Extract the target arguments (if there are none, we assume all).
        var argExtractor = ArgumentExtractor(arguments)
        let targetNames = argExtractor.extractOption(named: "target")
        let targets =
            targetNames.isEmpty
            ? context.package.targets
            : try context.package.targets(named: targetNames)

        // Iterate over the targets we've been asked to format.
        for target in targets {
            // Skip any type of target that doesn't have source files.
            // Note: We could choose to instead emit a warning or error here.
            guard let target = target.sourceModule, target.kind == .generic else { continue }
            let name = target.moduleName

            let url = URL(fileURLWithPath: context.package.directory.appending("\(name).gdextension").string)
            let settings: GodotConfigFile
            do {
                settings = try await GodotConfigFile(url)
            } catch {
                settings = GodotConfigFile()
                settings.set("compatibility_minimum", 4.2, section: "configuration")
                settings.set("entry_symbol", "swift_entry_point", section: "configuration")
            }

            let result = try packageManager.build(
                .target(name),
                parameters: .init(configuration: .debug, logging: .concise, echoLogs: true)
            )

            if result.succeeded {
                for artifact in result.builtArtifacts.filter({ $0.kind != .executable }) {
                    settings.set("macos.debug", artifact.path.string, section: "libraries")
                    settings.set("macos.debug", ["SwiftGodot": ""], section: "dependencies")
                    settings.set("macos.release", artifact.path.string.replacing("debug", with: "release"), section: "libraries")
                    settings.set("macos.release", ["SwiftGodot": ""], section: "dependencies")
                }
            } else {
                Diagnostics.warning("Couldn't build \(name).")
            }

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
