//
//  main.swift
//  SwiftGodotTestRunner
//
//  CLI tool that builds the test extension, launches Godot, and reports results
//

import Foundation

@main
struct SwiftGodotTestRunner {
    /// Locates an executable by name on PATH, returning its full path, or `nil` if not found.
    /// Uses `where.exe` on Windows and `/usr/bin/which` elsewhere.
    static func findExecutable(_ name: String) -> String? {
        let process = Process()
        #if os(Windows)
        let systemRoot = ProcessInfo.processInfo.environment["SystemRoot"] ?? "C:\\Windows"
        process.executableURL = URL(fileURLWithPath: "\(systemRoot)\\System32\\where.exe")
        #else
        process.executableURL = URL(fileURLWithPath: "/usr/bin/which")
        #endif
        process.arguments = [name]
        let pipe = Pipe()
        process.standardOutput = pipe
        process.standardError = pipe
        do {
            try process.run()
            process.waitUntilExit()
        } catch {
            return nil
        }
        guard process.terminationStatus == 0 else { return nil }
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        guard let output = String(data: data, encoding: .utf8) else { return nil }
        // `where` can report multiple matches (one per line); take the first non-empty one.
        return output
            .split(whereSeparator: \.isNewline)
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .first { !$0.isEmpty }
    }

    /// True once `path` exists, is non-empty, and its size has stabilized across a
    /// short interval (so we never read a half-written file).
    static func fileIsReady(_ path: String) -> Bool {
        let fm = FileManager.default
        guard let a = try? fm.attributesOfItem(atPath: path),
              let size = a[.size] as? Int, size > 0 else { return false }
        Thread.sleep(forTimeInterval: 0.2)
        guard let b = try? fm.attributesOfItem(atPath: path),
              let size2 = b[.size] as? Int else { return false }
        return size2 == size
    }

    /// Runs Godot and waits for its work to finish. On Windows the Godot process
    /// can hang on shutdown after the SwiftGodot extension is loaded, long after
    /// the useful work is done, so we don't rely on a clean exit: if a
    /// `completionFile` is given we terminate the process once that file is fully
    /// written; otherwise we wait up to `timeout` and then terminate. A process
    /// that exits on its own first is handled normally.
    /// Returns the termination status, or 0 when we terminated it after the work
    /// completed (completion file written).
    static func runGodot(
        _ godotPath: String,
        arguments: [String],
        cwd: String,
        completionFile: String?,
        timeout: TimeInterval
    ) -> Int32 {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: godotPath)
        process.arguments = arguments
        process.currentDirectoryURL = URL(fileURLWithPath: cwd)
        process.standardOutput = FileHandle.standardOutput
        process.standardError = FileHandle.standardError
        do {
            try process.run()
        } catch {
            print("      Godot launch failed: \(error)")
            exit(1)
        }

        let start = Date()
        var completed = false
        while process.isRunning {
            if let completionFile, fileIsReady(completionFile) {
                completed = true
                process.terminate()
                break
            }
            if Date().timeIntervalSince(start) > timeout {
                if completionFile == nil {
                    // No completion signal to wait on (e.g. the import step); the
                    // work is expected to be done by now and the process is just
                    // hanging on shutdown.
                    completed = true
                } else {
                    print("      Timed out after \(Int(timeout))s waiting for Godot.")
                }
                process.terminate()
                break
            }
            Thread.sleep(forTimeInterval: 0.25)
        }
        process.waitUntilExit()
        return completed ? 0 : process.terminationStatus
    }

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
        guard let swiftPath = findExecutable("swift") else {
            print("      Swift not found in PATH")
            exit(1)
        }

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

        #if os(Windows)
        // Godot's `open_dynamic_library` on Windows uses LoadLibraryExW with the
        // LOAD_LIBRARY_SEARCH_* flags, which ignore the PATH environment variable.
        // So the Swift runtime DLLs the extension links against must sit next to it
        // in `bin/`, even though they are on PATH for normal execution. Without this
        // the extension fails to load with "Error 126: The specified module could
        // not be found." We locate each DLL on PATH (via `where`) and copy it in.
        let runtimeDLLs = [
            "swiftCore.dll", "swiftCRT.dll", "swiftWinSDK.dll",
            "swift_Concurrency.dll", "swift_StringProcessing.dll", "swift_RegexParser.dll",
            "swiftRegexBuilder.dll", "swiftSwiftOnoneSupport.dll", "swiftDispatch.dll",
            "swiftDistributed.dll", "swiftObservation.dll", "swiftRemoteMirror.dll",
            "swiftSynchronization.dll",
            "Foundation.dll", "FoundationNetworking.dll", "FoundationXML.dll",
            "FoundationEssentials.dll", "FoundationInternationalization.dll",
            "_FoundationICU.dll",
            "BlocksRuntime.dll", "dispatch.dll",
        ]
        var copiedRuntime = 0
        for dll in runtimeDLLs {
            guard let source = findExecutable(dll) else { continue }
            let dest = "\(destDir)/\(dll)"
            do {
                if fm.fileExists(atPath: dest) {
                    try fm.removeItem(atPath: dest)
                }
                try fm.copyItem(atPath: source, toPath: dest)
                copiedRuntime += 1
            } catch {
                print("      Warning: failed to copy runtime \(dll): \(error)")
            }
        }
        print("      Copied \(copiedRuntime) Swift runtime DLLs")
        #endif

        // Find godot
        guard let godotPath = findExecutable("godot") else {
            print("      Godot not found in PATH")
            exit(1)
        }

        // On Windows the Godot process does not terminate once the SwiftGodot
        // extension is loaded (it hangs on shutdown after the work is done), so we
        // can't wait for a clean exit. `runGodot` watches for the work to complete
        // instead. These timeouts are upper bounds that only matter on Windows --
        // on macOS/Linux Godot exits on its own well before they elapse.
        let importTimeout: TimeInterval = 60
        let runTimeout: TimeInterval = 120

        // 3. Import project (needed to register the extension's nodes, e.g.
        //    TestRunnerNode, before the main scene loads). There is no file signal
        //    for import completion, so we rely on the timeout on Windows.
        print("\n[3/5] Importing Godot project...")
        _ = runGodot(
            godotPath,
            arguments: ["--headless", "--import", "--path", absoluteProjectPath],
            cwd: absoluteProjectPath,
            completionFile: nil,
            timeout: importTimeout
        )
        print("      Import successful")

        // 4. Launch Godot to run the tests. The test extension writes the results
        //    JSON when the run completes; we terminate Godot as soon as that file
        //    is fully written rather than waiting on a clean exit.
        print("\n[4/5] Running tests in Godot...")
        try? fm.removeItem(atPath: absoluteResultsPath) // clear stale results
        let godotExitCode = runGodot(
            godotPath,
            arguments: ["--headless", "--verbose", "--path", absoluteProjectPath],
            cwd: absoluteProjectPath,
            completionFile: absoluteResultsPath,
            timeout: runTimeout
        )
        print("      Godot finished with code: \(godotExitCode)")

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
