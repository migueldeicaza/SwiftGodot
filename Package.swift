// swift-tools-version: 6.3

// SwiftGodot (umbrella). The library is split into one dynamic-library package
// per area (runtime, core, controls, 2D, 3D, gltf, visual-shader-nodes, xr,
// editor) under Packages/, each its own dylib that references the others
// dynamically (no embedding). This root package is the umbrella: it re-exports
// every module as a single `import SwiftGodot`, hosts the macro plugin, and
// carries the examples and tests.

import CompilerPluginSupport
import PackageDescription

// Each module dylib re-exported by the umbrella so a consumer that links only
// `SwiftGodot` resolves symbols from all of them.
let reexportedModules = [
    "SwiftGodotRuntime", "SwiftGodotCore", "SwiftGodotControls",
    "SwiftGodot2D", "SwiftGodot3D", "SwiftGodotGLTF",
    "SwiftGodotVisualShaderNodes", "SwiftGodotXR", "SwiftGodotEditor",
]
let reexportFlags: [String] = reexportedModules.flatMap { ["-Xlinker", "-reexport-l\($0)"] }

// Forward the umbrella's `with_multi_process` trait to a module dependency only
// when it is enabled here.
let mp: PackageDescription.Package.Dependency.Trait = .trait(
    name: "with_multi_process",
    condition: .when(traits: ["with_multi_process"])
)

var targets: [Target] = [
    // Macros used by third parties (@Godot/@Export/@Callable/...). The macro
    // *declarations* live in the module packages (re-exported up); this is the
    // compiler-plugin implementation, applied to the umbrella so it propagates
    // to consumers.
    .macro(
        name: "SwiftGodotMacroLibrary",
        dependencies: [
            .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
            .product(name: "SwiftSyntax", package: "swift-syntax"),
            .product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
            .product(name: "SwiftDiagnostics", package: "swift-syntax"),
            .product(name: "SwiftParserDiagnostics", package: "swift-syntax"),
            .product(name: "SwiftParser", package: "swift-syntax"),
            .product(name: "SwiftBasicFormat", package: "swift-syntax"),
        ],
        swiftSettings: [.swiftLanguageMode(.v5)]
    ),

    // The umbrella module: re-exports every split module + carries the macro.
    .target(
        name: "SwiftGodot",
        dependencies: [
            .product(name: "SwiftGodotRuntime", package: "Runtime"),
            .product(name: "SwiftGodotCore", package: "Core"),
            .product(name: "SwiftGodotControls", package: "Controls"),
            .product(name: "SwiftGodot2D", package: "TwoD"),
            .product(name: "SwiftGodot3D", package: "ThreeD"),
            .product(name: "SwiftGodotGLTF", package: "GLTF"),
            .product(name: "SwiftGodotVisualShaderNodes", package: "VisualShaderNodes"),
            .product(name: "SwiftGodotXR", package: "XR"),
            .product(name: "SwiftGodotEditor", package: "Editor"),
            "SwiftGodotMacroLibrary",
        ],
        swiftSettings: [
            .unsafeFlags(["-suppress-warnings"]),
            .swiftLanguageMode(.v5),
        ],
        linkerSettings: [.unsafeFlags(reexportFlags)]
    ),

    // Test macro implementations for @SwiftGodotTest and @SwiftGodotTestSuite.
    .macro(
        name: "SwiftGodotTestMacrosLibrary",
        dependencies: [
            .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
            .product(name: "SwiftSyntax", package: "swift-syntax"),
            .product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
        ],
        swiftSettings: [.swiftLanguageMode(.v5)]
    ),

    // Test macro definitions and SwiftGodotTestSuiteProtocol.
    .target(
        name: "SwiftGodotTestMacros",
        dependencies: ["SwiftGodot"],
        swiftSettings: [.swiftLanguageMode(.v5)],
        plugins: ["SwiftGodotTestMacrosLibrary"]
    ),

    // Sample extension using the macro-based registration.
    .target(
        name: "SimpleExtension",
        dependencies: ["SwiftGodot"],
        exclude: ["SimpleExtension.gdextension", "README.md"],
        swiftSettings: [.swiftLanguageMode(.v5)],
        plugins: [.plugin(name: "EntryPointGeneratorPlugin", package: "Infra")]
    ),

    // Sample extension using manual registration.
    .target(
        name: "ManualExtension",
        dependencies: ["SwiftGodot"],
        exclude: ["ManualExtension.gdextension", "README.md"],
        swiftSettings: [.swiftLanguageMode(.v5)]
    ),

    // Test runner CLI.
    .executableTarget(
        name: "SwiftGodotTestRunner",
        dependencies: [],
        path: "Sources/SwiftGodotTestRunner",
        swiftSettings: [.swiftLanguageMode(.v5)]
    ),

    // Test extension loaded by Godot.
    .target(
        name: "SwiftGodotTestExtension",
        dependencies: ["SwiftGodot", "SwiftGodotTestMacros"],
        path: "Tests/SwiftGodotTestExtension",
        swiftSettings: [.swiftLanguageMode(.v5)]
    ),

    // General-purpose cross-platform tests.
    .testTarget(
        name: "SwiftGodotUniversalTests",
        dependencies: [
            "SwiftGodot",
            .product(name: "ExtensionApi", package: "Infra"),
            .product(name: "ExtensionApiJson", package: "Infra"),
        ],
        swiftSettings: [.swiftLanguageMode(.v5)]
    ),

    // Compile-only diagnostics tests (warnings promoted to errors).
    .testTarget(
        name: "SwiftGodotCompileDiagnosticsTests",
        dependencies: ["SwiftGodot"],
        swiftSettings: [
            .unsafeFlags(["-warnings-as-errors"]),
            .swiftLanguageMode(.v5),
        ]
    ),
]

