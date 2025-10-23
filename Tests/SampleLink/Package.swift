// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Samples",
    platforms: [
        .iOS(.v17),
        .macOS(.v15)
    ],
    products: [
        .executable(name: "DemoStatic", targets: ["DemoStatic"]),
	.library(name: "DemoDynamic", type: .dynamic, targets: ["DemoDynamic"])
    ],
    dependencies: [
        .package(path: "../..")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .executableTarget(
            name: "DemoStatic",
            dependencies: [
                .product(name: "SwiftGodotStatic", package: "SwiftGodot")
            ],
	    swiftSettings: [
                .unsafeFlags(["-Xfrontend", "-internalize-at-link", "-Xfrontend", "-lto=llvm-full", "-Xfrontend", "-disable-reflection-metadata"]),
            ],
            linkerSettings: [
                .unsafeFlags([
                    "-Xlinker", "-dead_strip",
		    "-Xlinker", "-no_exported_symbols",

		    // These are helpful to debug:
		    //"-Xlinker", "-why_live",
		    //"-Xlinker", "SYMBOL_FROM_NM_THAT_YOU_ARE_LOOKING_FOR"
		], .when(platforms: [.macOS, .iOS]))
            ]
        ),

	.target(
            name: "DemoDynamic",
            dependencies: [
                .product(name: "SwiftGodotStatic", package: "SwiftGodot")
            ],
	    swiftSettings: [
                .unsafeFlags(["-Xfrontend", "-internalize-at-link", "-Xfrontend", "-lto=llvm-full", "-Xfrontend", "-disable-reflection-metadata"]),
            ],
            linkerSettings: [
                .unsafeFlags([
                    "-Xlinker", "-dead_strip",
		    "-Xlinker", "-no_exported_symbols",

		    // These are helpful to debug:
		    //"-Xlinker", "-why_live",
		    //"-Xlinker", "SYMBOL_FROM_NM_THAT_YOU_ARE_LOOKING_FOR"]
		], .when(platforms: [.macOS, .iOS]))
            ]
        ),
    ]
)
