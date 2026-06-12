// swift-tools-version: 6.3

// SwiftGodot3D: 3D scene classes. Depends on the SwiftGodotCore dylib (dynamic,
// no embedding) and hosts deferred members of core classes that reference 3D
// types — e.g. `Mesh.createTrimeshShape() -> ConcavePolygonShape3D`,
// `Viewport.getCamera3d() -> Camera3D`, and the property
// `FogMaterial.densityTexture -> Texture3D`.

import PackageDescription

let package = Package(
    name: "SwiftGodot3D",
    platforms: [ .macOS(.v14), .iOS(.v17) ],
    products: [
        .library(name: "SwiftGodot3D", type: .dynamic, targets: ["SwiftGodot3D"]),
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
        .package(path: "../Servers", traits: [.trait(name: "with_multi_process", condition: .when(traits: ["with_multi_process"]))]),
    ],
    targets: [
        .target(
            name: "SwiftGodot3D",
            dependencies: [
                .product(name: "GDExtension", package: "Infra"),
                .product(name: "SwiftGodotRuntime", package: "Runtime"),
                .product(name: "SwiftGodotCore", package: "Core"),
                .product(name: "SwiftGodotServers", package: "Servers"),
            ],
            swiftSettings: [
                .define("CUSTOM_BUILTIN_IMPLEMENTATIONS"),
                .define("SWIFTGODOT_WITH_MULTI_PROCESS", .when(traits: ["with_multi_process"])),
                .unsafeFlags(["-suppress-warnings"]),
                .swiftLanguageMode(.v5),
            ],
            linkerSettings: [
                .unsafeFlags(["-Xlinker", "-reexport-lSwiftGodotCore", "-Xlinker", "-reexport-lSwiftGodotServers"]),
            ],
            plugins: [ .plugin(name: "CodeGeneratorPlugin", package: "Infra") ]
        ),
    ]
)
