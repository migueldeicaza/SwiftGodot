//
//  File 2.swift
//  
//
//  Created by Miguel de Icaza on 3/25/23.
//

func gmem_alloc (_ size: Int) -> UnsafeMutableRawPointer? {
    gi.mem_alloc (size)
}

func gmem_realloc (_ ptr: UnsafeMutableRawPointer?, size: Int) -> UnsafeMutableRawPointer? {
    return gi.mem_realloc (ptr, size)
}

func gmem_free (_ ptr: UnsafeMutableRawPointer?) {
    return gi.mem_free (ptr)
}

func gprintError (_ description: String, message: String? = nil, function: String, file: String, line: Int32, editorNotify: Bool) {
    if let message {
        gi.print_error_with_message (description, message, function, file, line, editorNotify ? 1 : 0)
    } else {
        gi.print_error (description, function, file, line, editorNotify ? 1 : 0)
    }
}

func gprintWarning (_ description: String, message: String? = nil, function: String, file: String, line: Int32, editorNotify: Bool) {
    if let message {
        gi.print_warning_with_message (description, message, function, file, line, editorNotify ? 1 : 0)
    } else {
        gi.print_warning (description, function, file, line, editorNotify ? 1 : 0)
    }
}

func gprintScriptError (_ description: String, message: String? = nil, function: String, file: String, line: Int32, editorNotify: Bool) {
    if let message {
        gi.print_script_error_with_message (description, message, function, file, line, editorNotify ? 1 : 0)
    } else {
        gi.print_script_error (description, function, file, line, editorNotify ? 1 : 0)
    }
}

func gGetNativeStructSize (name: String) -> UInt64 {
    return gi.get_native_struct_size (name)
}

/// Adds the type described by `name` as an Editor plugin.
///
/// You typically invoke this method from the `setupScene` method when initializing
/// the `.editor` level.   The type specified must subclass `EditorPlugin` and
/// should have been declared with `@Godot(.tool)`.
public func editorAddPlugin(name: StringName) {
    withUnsafeMutablePointer(to: &name.content) { namePtr in
        gi.editor_add_plugin(namePtr)
    }
}

/// Adds the specified type as a Godot Editor Plugin.
///
/// You typically invoke this method from the `setupScene` method when initializing
/// the `.editor` level.   The type specified should have been declared with `@Godot(.tool)`
public func editorAddPlugin<T:EditorPlugin> (type: T.Type) {
    let typeStr = String (describing: type)
    editorAddPlugin(name: StringName(typeStr))
}

/// Removes a Godot editor plugin from the editor by name
public func editorRemovePlugin(name: StringName) {
    withUnsafeMutablePointer(to: &name.content) { namePtr in
        gi.editor_remove_plugin(namePtr)
    }
}

/// Removes a Godot editor plugin.
public func editorRemovePlugin<T:EditorPlugin> (type: T.Type) {
    let typeStr = String (describing: type)
    editorRemovePlugin(name: StringName(typeStr))
}

