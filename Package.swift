// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import CompilerPluginSupport
import PackageDescription

var linkerSettings: [LinkerSetting] = []
#if os(macOS)
    linkerSettings.append(.unsafeFlags([
        "-Xlinker", "-undefined",
        "-Xlinker", "dynamic_lookup",
    ]))
#endif

// Products define the executables and libraries a package produces, and make them visible to other packages.
var products: [Product] = [
    .library(
        name: "SwiftGodot",
        type: .dynamic,
        targets: ["SwiftGodot"]
    ),
    .plugin(name: "CodeGeneratorPlugin", targets: ["CodeGeneratorPlugin"]),
]

// Macros aren't supported on Windows yet and this sample uses them
#if !os(Windows)
    products.append(
        .library(
            name: "SimpleExtension",
            type: .dynamic,
            targets: ["SimpleExtension"]
        ))
#endif

var targets: [Target] = [
    // The generator takes Godot's JSON-based API description as input and
    // produces Swift API bindings that can be used to call into Godot.
    .executableTarget(
        name: "Generator",
        dependencies: ["XMLCoder"],
        path: "Generator",
        exclude: ["README.md"]
    ),

    // This is a build-time plugin that invokes the generator and produces
    // the bindings that are compiled into SwiftGodot
    .plugin(
        name: "CodeGeneratorPlugin",
        capability: .buildTool(),
        dependencies: ["Generator"]
    ),

    // This allows the Swift code to call into the Godot bridge API (GDExtension)
    .target(
        name: "GDExtension"),
]

var swiftGodotPlugins: [Target.PluginUsage] = ["CodeGeneratorPlugin"]

// Macros aren't supported on Windows yet
#if !os(Windows)
    targets.append(contentsOf: [
        // These are macros that can be used by third parties to simplify their
        // SwiftGodot development experience, these are used at compile time by
        // third party projects
        .macro(name: "SwiftGodotMacroLibrary",
               dependencies: [
                   .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                   .product(name: "SwiftSyntax", package: "swift-syntax"),
                   .product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
               ]),
        // This contains sample code showing how to use the SwiftGodot API
        .target(
            name: "SimpleExtension",
            dependencies: ["SwiftGodot"],
            exclude: ["SwiftSprite.gdextension", "README.md"],
            linkerSettings: linkerSettings
        ),
        // Idea: -mark_dead_strippable_dylib
        .testTarget(name: "SwiftGodotMacroTests",
                    dependencies: [
                        "SwiftGodotMacroLibrary",
                        "SwiftGodot",
                        .product(name: "SwiftSyntaxMacrosTestSupport", package: "swift-syntax"),
                    ]),
    ])
    swiftGodotPlugins.append("SwiftGodotMacroLibrary")
#endif

targets.append(
    // This is the binding itself, it is made up of our generated code for the
    // Godot API, supporting infrastructure and extensions to the API to provide
    // a better Swift experience
    .target(
        name: "SwiftGodot",
        dependencies: ["GDExtension"],
        exclude: ["extension_api.json"],
        linkerSettings: linkerSettings,
        plugins: swiftGodotPlugins
    )
)

let package = Package(
    name: "SwiftGodot",
    platforms: [
        .macOS(.v13),
        .iOS("16.0"),
    ],
    products: products,
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(url: "https://github.com/CoreOffice/XMLCoder", from: "0.15.0"),
        .package(url: "https://github.com/apple/swift-docc-plugin", from: "1.0.0"),
        .package(url: "https://github.com/apple/swift-syntax.git", from: "509.0.0"),
    ],
    targets: targets
)
