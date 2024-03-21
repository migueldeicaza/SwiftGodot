//
//  Node.swift
//  
//
//  Created by Miguel de Icaza on 4/12/23.
//

/// Use the BindNode property wrapper in any subclass of Node to retrieve the node from the
/// current container that matches the name of the property.
///
/// For example:
///
///     class MyElements: CanvasLayer {
///         @BindNode var MovementComponent: Node?
///         @BindNode var movementComponent: Node?
///         @BindNode("MovementComponent") var customLabel: Node?
///     }
///
/// The above is equivalent to calling
///
///     getNode(path: NodeName("MovementComponent")) as? Node

@propertyWrapper
public struct BindNode<Value: Node> {
    public static subscript<T: Node>(
          _enclosingInstance instance: T,
          wrapped wrappedKeyPath: ReferenceWritableKeyPath<T, Value?>,
          storage storageKeyPath: ReferenceWritableKeyPath<T, Self>
    ) -> Value? {
        get {
            if #available(macOS 13.3, iOS 16.4, tvOS 16.4, *){
                let discoveredName: String = {
                    if let nodeName = instance[keyPath: storageKeyPath].nodeName {
                        return nodeName
                    }

                    // Check original variable name
                    let cleanedDebugName = makeCleanName(from: wrappedKeyPath.debugDescription)
                    guard !instance.hasNode(path: NodePath(from: cleanedDebugName)) else {
                        return cleanedDebugName
                    }

                    // Check upper cased first character variant to bridge the casing gap with swift
                    // variables and GD scene names.
                    let pascalVariantName = makePascalCaseName(from: cleanedDebugName)
                    if instance.hasNode(path: NodePath(from: pascalVariantName)) {
                        return pascalVariantName
                    }

                    // This won't be found, but it triggers a warning in godot pointing to the original
                    // inferred name used in the binding.
                    return cleanedDebugName
                }()

                return instance.getNode(path: NodePath(from: discoveredName)) as? Value
            } else {
                fatalError ("BindNode is not supported with current swift, or older Mac")
            }
        }
        set {
            fatalError()
        }
    }

    private static func makeCleanName(from debugDescriptionName: String) -> String {
        if let namePos = debugDescriptionName.lastIndex(of: ".") {
            return String (debugDescriptionName [debugDescriptionName.index(namePos, offsetBy: 1)...])
        } else {
            return debugDescriptionName
        }
    }

    private static func makePascalCaseName(from name: String) -> String {
        return name.prefix(1).uppercased() + name.dropFirst()
    }

    var nodeName: String?
    public init(_ nodeName: String? = nil) {
        self.nodeName = nodeName
    }

    @available(*, unavailable, message: "This property wrapper can only be applied to classes")
    public var wrappedValue: Value? {
        get { fatalError() }
        set { fatalError() }
    }
}
