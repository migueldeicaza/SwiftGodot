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
            guard let target = target.sourceModule, target.kind == .generic else { continue }
            let name = target.moduleName

            // read existing settings or make stubs
            let url = URL(fileURLWithPath: context.package.directory.appending("\(name).gdextension").string)
            let settings: GodotConfigFile
            do {
                settings = try await GodotConfigFile(url)
            } catch {
                settings = GodotConfigFile()
                settings.set("compatibility_minimum", 4.2, section: "configuration")
                settings.set("entry_symbol", "swift_entry_point", section: "configuration")
            }

            // build the target
            let result = try packageManager.build(
                .target(name),
                parameters: .init(configuration: .debug, logging: .concise, echoLogs: true)
            )

            // extract the artifacts if the build succeeded
            if result.succeeded {
                for artifact in result.builtArtifacts.filter({ $0.kind != .executable }) {
                    settings.set("macos.debug", artifact.path.string, section: "libraries")
                    settings.set("macos.release", artifact.path.string.replacing("debug", with: "release"), section: "libraries")

                    // TODO: add support for other platforms
                    let libGodotPath = artifact.path.string.replacing(name, with: "SwiftGodot")

                    settings.set("macos.debug", [libGodotPath: ""], section: "dependencies")
                    settings.set("macos.release", [libGodotPath.replacing("debug", with: "release"): ""], section: "dependencies")

                    // TODO: add correct dependencies for other platforms

                }
            } else {
                Diagnostics.warning("Couldn't build \(name).")
            }

            try await settings.write(to: url)
        }

    }
}