// Macro tests don't work on Windows yet.
#if !os(Windows)
    targets.append(
        .testTarget(
            name: "SwiftGodotMacrosTests",
            dependencies: [
                "SwiftGodotMacroLibrary",
                "SwiftGodot",
                .product(name: "SwiftSyntaxMacrosTestSupport", package: "swift-syntax"),
            ],
            exclude: ["Resources"],
            resources: [.copy("Resources")],
            swiftSettings: [.swiftLanguageMode(.v5)]
        ))
#endif

let package = Package(
    name: "SwiftGodot",
    platforms: [
        .macOS(.v14),
        .iOS(.v17),
    ],
    products: [
        .library(name: "SwiftGodot", type: .dynamic, targets: ["SwiftGodot"]),
        .library(name: "SimpleExtension", type: .dynamic, targets: ["SimpleExtension"]),
        .library(name: "ManualExtension", type: .dynamic, targets: ["ManualExtension"]),
        .executable(name: "SwiftGodotTestRunner", targets: ["SwiftGodotTestRunner"]),
        .library(name: "SwiftGodotTestExtension", type: .dynamic, targets: ["SwiftGodotTestExtension"]),
    ],
    traits: [
        .trait(
            name: "with_multi_process",
            description: "Use multi-process-safe code generation with reinitialization support."
        ),
    ],
    dependencies: [
        .package(path: "Packages/Infra"),
        .package(path: "Packages/Runtime", traits: [mp]),
        .package(path: "Packages/Core", traits: [mp]),
        .package(path: "Packages/Controls", traits: [mp]),
        .package(path: "Packages/TwoD", traits: [mp]),
        .package(path: "Packages/ThreeD", traits: [mp]),
        .package(path: "Packages/GLTF", traits: [mp]),
        .package(path: "Packages/VisualShaderNodes", traits: [mp]),
        .package(path: "Packages/XR", traits: [mp]),
        .package(path: "Packages/Editor", traits: [mp]),
        .package(url: "https://github.com/swiftlang/swift-syntax", from: "600.0.1"),
        .package(url: "https://github.com/swiftlang/swift-docc-plugin", from: "1.3.0"),
    ],
    targets: targets
)
