//
//  main.swift
//  SwiftGodotTestRunner
//
//  CLI tool that builds the test extension, launches Godot, and reports results
//

import Foundation

@main
struct SwiftGodotTestRunner {
    static func main() async {
        let projectPath = "Tests/SwiftGodotTestProject"
        let resultsPath = "Tests/SwiftGodotTestProject/test_results.json"
        let extensionTarget = "SwiftGodotTestExtension"
        let buildConfiguration = "debug"

        print("SwiftGodot Test Runner")
        print(String(repeating: "=", count: 60))

        let cwd = FileManager.default.currentDirectoryPath
        let absoluteProjectPath = projectPath.hasPrefix("/") ? projectPath : "\(cwd)/\(projectPath)"
        let absoluteResultsPath = resultsPath.hasPrefix("/") ? resultsPath : "\(cwd)/\(resultsPath)"
        print("\nPaths:")
        print("  Working directory: \(cwd)")
        print("  Project path:      \(absoluteProjectPath)")
        print("  Results path:      \(absoluteResultsPath)")
        print("  Extension target:  \(extensionTarget)")
        print("  Build config:      \(buildConfiguration)")

        // Find swift executable from PATH
        let whichSwiftProcess = Process()
        whichSwiftProcess.executableURL = URL(fileURLWithPath: "/usr/bin/which")
        whichSwiftProcess.arguments = ["swift"]
        let whichSwiftPipe = Pipe()
        whichSwiftProcess.standardOutput = whichSwiftPipe
        whichSwiftProcess.standardError = whichSwiftPipe
        do {
            try whichSwiftProcess.run()
            whichSwiftProcess.waitUntilExit()
        } catch {
            print("      Failed to find swift: \(error)")
            exit(1)
        }
        if whichSwiftProcess.terminationStatus != 0 {
            print("      Swift not found in PATH")
            exit(1)
        }
        let swiftPathData = whichSwiftPipe.fileHandleForReading.readDataToEndOfFile()
        let swiftPath = String(data: swiftPathData, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "swift"

        // 1. Build the test extension and dependencies
        print("\n[1/5] Building test extension...")
        let products = [extensionTarget, "SwiftGodot", "SwiftGodotRuntime"]
        for product in products {
            let process = Process()
            process.executableURL = URL(fileURLWithPath: swiftPath)
            process.arguments = ["build", "--product", product, "-c", buildConfiguration]
            process.currentDirectoryURL = URL(fileURLWithPath: cwd)
            process.standardOutput = FileHandle.standardOutput
            process.standardError = FileHandle.standardError
            do {
                try process.run()
                process.waitUntilExit()
                if process.terminationStatus != 0 {
                    print("      Build failed for \(product)")
                    exit(1)
                }
            } catch {
                print("      Build failed: \(error)")
                exit(1)
            }
        }
        print("      Build successful")

        // 2. Copy built libraries to Godot project
        print("\n[2/5] Copying libraries to test project...")
        let fm = FileManager.default
        let destDir = "\(projectPath)/bin"
        do {
            try fm.createDirectory(atPath: destDir, withIntermediateDirectories: true)
        } catch {
            print("      Failed to create bin directory: \(error)")
            exit(1)
        }

        #if os(macOS)
        let libPrefix = "lib"
        let libExt = "dylib"
        #if arch(arm64)
        let platformDir = "arm64-apple-macosx"
        #else
        let platformDir = "x86_64-apple-macosx"
        #endif
        #elseif os(Linux)
        let libPrefix = "lib"
        let libExt = "so"
        #if arch(arm64)
        let platformDir = "aarch64-unknown-linux-gnu"
        #else
        let platformDir = "x86_64-unknown-linux-gnu"
        #endif
        #elseif os(Windows)
        let libPrefix = ""
        let libExt = "dll"
        let platformDir = "x86_64-unknown-windows-msvc"
        #else
        let libPrefix = "lib"
        let libExt = "dylib"
        let platformDir = ""
        #endif

        let libraryNames = [extensionTarget, "SwiftGodot", "SwiftGodotRuntime"]
        let platformBuildDir = ".build/\(platformDir)/\(buildConfiguration)"
        let simpleBuildDir = ".build/\(buildConfiguration)"

        for name in libraryNames {
            let libName = "\(libPrefix)\(name).\(libExt)"
            let platformSource = "\(platformBuildDir)/\(libName)"
            let simpleSource = "\(simpleBuildDir)/\(libName)"

            let source: String
            if fm.fileExists(atPath: platformSource) {
                source = platformSource
            } else if fm.fileExists(atPath: simpleSource) {
                source = simpleSource
            } else {
                print("      Library not found: \(platformSource) or \(simpleSource)")
                exit(1)
            }

            let dest = "\(destDir)/\(libName)"
            do {
                if fm.fileExists(atPath: dest) {
                    try fm.removeItem(atPath: dest)
                }
                try fm.copyItem(atPath: source, toPath: dest)
                print("      Copied \(libName)")
            } catch {
                print("      Copy failed: \(error)")
                exit(1)
            }
        }
        print("      Copy successful")

        // Find godot
        let whichProcess = Process()
        whichProcess.executableURL = URL(fileURLWithPath: "/usr/bin/which")
        whichProcess.arguments = ["godot"]
        let whichPipe = Pipe()
        whichProcess.standardOutput = whichPipe
        whichProcess.standardError = whichPipe
        do {
            try whichProcess.run()
            whichProcess.waitUntilExit()
        } catch {
            print("      Failed to find godot: \(error)")
            exit(1)
        }
        if whichProcess.terminationStatus != 0 {
            print("      Godot not found in PATH")
            exit(1)
        }
        let godotPathData = whichPipe.fileHandleForReading.readDataToEndOfFile()
        let godotPath = String(data: godotPathData, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "godot"

        // 3. Import project (needed to detect GDExtensions)
        print("\n[3/5] Importing Godot project...")
        let importProcess = Process()
        importProcess.executableURL = URL(fileURLWithPath: godotPath)
        importProcess.arguments = ["--headless", "--import", "--path", absoluteProjectPath]
        importProcess.currentDirectoryURL = URL(fileURLWithPath: absoluteProjectPath)
        importProcess.standardOutput = FileHandle.standardOutput
        importProcess.standardError = FileHandle.standardError
        do {
            try importProcess.run()
            importProcess.waitUntilExit()
        } catch {
            print("      Import failed: \(error)")
            exit(1)
        }
        print("      Import successful")

        // 4. Launch Godot
        print("\n[4/5] Running tests in Godot...")
        let godotProcess = Process()
        godotProcess.executableURL = URL(fileURLWithPath: godotPath)
        godotProcess.arguments = ["--headless", "--path", absoluteProjectPath]
        godotProcess.currentDirectoryURL = URL(fileURLWithPath: absoluteProjectPath)
        godotProcess.standardOutput = FileHandle.standardOutput
        godotProcess.standardError = FileHandle.standardError
        var godotExitCode: Int32 = 0
        do {
            try godotProcess.run()
            godotProcess.waitUntilExit()
            godotExitCode = godotProcess.terminationStatus
            print("      Godot exited with code: \(godotExitCode)")
        } catch {
            print("      Godot launch failed: \(error)")
            exit(1)
        }

        // 5. Read and report results
        print("\n[5/5] Reading results...")
        do {
            let data = try Data(contentsOf: URL(fileURLWithPath: absoluteResultsPath))
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let results = try decoder.decode(TestResults.self, from: data)

            print("\n" + String(repeating: "=", count: 60))
            print("Test Results")
            print(String(repeating: "=", count: 60))

            for suite in results.suites {
                print("\n\(suite.name):")
                for test in suite.tests {
                    let icon = test.status == .passed ? "+" : (test.status == .failed ? "x" : "-")
                    let duration = test.duration >= 1.0 ? String(format: "%.2fs", test.duration) : String(format: "%.2fms", test.duration * 1000)
                    print("  [\(icon)] \(test.name) (\(duration))")
                    if let failure = test.failure {
                        print("      \(failure.message)")
                        print("      at \(failure.file):\(failure.line)")
                    }
                }
            }

            let totalDuration = results.duration >= 1.0 ? String(format: "%.2fs", results.duration) : String(format: "%.2fms", results.duration * 1000)
            print("\n" + String(repeating: "-", count: 60))
            print("Summary: \(results.summary.passed) passed, \(results.summary.failed) failed, \(results.summary.skipped) skipped")
            print("Total time: \(totalDuration)")
            print(String(repeating: "=", count: 60))

            // Use Godot's exit code if non-zero, otherwise use test results
            let testExitCode: Int32 = results.summary.failed > 0 ? 1 : 0
            exit(godotExitCode != 0 ? godotExitCode : testExitCode)
        } catch {
            print("      Failed to read results: \(error)")
            print("      Godot exit code was: \(godotExitCode)")
            exit(godotExitCode != 0 ? godotExitCode : 1)
        }
    }
}