//
///* variant general */
//void (*variant_new_copy)(GDExtensionVariantPtr r_dest, GDExtensionConstVariantPtr p_src);
//void (*variant_new_nil)(GDExtensionVariantPtr r_dest);
//void (*variant_destroy)(GDExtensionVariantPtr p_self);
//
///* variant type */
//void (*variant_call)(GDExtensionVariantPtr p_self, GDExtensionConstStringNamePtr p_method, const GDExtensionConstVariantPtr *p_args, GDExtensionInt p_argument_count, GDExtensionVariantPtr r_return, GDExtensionCallError *r_error);
//void (*variant_call_static)(GDExtensionVariantType p_type, GDExtensionConstStringNamePtr p_method, const GDExtensionConstVariantPtr *p_args, GDExtensionInt p_argument_count, GDExtensionVariantPtr r_return, GDExtensionCallError *r_error);
//void (*variant_evaluate)(GDExtensionVariantOperator p_op, GDExtensionConstVariantPtr p_a, GDExtensionConstVariantPtr p_b, GDExtensionVariantPtr r_return, GDExtensionBool *r_valid);
//void (*variant_set)(GDExtensionVariantPtr p_self, GDExtensionConstVariantPtr p_key, GDExtensionConstVariantPtr p_value, GDExtensionBool *r_valid);
//void (*variant_set_named)(GDExtensionVariantPtr p_self, GDExtensionConstStringNamePtr p_key, GDExtensionConstVariantPtr p_value, GDExtensionBool *r_valid);
//void (*variant_set_keyed)(GDExtensionVariantPtr p_self, GDExtensionConstVariantPtr p_key, GDExtensionConstVariantPtr p_value, GDExtensionBool *r_valid);
//void (*variant_set_indexed)(GDExtensionVariantPtr p_self, GDExtensionInt p_index, GDExtensionConstVariantPtr p_value, GDExtensionBool *r_valid, GDExtensionBool *r_oob);
//void (*variant_get)(GDExtensionConstVariantPtr p_self, GDExtensionConstVariantPtr p_key, GDExtensionVariantPtr r_ret, GDExtensionBool *r_valid);
//void (*variant_get_named)(GDExtensionConstVariantPtr p_self, GDExtensionConstStringNamePtr p_key, GDExtensionVariantPtr r_ret, GDExtensionBool *r_valid);
//void (*variant_get_keyed)(GDExtensionConstVariantPtr p_self, GDExtensionConstVariantPtr p_key, GDExtensionVariantPtr r_ret, GDExtensionBool *r_valid);
//void (*variant_get_indexed)(GDExtensionConstVariantPtr p_self, GDExtensionInt p_index, GDExtensionVariantPtr r_ret, GDExtensionBool *r_valid, GDExtensionBool *r_oob);
//GDExtensionBool (*variant_iter_init)(GDExtensionConstVariantPtr p_self, GDExtensionVariantPtr r_iter, GDExtensionBool *r_valid);
//GDExtensionBool (*variant_iter_next)(GDExtensionConstVariantPtr p_self, GDExtensionVariantPtr r_iter, GDExtensionBool *r_valid);
//void (*variant_iter_get)(GDExtensionConstVariantPtr p_self, GDExtensionVariantPtr r_iter, GDExtensionVariantPtr r_ret, GDExtensionBool *r_valid);
//GDExtensionInt (*variant_hash)(GDExtensionConstVariantPtr p_self);
//GDExtensionInt (*variant_recursive_hash)(GDExtensionConstVariantPtr p_self, GDExtensionInt p_recursion_count);
//GDExtensionBool (*variant_hash_compare)(GDExtensionConstVariantPtr p_self, GDExtensionConstVariantPtr p_other);
//GDExtensionBool (*variant_booleanize)(GDExtensionConstVariantPtr p_self);
//void (*variant_duplicate)(GDExtensionConstVariantPtr p_self, GDExtensionVariantPtr r_ret, GDExtensionBool p_deep);
//void (*variant_stringify)(GDExtensionConstVariantPtr p_self, GDExtensionStringPtr r_ret);
//
//GDExtensionVariantType (*variant_get_type)(GDExtensionConstVariantPtr p_self);
//GDExtensionBool (*variant_has_method)(GDExtensionConstVariantPtr p_self, GDExtensionConstStringNamePtr p_method);
//GDExtensionBool (*variant_has_member)(GDExtensionVariantType p_type, GDExtensionConstStringNamePtr p_member);
//GDExtensionBool (*variant_has_key)(GDExtensionConstVariantPtr p_self, GDExtensionConstVariantPtr p_key, GDExtensionBool *r_valid);
//void (*variant_get_type_name)(GDExtensionVariantType p_type, GDExtensionStringPtr r_name);
//GDExtensionBool (*variant_can_convert)(GDExtensionVariantType p_from, GDExtensionVariantType p_to);
//GDExtensionBool (*variant_can_convert_strict)(GDExtensionVariantType p_from, GDExtensionVariantType p_to);
//
///* ptrcalls */
//GDExtensionVariantFromTypeConstructorFunc (*get_variant_from_type_constructor)(GDExtensionVariantType p_type);
//GDExtensionTypeFromVariantConstructorFunc (*get_variant_to_type_constructor)(GDExtensionVariantType p_type);
//GDExtensionPtrOperatorEvaluator (*variant_get_ptr_operator_evaluator)(GDExtensionVariantOperator p_operator, GDExtensionVariantType p_type_a, GDExtensionVariantType p_type_b);
//GDExtensionPtrBuiltInMethod (*variant_get_ptr_builtin_method)(GDExtensionVariantType p_type, GDExtensionConstStringNamePtr p_method, GDExtensionInt p_hash);
//GDExtensionPtrConstructor (*variant_get_ptr_constructor)(GDExtensionVariantType p_type, int32_t p_constructor);
//GDExtensionPtrDestructor (*variant_get_ptr_destructor)(GDExtensionVariantType p_type);
//void (*variant_construct)(GDExtensionVariantType p_type, GDExtensionVariantPtr p_base, const GDExtensionConstVariantPtr *p_args, int32_t p_argument_count, GDExtensionCallError *r_error);
//GDExtensionPtrSetter (*variant_get_ptr_setter)(GDExtensionVariantType p_type, GDExtensionConstStringNamePtr p_member);
//GDExtensionPtrGetter (*variant_get_ptr_getter)(GDExtensionVariantType p_type, GDExtensionConstStringNamePtr p_member);
//GDExtensionPtrIndexedSetter (*variant_get_ptr_indexed_setter)(GDExtensionVariantType p_type);
//GDExtensionPtrIndexedGetter (*variant_get_ptr_indexed_getter)(GDExtensionVariantType p_type);
//GDExtensionPtrKeyedSetter (*variant_get_ptr_keyed_setter)(GDExtensionVariantType p_type);
//GDExtensionPtrKeyedGetter (*variant_get_ptr_keyed_getter)(GDExtensionVariantType p_type);
//GDExtensionPtrKeyedChecker (*variant_get_ptr_keyed_checker)(GDExtensionVariantType p_type);
//void (*variant_get_constant_value)(GDExtensionVariantType p_type, GDExtensionConstStringNamePtr p_constant, GDExtensionVariantPtr r_ret);
//GDExtensionPtrUtilityFunction (*variant_get_ptr_utility_function)(GDExtensionConstStringNamePtr p_function, GDExtensionInt p_hash);
//
///*  extra utilities */
//void (*string_new_with_latin1_chars)(GDExtensionStringPtr r_dest, const char *p_contents);
//void (*string_new_with_utf8_chars)(GDExtensionStringPtr r_dest, const char *p_contents);
//void (*string_new_with_utf16_chars)(GDExtensionStringPtr r_dest, const char16_t *p_contents);
//void (*string_new_with_utf32_chars)(GDExtensionStringPtr r_dest, const char32_t *p_contents);
//void (*string_new_with_wide_chars)(GDExtensionStringPtr r_dest, const wchar_t *p_contents);
//void (*string_new_with_latin1_chars_and_len)(GDExtensionStringPtr r_dest, const char *p_contents, GDExtensionInt p_size);
//void (*string_new_with_utf8_chars_and_len)(GDExtensionStringPtr r_dest, const char *p_contents, GDExtensionInt p_size);
//void (*string_new_with_utf16_chars_and_len)(GDExtensionStringPtr r_dest, const char16_t *p_contents, GDExtensionInt p_size);
//void (*string_new_with_utf32_chars_and_len)(GDExtensionStringPtr r_dest, const char32_t *p_contents, GDExtensionInt p_size);
//void (*string_new_with_wide_chars_and_len)(GDExtensionStringPtr r_dest, const wchar_t *p_contents, GDExtensionInt p_size);
///* Information about the following functions:
// * - The return value is the resulting encoded string length.
// * - The length returned is in characters, not in bytes. It also does not include a trailing zero.
// * - These functions also do not write trailing zero, If you need it, write it yourself at the position indicated by the length (and make sure to allocate it).
// * - Passing NULL in r_text means only the length is computed (again, without including trailing zero).
// * - p_max_write_length argument is in characters, not bytes. It will be ignored if r_text is NULL.
// * - p_max_write_length argument does not affect the return value, it's only to cap write length.
// */
//GDExtensionInt (*string_to_latin1_chars)(GDExtensionConstStringPtr p_self, char *r_text, GDExtensionInt p_max_write_length);
//GDExtensionInt (*string_to_utf8_chars)(GDExtensionConstStringPtr p_self, char *r_text, GDExtensionInt p_max_write_length);
//GDExtensionInt (*string_to_utf16_chars)(GDExtensionConstStringPtr p_self, char16_t *r_text, GDExtensionInt p_max_write_length);
//GDExtensionInt (*string_to_utf32_chars)(GDExtensionConstStringPtr p_self, char32_t *r_text, GDExtensionInt p_max_write_length);
//GDExtensionInt (*string_to_wide_chars)(GDExtensionConstStringPtr p_self, wchar_t *r_text, GDExtensionInt p_max_write_length);
//char32_t *(*string_operator_index)(GDExtensionStringPtr p_self, GDExtensionInt p_index);
//const char32_t *(*string_operator_index_const)(GDExtensionConstStringPtr p_self, GDExtensionInt p_index);
//
//void (*string_operator_plus_eq_string)(GDExtensionStringPtr p_self, GDExtensionConstStringPtr p_b);
//void (*string_operator_plus_eq_char)(GDExtensionStringPtr p_self, char32_t p_b);
//void (*string_operator_plus_eq_cstr)(GDExtensionStringPtr p_self, const char *p_b);
//void (*string_operator_plus_eq_wcstr)(GDExtensionStringPtr p_self, const wchar_t *p_b);
//void (*string_operator_plus_eq_c32str)(GDExtensionStringPtr p_self, const char32_t *p_b);
//
///*  XMLParser extra utilities */
//
//GDExtensionInt (*xml_parser_open_buffer)(GDExtensionObjectPtr p_instance, const uint8_t *p_buffer, size_t p_size);
//
///*  FileAccess extra utilities */
//
//void (*file_access_store_buffer)(GDExtensionObjectPtr p_instance, const uint8_t *p_src, uint64_t p_length);
//uint64_t (*file_access_get_buffer)(GDExtensionConstObjectPtr p_instance, uint8_t *p_dst, uint64_t p_length);
//
///*  WorkerThreadPool extra utilities */
//
//int64_t (*worker_thread_pool_add_native_group_task)(GDExtensionObjectPtr p_instance, void (*p_func)(void *, uint32_t), void *p_userdata, int p_elements, int p_tasks, GDExtensionBool p_high_priority, GDExtensionConstStringPtr p_description);
//int64_t (*worker_thread_pool_add_native_task)(GDExtensionObjectPtr p_instance, void (*p_func)(void *), void *p_userdata, GDExtensionBool p_high_priority, GDExtensionConstStringPtr p_description);
//
///* Packed array functions */
//
//uint8_t *(*packed_byte_array_operator_index)(GDExtensionTypePtr p_self, GDExtensionInt p_index); // p_self should be a PackedByteArray
//const uint8_t *(*packed_byte_array_operator_index_const)(GDExtensionConstTypePtr p_self, GDExtensionInt p_index); // p_self should be a PackedByteArray
//
//GDExtensionTypePtr (*packed_color_array_operator_index)(GDExtensionTypePtr p_self, GDExtensionInt p_index); // p_self should be a PackedColorArray, returns Color ptr
//GDExtensionTypePtr (*packed_color_array_operator_index_const)(GDExtensionConstTypePtr p_self, GDExtensionInt p_index); // p_self should be a PackedColorArray, returns Color ptr
//
//float *(*packed_float32_array_operator_index)(GDExtensionTypePtr p_self, GDExtensionInt p_index); // p_self should be a PackedFloat32Array
//const float *(*packed_float32_array_operator_index_const)(GDExtensionConstTypePtr p_self, GDExtensionInt p_index); // p_self should be a PackedFloat32Array
//double *(*packed_float64_array_operator_index)(GDExtensionTypePtr p_self, GDExtensionInt p_index); // p_self should be a PackedFloat64Array
//const double *(*packed_float64_array_operator_index_const)(GDExtensionConstTypePtr p_self, GDExtensionInt p_index); // p_self should be a PackedFloat64Array
//
//int32_t *(*packed_int32_array_operator_index)(GDExtensionTypePtr p_self, GDExtensionInt p_index); // p_self should be a PackedInt32Array
//const int32_t *(*packed_int32_array_operator_index_const)(GDExtensionConstTypePtr p_self, GDExtensionInt p_index); // p_self should be a PackedInt32Array
//int64_t *(*packed_int64_array_operator_index)(GDExtensionTypePtr p_self, GDExtensionInt p_index); // p_self should be a PackedInt32Array
//const int64_t *(*packed_int64_array_operator_index_const)(GDExtensionConstTypePtr p_self, GDExtensionInt p_index); // p_self should be a PackedInt32Array
//
//GDExtensionStringPtr (*packed_string_array_operator_index)(GDExtensionTypePtr p_self, GDExtensionInt p_index); // p_self should be a PackedStringArray
//GDExtensionStringPtr (*packed_string_array_operator_index_const)(GDExtensionConstTypePtr p_self, GDExtensionInt p_index); // p_self should be a PackedStringArray
//
//GDExtensionTypePtr (*packed_vector2_array_operator_index)(GDExtensionTypePtr p_self, GDExtensionInt p_index); // p_self should be a PackedVector2Array, returns Vector2 ptr
//GDExtensionTypePtr (*packed_vector2_array_operator_index_const)(GDExtensionConstTypePtr p_self, GDExtensionInt p_index); // p_self should be a PackedVector2Array, returns Vector2 ptr
//GDExtensionTypePtr (*packed_vector3_array_operator_index)(GDExtensionTypePtr p_self, GDExtensionInt p_index); // p_self should be a PackedVector3Array, returns Vector3 ptr
//GDExtensionTypePtr (*packed_vector3_array_operator_index_const)(GDExtensionConstTypePtr p_self, GDExtensionInt p_index); // p_self should be a PackedVector3Array, returns Vector3 ptr
//
//GDExtensionVariantPtr (*array_operator_index)(GDExtensionTypePtr p_self, GDExtensionInt p_index); // p_self should be an Array ptr
//GDExtensionVariantPtr (*array_operator_index_const)(GDExtensionConstTypePtr p_self, GDExtensionInt p_index); // p_self should be an Array ptr
//void (*array_ref)(GDExtensionTypePtr p_self, GDExtensionConstTypePtr p_from); // p_self should be an Array ptr
//void (*array_set_typed)(GDExtensionTypePtr p_self, GDExtensionVariantType p_type, GDExtensionConstStringNamePtr p_class_name, GDExtensionConstVariantPtr p_script); // p_self should be an Array ptr
//
///* Dictionary functions */
//
//GDExtensionVariantPtr (*dictionary_operator_index)(GDExtensionTypePtr p_self, GDExtensionConstVariantPtr p_key); // p_self should be an Dictionary ptr
//GDExtensionVariantPtr (*dictionary_operator_index_const)(GDExtensionConstTypePtr p_self, GDExtensionConstVariantPtr p_key); // p_self should be an Dictionary ptr
//
///* OBJECT */
//
//void (*object_method_bind_call)(GDExtensionMethodBindPtr p_method_bind, GDExtensionObjectPtr p_instance, const GDExtensionConstVariantPtr *p_args, GDExtensionInt p_arg_count, GDExtensionVariantPtr r_ret, GDExtensionCallError *r_error);
//void (*object_method_bind_ptrcall)(GDExtensionMethodBindPtr p_method_bind, GDExtensionObjectPtr p_instance, const GDExtensionConstTypePtr *p_args, GDExtensionTypePtr r_ret);
//void (*object_destroy)(GDExtensionObjectPtr p_o);
//GDExtensionObjectPtr (*global_get_singleton)(GDExtensionConstStringNamePtr p_name);
//
//void *(*object_get_instance_binding)(GDExtensionObjectPtr p_o, void *p_token, const GDExtensionInstanceBindingCallbacks *p_callbacks);
//void (*object_set_instance_binding)(GDExtensionObjectPtr p_o, void *p_token, void *p_binding, const GDExtensionInstanceBindingCallbacks *p_callbacks);
//
//void (*object_set_instance)(GDExtensionObjectPtr p_o, GDExtensionConstStringNamePtr p_classname, GDExtensionClassInstancePtr p_instance); /* p_classname should be a registered extension class and should extend the p_o object's class. */
//
//GDExtensionObjectPtr (*object_cast_to)(GDExtensionConstObjectPtr p_object, void *p_class_tag);
//GDExtensionObjectPtr (*object_get_instance_from_id)(GDObjectInstanceID p_instance_id);
//GDObjectInstanceID (*object_get_instance_id)(GDExtensionConstObjectPtr p_object);
//
///* REFERENCE */
//
//GDExtensionObjectPtr (*ref_get_object)(GDExtensionConstRefPtr p_ref);
//void (*ref_set_object)(GDExtensionRefPtr p_ref, GDExtensionObjectPtr p_object);
//
///* SCRIPT INSTANCE */
//
//GDExtensionScriptInstancePtr (*script_instance_create)(const GDExtensionScriptInstanceInfo *p_info, GDExtensionScriptInstanceDataPtr p_instance_data);
//
///* CLASSDB */
//
//GDExtensionObjectPtr (*classdb_construct_object)(GDExtensionConstStringNamePtr p_classname); /* The passed class must be a built-in godot class, or an already-registered extension class. In both case, object_set_instance should be called to fully initialize the object. */
//GDExtensionMethodBindPtr (*classdb_get_method_bind)(GDExtensionConstStringNamePtr p_classname, GDExtensionConstStringNamePtr p_methodname, GDExtensionInt p_hash);
//void *(*classdb_get_class_tag)(GDExtensionConstStringNamePtr p_classname);
//
///* CLASSDB EXTENSION */
//
///* Provided parameters for `classdb_register_extension_*` can be safely freed once the function returns. */
//void (*classdb_register_extension_class)(GDExtensionClassLibraryPtr p_library, GDExtensionConstStringNamePtr p_class_name, GDExtensionConstStringNamePtr p_parent_class_name, const GDExtensionClassCreationInfo *p_extension_funcs);
//void (*classdb_register_extension_class_method)(GDExtensionClassLibraryPtr p_library, GDExtensionConstStringNamePtr p_class_name, const GDExtensionClassMethodInfo *p_method_info);
//void (*classdb_register_extension_class_integer_constant)(GDExtensionClassLibraryPtr p_library, GDExtensionConstStringNamePtr p_class_name, GDExtensionConstStringNamePtr p_enum_name, GDExtensionConstStringNamePtr p_constant_name, GDExtensionInt p_constant_value, GDExtensionBool p_is_bitfield);
//void (*classdb_register_extension_class_property)(GDExtensionClassLibraryPtr p_library, GDExtensionConstStringNamePtr p_class_name, const GDExtensionPropertyInfo *p_info, GDExtensionConstStringNamePtr p_setter, GDExtensionConstStringNamePtr p_getter);
//void (*classdb_register_extension_class_property_group)(GDExtensionClassLibraryPtr p_library, GDExtensionConstStringNamePtr p_class_name, GDExtensionConstStringPtr p_group_name, GDExtensionConstStringPtr p_prefix);
//void (*classdb_register_extension_class_property_subgroup)(GDExtensionClassLibraryPtr p_library, GDExtensionConstStringNamePtr p_class_name, GDExtensionConstStringPtr p_subgroup_name, GDExtensionConstStringPtr p_prefix);
//void (*classdb_register_extension_class_signal)(GDExtensionClassLibraryPtr p_library, GDExtensionConstStringNamePtr p_class_name, GDExtensionConstStringNamePtr p_signal_name, const GDExtensionPropertyInfo *p_argument_info, GDExtensionInt p_argument_count);
//void (*classdb_unregister_extension_class)(GDExtensionClassLibraryPtr p_library, GDExtensionConstStringNamePtr p_class_name); /* Unregistering a parent class before a class that inherits it will result in failure. Inheritors must be unregistered first. */
//
//void (*get_library_path)(GDExtensionClassLibraryPtr p_library, GDExtensionStringPtr r_path);
