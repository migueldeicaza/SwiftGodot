import ExtensionApi
//  main.swift
//  SwiftGodot/Generator
//
//  Created by Miguel de Icaza on 5/20/20.
//  Copyright © 2020-2023 Miguel de Icaza. MIT Licensed
//
import Foundation

var args = CommandLine.arguments

var rootUrl: URL {
    let url = URL(fileURLWithPath: #file)  // SwiftGodot/Generator/Generator/main.swift
        .deletingLastPathComponent()  // SwiftGodot/Generator/Generator
        .deletingLastPathComponent()  // SwiftGodot/Generator
        .deletingLastPathComponent()  // SwiftGodot
    return url
}

var defaultExtensionApiJsonUrl: URL {
    rootUrl
        .appendingPathComponent("Sources")
        .appendingPathComponent("ExtensionApi")
        .appendingPathComponent("extension_api.json")
}

var defaultGeneratorOutputlUrl: URL {
    rootUrl
        .appendingPathComponent("GeneratedForDebug")
        .appendingPathComponent("Sources")
}

var defaultDocRootUrl: URL {
    rootUrl
        .appendingPathComponent("GeneratedForDebug")
        .appendingPathComponent("Docs")
}

let jsonFile = args.count > 1 ? args[1] : defaultExtensionApiJsonUrl.path
var generatorOutput = args.count > 2 ? args[2] : defaultGeneratorOutputlUrl.path
var docRoot = args.count > 3 ? args[3] : defaultDocRootUrl.path
let outputDir = args.count > 2 ? args[2] : generatorOutput

/// Special case for Xogot to avoid caching godot interface pointers
let noStaticCaches = false

// IF we want one file per type, or a smaller number of
// files that are combined.
var combineOutput = args.contains("--combined")

if args.count < 2 {
    print(
        """
        Usage is: generator path-to-extension-api output-directory doc-directory
        - path-to-extension-api is the full path to extension_api.json from Godot
        - output-directory is where the files will be placed
        - doc-directory is the Godot documentation resides (godot/doc)
        Running with defaults:
            path-to-extension-api = "\(jsonFile)"
            output-directory = "\(outputDir)"
            doc-directory = "\(docRoot)"
        """)
}

let jsonData = try! Data(url: URL(fileURLWithPath: jsonFile))
let jsonApi = try! JSONDecoder().decode(JGodotExtensionAPI.self, from: jsonData)

func dropMatchingPrefix(_ enumName: String, _ enumKey: String) -> String {
    let snake = snakeToCamel(enumKey)
    if snake.lowercased().starts(with: enumName.lowercased()) {
        if snake.count == enumName.count {
            return snake
        }
        let ret = String(snake[snake.index(snake.startIndex, offsetBy: enumName.count)...])
        if let f = ret.first {
            if f.isNumber {
                return snake
            }
        }
        if ret == "" {
            return snake
        }
        return ret.first!.lowercased() + ret.dropFirst()
    }
    return snake
}

var globalEnums: [String: JGodotGlobalEnumElement] = [:]

// Maps from a the class name to its definition
var classMap: [String: JGodotExtensionAPIClass] = [:]

// Tracks whether a Godot type has subclasses, we want to use this
// to determine whether we want to perform the more expensive lookup
// for handle -> Swift type using `getOrInitSwiftObject` rather than creating
// a plain wrapper directly from the handle
var hasSubclasses = Set<String>()

for x in jsonApi.classes {
    classMap[x.name] = x
    if let parentClass = x.inherits {
        hasSubclasses.insert(parentClass)
    }
}

let coreTraitSeedClasses: Set<String> = [
    "Object",
    "RefCounted",
    "Node",
]

let mediumTraitSeedClasses: Set<String> = coreTraitSeedClasses.union([
    "Node",
    "Node2D",
    "Node3D",
    "CanvasItem",
    "SceneTree",
    "ProjectSettings",
    "Viewport",
    "Window",
    "Input",
    "InputEvent",
    "Timer",
    "AudioStreamPlayer",
    "DisplayServer",
    "AudioServer",
    "OS",
    "PackedScene",
    "PathFollow2D",
    "CollisionShape2D",
    "RigidBody2D",
    "Sprite2D",
    "AnimatedSprite2D",
    "SpriteFrames",
    "Camera2D",
    "Camera3D",
    "Texture2D",
    "ResourceLoader",
    "ResourceSaver",
    "Material",
    "Shader",
    "RenderingServer",
    "RenderSceneBuffers",
    "RenderSceneBuffersConfiguration",
    "RenderData",
    "Compositor",
    "CompositorEffect",
    "TextServer",
])

let explicitClassTraits: [String: ClassTrait] = [:]

func normalizeClassName(from rawType: String) -> String? {
    var candidate = rawType
    if candidate.hasPrefix("const ") {
        candidate = String(candidate.dropFirst(6))
    }
    if candidate.hasSuffix("*") {
        candidate = String(candidate.dropLast())
    }
    if candidate.hasSuffix("?") {
        candidate = String(candidate.dropLast())
    }
    if candidate.hasPrefix("typedarray::") {
        let nested = String(candidate.dropFirst("typedarray::".count))
        return normalizeClassName(from: nested)
    }
    if candidate.hasPrefix("Ref<") && candidate.hasSuffix(">") {
        let inner = String(candidate.dropFirst(4).dropLast())
        return normalizeClassName(from: inner)
    }
    if candidate.hasPrefix("enum::") || candidate.hasPrefix("bitfield::") {
        return nil
    }
    if candidate.contains("::") {
        // Likely an enum or nested type, not a class dependency we need to surface here.
        return nil
    }
    if classMap[candidate] != nil {
        return candidate
    }
    return nil
}

func referencedClassNames(for classDef: JGodotExtensionAPIClass) -> Set<String> {
    var references = Set<String>()
    if let inherits = classDef.inherits, let normalized = normalizeClassName(from: inherits) {
        references.insert(normalized)
    }
    if let properties = classDef.properties {
        for property in properties {
            if let normalized = normalizeClassName(from: property.type) {
                references.insert(normalized)
            }
        }
    }
    if let methods = classDef.methods {
        for method in methods {
            if let ret = method.returnValue, let normalized = normalizeClassName(from: ret.type) {
                references.insert(normalized)
            }
            for argument in method.arguments ?? [] {
                if let normalized = normalizeClassName(from: argument.type) {
                    references.insert(normalized)
                }
            }
        }
    }
    if let signals = classDef.signals {
        for signal in signals {
            for argument in signal.arguments ?? [] {
                if let normalized = normalizeClassName(from: argument.type) {
                    references.insert(normalized)
                }
            }
        }
    }
    return references
}

func resolveTraitClosure(startingFrom seed: Set<String>) -> Set<String> {
    var result = seed
    var worklist = Array(seed)
    while let current = worklist.popLast() {
        guard let classDef = classMap[current] else {
            continue
        }
        for dependency in referencedClassNames(for: classDef) {
            if !result.contains(dependency) {
                result.insert(dependency)
                worklist.append(dependency)
            }
        }
    }
    return result
}

let resolvedCoreClasses = resolveTraitClosure(startingFrom: coreTraitSeedClasses)
let resolvedMediumClasses = resolveTraitClosure(startingFrom: mediumTraitSeedClasses).subtracting(resolvedCoreClasses)

for className in resolvedCoreClasses {
    traitByClassName[className] = .core
}

for className in resolvedMediumClasses {
    traitByClassName[className] = .medium
}

for (className, trait) in explicitClassTraits {
    traitByClassName[className] = trait
}

private var structTypes: Set<String> = [
    "const void*",
    "AudioFrame*",
    "Float",
    "Int",
    "float",
    "int",
    "Int32",
    "Bool",
    "bool",
]

/// - parameter type: A type name as found in `extension_api.json`.
/// - returns: True if the type is represented in Swift as simple `struct` with fields (or as a built-in Swift type), not wrapping a handle (pointer) to a native Godot object.
func isStruct(_ type: String) -> Bool { structTypes.contains(type) }

var builtinMap: [String: JGodotBuiltinClass] = [:]

for x in jsonApi.builtinClasses {
    if x.members?.count ?? 0 > 0 {
        structTypes.insert(x.name)
    }
    builtinMap[x.name] = x
}

let buildConfiguration: String = "float_64"
var builtinSizes: [String: Int] = [:]
for cs in jsonApi.builtinClassSizes {
    if cs.buildConfiguration == buildConfiguration {
        for c in cs.sizes {
            builtinSizes[c.name] = c.size
        }
    }
}
var builtinMemberOffsets: [String: [JGodotMember]] = [:]
for mo in jsonApi.builtinClassMemberOffsets {
    if mo.buildConfiguration == buildConfiguration {
        for c in mo.classes {
            builtinMemberOffsets[c.name.rawValue] = c.members
        }
    }
}

let generatedBuiltinDir: String? = combineOutput ? nil : (outputDir + "/generated-builtin/")
let generatedDir: String? = combineOutput ? nil : (outputDir + "/generated/")

if combineOutput {
    try! FileManager.default.createDirectory(atPath: outputDir + "/generated/", withIntermediateDirectories: true)
} else if let generatedBuiltinDir, let generatedDir {
    try! FileManager.default.createDirectory(atPath: generatedBuiltinDir, withIntermediateDirectories: true)
    try! FileManager.default.createDirectory(atPath: generatedDir, withIntermediateDirectories: true)
}

//#if os(Windows)
//// Because we generate too many symbols for Windows to be able to compile the library
//// we eliminate some rare classes from the build.   This is a temporary hack to unblock
//// people while I split SwiftGodot into smaller chunks.
//skipList.insert("RenderingServer")
//skipList.insert("WebXRInterface")
//skipList.insert("OpenXRInterface")
//#endif

struct Generator {
    func run() async throws {
        let coreDefPrinter = await PrinterFactory.shared.initPrinter("core-defs", withPreamble: true)
        generateUnsafePointerHelpers(coreDefPrinter)
        generateEnums(coreDefPrinter, cdef: nil, values: jsonApi.globalEnums, prefix: "")
        await generateBuiltinClasses(values: jsonApi.builtinClasses, outputDir: generatedBuiltinDir)
        await generateUtility(values: jsonApi.utilityFunctions, outputDir: generatedBuiltinDir)
        await generateClasses(values: jsonApi.classes, outputDir: generatedDir)

        generateVariantGodotInterface(coreDefPrinter)
        generateCtorPointers(coreDefPrinter)
        generateNativeStructures(coreDefPrinter, values: jsonApi.nativeStructures)

        if let generatedBuiltinDir {
            coreDefPrinter.save(generatedBuiltinDir + "/core-defs.swift")
        }

        if combineOutput {
            await PrinterFactory.shared.saveMultiplexed(outputDir)
        }
    }
}

let semaphore = DispatchSemaphore(value: 0)
let _ = Task {
    let generator = Generator()
    try! await generator.run()
    semaphore.signal()
}
semaphore.wait()

//print ("Done")
