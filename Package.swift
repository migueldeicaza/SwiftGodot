// swift-tools-version: 6.3

import CompilerPluginSupport
import PackageDescription

let withMultiProcessTrait = "with_multi_process"

// Build switches. The values below are the public defaults; a copy of this
// package vendored into an application (Xogot) flips them and otherwise
// carries no code changes. Keep every host-specific policy here.
//
// - useVendoredModuleNames: rename the products and modules to XogotSwiftGodot,
//   XogotSwiftGodotRuntime, XogotExtensionApi and XogotExtensionApiJson (via
//   -module-alias) so an application can embed this copy next to a user's own
//   SwiftGodot without symbol clashes.
// - usePreparedGenerator: CodeGeneratorPlugin does not depend on the Generator
//   target and runs .build-tools/Generator instead, produced by `make prep`.
//   Avoids Xcode relinking the generator (and regenerating the API) on every
//   build of the host project.
// - usePrecompiledSwiftSyntax: take swift-syntax from swift-precompiled instead
//   of building it from source.
// - emitStableInterfaces: emit library-evolution module interfaces in release
//   builds, needed for the binary XCFramework distribution.
// - suppressGeneratedWarnings: pass -suppress-warnings to the SwiftGodot target,
//   whose sources are generated.
// - staticCachesOnMacOS: with the with_multi_process trait, generated code
//   avoids stored static caches so Godot can be reinitialized; this keeps the
//   stored caches on macOS only, for hosts that reinitialize on iOS alone.
let useVendoredModuleNames = false
let usePreparedGenerator = false
let usePrecompiledSwiftSyntax = false
let emitStableInterfaces = true
let suppressGeneratedWarnings = true
let staticCachesOnMacOS = false

let swiftGodotPackageName = useVendoredModuleNames ? "XogotSwiftGodot" : "SwiftGodot"
let swiftGodotTargetName = useVendoredModuleNames ? "XogotSwiftGodot" : "SwiftGodot"
let swiftGodotRuntimeTargetName = useVendoredModuleNames ? "XogotSwiftGodotRuntime" : "SwiftGodotRuntime"
let swiftGodotStaticProductName = useVendoredModuleNames ? "XogotSwiftGodotStatic" : "SwiftGodotStatic"
let swiftGodotRuntimeStaticProductName = useVendoredModuleNames ? "XogotSwiftGodotRuntimeStatic" : "SwiftGodotRuntimeStatic"
let extensionApiTargetName = useVendoredModuleNames ? "XogotExtensionApi" : "ExtensionApi"
let extensionApiJsonTargetName = useVendoredModuleNames ? "XogotExtensionApiJson" : "ExtensionApiJson"
let extensionApiProductName = useVendoredModuleNames ? "XogotExtensionApi" : "ExtensionApi"

var dependencies: [Package.Dependency] = [
    .package(url: "https://github.com/apple/swift-argument-parser", from: "1.3.0"),
    usePrecompiledSwiftSyntax
        ? .package(url: "https://github.com/swift-precompiled/swift-syntax.git", exact: "603.0.2")
        : .package(url: "https://github.com/swiftlang/swift-syntax", from: "603.0.2"),
]

if Context.environment["GENERATE_DOCS"] == "1" {
    dependencies.append(.package(url: "https://github.com/swiftlang/swift-docc-plugin", from: "1.3.0"))
}

let swiftGodotModuleAliases: [SwiftSetting] = useVendoredModuleNames ? [
    .unsafeFlags([
        "-module-alias", "SwiftGodot=\(swiftGodotTargetName)",
        "-module-alias", "SwiftGodotRuntime=\(swiftGodotRuntimeTargetName)",
        "-module-alias", "ExtensionApi=\(extensionApiTargetName)",
        "-module-alias", "ExtensionApiJson=\(extensionApiJsonTargetName)",
    ]),
] : []

let vendoredModuleNameSettings: [SwiftSetting] = useVendoredModuleNames ? [
    .define("SWIFTGODOT_VENDORED_MODULE_NAMES"),
] : []

