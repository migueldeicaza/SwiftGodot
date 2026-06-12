//
//  DeferredSplit.swift
//  Generator
//
//  Support for splitting the API into independent module dylibs without
//  degrading the public API surface.
//
//  When a class lives in a lower module (e.g. `ButtonGroup` in core) but one of
//  its members references a type that only exists in a higher module (e.g.
//  `BaseButton` in controls), we cannot surface that member in the lower module
//  because the referenced type isn't visible there. Rather than degrade the
//  member to a weaker ancestor type, we *omit* it from the lower module and
//  re-emit it verbatim as an `extension` in the higher module where every
//  referenced type first becomes available. The Godot API surface is preserved
//  exactly, and types stay in their own dylibs.
//

import Foundation
import ExtensionApi

/// Extracts the Godot *class* name a type string refers to, or `nil` if the type
/// is a builtin/primitive/global-enum (always available, never a split concern).
/// Handles `typedarray::T`, `enum::Class.Case`, `bitfield::Class.Flags`, nested
/// `Class.Inner`, and pointer suffixes.
func referencedClassName(fromGodotType rawType: String) -> String? {
    var s = rawType
    if s.hasPrefix("typedarray::") { s = String(s.dropFirst("typedarray::".count)) }
    if s.hasPrefix("enum::") { s = String(s.dropFirst("enum::".count)) }
    else if s.hasPrefix("bitfield::") { s = String(s.dropFirst("bitfield::".count)) }
    // Drop pointer markers and whitespace ("Object*", "const uint8_t*").
    s = s.replacingOccurrences(of: "*", with: "").trimmingCharacters(in: .whitespaces)
    // A nested member like `Camera3D.ProjectionType` references `Camera3D`.
    if let dot = s.firstIndex(of: ".") {
        s = String(s[..<dot])
    }
    return classMap[s] != nil ? s : nil
}

/// All Godot class names referenced by a method's signature (return + arguments).
func referencedClassNames(of method: JGodotClassMethod) -> Set<String> {
    var result = Set<String>()
    if let rt = method.returnValue?.type, let c = referencedClassName(fromGodotType: rt) {
        result.insert(c)
    }
    for arg in method.arguments ?? [] {
        if let c = referencedClassName(fromGodotType: arg.type) {
            result.insert(c)
        }
    }
    return result
}

/// A referenced class is resolvable in the current module if it's available, or
/// if it has an explicit `allowedClassFallbacks` entry (legacy intentional
/// degradation, e.g. the runtime surfacing `Node` as `Object`). Only classes
/// that are neither available nor explicitly degraded trigger skip-and-defer.
func classResolvableHere(_ className: String) -> Bool {
    availableClassNames.contains(className) || allowedClassFallbacks[className] != nil
}

/// True when every referenced class is resolvable in the module being generated.
func typesAvailable(_ classNames: Set<String>) -> Bool {
    guard availableClassFilterProvided else { return true }
    return classNames.allSatisfy { classResolvableHere($0) }
}

/// True when at least one referenced class is *introduced* by the module being
/// generated (i.e. generated here, not merely inherited from a dependency).
/// This is what makes a member "first become emittable" exactly at this module,
/// so it is emitted in precisely one module and never duplicated.
func typesIntroducedLocally(_ classNames: Set<String>) -> Bool {
    classNames.contains { classesToGenerate.contains($0) }
}

/// A method is emittable inline in the current (home) module iff all the classes
/// it references are available here. Non-class references never block it.
func methodIsEmittableHere(_ method: JGodotClassMethod) -> Bool {
    typesAvailable(referencedClassNames(of: method))
}

/// Transitive set of modules visible from `module` (itself + all dependencies).
private var visibleModulesCache: [String: Set<String>] = [:]
func visibleModules(_ module: String) -> Set<String> {
    if let cached = visibleModulesCache[module] { return cached }
    var seen = Set<String>()
    var stack = [module]
    while let m = stack.popLast() {
        guard seen.insert(m).inserted else { continue }
        stack.append(contentsOf: moduleDeps[m] ?? [])
    }
    visibleModulesCache[module] = seen
    return seen
}

/// When a member is omitted from this module because a referenced type isn't
/// available, verify that *some* module in the graph can host it. A member whose
/// referenced types span two incomparable modules ("cross-sibling") is hostable
/// nowhere and would be silently dropped — fail the build loudly instead.
func ensureHostableSomewhere(className: String, memberName: String, refs: Set<String>) {
    guard moduleGraphProvided, let homeClass = classHome[className] else { return }
    var required: Set<String> = [homeClass]
    for r in refs {
        if let h = classHome[r] { required.insert(h) }
    }
    for module in moduleDeps.keys where required.isSubset(of: visibleModules(module)) {
        return // hostable here
    }
    fatalError("""
    SwiftGodot Generator: cross-sibling member '\(className).\(memberName)' references \
    \(refs.sorted()) whose home modules \(required.sorted()) are not all visible in any \
    single module, so it can be hosted nowhere. Add a dependency edge so one module sees \
    all of them (e.g. make the home module depend on the others), or host it in the umbrella.
    """)
}

