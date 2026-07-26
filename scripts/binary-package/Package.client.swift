// swift-tools-version: 6.3

import PackageDescription

// Keep this as the root package so swift-syntax remains a transitive,
// host-only dependency supplied by SwiftGodot's macro target.
let package = Package(
    name: "BinaryClient",
    platforms: [.macOS(.v14)],
    dependencies: [
        .package(path: "../SwiftGodot"),
    ],
    targets: [
        .executableTarget(
            name: "BinaryClient",
            dependencies: [
                .product(name: "SwiftGodot", package: "SwiftGodot"),
            ]
        ),
    ]
)
