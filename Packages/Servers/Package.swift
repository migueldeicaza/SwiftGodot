// swift-tools-version: 6.3

// SwiftGodotServers: generated bindings for the large Godot server families
// split out of SwiftGodotCore as a size experiment.

import PackageDescription

let package = Package(
    name: "SwiftGodotServers",
    platforms: [
        .macOS(.v14),
        .iOS(.v17),
    ],
    products: [
        .library(
            name: "SwiftGodotServers",
            type: .dynamic,
            targets: ["SwiftGodotServers"]
        ),
    ],
    traits: [
        .trait(
            name: "with_multi_process",
            description: "Use multi-process-safe code generation with reinitialization support."
        ),
    ],
    dependencies: [
        .package(path: "../Infra"),
        .package(path: "../Runtime", traits: [.trait(name: "with_multi_process", condition: .when(traits: ["with_multi_process"]))]),
        .package(path: "../Core", traits: [.trait(name: "with_multi_process", condition: .when(traits: ["with_multi_process"]))]),
    ],
    targets: [
        .target(
            name: "SwiftGodotServers",
            dependencies: [
                .product(name: "GDExtension", package: "Infra"),
                .product(name: "SwiftGodotRuntime", package: "Runtime"),
                .product(name: "SwiftGodotCore", package: "Core"),
            ],
            swiftSettings: [
                .define("CUSTOM_BUILTIN_IMPLEMENTATIONS"),
                .define("SWIFTGODOT_WITH_MULTI_PROCESS", .when(traits: ["with_multi_process"])),
                .unsafeFlags(["-suppress-warnings"]),
                .swiftLanguageMode(.v5),
            ],
            linkerSettings: [
                .unsafeFlags(["-Xlinker", "-reexport-lSwiftGodotCore"]),
            ],
            plugins: [
                .plugin(name: "CodeGeneratorPlugin", package: "Infra"),
            ]
        ),
    ]
)
