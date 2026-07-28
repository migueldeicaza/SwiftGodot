// swift-tools-version: 6.3

import PackageDescription

// Keep this as the root package so the validation build sees SwiftGodotBinary
// exactly the way a real client does. The dependency identity must differ from
// the source package's `swiftgodot` identity embedded in the XCFramework
// interfaces.
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
