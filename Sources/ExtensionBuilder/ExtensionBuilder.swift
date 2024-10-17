// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 16/10/24.
//  All code (c) 2024 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

// This is a big old hack right now.
// See https://github.com/migueldeicaza/SwiftGodot/pull/577 for more discussion.
//
// If we decide that some version of this is worth keeping, I will obviously
// clean it up and make it more robust, add tests, fill out the other platforms,
// etc.

import Foundation

@main struct ExtensionBuilder {
    let packageDirectory: URL
    let outputDirectory: URL
    let targetDirectory: URL
    let inXcode = false

    /// Entry point for the builder.
    ///
    /// Extracts the arguments from the command line and
    /// kicks off a build.
    static func main() async {
        let args = CommandLine.arguments
        guard args.count >= 4 else {
            print(
                """
                Usage: builder <package-directory> <target-directory> <output-directory> <input.gdextension> {<input.gdextension> ...}
                """
            )
            return
        }

        let packageDirectoryURL = URL(fileURLWithPath: args[1])
        let targetDirectoryURL = URL(fileURLWithPath: args[2])
        let outputDirectoryURL = URL(fileURLWithPath: args[3])
        try? FileManager.default.createDirectory(at: outputDirectoryURL, withIntermediateDirectories: true)

        let builder = ExtensionBuilder(
            packageDirectory: packageDirectoryURL,
            outputDirectory: outputDirectoryURL,
            targetDirectory: targetDirectoryURL
        )

        await builder.process(inputs: args.dropFirst(4))
    }

    /// Returns the build directory for a given arch/platform/config.
    func buildDirectory(arch: String, platform: String, config: String) -> URL? {
        guard !inXcode else { return nil }

        var u = outputDirectory
        repeat {
            u = u.deletingLastPathComponent()
            if u.path.isEmpty {
                return nil
            }
            if u.lastPathComponent == ".build" {
                break
            }
        } while true

        return u.appending(path: "\(arch)-\(platform)").appending(path: config)
    }

    /// Returns the path to the built library for a given arch/platform/config.
    func libraryPath(arch: String, platform: String, mode: String) -> URL? {
        guard let url = buildDirectory(arch: arch, platform: platform, config: mode) else { return nil }
        return url.appending(path: "lib\(targetName).dylib")
    }

    /// The name of the target.
    /// Assumed to be the name of the target directory.
    // TODO: Is there a more authoritative way to get this? Maybe from the plugin context?
    var targetName: String {
        targetDirectory.lastPathComponent
    }

    /// Process the input files.
    func process(inputs: Array<String>.SubSequence) async {
        for file in inputs {
            let inputURL = URL(fileURLWithPath: file)
            let outputURL = outputDirectory.appending(path: inputURL.lastPathComponent).deletingPathExtension().appendingPathExtension("gdextension")
            do {
                try await process(inputURL, outputURL: outputURL)
            } catch {
                print("failed to process \(inputURL) to \(outputURL): \(error)")
            }
        }
    }

    /// Process a single input file.
    func process(_ inputURL: URL, outputURL: URL) async throws {
        // read the input file
        let content = try await GodotConfigFile(inputURL)

        // insert the library paths
        insertLibraryPaths(content)

        #if LOOK_FOR_EXPORT_KEY
            // look for a special key in the input file, and
            // if it's there, treat it as a path to write an additional
            // copy of the output to
            let outputPath = content.get("export", section: "swiftgodot")

        #endif

        // strip our keys from the output
        content.remove(section: "swiftgodot")

        #if APPEND_LOG  // This is a hack to help debug the builder.
            var log = """
                     package: \(packageDirectory)
                     target: \(targetDirectory)
                     output: \(outputDirectory)
                     cwd: \(FileManager.default.currentDirectoryPath)
                     env:

                """
            for e in ProcessInfo.processInfo.environment {
                log += "\(e.key) = \(e.value)\n"
            }

            content.set("log", log, section: "swiftgodot")
        #endif

        try await content.write(to: outputURL)

        #if LOOK_FOR_EXPORT_KEY
            // The idea was that we could use an extra key in the
            // input file to specify a location to export a copy of
            // the generated gdextension file to.
            // This would allow us to write it directly into the Godot project.
            //
            // Sadly, the SPM sandboxing of the build plugin stops us from
            // doing this, so it's not really useful.

            if let outputPath,
                let containerURL = URL(string: outputPath, relativeTo: outputDirectory)
            {
                try FileManager.default.createDirectory(at: containerURL, withIntermediateDirectories: true)
                let pathURL = containerURL.appending(path: outputURL.lastPathComponent)
                try await content.write(to: pathURL)
            }
        #endif
    }

    /// Write the library keys into the config file.
    func insertLibraryPaths(_ content: GodotConfigFile) {
        let platforms = [
            ("macos", ["arm64", "x86_64"], "apple-macosx")
        ]

        for config in ["debug", "release"] {
            for (key, archs, platform) in platforms {
                for arch in archs {
                    if let url = libraryPath(arch: arch, platform: platform, mode: config) {
                        content.set("\(key).\(config).\(arch)", url.path, section: "libraries")
                    }
                }
            }
        }
    }
}
