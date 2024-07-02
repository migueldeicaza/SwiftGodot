//
//  File.swift
//  
//
//  Created by Miguel de Icaza on 4/7/23.
//

extension PackedStringArray {
    /// Initializes a ``PackedStringArray`` from an array of strings
    public convenience init (_ values: [String]) {
        self.init ()
        for x in values {
            append(value: x)
        }
    }
    
    /// Accesses a specific element in the ``PackedStringArray``
    public subscript (index: Int) -> String {
        get {
            return GString.stringFromGStringPtr(ptr: gi.packed_string_array_operator_index_const (&content, Int64 (index))) ?? ""
        }
        set {
            set (index: Int64 (index), value: newValue)
        }
    }
    
    @available(*, deprecated, renamed: "append(_:)", message: "This method signature has been deprecated in favor of append(_:)")
    public func append(value: String) {
        append(value)
    }
}

extension PackedByteArray {
    /// Accesses a specific element in the ``PackedByteArray``
    public subscript (index: Int) -> UInt8 {
        get {
            let ptr = gi.packed_byte_array_operator_index_const (&content, Int64 (index))
            return ptr!.pointee
        }
        set {
            set (index: Int64 (index), value: Int64 (newValue))
        }
    }
    
    /// Provides a mechanism to access the underlying data for the packed byte array
    ///
    /// - Parameter method: a callback that is invoked with a pointer to the underlying data, and
    /// the number of bytes in that block of data.   The callback is allowed to return nil it if fails to
    /// do anything with the data or if the array is empty.
    ///
    /// You could implement a method to access your data like this:
    /// ```
    /// let data: Data? = withUnsafeAccessToData { ptr, count in Data (bytes: ptr, count: count) }
    /// ```
    public func withUnsafeAccessToData<T> (_ method: (_ pointer: UnsafeRawPointer, _ count: Int)->T?) -> T? {
        if let ptr = gi.packed_byte_array_operator_index(&content, 0) {
            return method (ptr, Int (size ()))
        }
        return nil
    }
    
    /// Returns the underlying storage as an array of bytes
    public func asBytes () -> [UInt8] {
        let count = Int (size())
        if let ptr = gi.packed_byte_array_operator_index(&content, 0) {
            return ptr.withMemoryRebound(to: UInt8.self, capacity: count) { typed in
                var ret: [UInt8] = Array.init(repeating: 0, count: count)
                for idx in 0..<count {
                    ret [idx] = typed [idx]
                }
                return ret
            }
        }
        return []
    }
    /// Provides a mechanism to access the underlying data for the packed byte array for mutation
    ///
    /// - Parameter method: a callback that is invoked with a pointer to a copy of the underlying data, and
    /// the number of bytes in that block of data.   The callback is allowed to return nil it if fails to
    /// do anything with the data.
    ///
    public func withUnsafeMutableAccessToData<T> (_ method: (_ pointer: UnsafeMutableRawPointer, _ count: Int)->T?) -> T? {
        if let ptr = gi.packed_byte_array_operator_index(&content, 0) {
            return method (ptr, Int (size ()))
        }
        return nil
    }
    
    /// Read-only access the underlying data for this packed byte array
    ///
    /// - Parameter method: a callback that is invoked with a non-mutable pointer to the underlying data, and
    /// the number of bytes in that block of data. The callback is allowed to return nil if it fails to
    /// do anything with the data.
    public func withUnsafeConstAccessToData<T> (_ method: (_ pointer: UnsafeRawPointer, _ count: Int) -> T?) -> T? {
        if let ptr = gi.packed_byte_array_operator_index_const(&content, 0) {
            return method(ptr, Int(size()))
        }
        return nil
    }

    /// Initializes a PackedByteArray from an array of UInt8 values.
    public convenience init (_ data: [UInt8]) {
        self.init ()
        _ = resize(newSize: Int64(data.count))
        if let ptr = gi.packed_byte_array_operator_index(&content, 0) {
            ptr.withMemoryRebound(to: UInt8.self, capacity: data.count) { typed in
                var idx = 0
                for value in data {
                    typed [idx] = value
                    idx += 1
                }
            }
        }
    }
    
    /// Appends an element at the end of the array
    public func append(_ value: UInt8) {
        append(value: Int64(value))
    }
}

extension PackedColorArray {
    /// Accesses a specific element in the ``PackedColorArray``
    public subscript (index: Int) -> Color {
        get {
            let ptr = gi.packed_color_array_operator_index_const (&content, Int64 (index))
            return ptr!.assumingMemoryBound(to: Color.self).pointee
        }
        set {
            set (index: Int64 (index), value: newValue)
        }
    }
    @available(*, deprecated, renamed: "append(_:)", message: "This method signature has been deprecated in favor of append(_:)")
    public func append(value: Color) {
        append(value)
    }
}