/// All Godot class names referenced by a signal's argument types.
func referencedClassNames(of signal: JGodotSignal) -> Set<String> {
    var result = Set<String>()
    for arg in signal.arguments ?? [] {
        if let c = referencedClassName(fromGodotType: arg.type) {
            result.insert(c)
        }
    }
    return result
}

func signalIsEmittableHere(_ signal: JGodotSignal) -> Bool {
    typesAvailable(referencedClassNames(of: signal))
}

/// Names of the getter/setter methods that back this class's properties, so we
/// don't surface them as standalone methods.
private func propertyBackedMethodNames(_ cdef: JGodotExtensionAPIClass) -> Set<String> {
    var backed = Set<String>()
    for prop in cdef.properties ?? [] {
        if !prop.getter.isEmpty { backed.insert(prop.getter) }
        if let setter = prop.setter, !setter.isEmpty { backed.insert(setter) }
    }
    return backed
}

/// Emits, into a single per-module file, `extension` members for classes that
/// live in *lower* modules but whose members first become surfaceable here
/// because this module introduces the referenced type(s).
///
/// The file is always written (even if empty) so it can be a declared, stable
/// build-plan output for the module's target.
func generateDeferredExtensions(outputDir: String?) async {
    // Only meaningful for split targets that restrict their class set.
    guard classFilterProvided, availableClassFilterProvided else {
        if let outputDir {
            let p = await PrinterFactory.shared.initPrinter("_DeferredExtensions", withPreamble: true)
            p ("// No deferred extensions for this target.")
            p.save(outputDir + "_DeferredExtensions.swift")
        }
        return
    }

    let p = await PrinterFactory.shared.initPrinter("_DeferredExtensions", withPreamble: true)
    p ("// Members of lower-module classes whose referenced types first become")
    p ("// available in this module. Surfaced as extensions to preserve the exact")
    p ("// Godot API without moving types across modules.")
    p ("")

    // Classes visible here but generated in a dependency module.
    let lowerClasses = availableClassNames.subtracting(classesToGenerate).sorted()

    for className in lowerClasses {
        guard let cdef = classMap[className] else { continue }
        let backed = propertyBackedMethodNames(cdef)
        let asSingleton = jsonApi.singletons.contains { $0.name == cdef.name } && cdef.name != "EditorInterface"

        let deferredMethods = (cdef.methods ?? []).filter { method in
            if method.isVirtual { return false }            // can't override via extension
            if backed.contains(method.name) { return false } // surfaced as a property instead
            let refs = referencedClassNames(of: method)
            // Emittable now, and not already emittable in the home module.
            return typesAvailable(refs) && typesIntroducedLocally(refs)
        }

        let deferredProperties = (cdef.properties ?? []).filter { property in
            guard let refs = referencedClassNames(ofProperty: property, cdef: cdef) else { return false }
            return typesAvailable(refs) && typesIntroducedLocally(refs)
        }

        let deferredSignals = (cdef.signals ?? []).filter { signal in
            let refs = referencedClassNames(of: signal)
            return typesAvailable(refs) && typesIntroducedLocally(refs)
        }

        guard !deferredMethods.isEmpty || !deferredProperties.isEmpty || !deferredSignals.isEmpty else { continue }

        p ("extension \(className)") {
            var localReferenced = Set<String>()
            for property in deferredProperties {
                generateProperty(
                    p,
                    cdef: cdef,
                    property: property,
                    methods: cdef.methods ?? [],
                    referencedMethods: &localReferenced,
                    asSingleton: asSingleton,
                    emitBackingMethods: true
                )
            }
            for method in deferredMethods {
                performExplaniningNonCriticalErrors {
                    _ = try generateMethod(
                        p,
                        method: method,
                        className: cdef.name,
                        cdef: cdef,
                        usedMethods: backed,
                        generatedMethodKind: .classMethod,
                        asSingleton: asSingleton
                    )
                }
            }
            for signal in deferredSignals {
                emitSignal(p, cdef: cdef, signal: signal)
            }
        }
        p ("")
    }

    if let outputDir {
        p.save(outputDir + "_DeferredExtensions.swift")
    }
}
