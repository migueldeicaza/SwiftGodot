// swift-tools-version: 6.3

import CompilerPluginSupport
import PackageDescription

let package = Package(
    name: "SwiftGodotBinaryTest",
    platforms: [.macOS(.v14)],
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
        .executableTarget(
            name: "BinaryClient",
            dependencies: ["SwiftGodotSupport"],
            path: "Client"
        ),
    ]
)
