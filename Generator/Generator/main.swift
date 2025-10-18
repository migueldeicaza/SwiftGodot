import ExtensionApi
//  main.swift
//  SwiftGodot/Generator
//
//  Created by Miguel de Icaza on 5/20/20.
//  Copyright © 2020-2023 Miguel de Icaza. MIT Licensed
//
import Foundation

var args = CommandLine.arguments
var positionalArgs: [String] = []
var combineOutput = false

var index = 1
while index < args.count {
    let argument = args[index]
    switch argument {
    case "--combined":
        combineOutput = true
    case "--class-filter":
        let path = args[index + 1]
        let contents = try! String(contentsOfFile: path, encoding: .utf8)
        classWhitelist = Set(normalizedSymbolEntries(from: contents))
        classFilterProvided = true
        index += 1
    case "--available-class-filter":
        let path = args[index + 1]
        let contents = try! String(contentsOfFile: path, encoding: .utf8)
        availableClassNames = Set(normalizedSymbolEntries(from: contents))
        availableClassFilterProvided = true
        index += 1
    case "--builtin-filter":
        let path = args[index + 1]
        let contents = try! String(contentsOfFile: path, encoding: .utf8)
        builtinWhitelist = Set(normalizedSymbolEntries(from: contents))
        builtinFilterProvided = true
        index += 1
    case "--preamble-file":
        let path = args[index + 1]
        var contents = try! String(contentsOfFile: path, encoding: .utf8)
        if !contents.isEmpty && !contents.hasSuffix("\n") {
            contents.append("\n")
        }
        additionalPreamble = contents
        index += 1
    default:
        positionalArgs.append(argument)
    }
    index += 1
}

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

let jsonFile = positionalArgs.count > 0 ? positionalArgs[0] : defaultExtensionApiJsonUrl.path
var generatorOutput = positionalArgs.count > 1 ? positionalArgs[1] : defaultGeneratorOutputlUrl.path
var docRoot = positionalArgs.count > 2 ? positionalArgs[2] : defaultDocRootUrl.path
let outputDir = positionalArgs.count > 1 ? positionalArgs[1] : generatorOutput

/// Special case for Xogot to avoid caching godot interface pointers
let noStaticCaches = false

if positionalArgs.count < 1 {
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

if classFilterProvided {
    var stack: [String] = Array(classWhitelist)
    while let current = stack.popLast() {
        guard let inherits = classMap[current]?.inherits, !inherits.isEmpty else {
            continue
        }
        if !classWhitelist.contains(inherits) {
            classWhitelist.insert(inherits)
            stack.append(inherits)
        }
    }
}

if availableClassFilterProvided {
    var stack: [String] = Array(availableClassNames)
    while let current = stack.popLast() {
        guard let inherits = classMap[current]?.inherits, !inherits.isEmpty else {
            continue
        }
        if !availableClassNames.contains(inherits) {
            availableClassNames.insert(inherits)
            stack.append(inherits)
        }
    }
} else if classFilterProvided {
    availableClassNames = classWhitelist
} else {
    availableClassNames = Set(classMap.keys)
    availableClassFilterProvided = true
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
