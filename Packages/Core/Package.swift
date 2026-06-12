// swift-tools-version: 6.3

// SwiftGodotCore: the bulk of the engine classes that aren't 2D/3D/editor
// specific. Depends on the SwiftGodotRuntime dylib and references it
// dynamically (no embedding). Re-exports the runtime dylib at link time so a
// consumer that links SwiftGodotCore also resolves runtime symbols.

import PackageDescription

let package = Package(
    name: "SwiftGodotCore",
    platforms: [
        .macOS(.v14),
        .iOS(.v17),
    ],
    products: [
        .library(
            name: "SwiftGodotCore",
            type: .dynamic,
            targets: ["SwiftGodotCore"]
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
    ],
    targets: [
        .target(
            name: "SwiftGodotCore",
            dependencies: [
                .product(name: "GDExtension", package: "Infra"),
                .product(name: "SwiftGodotRuntime", package: "Runtime"),
            ],
            swiftSettings: [
                .define("CUSTOM_BUILTIN_IMPLEMENTATIONS"),
                .define("SWIFTGODOT_WITH_MULTI_PROCESS", .when(traits: ["with_multi_process"])),
                .unsafeFlags(["-suppress-warnings"]),
                .swiftLanguageMode(.v5),
            ],
            linkerSettings: [
                // Re-export the runtime dylib so downstream linkers resolve
                // runtime symbols through SwiftGodotCore.
                .unsafeFlags(["-Xlinker", "-reexport-lSwiftGodotRuntime"]),
            ],
            plugins: [
                .plugin(name: "CodeGeneratorPlugin", package: "Infra"),
            ]
        ),
    ]
)