extension PackedFloat32Array {
    /// Accesses a specific element in the ``PackedFloat32Array``
    public subscript (index: Int) -> Float {
        get {
            let ptr = gi.packed_float32_array_operator_index_const (&content, Int64 (index))
            return ptr!.pointee
        }
        set {
            set (index: Int64 (index), value: Double (newValue))
        }
    }
    
    /// Initializes a PackedByteArray from an array of Float values.
    public convenience init (_ data: [Float]) {
        self.init ()
        _ = resize(newSize: Int64(data.count))
        if let ptr = gi.packed_float32_array_operator_index(&content, 0) {
            ptr.withMemoryRebound(to: Float.self, capacity: data.count) { typed in
                var idx = 0
                for value in data {
                    typed [idx] = value
                    idx += 1
                }
            }
        }
    }
    
    /// Appends an element at the end of the array
    public func append(_ value: Float) {
        append (value: Double (value))
    }
}

extension PackedFloat64Array {
    /// Accesses a specific element in the ``PackedFloat64Array``
    public subscript (index: Int) -> Double {
        get {
            let ptr = gi.packed_float64_array_operator_index_const (&content, Int64(index))
            return ptr!.pointee
        }
        set {
            set (index: Int64 (index), value: newValue)
        }
    }
    
    /// Initializes a PackedByteArray from an array of Double values.
    public convenience init (_ data: [Double]) {
        self.init ()
        _ = resize(newSize: Int64(data.count))
        if let ptr = gi.packed_float64_array_operator_index(&content, 0) {
            ptr.withMemoryRebound(to: Double.self, capacity: data.count) { typed in
                var idx = 0
                for value in data {
                    typed [idx] = value
                    idx += 1
                }
            }
        }
    }
    
    @available(*, deprecated, renamed: "append(_:)", message: "This method signature has been deprecated in favor of append(_:)")
    public func append(value: Double) {
        append(value)
    }
}

extension PackedInt32Array {
    /// Accesses a specific element in the ``PackedInt32Array``
    public subscript (index: Int) -> Int32 {
        get {
            let ptr = gi.packed_int32_array_operator_index_const (&content, Int64(index))
            return ptr!.pointee
        }
        set {
            set (index: Int64 (index), value: Int64(newValue))
        }
    }
    
    /// Initializes a PackedByteArray from an array of Int32 values values.
    public convenience init (_ data: [Int32]) {
        self.init ()
        _ = resize(newSize: Int64(data.count))
        if let ptr = gi.packed_int32_array_operator_index(&content, 0) {
            ptr.withMemoryRebound(to: Int32.self, capacity: data.count) { typed in
                var idx = 0
                for value in data {
                    typed [idx] = value
                    idx += 1
                }
            }
        }
    }

    /// Appends an element at the end of the array
    public func append(_ value: Int32) {
        append (value: Int64 (value))
    }
}

extension PackedInt64Array {
    /// Accesses a specific element in the ``PackedInt64Array``
    public subscript (index: Int) -> Int64 {
        get {
            let ptr = gi.packed_int64_array_operator_index_const(&content, Int64(index))
            return ptr!.pointee
        }
        set {
            set (index: Int64 (index), value: newValue)
        }
    }
    
    /// Initializes a PackedByteArray from an array of Int32 values values.
    public convenience init (_ data: [Int64]) {
        self.init ()
        _ = resize(newSize: Int64(data.count))
        if let ptr = gi.packed_int64_array_operator_index(&content, 0) {
            ptr.withMemoryRebound(to: Int64.self, capacity: data.count) { typed in
                var idx = 0
                for value in data {
                    typed [idx] = value
                    idx += 1
                }
            }
        }
    }

    @available(*, deprecated, renamed: "append(_:)", message: "This method signature has been deprecated in favor of append(_:)")
    public func append(value: Int64) {
        append(value)
    }
}

extension PackedVector2Array {
    /// Accesses a specific element in the ``PackedVector2Array``
    public subscript (index: Int) -> Vector2 {
        get {
            let ptr = gi.packed_vector2_array_operator_index_const (&content, Int64(index))
            return ptr!.assumingMemoryBound(to: Vector2.self).pointee
        }
        set {
            set (index: Int64 (index), value: newValue)
        }
    }
    @available(*, deprecated, renamed: "append(_:)", message: "This method signature has been deprecated in favor of append(_:)")
    public func append(value: Vector2) {
        append(value)
    }
}

extension PackedVector3Array {
    /// Accesses a specific element in the ``PackedVector3Array``
    public subscript (index: Int) -> Vector3 {
        get {
            let ptr = gi.packed_vector3_array_operator_index_const (&content, Int64(index))
            return ptr!.assumingMemoryBound(to: Vector3.self).pointee
        }
        set {
            set (index: Int64 (index), value: newValue)
        }
    }
    @available(*, deprecated, renamed: "append(_:)", message: "This method signature has been deprecated in favor of append(_:)")
    public func append(value: Vector3) {
        append(value)
    }
}


