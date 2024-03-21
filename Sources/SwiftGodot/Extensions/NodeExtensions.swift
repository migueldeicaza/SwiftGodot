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
///         @BindNode var GameOverLabel: Label
///     }
///
///
/// The above is equivalent to calling
///
///     getNode(path: NodeName("GameOverLabel")) as! Label

/// Use the BindNode property wrapper in any subclass of Node to retrieve the node from the
/// current container that matches the name of the property.
///
/// For example:
///
///     class MyElements: CanvasLayer {
///         @BindNode var GameOverLabel: Label
///         @BindNode var gameOverLabel: Label
///
///         @BindNode(nodeName: "GameOverLabel") var customLabel: Label
///     }
///
/// The above is equivalent to calling
///
///     getNode(path: NodeName("GameOverLabel")) as! Label

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

                    // Check lower/upper cased first character variants to bridge the casing gap with
                    // swift variables and GD scene names.
                    let firstCharacterCaseVariantNames = makeVariantNames(from: cleanedDebugName)
                    if instance.hasNode(path: NodePath(from: firstCharacterCaseVariantNames.camel)) {
                        return firstCharacterCaseVariantNames.camel
                    } else {
                        return firstCharacterCaseVariantNames.pascal
                    }
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

    private static func makeVariantNames(from name: String) -> (camel: String, pascal: String) {
        let camel = name.prefix(1).lowercased() + name.dropFirst()
        let pascal = name.prefix(1).uppercased() + name.dropFirst()
        return (camel, pascal)
    }

    var nodeName: String?
    public init(nodeName: String? = nil) {
        self.nodeName = nodeName
    }

    @available(*, unavailable, message: "This property wrapper can only be applied to classes")
    public var wrappedValue: Value? {
        get { fatalError() }
        set { fatalError() }
    }
}
