// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

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
        .plugin(name: "CodeGeneratorPlugin", targets: ["CodeGeneratorPlugin"]),
        .library(
            name: "SimpleExtension",
            type: .dynamic,
            targets: ["SimpleExtension"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
        .package(url: "https://github.com/CoreOffice/XMLCoder", from: "0.15.0"),
        .package(url: "https://github.com/apple/swift-docc-plugin", from: "1.0.0")
    ],
    targets: [
        .plugin(
            name: "CodeGeneratorPlugin",
            capability: .buildTool(),
            dependencies: ["Generator"]
        ),
        .executableTarget(
            name: "Generator",
            dependencies: ["XMLCoder"],
            path: "Generator",
            swiftSettings: [.unsafeFlags (["-enable-bare-slash-regex"])]),
        .target(
            name: "GDExtension"),
        .target(
            name: "SwiftGodot",
            dependencies: ["GDExtension", "Generator"],
            swiftSettings: [.unsafeFlags (["-suppress-warnings"])],
            linkerSettings: [
                .unsafeFlags (
                    ["-Xlinker", "-undefined",
                     "-Xlinker", "dynamic_lookup",
                    ])
            ], plugins: ["CodeGeneratorPlugin"]),
        .target(
            name: "SimpleExtension",
            dependencies: ["SwiftGodot"],
            swiftSettings: [.unsafeFlags (["-suppress-warnings"])],
            linkerSettings: [
                .unsafeFlags (
                    ["-Xlinker", "-undefined",
                     "-Xlinker", "dynamic_lookup"])]),
        // Idea: -mark_dead_strippable_dylib
        .testTarget(
            name: "SwiftGodotTests",
            dependencies: ["SwiftGodot"]),
    ]
)
