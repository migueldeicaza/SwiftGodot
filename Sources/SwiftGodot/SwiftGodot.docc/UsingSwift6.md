# Using The Swift 6 Compiler With SwiftGodot

Swift 6 added a host of features which aim to make it dramatically easier to write concurrent code that is free from data-races. The compiler will now be able to catch many more concurrency bugs at compile time. However, SwiftGodot is not yet ready to adopt all of Swift 6's new concurrency model. In the meanwhile, this guide will show you how to get SwiftGodot running with Swift 6 tools.

## Clearing Up Misconceptions
First we must understand the difference between Swift **tool versions** and **language modes**. 

The Swift **tool version** is the version of Swift that you have downloaded on your system. To identify which version of Swift you have installed, you can run `swift -version` in the terminal. 

The Swift **language mode** determines which version of Swift <u>syntax</u> you would like to use. This also determines which Swift language features you are able to use in your code. 

The Swift 6 **tool version** is able to run in the following language modes: 
- Swift 4
- Swift 4.2
- Swift 5
- Swift 6

## Path To Using Swift 6 Tooling
If your system has Swift 6 installed, you may notice that your SwiftGodot project will not compile. This is because the Swift 6 compiler is more strict about certain things that the Swift 5 compiler was not. Here are a few pathways to get your SwiftGodot project to compile with Swift 6 tools: 

1. **Use the Swift 5 language mode**: You can use the Swift 5 language mode in your Swift 6 compiler. This will allow you to use the Swift 5 features that you are familiar with.
2. **Use the Swift 6 language mode**: You can use the Swift 6 language mode in your Swift 6 compiler. This will allow you to use the latest Swift 6 features. However, you will need to suppress some errors in order to get your SwiftGodot project to compile.

**We recommend using the Swift 5 language mode for now unless you require Swift 6 only features.** This will allow you to continue using SwiftGodot without having to suppress any errors. (Bear in mind that it is possible to use Swift 6 features even in the Swift 5 language mode by enabling upcoming feature flags).

## Which Language Mode Am I Using?

The best place to find out which language mode you are using is in the Swift docs: [Enabling The Swift 6 Language Mode](https://www.swift.org/migration/documentation/swift-6-concurrency-migration-guide/swift6mode/). Here we will summarize a few highlights from the documentation. Be sure to read the docs to make the best informed decision for your project. 

### SPM
If you are using Swift Package Manager with the Swift 6 tools, then your targets will be using the Swift 6 language mode, by default. To opt into the Swift 5 language mode, you can add the following to your `Package.swift` file: 

```swift
// swift-tools-version:6.0

// ...
targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "MySwiftGodotProject",
            dependencies: [
                "SwiftGodot", 
            ],
            swiftSettings: [
                .swiftLanguageMode(.v5), // 👈🏼
            ]
        ),
    ]

    // ...
```

## Using the Swift 5 Language Mode

### Concurrency Safety in Swift 5 Language Mode
It's important to remember that just because you are using the Swift 5 language mode does not mean that your code loses Swift's powerful concurrency features such as `async` and `await` (which were added in Swift 5.5). 

#### Using Swift 6 Features And Strict Concurrency Checking In Swift 5 Language Mode
It's important to note that you can still use Swift 6 features in the Swift 5 language mode. In particular, you should consider turning on strict concurrency checking in the Swift 5 language mode. Unlike the Swift 6 language mode, when you turn on strict concurrency checking in the Swift 5 language mode, concurrency violations will result in compiler warnings, not errors. 


## Using The Swift 6 Language Mode
If you do decide to use Swift 6 language mode, you will need to suppress some warnings in order to get your SwiftGodot project to compile. Here are a few tips to help you get started:

## Use `@unchecked Sendable`
It is recommended to add `@unchecked Sendable` conformance to any type that has the `@Godot` macro attached to it. 

```swift 
@Godot class MyType: @unchecked Sendable {
	  // ...
}
```

This does not make your code any less safe than it was before Swift 6. Rather it is telling the compiler that you are opting out of strict sendability checking for this type. In other words you are telling the compiler that you will handle the responsibility of ensuring that this type is safe to be sent across concurrency boundaries. (Since this was the case before Swift 6, this is not any less safe than it was before).

>Not adding `@unchecked Sendable` to your `@Godot` types means that certain features like the `@Callable` macro will not compile. 

## Consider using `@preconcurrency import SwiftGodot`
You should also consider using `@preconcurrency import SwiftGodot` to import SwiftGodot. Certain features may not compile without using `@preconcurrency`. 
