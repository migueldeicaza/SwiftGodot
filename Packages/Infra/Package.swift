// swift-tools-version: 6.3

// Infra: the shared build tooling for the split SwiftGodot packages.
// It vends the code generator + its build-tool plugin, the EntryPoint generator
// + plugin, the GDExtension C bridge, and the ExtensionApi data models /
// extension_api.json resource. Every split module package and the umbrella
// (root) package depends on this one.

import CompilerPluginSupport
import PackageDescription

let package = Package(
    name: "Infra",
    platforms: [
        .macOS(.v14),
        .iOS(.v17),
    ],
    products: [
        .plugin(name: "CodeGeneratorPlugin", targets: ["CodeGeneratorPlugin"]),
        .plugin(name: "EntryPointGeneratorPlugin", targets: ["EntryPointGeneratorPlugin"]),
        .library(name: "GDExtension", targets: ["GDExtension"]),
        .library(name: "ExtensionApi", targets: ["ExtensionApi"]),
        .library(name: "ExtensionApiJson", targets: ["ExtensionApiJson"]),
    ],
    dependencies: [
        .package(url: "https://github.com/swiftlang/swift-syntax", from: "600.0.1"),
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.3.0"),
    ],
    targets: [
        // GDExtension C bridge.
        .target(
            name: "GDExtension",
            swiftSettings: [.swiftLanguageMode(.v5)]
        ),

        // GDExtension JSON API data models.
        .target(
            name: "ExtensionApi",
            exclude: ["ExtensionApiJson.swift", "extension_api.json"],
            swiftSettings: [.swiftLanguageMode(.v5)]
        ),

        // Resource bundle carrying extension_api.json (used by tests).
        .target(
            name: "ExtensionApiJson",
            path: "Sources/ExtensionApi",
            exclude: ["ApiJsonModel.swift", "ApiJsonModel+Extra.swift"],
            sources: ["ExtensionApiJson.swift"],
            resources: [.process("extension_api.json")],
            swiftSettings: [.swiftLanguageMode(.v5)]
        ),

        // The generator: turns extension_api.json into Swift bindings.
        .executableTarget(
            name: "Generator",
            dependencies: [
                "ExtensionApi",
                .product(name: "SwiftSyntax", package: "swift-syntax"),
                .product(name: "SwiftSyntaxBuilder", package: "swift-syntax"),
            ],
            path: "Sources/Generator/Generator",
            swiftSettings: [.swiftLanguageMode(.v5)]
        ),

        // Build-tool plugin that invokes the generator per target.
        .plugin(
            name: "CodeGeneratorPlugin",
            capability: .buildTool(),
            dependencies: ["Generator"]
        ),

        // Generates EntryPoint.swift to bootstrap a Godot extension.
        .executableTarget(
            name: "EntryPointGenerator",
            dependencies: [
                .product(name: "SwiftSyntax", package: "swift-syntax"),
                .product(name: "SwiftParser", package: "swift-syntax"),
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
            ],
            swiftSettings: [.swiftLanguageMode(.v5)]
        ),

        .plugin(
            name: "EntryPointGeneratorPlugin",
            capability: .buildTool(),
            dependencies: ["EntryPointGenerator"]
        ),
    ]
)
