/// A node that Godot creates before the main scene.
///
/// Use `init(name:type:)` from SwiftGodot to select a Node subclass.
public struct Autoload {
    public let name: String
    public let nodeType: Object.Type

    @_spi(SwiftGodotRuntimePrivate)
    public init(name: String, nodeType: Object.Type) {
        self.name = name
        self.nodeType = nodeType
    }
}

extension [Autoload] {
    /// Adds autoload types to the registration list without duplicate types.
    public func typesForRegistration(adding types: [Object.Type]) -> [Object.Type] {
        var seen = Set<ObjectIdentifier>()
        return (types + map(\.nodeType)).filter { seen.insert(ObjectIdentifier($0)).inserted }
    }
}
