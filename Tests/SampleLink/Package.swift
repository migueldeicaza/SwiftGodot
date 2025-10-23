// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Samples",
    platforms: [
        .iOS(.v17),
        .macOS(.v15)
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
                .unsafeFlags(
                    ["-Xlinker", "-dead_strip",
		    "-Xlinker", "-no_exported_symbols",
		    "-Xlinker", "-why_live",
		    //"-Xlinker", "_$s10SwiftGodot10OpenXRHandC10BoneUpdateOMa"]
		    //"-Xlinker", "_$s10SwiftGodot10OpenXRHandC10BoneUpdateOSYAAMA"
		    "-Xlinker", "_$s10SwiftGodot10OpenXRHandC15method_set_hand33_0B6DE4D26A8E536FD53858E8549F662ELLSVvpZ"
		    ],
                    .when(platforms: [.macOS, .iOS])
                ),
//                .unsafeFlags(
//                    ["-Xlinker", "-map", "-Xlinker", ".build/DemoStatic.map"],
//                    .when(platforms: [.macOS, .iOS])
//                )
//
            ]
        ),
    ]
)
