//
//  ExtensionInterface.swift: Extension interface for SwiftGodot
//

internal import GDExtension

/// The pointer to the Godot Extension Interface
var extensionInterface: ExtensionInterface!

///
/// This method is used to configure the extension interface for SwiftGodot to
/// operate.   It is only used when you use SwiftGodot embedded into an
/// application - as opposed to using SwiftGodot purely as an extension
///
public func setExtensionInterface(_ interface: ExtensionInterface) {
    extensionInterface = interface
    loadGodotInterface(unsafeBitCast(interface.getProcAddr(), to: GDExtensionInterfaceGetProcAddress.self))
}

/// Opaque version of `setExtensionInterface` which can be called from another module without importing `GDExtension`.
public func setExtensionInterfaceOpaque(library libraryPtr: UnsafeMutableRawPointer, getProcAddrFun godotGetProcAddr: Any) {
    let interface = LibGodotExtensionInterface(library: libraryPtr, getProcAddrFun: godotGetProcAddr as! GDExtensionInterfaceGetProcAddress)
    setExtensionInterface(interface)
}

public protocol ExtensionInterface {

    func variantShouldDeinit(content: UnsafeRawPointer) -> Bool

    func objectShouldDeinit(handle: UnsafeRawPointer) -> Bool

    func objectInited(object: Wrapped)

    func objectDeinited(object: Wrapped)

    func getLibrary() -> UnsafeMutableRawPointer

    func getProcAddr() -> OpaquePointer

}

class LibGodotExtensionInterface: ExtensionInterface {

    /// If your application is crashing due to the Variant leak fixes, please
    /// enable this flag, and provide me with a test case, so I can find that
    /// pesky scenario.
    public let experimentalDisableVariantUnref = false

    private let library: GDExtensionClassLibraryPtr
    private let getProcAddrFun: GDExtensionInterfaceGetProcAddress

    public init(library: GDExtensionClassLibraryPtr, getProcAddrFun: GDExtensionInterfaceGetProcAddress) {
        self.library = library
        self.getProcAddrFun = getProcAddrFun
    }

    public func variantShouldDeinit(content: UnsafeRawPointer) -> Bool {
        return !experimentalDisableVariantUnref
    }

    public func objectShouldDeinit(handle: UnsafeRawPointer) -> Bool {
        return true
    }

    public func objectInited(object: Wrapped) {}

    public func objectDeinited(object: Wrapped) {}

    public func getLibrary() -> UnsafeMutableRawPointer {
        return UnsafeMutableRawPointer(mutating: library)
    }

    public func getProcAddr() -> OpaquePointer {
        return unsafeBitCast(getProcAddrFun, to: OpaquePointer.self)
    }

}