let swiftGodotBuildSettings = swiftGodotModuleAliases + vendoredModuleNameSettings
let stableInterfaceSettings: [SwiftSetting] = emitStableInterfaces ? [
    .unsafeFlags(
        [
            "-enable-library-evolution",
            "-emit-module-interface",
            "-Xfrontend", "-module-interface-preserve-types-as-written",
        ],
        .when(platforms: [.macOS, .iOS], configuration: .release)
    ),
] : []
let generatedTargetStaticCacheSettings: [SwiftSetting] = staticCachesOnMacOS ? [
    .define("SWIFTGODOT_STATIC_CACHES_ON_MACOS"),
] : []
let swiftGodotWarningSettings: [SwiftSetting] = suppressGeneratedWarnings ? [
    .unsafeFlags(["-suppress-warnings"]),
] : []

// Products define the executables and libraries a package produces, and make them visible to other packages.
var products: [Product] = [
    .library(
        name: swiftGodotRuntimeTargetName,
        type: .dynamic,
        targets: [swiftGodotRuntimeTargetName]
    ),
    .library(
        name: swiftGodotTargetName,
        type: .dynamic,
        targets: [swiftGodotTargetName]
    ),

    .library(
        name: swiftGodotRuntimeStaticProductName,
        targets: [swiftGodotRuntimeTargetName]
    ),
    .library(
        name: swiftGodotStaticProductName,
        targets: [swiftGodotTargetName]
    ),

    .library(
        name: extensionApiProductName,
        targets: [
            extensionApiTargetName,
            extensionApiJsonTargetName,
        ]
    ),

    .plugin(
        name: "CodeGeneratorPlugin",
        targets: ["CodeGeneratorPlugin"]
    ),

    .plugin(
        name: "EntryPointGeneratorPlugin",
        targets: ["EntryPointGeneratorPlugin"]
    ),

    .library(
        name: "SimpleExtension",
        type: .dynamic,
        targets: ["SimpleExtension"]
    ),

    .library(
        name: "ManualExtension",
        type: .dynamic,
        targets: ["ManualExtension"]
    ),

    .executable(
        name: "SwiftGodotTestRunner",
        targets: ["SwiftGodotTestRunner"]
    ),

    .library(
        name: "SwiftGodotTestExtension",
        type: .dynamic,
        targets: ["SwiftGodotTestExtension"]
    ),
]

