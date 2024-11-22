@_implementationOnly import GDExtension

extension Object {

    /// Make a raw call to a method bind.
    /// All input arguments must be marshaled into `Variant`s.
    /// The result is a `Variant` that must be unmarshaled into the expected type.
    @discardableResult /* discardable per discardableList: Object, emit_signal */
    final func rawCall(_ p_method_bind: GDExtensionMethodBindPtr, arguments: [Variant]) -> Variant? {
        var _result: Variant.ContentType = Variant.zero
        // A temporary allocation containing pointers to `Variant.ContentType` of marshaled arguments
        withUnsafeTemporaryAllocation(of: UnsafeRawPointer?.self, capacity: arguments.count) { pArgsBuffer in
            defer { pArgsBuffer.deinitialize() }
            guard let pArgs = pArgsBuffer.baseAddress else {
                fatalError("pArgsBuffer.baseAddress is nil")
            }

            // A temporary allocation containing `Variant.ContentType` of marshaled arguments
            withUnsafeTemporaryAllocation(of: Variant.ContentType.self, capacity: arguments.count) { contentsBuffer in
                defer { contentsBuffer.deinitialize() }
                guard let contentsPtr = contentsBuffer.baseAddress else {
                    fatalError("contentsBuffer.baseAddress is nil")
                }

                for i in 0..<arguments.count {
                    // Copy `content`s of the variadic `Variant`s into `contentBuffer`
                    contentsBuffer.initializeElement(at: i, to: arguments[i].content)
                    // Initialize `pArgs` elements following mandatory arguments to point at respective contents of `contentsBuffer`
                    pArgsBuffer.initializeElement(at: i, to: contentsPtr + i)
                }

                gi.object_method_bind_call(p_method_bind, UnsafeMutableRawPointer(mutating: handle), pArgs, Int64(arguments.count), &_result, nil)
            }
        }

        return Variant(takingOver: _result)
    }

    /// Non-variadic variation on the emitSignal method.
    /// Used by GenericSignal.
    public final func emitSignalWithArguments(_ arguments: [Variant]) -> Variant? {
        return rawCall(Object.method_emit_signal, arguments: arguments)
    }

}
