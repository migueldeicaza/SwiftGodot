// swift-tools-version: 6.3

// SwiftGodotRuntime: the core runtime (builtins, Object, RefCounted, the small
// set of bootstrap classes). This is the one dylib that holds the global Godot
// interface state; every other module references it dynamically.

import PackageDescription

let package = Package(
    name: "SwiftGodotRuntime",
    platforms: [
        .macOS(.v14),
        .iOS(.v17),
    ],
    products: [
        .library(
            name: "SwiftGodotRuntime",
            type: .dynamic,
            targets: ["SwiftGodotRuntime"]
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
    ],
    targets: [
        .target(
            name: "SwiftGodotRuntime",
            dependencies: [
                .product(name: "GDExtension", package: "Infra"),
            ],
            swiftSettings: [
                .define("CUSTOM_BUILTIN_IMPLEMENTATIONS"),
                .define("SWIFTGODOT_WITH_MULTI_PROCESS", .when(traits: ["with_multi_process"])),
                .unsafeFlags(["-suppress-warnings"]),
                .swiftLanguageMode(.v5),
            ],
            plugins: [
                .plugin(name: "CodeGeneratorPlugin", package: "Infra"),
            ]
        ),
    ]
)