/// Targets are the basic building blocks of a package. A target can define a module, plugin, test suite, etc.
var targets: [Target] = [
    .executableTarget(
        name: "EntryPointGenerator",
        dependencies: [
            .product(name: "SwiftSyntax", package: "swift-syntax"),
            .product(name: "SwiftParser", package: "swift-syntax"),
            .product(name: "ArgumentParser", package: "swift-argument-parser"),
        ],
        swiftSettings: [.swiftLanguageMode(.v5)] + swiftGodotBuildSettings
    ),

    // Scans test sources for @SwiftGodotTestSuite classes and generates the
    // TestRunnerNode.generatedSuites array consumed by the test runner.
    .executableTarget(
        name: "TestSuiteGenerator",
        dependencies: [
            .product(name: "SwiftSyntax", package: "swift-syntax"),
            .product(name: "SwiftParser", package: "swift-syntax"),
            .product(name: "ArgumentParser", package: "swift-argument-parser"),
        ],
        swiftSettings: [.swiftLanguageMode(.v5)] + swiftGodotBuildSettings
    ),

    // This contains GDExtension's JSON API data models
    .target(
        name: extensionApiTargetName,
        path: "Sources/ExtensionApi",
        exclude: ["ExtensionApiJson.swift", "extension_api.json"],
        swiftSettings: [.swiftLanguageMode(.v5)] + swiftGodotBuildSettings
    ),

    // This contains a resource bundle with extension_api.json
    .target(
        name: extensionApiJsonTargetName,
        path: "Sources/ExtensionApi",
        exclude: ["ApiJsonModel.swift", "ApiJsonModel+Extra.swift"],
        sources: ["ExtensionApiJson.swift"],
        resources: [.process("extension_api.json")],
        swiftSettings: [.swiftLanguageMode(.v5)] + swiftGodotBuildSettings
    ),

    // The generator takes Godot's JSON-based API description as input and
    // produces Swift API bindings that can be used to call into Godot.
    .executableTarget(
        name: "Generator",
        dependencies: [
            .target(name: extensionApiTargetName),
            .product(name: "SwiftSyntax", package: "swift-syntax"),
            .product(name: "SwiftSyntaxBuilder", package: "swift-syntax"),
        ],
        path: "Generator",
        exclude: ["README.md"],
        swiftSettings: [
            .swiftLanguageMode(.v5)
            // Uncomment for using legacy array-based marshalling
            //.define("LEGACY_MARSHALING")
        ] + swiftGodotBuildSettings
    ),

    // This is a build-time plugin that invokes the generator and produces
    // the bindings that are compiled into SwiftGodot.
    .plugin(
        name: "CodeGeneratorPlugin",
        capability: .buildTool(),
        dependencies: usePreparedGenerator ? [] : ["Generator"]
    ),

    // This is a build-time plugin that generates the EntryPoint.swift file,
    // which is used to bootstrap the SwiftGodot API and register your
    // extension and classes with Godot.
    .plugin(
        name: "EntryPointGeneratorPlugin",
        capability: .buildTool(),
        dependencies: ["EntryPointGenerator"]
    ),

    // This is a build-time plugin that generates the list of test suites
    // (TestRunnerNode.generatedSuites) by scanning for @SwiftGodotTestSuite.
    .plugin(
        name: "TestSuiteGeneratorPlugin",
        capability: .buildTool(),
        dependencies: ["TestSuiteGenerator"]
    ),

    // This allows the Swift code to call into the Godot bridge API (GDExtension)
    .target(
        name: "GDExtension",
        swiftSettings: [.swiftLanguageMode(.v5)] + swiftGodotBuildSettings
    ),

    // These are macros that can be used by third parties to simplify their
    // SwiftGodot development experience, these are used at compile time by
    // third party projects
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
        swiftSettings: [.swiftLanguageMode(.v5)] + swiftGodotBuildSettings
    ),

    // Test macro implementation for @SwiftGodotTestSuite
    .macro(
        name: "SwiftGodotTestMacrosLibrary",
        dependencies: [
            .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
            .product(name: "SwiftSyntax", package: "swift-syntax"),
            .product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
        ],
        swiftSettings: [.swiftLanguageMode(.v5)] + swiftGodotBuildSettings
    ),

    // Test macro definitions and SwiftGodotTestSuiteProtocol
    .target(
        name: "SwiftGodotTestMacros",
        dependencies: [.target(name: swiftGodotTargetName)],
        swiftSettings: [.swiftLanguageMode(.v5)] + swiftGodotBuildSettings,
        plugins: ["SwiftGodotTestMacrosLibrary"]
    ),
    // This contains sample code showing how to use the SwiftGodot API
    .target(
        name: "SimpleExtension",
        dependencies: [.target(name: swiftGodotTargetName)],
        exclude: ["SimpleExtension.gdextension", "README.md"],
        swiftSettings: [.swiftLanguageMode(.v5)] + swiftGodotBuildSettings,
        plugins: [.plugin(name: "EntryPointGeneratorPlugin")]
    ),

    // This contains sample code showing how to use the SwiftGodot API
    // with manual registration of methods and properties
    .target(
        name: "ManualExtension",
        dependencies: [.target(name: swiftGodotTargetName)],
        exclude: ["ManualExtension.gdextension", "README.md"],
        swiftSettings: [.swiftLanguageMode(.v5)] + swiftGodotBuildSettings
    ),

    // This is the core runtime for SwiftGodot, it only contains the builtins
    // the Object and RefCounted classes.
    .target(
        name: swiftGodotRuntimeTargetName,
        dependencies: ["GDExtension"],
        path: "Sources/SwiftGodotRuntime",
        swiftSettings: [
            .define("CUSTOM_BUILTIN_IMPLEMENTATIONS"),
            .define("SWIFTGODOT_WITH_MULTI_PROCESS", .when(traits: [withMultiProcessTrait])),
            .unsafeFlags(
                [
                    "-suppress-warnings",
                    "-Xfrontend", "-conditional-runtime-records",
                    "-Xfrontend", "-internalize-at-link",
                    "-Xfrontend", "-lto=llvm-full",
                ]
            ),
            .swiftLanguageMode(.v5),
        ] + swiftGodotBuildSettings + stableInterfaceSettings + generatedTargetStaticCacheSettings,
        plugins: ["CodeGeneratorPlugin", "SwiftGodotMacroLibrary"]
    ),

    // This binds the rest of the Godot API, it will eventually be split
    // up in chunks
    .target(
        name: swiftGodotTargetName,
        dependencies: ["GDExtension", .target(name: swiftGodotRuntimeTargetName)],
        path: "Sources/SwiftGodot",
        swiftSettings: [
            .swiftLanguageMode(.v5),
            .define("CUSTOM_BUILTIN_IMPLEMENTATIONS"),
            .define("SWIFTGODOT_WITH_MULTI_PROCESS", .when(traits: [withMultiProcessTrait])),
        ] + swiftGodotBuildSettings + swiftGodotWarningSettings + stableInterfaceSettings + generatedTargetStaticCacheSettings,
        plugins: ["CodeGeneratorPlugin"]
    ),

    // General purpose cross-platform tests
    .testTarget(
        name: "SwiftGodotUniversalTests",
        dependencies: [
            .target(name: swiftGodotTargetName),
            .target(name: swiftGodotRuntimeTargetName),
            .target(name: extensionApiTargetName),
            .target(name: extensionApiJsonTargetName),
        ],
        swiftSettings: [.swiftLanguageMode(.v5)] + swiftGodotBuildSettings
    ),

    // Compile-only diagnostics tests. These intentionally build selected
    // client idioms with warnings promoted to errors.
    .testTarget(
        name: "SwiftGodotCompileDiagnosticsTests",
        dependencies: [.target(name: swiftGodotTargetName)],
        swiftSettings: [
            .unsafeFlags(["-warnings-as-errors"]),
            .swiftLanguageMode(.v5),
        ] + swiftGodotBuildSettings
    ),

    // Test runner CLI executable
    .executableTarget(
        name: "SwiftGodotTestRunner",
        dependencies: [],
        path: "Sources/SwiftGodotTestRunner",
        swiftSettings: [.swiftLanguageMode(.v5)] + swiftGodotBuildSettings
    ),

    // Test extension (loaded by Godot) - includes all test infrastructure and test suites
    .target(
        name: "SwiftGodotTestExtension",
        dependencies: [.target(name: swiftGodotTargetName), "SwiftGodotTestMacros"],
        path: "Tests/SwiftGodotTestExtension",
        swiftSettings: [.swiftLanguageMode(.v5)] + swiftGodotBuildSettings,
        plugins: ["TestSuiteGeneratorPlugin"]
    ),
]

// Macro tests don't work on Windows yet
#if !os(Windows)
    // Idea: -mark_dead_strippable_dylib
    targets.append(
        .testTarget(
            name: "SwiftGodotMacrosTests",
            dependencies: [
                "SwiftGodotMacroLibrary",
                .target(name: swiftGodotTargetName),
                .product(name: "SwiftSyntaxMacrosTestSupport", package: "swift-syntax"),
            ],
            exclude: ["Resources"],
            resources: [
                .copy("Resources")
            ],
            swiftSettings: [.swiftLanguageMode(.v5)] + swiftGodotBuildSettings
        ))
#endif

let package = Package(
    name: swiftGodotPackageName,
    platforms: [
        .macOS(.v14),
        .iOS (.v17)
    ],
    products: products,
    traits: [
        .trait(
            name: withMultiProcessTrait,
            description: "Use multi-process-safe code generation with reinitialization support."
        ),
    ],
    dependencies: dependencies,
    targets: targets
)
