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
// for handle -> Swift type using `lookupNativeObject` rather than creating
// a plain wrapper directly from the handle
var hasSubclasses = Set<String>()

for x in jsonApi.classes {
    classMap[x.name] = x
    if let parentClass = x.inherits {
        hasSubclasses.insert(parentClass)
    }
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
