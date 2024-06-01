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
/// 
/// Notice that nodes wrapped with @BindNode will crash at runtime if you do not have a 
/// node in your scene that matches that name.    If your are dealing with dynamic content
/// or you are developing and things change often, you might use the alternative ``SceneTree``
/// which allow you to use a nullable value, so you can test at runtime if the node
/// exists or not.
@propertyWrapper
public struct BindNode<Value: Node> {
    public static subscript<T: Node>(
          _enclosingInstance instance: T,
          wrapped wrappedKeyPath: ReferenceWritableKeyPath<T, Value>,
          storage storageKeyPath: ReferenceWritableKeyPath<T, Self>
    ) -> Value {
        get {
            if #available(macOS 13.3, iOS 16.4, tvOS 16.4, *) {
				if let node = instance[keyPath: storageKeyPath].cachedNode {
					return node as! Value
				}

				if !instance[keyPath: storageKeyPath].path.isEmpty {
					let nodePath = NodePath(from: instance[keyPath: storageKeyPath].path)
					instance[keyPath: storageKeyPath].cachedNode = instance.getNode(path: nodePath)
					return instance[keyPath: storageKeyPath].cachedNode as! Value
				}

                let name: String
                let fullName = wrappedKeyPath.debugDescription
                if let namePos = fullName.lastIndex(of: ".") {
                    name = String (fullName [fullName.index(namePos, offsetBy: 1)...])
                } else {
                    name = fullName
                }
                let nodePath = NodePath(from: name)
                
				instance[keyPath: storageKeyPath].cachedNode = instance.getNode(path: nodePath)
                return instance[keyPath: storageKeyPath].cachedNode as! Value
            } else {
                fatalError ("BindNode is not supported with current swift, or older Mac")
            }
        }
        set {
            fatalError()
        }
    }
    
    /// - Parameter path: An optional path to the node within the tree, if not provided, the name of the property is used.
    public init (withPath path: String = "") { self.path = path }
    @available(*, unavailable, message: "This property wrapper can only be applied to classes")
    public var wrappedValue: Value {
        get {
            fatalError()
        }
        set {
            fatalError()
        }
    }
	private var cachedNode: Node?
	private var path: String
}

