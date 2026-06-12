// swift-tools-version: 6.3

// SwiftGodotControls: GUI control classes (Button, Label, Tree, ...). Depends on
// the SwiftGodotCore dylib and references it dynamically (no embedding). Also
// hosts the "deferred" members of lower-module classes whose API references a
// controls type — e.g. `ButtonGroup.getPressedButton() -> BaseButton`, which is
// omitted from core and re-emitted here as an extension.

import PackageDescription

let package = Package(
    name: "SwiftGodotControls",
    platforms: [
        .macOS(.v14),
        .iOS(.v17),
    ],
    products: [
        .library(
            name: "SwiftGodotControls",
            type: .dynamic,
            targets: ["SwiftGodotControls"]
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
            name: "SwiftGodotControls",
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
