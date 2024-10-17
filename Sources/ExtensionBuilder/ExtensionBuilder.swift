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

        await builder.build(inputs: args.dropFirst(4))
    }

    func buildDirectory(arch: String, platform: String, mode: String) -> URL? {
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

        return u.appending(path: "\(arch)-\(platform)").appending(path: mode)
    }

    func builtPath(arch: String, platform: String, mode: String) -> URL? {
        guard let url = buildDirectory(arch: arch, platform: platform, mode: mode) else { return nil }
        return url.appending(path: "lib\(targetName).dylib")
    }

    var targetName: String {
        targetDirectory.lastPathComponent
    }

    func build(inputs: Array<String>.SubSequence) async {
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

    let sectionPattern: Regex = #/\s*\[(?<section>\w+)\]\s*/#
    let assignmentPattern: Regex = #/\s*(?<key>\S+)\s*=\s*(?<value>\S*)\s*/#
    let stringPattern: Regex = #/"(?<content>.*)"/#

    func process(_ inputURL: URL, outputURL: URL) async throws {
        let content = try await GodotConfigFile(inputURL)

        let platforms = [
            ("macos", ["arm64", "x86_64"], "apple-macosx")
        ]

        for config in ["debug", "release"] {
            for (key, archs, platform) in platforms {
                for arch in archs {
                    if let url = builtPath(arch: arch, platform: platform, mode: config) {
                        content.set("\(key).\(config).\(arch)", url.path, section: "libraries")
                    }
                }
            }
        }

        let outputPath = content.get("output", section: "swiftgodot")
        content.remove(section: "swiftgodot")

        #if APPEND_LOG
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
        if let outputPath,
            let containerURL = URL(string: outputPath, relativeTo: outputDirectory)
        {
            try FileManager.default.createDirectory(at: containerURL, withIntermediateDirectories: true)
            let pathURL = containerURL.appending(path: outputURL.lastPathComponent)
            try await content.write(to: pathURL)
        }
    }
}
