//
//  File.swift
//  
//
//  Created by Miguel de Icaza on 4/8/23.
//

import GDExtension

public enum ArrayError {
    case outOfRange
}

@available(*, deprecated, renamed: "VariantArray", message: "GArray was renamed to `VariantArray` to better communicate its semantics")
public typealias GArray = VariantArray

extension VariantArray: CustomDebugStringConvertible {
    /// Provides debug description of this instance:
    /// ```
    /// let array = VariantArray()
    /// array.append(1)
    /// array.append(2)
    /// print(array) // prints [1, 2]
    /// ```
    public var debugDescription: String {
        "[\(map { $0?.description ?? "nil"}.joined(separator: ", "))]"
    }
    
    /// Return the typing information suitable for Swift metatype magic.
    @usableFromInline
    var typing: ContainerTypingParameter {
        let rawValue = getTypedBuiltin()
        guard let gtype = Variant.GType(rawValue: rawValue) else {
            fatalError("Unknown variant type rawValue: \(rawValue)")
        }
        
        switch gtype {
        case .object:
            let className = getTypedClassName().asciiDescription
            guard let metatype = typeOfClass(named: className) else {
                GD.printErr("Unknown class name: \(className).")
                return .builtin(.nil)
            }
            
            return .object(metatype)
        default:
            return .builtin(gtype)
        }
    }
    
    /// Initializes an empty, but typed `VariantArray`. For example: `VariantArray(Node?.self)`, `VariantArray(Int.self)`
    /// - Parameter type: `T` the type of the elements in the VariantArray, must conform to `_GodotContainerTypingParameter`.
    public convenience init<T: _GodotContainerTypingParameter>(_ type: T.Type = T.self) {
        self.init(
            base: VariantArray(),
            type: Int32(T._variantType.rawValue),
            className: T._className,
            script: nil
        )
    }
    
    /// Initializes an empty, but typed `VariantArray`. For example: `VariantArray(Node.self)`
    /// - Parameter type: `T` the type of the elements in the VariantArray, must conform to `_GodotNullableBridgeable`.
    ///
    /// ### Note
    /// It's the same as `init(T?.self)`.
    public convenience init<T: _GodotNullableBridgeable>(_ type: T.Type = T.self) {
        self.init(T?.self)
    }
    
    /// Allows subscription array as in `array[0]`.    
    public subscript(index: Int) -> Variant? {
        get {
            guard let ret = gi.array_operator_index(&content, Int64 (index)) else {
                return nil
            }
            let ptr = ret.assumingMemoryBound(to: VariantContent.self)
            
            // We are making a copy of the variant managed by the array. Array is managing its copy, we are managing ours
            return Variant(copying: ptr.pointee)
        }
        set {
            setVariant(newValue, at: index)
        }
    }

    /// Reads the ``Variant?`` at `index` and passes it to `body`.
    public func withVariant<R>(at index: Int, _ body: (Variant?) -> R) -> R {
        guard let ret = gi.array_operator_index(&content, Int64 (index)) else {
            return body(nil)
        }

        let ptr = ret.assumingMemoryBound(to: VariantContent.self)
        // We make a copy of the variant managed by the array; the array keeps managing its own.
        return body(Variant(copying: ptr.pointee))
    }

    /// Set ``Variant?`` at `index`.
    public func setVariant(_ variantOrNil: Variant?, at index: Int) {
        guard let ret = gi.array_operator_index(&content, Int64 (index)) else {
            return
        }

        let ptr = ret.assumingMemoryBound(to: VariantContent.self)

        // Owned content describing the new value.
        let newContent = variantOrNil.makeContent()

        guard ptr.pointee != newContent else {
            // Already holds the same value; release the content we just built.
            var c = newContent
            if !c.isZero { gi.variant_destroy(&c) }
            return
        }

        // Destroy the element the array currently owns at `index`.
        gi.variant_destroy(ptr)

        // Transfer ownership of the freshly built content to the array.
        ptr.pointee = newContent
    }
}
