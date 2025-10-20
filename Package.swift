// swift-tools-version: 6.0

import CompilerPluginSupport
import PackageDescription

// Products define the executables and libraries a package produces, and make them visible to other packages.
var products: [Product] = [
//    .library(
//        name: "SwiftGodot",
//        type: .dynamic,
//        targets: ["SwiftGodot"]
//    ),
//    .library(
//        name: "SwiftGodotStatic",
//        targets: ["SwiftGodot"]
//    ),

    // The components of SwiftGodot
    .library(
        name: "SwiftGodotRuntime",
        type: .dynamic,
        targets: ["SwiftGodotRuntime"]
    ),
    .library(
        name: "SwiftGodotCore",
        type: .dynamic,
        targets: ["SwiftGodotCore"]
    ),
//    .library(
//        name: "SwiftGodot2D",
//        type: .dynamic,
//        targets: ["SwiftGodot2D"]
//    ),
//
//    .library(
//        name: "SwiftGodot3D",
//        type: .dynamic,
//        targets: ["SwiftGodot3D"]
//    ),
//    .library(
//        name: "SwiftGodotControls",
//        type: .dynamic,
//        targets: ["SwiftGodotControls"]
//    ),
//    .library(
//        name: "SwiftGodotGLTF",
//        type: .dynamic,
//        targets: ["SwiftGodotGLTF"]
//    ),
//    .library(
//        name: "SwiftGodotXR",
//        type: .dynamic,
//        targets: ["SwiftGodotXR"]
//    ),
//    .library(
//        name: "SwiftGodotVisualShaderNodes",
//        type: .dynamic,
//        targets: ["SwiftGodotVisualShaderNodes"]
//    ),
//    .library(
//        name: "SwiftGodotEditor",
//        type: .dynamic,
//        targets: ["SwiftGodotEditor"]),
//    .library(
//        name: "ExtensionApi",
//        targets: [
//            "ExtensionApi",
//            "ExtensionApiJson",
//        ]
//    ),
//
//    .plugin(
//        name: "CodeGeneratorPlugin",
//        targets: ["CodeGeneratorPlugin"]
//    ),
//
//    .plugin(
//        name: "EntryPointGeneratorPlugin",
//        targets: ["EntryPointGeneratorPlugin"]
//    ),
//
//    .library(
//        name: "SimpleExtension",
//        type: .dynamic,
//        targets: ["SimpleExtension"]
//    ),
//
//    .library(
//        name: "ManualExtension",
//        type: .dynamic,
//        targets: ["ManualExtension"]
//    ),
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
        dependencies: ["Generator"],
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
        swiftSettings: [.swiftLanguageMode(.v5)]
    ),
//    // This contains sample code showing how to use the SwiftGodot API
//    .target(
//        name: "SimpleExtension",
//        dependencies: [
//            .product(name: "SwiftGodot2D", package: "SwiftGodot"),
//	],
//        exclude: ["SimpleExtension.gdextension", "README.md"],
//        swiftSettings: [.swiftLanguageMode(.v5)],
//        plugins: [.plugin(name: "EntryPointGeneratorPlugin")]
//    ),
//
//    // This contains sample code showing how to use the SwiftGodot API
//    // with manual registration of methods and properties
//    .target(
//        name: "ManualExtension",
//        dependencies: [
//            .product(name: "SwiftGodot2D", package: "SwiftGodot"),
//	],
//        exclude: ["ManualExtension.gdextension", "README.md"],
//        swiftSettings: [.swiftLanguageMode(.v5)]
//    ),
//
    // This is the binding itself, it is made up of our generated code for the
    // Godot API, supporting infrastructure and extensions to the API to provide
    // a better Swift experience
    .target(
        name: "SwiftGodotRuntime",
        dependencies: ["GDExtension"],
        swiftSettings: [
            .swiftLanguageMode(.v5),
            .define("CUSTOM_BUILTIN_IMPLEMENTATIONS"),
        ],
        plugins: ["CodeGeneratorPlugin", "SwiftGodotMacroLibrary"]
    ),
    .target(
        name: "SwiftGodotCore",
        dependencies: [
            //.product(name: "SwiftGodotRuntime", package: "SwiftGodot")
	    "SwiftGodotRuntime"
        ],
        swiftSettings: [
            .swiftLanguageMode(.v5),
            .define("CUSTOM_BUILTIN_IMPLEMENTATIONS"),
        ],
        plugins: ["CodeGeneratorPlugin"]
    ),
