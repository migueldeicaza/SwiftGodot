// swift-tools-version: 6.3
import PackageDescription
let package = Package(
    name: "SwiftGodotEditor",
    platforms: [ .macOS(.v14), .iOS(.v17) ],
    products: [ .library(name: "SwiftGodotEditor", type: .dynamic, targets: ["SwiftGodotEditor"]) ],
    traits: [
        .trait(
            name: "with_multi_process",
            description: "Use multi-process-safe code generation with reinitialization support."
        ),
    ],
    dependencies: [
        .package(path: "../Infra"), .package(path: "../Runtime", traits: [.trait(name: "with_multi_process", condition: .when(traits: ["with_multi_process"]))]), .package(path: "../Core", traits: [.trait(name: "with_multi_process", condition: .when(traits: ["with_multi_process"]))]),
        .package(path: "../Controls", traits: [.trait(name: "with_multi_process", condition: .when(traits: ["with_multi_process"]))]), .package(path: "../ThreeD", traits: [.trait(name: "with_multi_process", condition: .when(traits: ["with_multi_process"]))]),
        .package(path: "../GLTF", traits: [.trait(name: "with_multi_process", condition: .when(traits: ["with_multi_process"]))]), .package(path: "../XR", traits: [.trait(name: "with_multi_process", condition: .when(traits: ["with_multi_process"]))]),
    ],
    targets: [
        .target(name: "SwiftGodotEditor",
            dependencies: [
                .product(name: "GDExtension", package: "Infra"),
                .product(name: "SwiftGodotRuntime", package: "Runtime"),
                .product(name: "SwiftGodotCore", package: "Core"),
                .product(name: "SwiftGodotControls", package: "Controls"),
                .product(name: "SwiftGodot3D", package: "ThreeD"),
                .product(name: "SwiftGodotGLTF", package: "GLTF"),
                .product(name: "SwiftGodotXR", package: "XR"),
            ],
            swiftSettings: [ .define("CUSTOM_BUILTIN_IMPLEMENTATIONS"),
                .define("SWIFTGODOT_WITH_MULTI_PROCESS", .when(traits: ["with_multi_process"])), .unsafeFlags(["-suppress-warnings"]), .swiftLanguageMode(.v5) ],
            linkerSettings: [ .unsafeFlags(["-Xlinker","-reexport-lSwiftGodotCore","-Xlinker","-reexport-lSwiftGodotControls","-Xlinker","-reexport-lSwiftGodot3D","-Xlinker","-reexport-lSwiftGodotGLTF","-Xlinker","-reexport-lSwiftGodotXR"]) ],
            plugins: [ .plugin(name: "CodeGeneratorPlugin", package: "Infra") ]
        )
    ]
)
