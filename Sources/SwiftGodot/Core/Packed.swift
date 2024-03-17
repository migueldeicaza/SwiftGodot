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
            return GString.stringFromGStringPtr(ptr: gi.packed_string_array_operator_index (&content, Int64 (index))) ?? ""
        }
        set {
            set (index: Int64 (index), value: newValue)
        }
    }
}

extension PackedByteArray {
    /// Accesses a specific element in the ``PackedByteArray``
    public subscript (index: Int) -> UInt8 {
        get {
            let ptr = gi.packed_byte_array_operator_index (&content, Int64 (index))
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
    /// do anything with the data.
    ///
    /// You could implement a method to access your data like this:
    /// ```
    /// let data: Data? = withUnsafeAccessToData { ptr, count in Data (ptr, count) }
    /// ```
    public func withUnsafeAccessToData<T> (_ method: (_ pointer: UnsafeRawPointer, _ count: Int)->T?) -> T? {
        if let ptr = gi.packed_byte_array_operator_index(&content, 0) {
            return method (ptr, Int (size ()))
        }
        return nil
    }
}

extension PackedColorArray {
    /// Accesses a specific element in the ``PackedColorArray``
    public subscript (index: Int) -> Color {
        get {
            let ptr = gi.packed_color_array_operator_index (&content, Int64 (index))
            return ptr!.assumingMemoryBound(to: Color.self).pointee
        }
        set {
            set (index: Int64 (index), value: newValue)
        }
    }
}

extension PackedFloat32Array {
    /// Accesses a specific element in the ``PackedFloat32Array``
    public subscript (index: Int) -> Float {
        get {
            let ptr = gi.packed_float32_array_operator_index (&content, Int64 (index))
            return ptr!.pointee
        }
        set {
            set (index: Int64 (index), value: Double (newValue))
        }
    }
}

extension PackedFloat64Array {
    /// Accesses a specific element in the ``PackedFloat64Array``
    public subscript (index: Int) -> Double {
        get {
            let ptr = gi.packed_float64_array_operator_index (&content, Int64(index))
            return ptr!.pointee
        }
        set {
            set (index: Int64 (index), value: newValue)
        }
    }
}

extension PackedInt32Array {
    /// Accesses a specific element in the ``PackedInt32Array``
    public subscript (index: Int) -> Int32 {
        get {
            let ptr = gi.packed_int32_array_operator_index (&content, Int64(index))
            return ptr!.pointee
        }
        set {
            set (index: Int64 (index), value: Int64(newValue))
        }
    }
}

extension PackedInt64Array {
    /// Accesses a specific element in the ``PackedInt64Array``
    public subscript (index: Int) -> Int64 {
        get {
            let ptr = gi.packed_int64_array_operator_index(&content, Int64(index))
            return ptr!.pointee
        }
        set {
            set (index: Int64 (index), value: newValue)
        }
    }
}

extension PackedVector2Array {
    /// Accesses a specific element in the ``PackedVector2Array``
    public subscript (index: Int) -> Vector2 {
        get {
            let ptr = gi.packed_vector2_array_operator_index (&content, Int64(index))
            return ptr!.assumingMemoryBound(to: Vector2.self).pointee
        }
        set {
            set (index: Int64 (index), value: newValue)
        }
    }
}

extension PackedVector3Array {
    /// Accesses a specific element in the ``PackedVector3Array``
    public subscript (index: Int) -> Vector3 {
        get {
            let ptr = gi.packed_vector3_array_operator_index (&content, Int64(index))
            return ptr!.assumingMemoryBound(to: Vector3.self).pointee
        }
        set {
            set (index: Int64 (index), value: newValue)
        }
    }
}