//    .target(
//        name: "SwiftGodot2D",
//        dependencies: [
//            .product(name: "SwiftGodotRuntime", package: "SwiftGodot"),
//            .product(name: "SwiftGodotCore", package: "SwiftGodot")
//        ],
//        swiftSettings: [
//            .swiftLanguageMode(.v5),
//            .define("CUSTOM_BUILTIN_IMPLEMENTATIONS"),
//        ],
//        plugins: ["CodeGeneratorPlugin"]
//    ),
////    .target(
//        name: "SwiftGodot3D",
//        dependencies: [
//            .product(name: "SwiftGodotRuntime", package: "SwiftGodot"),
//            .product(name: "SwiftGodotCore", package: "SwiftGodot")
//        ],
//        swiftSettings: [
//            .swiftLanguageMode(.v5),
//            .define("CUSTOM_BUILTIN_IMPLEMENTATIONS"),
//        ],
//        plugins: ["CodeGeneratorPlugin"]
//    ),
//    .target(
//        name: "SwiftGodotGLTF",
//        dependencies: [
//            .product(name: "SwiftGodotRuntime", package: "SwiftGodot"),
//            .product(name: "SwiftGodotCore", package: "SwiftGodot"),
//            .product(name: "SwiftGodot3D", package: "SwiftGodot"),
//        ],
//        swiftSettings: [
//            .swiftLanguageMode(.v5),
//            .define("CUSTOM_BUILTIN_IMPLEMENTATIONS"),
//        ],
//        plugins: ["CodeGeneratorPlugin"]
//    ),
//    .target(
//        name: "SwiftGodotControls",
//        dependencies: [
//            .product(name: "SwiftGodotRuntime", package: "SwiftGodot"),
//            .product(name: "SwiftGodotCore", package: "SwiftGodot"),
//        ],
//        swiftSettings: [
//            .swiftLanguageMode(.v5),
//            .define("CUSTOM_BUILTIN_IMPLEMENTATIONS"),
//        ],
//        plugins: ["CodeGeneratorPlugin"]
//    ),
//    .target(
//        name: "SwiftGodotVisualShaderNodes",
//        dependencies: [
//            .product(name: "SwiftGodotRuntime", package: "SwiftGodot"),
//            .product(name: "SwiftGodotCore", package: "SwiftGodot"),
//        ],
//        swiftSettings: [
//            .swiftLanguageMode(.v5),
//            .define("CUSTOM_BUILTIN_IMPLEMENTATIONS"),
//        ],
//        plugins: ["CodeGeneratorPlugin"]
//    ),
//    .target(
//        name: "SwiftGodotXR",
//        dependencies: [
//            .product(name: "SwiftGodotRuntime", package: "SwiftGodot"),
//            .product(name: "SwiftGodotCore", package: "SwiftGodot"),
//            .product(name: "SwiftGodotControls", package: "SwiftGodot"),
//            .product(name: "SwiftGodot3D", package: "SwiftGodot"),
//        ],
//        swiftSettings: [
//            .swiftLanguageMode(.v5),
//            .define("CUSTOM_BUILTIN_IMPLEMENTATIONS"),
//        ],
//        plugins: ["CodeGeneratorPlugin"]
//    ),
//    .target(
//        name: "SwiftGodotEditor",
//        dependencies: [
//            .product(name: "SwiftGodotCore", package: "SwiftGodot",),
//            .product(name: "SwiftGodotControls", package: "SwiftGodot",),
//            .product(name: "SwiftGodot3D", package: "SwiftGodot",),
//            .product(name: "SwiftGodotGLTF", package: "SwiftGodot"),
//        ],
//        swiftSettings: [
//            .swiftLanguageMode(.v5),
//            .define("CUSTOM_BUILTIN_IMPLEMENTATIONS"),
//        ],
//        plugins: ["CodeGeneratorPlugin"]
//    ),
//    // For the bulky SwiftGodot, I am going to let SwiftPm put an all-in-one library
//    // TODO: what to do about registation differently here?
//    .target(
//        name: "SwiftGodot",
//        dependencies: [
//            "SwiftGodotRuntime",
//            "SwiftGodotCore",
//            "SwiftGodot2D",
//            "SwiftGodot3D",
//            "SwiftGodotGLTF",
//            "SwiftGodotControls",
//            "SwiftGodotVisualShaderNodes",
//            "SwiftGodotXR",
//            "SwiftGodotEditor"
//        ],
//        swiftSettings: [
//            .swiftLanguageMode(.v5),
//            .define("CUSTOM_BUILTIN_IMPLEMENTATIONS"),
//        ],
//    ),
//
//    // General purpose cross-platform tests
//    .testTarget(
//        name: "SwiftGodotUniversalTests",
//        dependencies: [
//            "SwiftGodot",
//            "ExtensionApi",
//            "ExtensionApiJson",
//        ],
//        swiftSettings: [.swiftLanguageMode(.v5)]
//    ),
]

