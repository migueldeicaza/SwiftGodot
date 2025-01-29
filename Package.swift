// swift-tools-version: 6.0

import CompilerPluginSupport
import PackageDescription
import Foundation

// Products define the executables and libraries a package produces, and make them visible to other packages.
var products: [Product] = [
    .library(
        name: "SwiftGodot",
        type: .dynamic,
        targets: ["SwiftGodot"]
    ),

    .library(
        name: "SwiftGodotStatic",
        targets: ["SwiftGodot"]
    ),

    .library(
        name: "ExtensionApi",
        targets: [
            "ExtensionApi",
            "ExtensionApiJson",
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
        swiftSettings: [.swiftLanguageMode(.v5)]
    ),

    // This contains GDExtension's JSON API data models
    .target(
        name: "ExtensionApi",
        exclude: ["ExtensionApiJson.swift", "extension_api.json"],
        swiftSettings: [.swiftLanguageMode(.v5)]
    ),

    // This contains a resource bundle with extension_api.json
    .target(
        name: "ExtensionApiJson",
        path: "Sources/ExtensionApi",
        exclude: ["ApiJsonModel.swift", "ApiJsonModel+Extra.swift"],
        sources: ["ExtensionApiJson.swift"],
        resources: [.process("extension_api.json")],
        swiftSettings: [.swiftLanguageMode(.v5)]
    ),

    // The generator takes Godot's JSON-based API description as input and
    // produces Swift API bindings that can be used to call into Godot.
    .executableTarget(
        name: "Generator",
        dependencies: [
            "ExtensionApi",
            .product(name: "SwiftSyntax", package: "swift-syntax"),
            .product(name: "SwiftSyntaxBuilder", package: "swift-syntax"),
        ],
        path: "Generator",
        exclude: ["README.md"],
        swiftSettings: [
            .swiftLanguageMode(.v5)
            // Uncomment for using legacy array-based marshalling
            //.define("LEGACY_MARSHALING")
        ]
    ),

    // This is a build-time plugin that invokes the generator and produces
    // the bindings that are compiled into SwiftGodot.
    .plugin(
        name: "CodeGeneratorPlugin",
        capability: .buildTool(),
        dependencies: ["Generator"]
    ),

    // This is a build-time plugin that generates the EntryPoint.swift file,
    // which is used to bootstrap the SwiftGodot API and register your
    // extension and classes with Godot.
    .plugin(
        name: "EntryPointGeneratorPlugin",
        capability: .buildTool(),
        dependencies: ["EntryPointGenerator"]
    ),

    // This allows the Swift code to call into the Godot bridge API (GDExtension)
    .target(
        name: "GDExtension",
        swiftSettings: [.swiftLanguageMode(.v5)]
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
        ],
        swiftSettings: [
            .swiftLanguageMode(.v5),
            .unsafeFlags(
                [
                    "-Xfrontend", "-entry-point-function-name",
                    "-Xfrontend", "wWinMain",
                ], .when(platforms: [.windows])),
        ]
    ),
    // This contains sample code showing how to use the SwiftGodot API
    .target(
        name: "SimpleExtension",
        dependencies: ["SwiftGodot"],
        exclude: ["SwiftSprite.gdextension", "README.md"],
        swiftSettings: [.swiftLanguageMode(.v5)]
    ),

    // This is the binding itself, it is made up of our generated code for the
    // Godot API, supporting infrastructure and extensions to the API to provide
    // a better Swift experience
    .target(
        name: "SwiftGodot",
        dependencies: ["GDExtension"],
        swiftSettings: [
            .swiftLanguageMode(.v5),
            .define("CUSTOM_BUILTIN_IMPLEMENTATIONS"),
        ],
        plugins: ["CodeGeneratorPlugin", "SwiftGodotMacroLibrary"]
    ),

    // General purpose cross-platform tests
    .testTarget(
        name: "SwiftGodotUniversalTests",
        dependencies: [
            "SwiftGodot",
            "ExtensionApi",
            "ExtensionApiJson",
        ],
        swiftSettings: [.swiftLanguageMode(.v5)]
    ),

    // Macro tests
    // Idea: -mark_dead_strippable_dylib
    .testTarget(
        name: "SwiftGodotMacrosTests",
        dependencies: [
            "SwiftGodotMacroLibrary",
            "SwiftGodot",
            .product(name: "SwiftSyntaxMacrosTestSupport", package: "swift-syntax"),
        ],
        swiftSettings: [.swiftLanguageMode(.v5)]
    ),
]

// libgodot is only available for macOS and most of the tests depend on it
var godotRuntime: Target?
if FileManager.default.fileExists(atPath: "libgodot.xcframework") {
    godotRuntime = .binaryTarget(
        name: "libgodot",
        path: "libgodot.xcframework"
    )
} else { 
    #if os(macOS)
    /// You might want to build your own libgodot, so you can step into it in the debugger when fixing failing tests. Here's how:
    ///
    /// 1. Check out the appropriate branch of https://github.com/migueldeicaza/libgodot
    /// 2. Build with `scons platform=macos target=template_debug dev_build=yes library_type=shared_library`. The `target=template_debug` is important, because `target=editor` will get you a `TOOLS_ENABLED` build that breaks some test cases.
    /// 3. Use `scripts/make-libgodot.framework` to build an `xcframework` and put it at the root of your SwiftGodot work tree.
    /// 4. Change `#if true` to `#if false` below.
    ///
    godotRuntime = .binaryTarget(
        name: "libgodot",
        url: "https://github.com/migueldeicaza/SwiftGodotKit/releases/download/4.3.5/libgodot.xcframework.zip",
        checksum: "865ea17ad3e20caab05b3beda35061f57143c4acf0e4ad2684ddafdcc6c4f199"
    )
    #endif

    #if os(Windows)
    godotRuntime = .systemLibrary(name: "libgodot")
    #endif
}

if let godotRuntime {
    targets.append(contentsOf: [
        // Godot runtime as a library
        godotRuntime,

        // Base functionality for Godot runtime dependant tests
        .target(
            name: "SwiftGodotTestability",
            dependencies: [
                "SwiftGodot",
                "libgodot",
                "GDExtension",
            ],
            swiftSettings: [.swiftLanguageMode(.v5)]
        ),

        // General purpose runtime dependant tests
        .testTarget(
            name: "SwiftGodotTests",
            dependencies: [
                "SwiftGodotTestability"
            ],
            swiftSettings: [.swiftLanguageMode(.v5)]
        ),

        // Runtime dependant tests based on the engine tests from Godot's repository
        .testTarget(
            name: "SwiftGodotEngineTests",
            dependencies: [
                "SwiftGodotTestability"
            ],
            swiftSettings: [.swiftLanguageMode(.v5)]
        ),
    ])

    products.append(
        .library(
            name: "SwiftGodotTestability",
            targets: ["SwiftGodotTestability"]))
}

let package = Package(
    name: "SwiftGodot",
    platforms: [
        .macOS(.v14),
        .iOS(.v17),
    ],
    products: products,
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.3.0"),
        .package(url: "https://github.com/swiftlang/swift-docc-plugin", from: "1.3.0"),
        .package(url: "https://github.com/swiftlang/swift-syntax", from: "600.0.1"),
    ],
    targets: targets
)
