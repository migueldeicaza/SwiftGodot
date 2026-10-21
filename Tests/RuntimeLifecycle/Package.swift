// swift-tools-version: 6.3

import PackageDescription

let fixtureNames = [
    "LifecycleDefaultExtension",
    "LifecycleExtensionA",
    "LifecycleExtensionB",
]

let package = Package(
    name: "RuntimeLifecycle",
    platforms: [.macOS(.v14)],
    products: fixtureNames.map {
        .library(name: $0, type: .dynamic, targets: [$0])
    },
    dependencies: [.package(path: "../..")],
    targets: fixtureNames.map {
        .target(
            name: $0,
            dependencies: [.product(name: "SwiftGodot", package: "SwiftGodot")],
            path: $0,
            swiftSettings: [.swiftLanguageMode(.v5)]
        )
    }
)
