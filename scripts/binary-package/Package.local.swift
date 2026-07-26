// swift-tools-version: 6.3

import CompilerPluginSupport
import PackageDescription

// This package must be consumed through Package.client.swift during validation.
// Making swift-syntax a direct dependency of the root test package causes
// SwiftPM to classify it as exported and intentionally disable prebuilts.
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
    dependencies: [
        .package(url: "https://github.com/swiftlang/swift-syntax", from: "603.0.2"),
    ],
    targets: [
        .binaryTarget(name: "SwiftGodot", path: "Artifacts/SwiftGodot.xcframework"),
        .binaryTarget(name: "SwiftGodotRuntime", path: "Artifacts/SwiftGodotRuntime.xcframework"),
        .binaryTarget(name: "GDExtension", path: "Artifacts/GDExtension.xcframework"),
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
