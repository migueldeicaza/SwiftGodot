// swift-tools-version: 6.3

import CompilerPluginSupport
import PackageDescription

// Local variant of Package.swift.template used by scripts/test-binary-package:
// the same graph, reading the XCFrameworks from disk instead of a release.
let package = Package(
    name: "SwiftGodot",
    platforms: [
        .macOS(.v14),
        .iOS(.v17),
    ],
    products: [
        .library(name: "SwiftGodot", targets: ["SwiftGodotSupport"]),
        .library(name: "SwiftGodotRuntime", targets: ["SwiftGodotRuntimeSupport"]),
    ],
    targets: [
        .binaryTarget(name: "SwiftGodot", path: "Artifacts/SwiftGodot.xcframework"),
        .binaryTarget(name: "SwiftGodotRuntime", path: "Artifacts/SwiftGodotRuntime.xcframework"),
        .binaryTarget(name: "GDExtension", path: "Artifacts/GDExtension.xcframework"),
        .binaryTarget(name: "SwiftGodotMacroPlugin", path: "Artifacts/SwiftGodotMacroPlugin.xcframework"),
        .macro(
            name: "SwiftGodotMacroLibrary",
            dependencies: ["SwiftGodotMacroPlugin"]
        ),
        .target(
            name: "SwiftGodotSupport",
            dependencies: [
                "SwiftGodot",
                "SwiftGodotRuntime",
                "GDExtension",
                "SwiftGodotMacroLibrary",
            ]
        ),
        .target(
            name: "SwiftGodotRuntimeSupport",
            dependencies: [
                "SwiftGodotRuntime",
                "GDExtension",
                "SwiftGodotMacroLibrary",
            ]
        ),
    ]
)
