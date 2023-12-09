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

@propertyWrapper
public struct BindNode<Value: Node> {
    public static subscript<T: Node>(
          _enclosingInstance instance: T,
          wrapped wrappedKeyPath: ReferenceWritableKeyPath<T, Value>,
          storage storageKeyPath: ReferenceWritableKeyPath<T, Self>
    ) -> Value {
        get {
            if #available(macOS 13.3, iOS 16.4, tvOS 16.4, *){
                let name: String
                let fullName = wrappedKeyPath.debugDescription
                if let namePos = fullName.lastIndex(of: ".") {
                    name = String (fullName [fullName.index(namePos, offsetBy: 1)...])
                } else {
                    name = fullName
                }
                let nodePath = NodePath(from: name)
                
                return instance.getNode(path: nodePath) as! Value
            } else {
                fatalError ("BindNode is not supported with current swift, or older Mac")
            }
        }
        set {
            fatalError()
        }
    }
    
    public init () {}
    @available(*, unavailable, message: "This property wrapper can only be applied to classes")
    public var wrappedValue: Value {
        get {
            fatalError()
        }
        set {
            fatalError()
        }
    }
}

