// swift-tools-version: 6.3
import PackageDescription
let package = Package(
    name: "SwiftGodotVisualShaderNodes",
    platforms: [ .macOS(.v14), .iOS(.v17) ],
    products: [ .library(name: "SwiftGodotVisualShaderNodes", type: .dynamic, targets: ["SwiftGodotVisualShaderNodes"]) ],
    traits: [
        .trait(
            name: "with_multi_process",
            description: "Use multi-process-safe code generation with reinitialization support."
        ),
    ],
    dependencies: [
        .package(path: "../Infra"), .package(path: "../Runtime", traits: [.trait(name: "with_multi_process", condition: .when(traits: ["with_multi_process"]))]),
        .package(path: "../Core", traits: [.trait(name: "with_multi_process", condition: .when(traits: ["with_multi_process"]))]), .package(path: "../ThreeD", traits: [.trait(name: "with_multi_process", condition: .when(traits: ["with_multi_process"]))]),
    ],
    targets: [
        .target(name: "SwiftGodotVisualShaderNodes",
            dependencies: [
                .product(name: "GDExtension", package: "Infra"),
                .product(name: "SwiftGodotRuntime", package: "Runtime"),
                .product(name: "SwiftGodotCore", package: "Core"),
                .product(name: "SwiftGodot3D", package: "ThreeD"),
            ],
            swiftSettings: [ .define("CUSTOM_BUILTIN_IMPLEMENTATIONS"),
                .define("SWIFTGODOT_WITH_MULTI_PROCESS", .when(traits: ["with_multi_process"])), .unsafeFlags(["-suppress-warnings"]), .swiftLanguageMode(.v5) ],
            linkerSettings: [ .unsafeFlags(["-Xlinker","-reexport-lSwiftGodotCore","-Xlinker","-reexport-lSwiftGodot3D"]) ],
            plugins: [ .plugin(name: "CodeGeneratorPlugin", package: "Infra") ]
        )
    ]
)
