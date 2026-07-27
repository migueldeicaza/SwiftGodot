// swift-tools-version: 6.3

import PackageDescription

// Keep this as the root package so swift-syntax remains a transitive,
// host-only dependency supplied by SwiftGodotBinary's macro target. The
// dependency identity must also differ from the source package's `swiftgodot`
// identity embedded in the XCFramework interfaces.
let package = Package(
    name: "BinaryClient",
    platforms: [.macOS(.v14)],
    dependencies: [
        .package(path: "../SwiftGodotBinary"),
    ],
    targets: [
        .executableTarget(
            name: "BinaryClient",
            dependencies: [
                .product(name: "SwiftGodot", package: "SwiftGodotBinary"),
            ]
        ),
    ]
)
