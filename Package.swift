// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription
import CompilerPluginSupport

let package = Package(
    name: "SwiftGodot",
    platforms: [
        .macOS(.v13),
        .iOS ("16.0")
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "SwiftGodot",
            type: .dynamic,
            targets: ["SwiftGodot"]),
        .library(
            name: "SwiftGodotMacros",
            targets: ["SwiftGodotMacros"]),
        .plugin(name: "CodeGeneratorPlugin", targets: ["CodeGeneratorPlugin"]),
        .library(
            name: "SimpleExtension",
            type: .dynamic,
            targets: ["SimpleExtension"]),
        .library(
            name: "SwiftGodotEditorExtension",
            type: .dynamic,
            targets: ["SwiftGodotEditorExtension"]),

    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
        .package(url: "https://github.com/CoreOffice/XMLCoder", from: "0.15.0"),
        .package(url: "https://github.com/apple/swift-docc-plugin", from: "1.0.0"),
        .package(url: "https://github.com/apple/swift-syntax.git", from: "509.0.0"),
    ],
    targets: [
        // The generator takes Godot's JSON-based API description as input and
        // produces Swift API bindings that can be used to call into Godot.
        .executableTarget(
            name: "Generator",
            dependencies: ["XMLCoder"],
            path: "Generator",
            swiftSettings: [.unsafeFlags (["-enable-bare-slash-regex"])]),
        
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
        
        // This is the binding itself, it is made up of our generated code for the
        // Godot API, supporting infrastructure and extensions to the API to provide
        // a better Swift experience
        .target(
            name: "SwiftGodot",
            dependencies: ["GDExtension"],
            swiftSettings: [.unsafeFlags (["-suppress-warnings"])],
            linkerSettings: [
                .unsafeFlags (
                    ["-Xlinker", "-undefined",
                     "-Xlinker", "dynamic_lookup",
                    ])
            ], plugins: ["CodeGeneratorPlugin"]),
        
        // These are macros that can be used by third parties to simplify their
        // SwiftGodot development experience, these are used at compile time by
        // third party projects
        .macro(name: "SwiftGodotMacroLibrary",
               dependencies: [
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftSyntax", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax")
               ]),
        
        // This contains the macro API contract that is referenced by applications
        .target (
            name: "SwiftGodotMacros",
            dependencies: ["SwiftGodotMacroLibrary", .target(name: "SwiftGodot")]),
        
        // This contains sample code showing how to use the SwiftGodot API
        .target(
            name: "SwiftGodotEditorExtension",
            dependencies: ["SwiftGodot"],
            swiftSettings: [.unsafeFlags (["-suppress-warnings"])],
            linkerSettings: [.unsafeFlags (
                ["-Xlinker", "-undefined",
                 "-Xlinker", "dynamic_lookup"])]),
        .target(
            name: "SimpleExtension",
            dependencies: ["SwiftGodotMacros"],
            swiftSettings: [.unsafeFlags (["-suppress-warnings"])],
            linkerSettings: [
                .unsafeFlags (
                    ["-Xlinker", "-undefined",
                     "-Xlinker", "dynamic_lookup"])]),
        // Idea: -mark_dead_strippable_dylib
        
        // Test suite for SwiftGodot
//        .testTarget(
//            name: "SwiftGodotTests",
//            dependencies: ["SwiftGodot"]),
    ]
)
