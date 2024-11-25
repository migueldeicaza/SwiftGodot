//
//  main.swift
//  SwiftGodot/Generator
//
//  Created by Miguel de Icaza on 5/20/20.
//  Copyright © 2020-2023 Miguel de Icaza. MIT Licensed
//
import ArgumentParser
import ExtensionApi
import Foundation

var args = CommandLine.arguments

var rootUrl: URL {
    let url = URL(fileURLWithPath: #file) // SwiftGodot/Generator/Generator/main.swift
        .deletingLastPathComponent() // SwiftGodot/Generator/Generator
        .deletingLastPathComponent() // SwiftGodot/Generator
        .deletingLastPathComponent() // SwiftGodot
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

let jsonFile = args.count > 1 ? args [1] : defaultExtensionApiJsonUrl.path
let generateResettableCache = false

if args.count < 2 {
    print("""
    Usage is: generator path-to-extension-api output-directory doc-directory
    - path-to-extension-api is the full path to extension_api.json from Godot
    - output-directory is where the files will be placed
    - doc-directory is the Godot documentation resides (godot/doc)
    Running with defaults:
        path-to-extension-api = "\(jsonFile)"
    """)
}

let jsonData = try! Data(url: URL(fileURLWithPath: jsonFile))
let jsonApi = try! JSONDecoder().decode(JGodotExtensionAPI.self, from: jsonData)

func dropMatchingPrefix (_ enumName: String, _ enumKey: String) -> String {
    let snake = snakeToCamel (enumKey)
    if snake.lowercased().starts(with: enumName.lowercased()) {
        if snake.count == enumName.count {
            return snake
        }
        let ret = String (snake [snake.index (snake.startIndex, offsetBy: enumName.count)...])
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

//#if os(Windows)
//// Because we generate too many symbols for Windows to be able to compile the library
//// we eliminate some rare classes from the build.   This is a temporary hack to unblock
//// people while I split SwiftGodot into smaller chunks.
//skipList.insert("RenderingServer")
//skipList.insert("WebXRInterface")
//skipList.insert("OpenXRInterface")
//#endif

struct GeneratorCommand: AsyncParsableCommand {
    @Flag(
        help: "Generator all output to a single Swift file. Possibly useful on Windows."
    ) var singleFile = false

    @Argument(
        help: "Path to the `extension_api.json` file exported by Godot.",
        completion: .file(extensions: [".json"])
    ) var jsonFile: String = defaultExtensionApiJsonUrl.path

    @Argument(
        help: "Path to the folder in which to write generated Swift files. I will create this if it doesn't exist.",
        completion: .directory
    ) var outputDir: String = defaultGeneratorOutputlUrl.path

    mutating func run() async throws {
        let generator = Generator(command: self)
        try await generator.run()
    }
}

extension Array {
    fileprivate func makeDictionary<Key: Hashable, Value>(
        key: (Element) -> Key,
        value: (Element) -> Value
    ) -> [Key: Value] {
        var answer = [Key: Value]()
        for element in self {
            answer[key(element)] = value(element)
        }
        return answer
    }
}

extension JGodotExtensionAPI {
    func makeGlobalEnumMap() -> [String: JGodotGlobalEnumElement] {
        var answer: [String: JGodotGlobalEnumElement] = [:]

        for en in globalEnums {
            answer[en.name] = en
        }

        for bc in builtinClasses {
            guard let enums = bc.enums else { continue }
            let prefix = bc.name + "."
            for en in enums {
                answer[prefix + en.name] = en
            }
        }

        return answer
    }
}

struct Generator {
    let command: GeneratorCommand

    let builtinMemberOffsets: [String: [JGodotMember]]
    let builtinSizes: [String: Int]
    let builtinMap: [String: JGodotBuiltinClass]
    let structTypes: Set<String>

    /// All members of this set have subclasses.
    ///
    /// If a Godot handle is for a class with subclasses, I have to
    /// perform a `lookupObject` at runtime to wrap the handle, which
    /// is more expensive than creating the wrapper directly.
    let hasSubclasses: Set<String>

    /// Maps from a the class name to its definition
    let classMap: [String:JGodotExtensionAPIClass]

    let globalEnums: [String: JGodotGlobalEnumElement]

    var generatedBuiltinDir: String? { command.singleFile ? nil : (command.outputDir + "/generated-builtin/") }
    var generatedDir: String? { command.singleFile ? nil : (command.outputDir + "/generated/") }

    private static let knownStructTypes: Set<String> = [
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

    init(command: GeneratorCommand) {
        let buildConfiguration: String = "float_64"

        self.command = command

        builtinMemberOffsets = jsonApi.builtinClassMemberOffsets
            .first { $0.buildConfiguration == buildConfiguration }?
            .classes.makeDictionary(key: \.name.rawValue, value: \.members) ?? [:]

        builtinSizes = jsonApi.builtinClassSizes
            .first { $0.buildConfiguration == buildConfiguration }?
            .sizes.makeDictionary(key: \.name, value: \.size) ?? [:]

        structTypes = Self.knownStructTypes.union(
            jsonApi.builtinClasses
                .lazy
                .filter { $0.members?.count ?? 0 > 0 }
                .map(\.name)
        )

        builtinMap = jsonApi.builtinClasses.makeDictionary(key: \.name, value: \.self)

        hasSubclasses = Set(jsonApi.classes.lazy.compactMap { $0.inherits })

        classMap = jsonApi.classes.makeDictionary(key: \.name, value: \.self)

        globalEnums = jsonApi.makeGlobalEnumMap()
    }

    func makeFolders() throws {
        if command.singleFile {
            try! FileManager.default.createDirectory(atPath: command.outputDir, withIntermediateDirectories: true)
        } else if let generatedBuiltinDir, let generatedDir {
            try! FileManager.default.createDirectory(atPath: generatedBuiltinDir, withIntermediateDirectories: true)
            try! FileManager.default.createDirectory(atPath: generatedDir, withIntermediateDirectories: true)
        }
    }

    func run() async throws {
        try makeFolders()

        let coreDefPrinter = await PrinterFactory.shared.initPrinter("core-defs")
        coreDefPrinter.preamble()
        generateUnsafePointerHelpers(coreDefPrinter)

        generateEnums(coreDefPrinter, cdef: nil, values: jsonApi.globalEnums)
        await generateBuiltinClasses(values: jsonApi.builtinClasses, outputDir: generatedBuiltinDir)
        await generateUtility(values: jsonApi.utilityFunctions, outputDir: generatedBuiltinDir)
        await generateClasses (values: jsonApi.classes, outputDir: generatedDir)
        generateCtorPointers (coreDefPrinter)
        generateNativeStructures(coreDefPrinter, values: jsonApi.nativeStructures)

        if let generatedBuiltinDir {
            coreDefPrinter.save (generatedBuiltinDir + "/core-defs.swift")
        }

        if command.singleFile {
            await PrinterFactory.shared.save(command.outputDir + "/generated.swift")
        }
    }
}

let semaphore = DispatchSemaphore(value: 0)
let _ = Task {
    defer { semaphore.signal() }
    await GeneratorCommand.main()
}
semaphore.wait()

//print ("Done")
