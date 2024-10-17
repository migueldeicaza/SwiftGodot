// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 16/10/24.
//  All code (c) 2024 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

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
        var section = "_"
        var values: [String: String] = [:]
        var content: [String: [String: String]] = [:]
        for try await line in inputURL.lines {
            if let match = line.matches(of: sectionPattern).first {
                if !values.isEmpty {
                    content[section] = values
                }
                section = String(match.section)
                values = [:]
            } else if let match = line.matches(of: assignmentPattern).first {
                values[String(match.key)] = String(match.value)
            }
        }
        if !values.isEmpty {
            content[section] = values
        }

        let platforms = [
            ("macos", ["arm64", "x86_64"], "apple-macosx")
        ]

        if content["libraries"] == nil {
            content["libraries"] = [:]
        }
        if content["dependencies"] == nil {
            content["dependencies"] = [:]
        }

        for config in ["debug", "release"] {
            for (key, archs, platform) in platforms {
                for arch in archs {
                    if let url = builtPath(arch: arch, platform: platform, mode: config) {
                        content["libraries"]?["\(key).\(config).\(arch)"] = "\"\(url.path)\""
                    }
                }
            }
        }

        let outputPath = content["swiftgodot"]?["export"]
        content.removeValue(forKey: "swiftgodot")

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

            content["swift"] = ["log": "\"\(log)\""]
        #endif

        var output: [String] = []
        for (section, values) in content {
            output.append("[\(section)]")
            for (key, value) in values {
                output.append("\(key) = \(value)")
            }
        }
        let combined = output.joined(separator: "\n")

        try combined.write(to: outputURL, atomically: true, encoding: .utf8)
        if let op = outputPath,
            let path = op.matches(of: stringPattern).first,
            let containerURL = URL(string: String(path.content), relativeTo: outputDirectory)
        {
            try FileManager.default.createDirectory(at: containerURL, withIntermediateDirectories: true)
            let pathURL = containerURL.appending(path: outputURL.lastPathComponent)
            try combined.write(to: pathURL, atomically: true, encoding: .utf8)
        }
    }
}
