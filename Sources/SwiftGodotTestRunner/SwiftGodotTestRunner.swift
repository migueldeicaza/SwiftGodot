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
        let runner = GodotTestOrchestrator()
        let exitCode = await runner.run()
        exit(Int32(exitCode))
    }
}

/// Orchestrates building tests, launching Godot, and reporting results
struct GodotTestOrchestrator {
    let projectPath: String
    let resultsPath: String
    let extensionTarget: String
    let buildConfiguration: String

    init(
        projectPath: String = "Tests/SwiftGodotTestProject",
        resultsPath: String = "Tests/SwiftGodotTestProject/test_results.json",
        extensionTarget: String = "SwiftGodotTestExtension",
        buildConfiguration: String = "debug"
    ) {
        self.projectPath = projectPath
        self.resultsPath = resultsPath
        self.extensionTarget = extensionTarget
        self.buildConfiguration = buildConfiguration
    }

    func run() async -> Int {
        print("SwiftGodot Test Runner")
        print(String(repeating: "=", count: 60))

        // Print all paths for CI debugging
        let cwd = FileManager.default.currentDirectoryPath
        let absoluteProjectPath = projectPath.hasPrefix("/") ? projectPath : "\(cwd)/\(projectPath)"
        let absoluteResultsPath = resultsPath.hasPrefix("/") ? resultsPath : "\(cwd)/\(resultsPath)"
        print("\nPaths:")
        print("  Working directory: \(cwd)")
        print("  Project path:      \(absoluteProjectPath)")
        print("  Results path:      \(absoluteResultsPath)")
        print("  Extension target:  \(extensionTarget)")
        print("  Build config:      \(buildConfiguration)")

        // 1. Build the test extension
        print("\n[1/4] Building test extension...")
        do {
            try await buildExtension()
            print("      Build successful")
        } catch {
            print("      Build failed: \(error)")
            return 1
        }

        // 2. Copy built library to Godot project
        print("\n[2/4] Copying library to test project...")
        do {
            try copyLibraryToProject()
            print("      Copy successful")
        } catch {
            print("      Copy failed: \(error)")
            return 1
        }

        // 3. Launch Godot
        print("\n[3/4] Running tests in Godot...")
        let godotExitCode: Int
        do {
            godotExitCode = try await launchGodot()
        } catch {
            print("      Godot launch failed: \(error)")
            return 1
        }

        // 4. Read and report results
        print("\n[4/4] Reading results...")
        do {
            let results = try readResults()
            printResults(results)
            // Test results are the source of truth - Godot may exit non-zero due to expected errors during tests
            return results.summary.failed > 0 ? 1 : 0
        } catch {
            print("      Failed to read results: \(error)")
            print("      Godot exit code was: \(godotExitCode)")
            return godotExitCode != 0 ? godotExitCode : 1
        }
    }

    private func buildExtension() async throws {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/swift")
        process.arguments = [
            "build",
            "--product", extensionTarget,
            "-c", buildConfiguration
        ]
        process.currentDirectoryURL = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)

        // Forward stdout/stderr directly for real-time output
        process.standardOutput = FileHandle.standardOutput
        process.standardError = FileHandle.standardError

        try process.run()
        process.waitUntilExit()

        if process.terminationStatus != 0 {
            throw TestRunnerError.buildFailed("See output above")
        }
    }

    private func copyLibraryToProject() throws {
        let fm = FileManager.default
        let destDir = "\(projectPath)/bin"

        // Create destination directory
        try fm.createDirectory(atPath: destDir, withIntermediateDirectories: true)

        // Platform-specific library extension and build directory
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

        // Libraries to copy: extension + dependencies
        let libraryNames = [extensionTarget, "SwiftGodot", "SwiftGodotRuntime"]

        // Try platform-specific path first, then fallback to simple path
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
                throw TestRunnerError.libraryNotFound("\(platformSource) or \(simpleSource)")
            }

            let dest = "\(destDir)/\(libName)"

            // Remove existing file if present
            if fm.fileExists(atPath: dest) {
                try fm.removeItem(atPath: dest)
            }

            // Copy new file
            try fm.copyItem(atPath: source, toPath: dest)
            print("      Copied \(libName)")
        }
    }

    private func launchGodot() async throws -> Int {
        // Check if godot is in PATH
        let whichProcess = Process()
        whichProcess.executableURL = URL(fileURLWithPath: "/usr/bin/which")
        whichProcess.arguments = ["godot"]
        let whichPipe = Pipe()
        whichProcess.standardOutput = whichPipe
        whichProcess.standardError = whichPipe

        try whichProcess.run()
        whichProcess.waitUntilExit()

        if whichProcess.terminationStatus != 0 {
            throw TestRunnerError.godotNotFound
        }

        let godotPathData = whichPipe.fileHandleForReading.readDataToEndOfFile()
        let godotPath = String(data: godotPathData, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "godot"

        // Launch Godot
        let process = Process()
        process.executableURL = URL(fileURLWithPath: godotPath)
        process.arguments = [
            "--headless",
            "--path", projectPath,
            "--quit-after", "600"  // Timeout after 10 minutes
        ]
        process.currentDirectoryURL = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)

        // Forward stdout/stderr
        process.standardOutput = FileHandle.standardOutput
        process.standardError = FileHandle.standardError

        try process.run()
        process.waitUntilExit()

        return Int(process.terminationStatus)
    }

    private func readResults() throws -> TestResults {
        let data = try Data(contentsOf: URL(fileURLWithPath: resultsPath))
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode(TestResults.self, from: data)
    }

    private func printResults(_ results: TestResults) {
        print("\n" + String(repeating: "=", count: 60))
        print("Test Results")
        print(String(repeating: "=", count: 60))

        for suite in results.suites {
            print("\n\(suite.name):")
            for test in suite.tests {
                let icon = test.status == .passed ? "+" : (test.status == .failed ? "x" : "-")
                print("  [\(icon)] \(test.name) (\(test.durationMs)ms)")
                if let failure = test.failure {
                    print("      \(failure.message)")
                    print("      at \(failure.file):\(failure.line)")
                }
            }
        }

        print("\n" + String(repeating: "-", count: 60))
        print("Summary: \(results.summary.passed) passed, \(results.summary.failed) failed, \(results.summary.skipped) skipped")
        print("Total time: \(results.durationMs)ms")
        print(String(repeating: "=", count: 60))
    }
}

enum TestRunnerError: Error, CustomStringConvertible {
    case buildFailed(String)
    case libraryNotFound(String)
    case godotNotFound
    case resultsNotFound

    var description: String {
        switch self {
        case .buildFailed(let output):
            return "Build failed:\n\(output)"
        case .libraryNotFound(let path):
            return "Built library not found at: \(path)"
        case .godotNotFound:
            return "Godot not found in PATH. Please install Godot and ensure 'godot' command is available."
        case .resultsNotFound:
            return "Test results file not found"
        }
    }
}
