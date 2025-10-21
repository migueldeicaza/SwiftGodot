// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Samples",
    platforms: [
        .iOS(.v17),
        .macOS(.v15)
    ],
    dependencies: [
        .package(path: "..")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .executableTarget(
            name: "DemoStatic",
            dependencies: [
                .product(name: "SwiftGodotStatic", package: "SwiftGodot")

            ],
            linkerSettings: [
                .unsafeFlags(
                    ["-Xlinker", "-dead_strip", "-Xlinker", "-no_exported_symbols"],
                    .when(platforms: [.macOS, .iOS])
                ),
//                .unsafeFlags(
//                    ["-Xlinker", "-map", "-Xlinker", ".build/DemoStatic.map"],
//                    .when(platforms: [.macOS, .iOS])
//                )
//
            ]
        ),
    ]
)