// Macro tests don't work on Windows yet
//  #if !os(Windows)
//      // Idea: -mark_dead_strippable_dylib
//      targets.append(
//          .testTarget(
//              name: "SwiftGodotMacrosTests",
//              dependencies: [
//                  "SwiftGodotMacroLibrary",
//                  .product(name: "SwiftGodotCore", package: "SwiftGodot"),
//                  .product(name: "SwiftSyntaxMacrosTestSupport", package: "swift-syntax"),
//              ],
//              resources: [
//                  .copy("Resources")
//              ],
//              swiftSettings: [.swiftLanguageMode(.v5)]
//          ))
//  #endif
//  
//  // libgodot is only available for macOS and testability runtime depends on it
//  #if os(macOS)
//      /// You might want to build your own libgodot, so you can step into it in the debugger when fixing failing tests. Here's how:
//      ///
//      /// 1. Check out the appropriate branch of https://github.com/migueldeicaza/libgodot
//      /// 2. Build with `scons platform=macos target=template_debug dev_build=yes library_type=shared_library`. The `target=template_debug` is important, because `target=editor` will get you a `TOOLS_ENABLED` build that breaks some test cases.
//      /// 3. Use `scripts/make-libgodot.framework` to build an `xcframework` and put it at the root of your SwiftGodot work tree.
//      /// 4. Change `#if true` to `#if false` below.
//      ///
//      #if true
//          let libgodot_tests = Target.binaryTarget(
//              name: "libgodot_tests",
//              url: "https://github.com/migueldeicaza/SwiftGodotKit/releases/download/4.3.5/libgodot.xcframework.zip",
//              checksum: "865ea17ad3e20caab05b3beda35061f57143c4acf0e4ad2684ddafdcc6c4f199"
//          )
//      #else
//          let libgodot_tests = Target.binaryTarget(
//              name: "libgodot_tests",
//              path: "libgodot.xcframework"
//          )
//      #endif
//  
//      targets.append(contentsOf: [
//          // Godot runtime as a library
//  
//          libgodot_tests,
//  
//  //        // Base functionality for Godot runtime dependant tests
//  //        .target(
//  //            name: "SwiftGodotTestability",
//  //            dependencies: [
//  //                "SwiftGodot",
//  //                "libgodot_tests",
//  //                "GDExtension",
//  //            ],
//  //            swiftSettings: [.swiftLanguageMode(.v5)]
//  //        ),
//  //
//          // General purpose runtime dependant tests
//  //        .testTarget(
//  //            name: "SwiftGodotTests",
//  //            dependencies: [
//  //                "SwiftGodotTestability"
//  //            ],
//  //            swiftSettings: [.swiftLanguageMode(.v5)]
//  //        ),
//  //
//          // Runtime dependant tests based on the engine tests from Godot's repository
//  //        .testTarget(
//  //            name: "SwiftGodotEngineTests",
//  //            dependencies: [
//  //                "SwiftGodotTestability"
//  //            ],
//  //            swiftSettings: [.swiftLanguageMode(.v5)]
//  //        ),
//      ])
//  
//  //    products.append(
//  //        .library(
//  //            name: "SwiftGodotTestability",
//  //            targets: ["SwiftGodotTestability"]))
//  //
//  #endif

let package = Package(
    name: "SwiftGodot",
    platforms: [
        .macOS(.v14),
        .iOS (.v17)
    ],
    products: products,
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.3.0"),
        .package(url: "https://github.com/swiftlang/swift-docc-plugin", from: "1.3.0"),
        .package(url: "https://github.com/swiftlang/swift-syntax", from: "600.0.1"),

        // This is so that we can reference other packages with the `.product(name:package:)`
        // syntax prevents SwiftPM from creating libraries that embed the dependencies in
        // them.  Without this, if SwiftGodot2D depends on SwiftGodotCore, this would put
        // the contents of SwiftGodotCore into SwiftGodot2D.   By referencing packages
        // with .package(name: "SwiftGodotCore", package: "SwiftGodot") that behavior
        // is avoided.
        .package(name: "SwiftGodot", path: ".")
    ],
    targets: targets
)
