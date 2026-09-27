//
//  ClassDistributionTests.swift
//
//  Verifies that every class declared in `extension_api.json` is assigned to
//  one of the split-module distribution lists used by the CodeGeneratorPlugin.
//

import XCTest
import ExtensionApi
import ExtensionApiJson

/// The CodeGeneratorPlugin decides which generated module each Godot class lands
/// in using the lists in `Plugins/CodeGeneratorPlugin/ModuleClasses.json` (the
/// single source of truth — the plugin loads the very same file at build time).
/// A class missing from all lists only surfaces as a "missing reference type"
/// build failure during code generation *if something references it*; otherwise
/// it is silently dropped and its API is never generated — as nearly happened
/// with the classes added in the Godot 4.7 bump.
///
/// This test decodes that JSON and asserts:
/// - coverage: every JSON-declared class is assigned to some module, and
/// - partition: no class lives in two split modules (would be generated twice;
///   the intentional runtime/core dependency overlap is excluded).
///
/// It runs without a full code-generation build and fails with the exact list
/// of unassigned classes.
final class ClassDistributionTests: XCTestCase {

    /// The generated-module distribution lists. `runtime` is a dependency of
    /// every other module, so it is allowed to overlap `core` (`MainLoop`,
    /// `Resource`, `ScriptLanguage`) and is tracked separately from the rest.
    private static let splitModules = [
        "core", "gltf", "twoD", "threeD",
        "controls", "xr", "visualShaderNodes", "editor",
    ]
    private static let runtimeModule = "runtime"

    func testEveryApiClassIsDistributedAcrossModules() throws {
        let api = try Self.loadExtensionApi()
        let lists = try Self.loadModuleClasses()

        // Map each class to the module list(s) that declare it.
        var classToModules: [String: [String]] = [:]
        for module in Self.splitModules + [Self.runtimeModule] {
            let files = try XCTUnwrap(lists[module], "ModuleClasses.json has no '\(module)' list")
            for file in files {
                classToModules[Self.className(from: file), default: []].append(module)
            }
        }

        let apiClasses = Set(api.classes.map { $0.name })

        // 1. Coverage: every class declared in the JSON must be assigned to a module.
        let missing = apiClasses.subtracting(classToModules.keys).sorted()
        XCTAssertTrue(
            missing.isEmpty,
            """
            \(missing.count) class(es) declared in extension_api.json are not assigned \
            to any module in ModuleClasses.json. Add each to the appropriate list \
            (core / twoD / threeD / controls / xr / editor / …):
            \(missing.map { "  \($0)" }.joined(separator: "\n"))
            """
        )

        // 2. Partition: no class may live in two *different* split modules, which
        //    would generate it twice. The intentional runtime/core overlap is excluded.
        let duplicated = classToModules
            .filter { $0.value.filter { $0 != Self.runtimeModule }.count > 1 }
            .map { "  \($0.key) in [\($0.value.sorted().joined(separator: ", "))]" }
            .sorted()
        XCTAssertTrue(
            duplicated.isEmpty,
            """
            Class(es) assigned to more than one split module (would be generated twice):
            \(duplicated.joined(separator: "\n"))
            """
        )
    }

    // MARK: - Helpers

    private static func className(from file: String) -> String {
        file.hasSuffix(".swift") ? String(file.dropLast(".swift".count)) : file
    }

    private static func loadExtensionApi() throws -> JGodotExtensionAPI {
        let url = try XCTUnwrap(URL.extensionApiJson, "extension_api.json resource is unavailable")
        let data = try Data(contentsOf: url)
        return try JSONDecoder().decode(JGodotExtensionAPI.self, from: data)
    }

    /// Loads the same `ModuleClasses.json` the CodeGeneratorPlugin consumes.
    private static func loadModuleClasses() throws -> [String: [String]] {
        // <repo>/Tests/SwiftGodotUniversalTests/ClassDistributionTests.swift
        let url = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()   // SwiftGodotUniversalTests
            .deletingLastPathComponent()   // Tests
            .deletingLastPathComponent()   // <repo>
            .appendingPathComponent("Plugins")
            .appendingPathComponent("CodeGeneratorPlugin")
            .appendingPathComponent("ModuleClasses.json")
        let data = try Data(contentsOf: url)
        return try JSONDecoder().decode([String: [String]].self, from: data)
    }
}
