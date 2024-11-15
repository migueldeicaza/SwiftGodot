//
//  ClassInfo+ConvenienceProperties.swift
//  
//
//  Created by Marquis Kurt on 5/29/23.
//

#if canImport(UniformTypeIdentifiers)
import UniformTypeIdentifiers

@available(macOS 11.0, *)
extension UTType {
    /// The file type that corresponds to a Godot resource file.
    public static var godotResource = UTType(filenameExtension: "res")

    /// The file type that corresponds to a Godot scene file.
    public static var godotScene = UTType(filenameExtension: "tscn")

    /// The file type that corresponds to a GDScript file.
    public static var gdscript = UTType(filenameExtension: "gd")

    /// The file type that corresponds to a Godot shader file.
    public static var godotShader = UTType(filenameExtension: "gdshader")

    /// The file type that corresponds to a Godot tileset resource.
    public static var godotTilesetResource = UTType(filenameExtension: "tres")
}
#endif

public protocol Nameable {
    var name: String { get }
}

extension ClassInfo {
    /// A type alias referencing a class info function that can be registered.
    public typealias ClassInfoFunction = (T) -> (borrowing Arguments) -> Variant?

    /// A type alias referencing a registerable int enum.
    public typealias RegisteredIntEnum = CaseIterable & Nameable & RawRepresentable<Int>

    /// Performs an operation on an argument that originates from a setter method.
    ///
    /// This can be used inside setter method to set a property in-class with a guaranteed argument value.
    ///
    /// ```swift
    /// func setBubbleCount(args: borrowing Arguments) -> Variant? {
    ///     withCheckedProperty(named: "bubbles", in: args) { argument in
    ///         self.bubbles = Int(argument) ?? 0
    ///     }
    /// }
    /// ```
    ///
    /// - Parameter name: The name of the property that is being set.
    /// - Parameter arguments: The list of arguments that were passed from the setter.
    /// - Parameter action: A closure that accepts a valid argument.
    public static func withCheckedProperty(named name: String,
                                           in arguments: borrowing Arguments,
                                           perform action: (Variant?) -> Void) -> Variant? {
        guard let arg = arguments.first else {
            GD.pushError("Expected argument for \(name), but got nil instead.")
            return nil
        }
        action(arg)
        return nil
    }

    /// Registers a checkbox toggle in the editor.
    /// - Parameter name: The name of the property that will appear in the editor.
    /// - Parameter prefix: The prefix to apply to the property name. Defaults to the class's name if not provided.
    /// - Parameter getter: The getter method the editor will call to get the property.
    /// - Parameter setter: The setter method the editor will call to set the property.
    public func registerCheckbox(named name: String,
                                 prefix: String? = nil,
                                 getter: @escaping ClassInfoFunction,
                                 setter: @escaping ClassInfoFunction) {
        let registeredPrefix = prefix ?? "\(T.self)"
        let property = PropInfo(propertyType: .bool,
                                propertyName: StringName("\(registeredPrefix)_\(name)"),
                                className: StringName("\(T.self)"),
                                hint: .flags,
                                hintStr: "",
                                usage: .default)
        registerSetter(prefix: registeredPrefix, name: name, property: property, setter: setter)
        registerGetter(prefix: registeredPrefix, name: name, property: property, getter: getter)
        registerProperty(property,
                         getter: StringName("\(registeredPrefix)_get_\(name)"),
                         setter: StringName("\(registeredPrefix)_set_\(name)"))
    }

    /// Registers an enumeration in the editor.
    /// - Parameter name: The name of the property that will appear in the editor.
    /// - Parameter enumType: The enumeration type that will be selected in the editor.
    /// - Parameter prefix: The prefix to apply to the property name. Defaults to the class's name if not provided.
    /// - Parameter getter: The getter method the editor will call to get the property.
    /// - Parameter setter: The setter method the editor will call to set the property.
    public func registerEnum<Enum: RegisteredIntEnum>(named name: String,
                                                      for enumType: Enum.Type,
                                                      prefix: String? = nil,
                                                      getter: @escaping ClassInfoFunction,
                                                      setter: @escaping ClassInfoFunction) {
        let registeredPrefix = prefix ?? "\(T.self)"
        let property = PropInfo(propertyType: .int,
                                propertyName: StringName("\(registeredPrefix)_\(name)"),
                                className: StringName("\(T.self)"),
                                hint: .enum,
                                hintStr: GString(Enum.allCases.map(\.name).joined(separator: ",")),
                                usage: .default)
        registerGetter(prefix: registeredPrefix, name: name, property: property, getter: getter)
        registerSetter(prefix: registeredPrefix, name: name, property: property, setter: setter)
        registerProperty(property,
                         getter: StringName("\(registeredPrefix)_get_\(name)"),
                         setter: StringName("\(registeredPrefix)_set_\(name)"))
    }

    /// Registers a file picker in the editor.
    ///
    /// - Important: This method is deprecated on macOS 12.0 or later; Use the
    ///   ``ClassInfo/registerFilePicker(named:allowedTypes:prefix:getter:setter:)-9oeps`` method for newer macOS
    ///   versions.
    ///
    /// - Parameter name: The name of the property that will appear in the editor.
    /// - Parameter allowedTypes: The types of files allowed in the file picker.
    /// - Parameter prefix: The prefix to apply to the property name. Defaults to the class's name if not provided.
    /// - Parameter getter: The getter method the editor will call to get the property.
    /// - Parameter setter: The setter method the editor will call to set the property.
    @available(macOS, introduced: 10.15, deprecated: 12.0, message: "Use the variant with UTTypes.")
    public func registerFilePicker(named name: String,
                                   allowedTypes: [String] = ["*"],
                                   prefix: String? = nil,
                                   getter: @escaping ClassInfoFunction,
                                   setter: @escaping ClassInfoFunction) {
        let registeredPrefix = prefix ?? "\(T.self)"
        let fileExtensions = allowedTypes.map { "*.\($0)" }.joined(separator: ",")
        let property = PropInfo(propertyType: .string,
                                propertyName: StringName(name),
                                className: StringName("\(T.self)"),
                                hint: .file,
                                hintStr: GString(fileExtensions),
                                usage: .default)
        registerSetter(prefix: registeredPrefix, name: name, property: property, setter: setter)
        registerGetter(prefix: registeredPrefix, name: name, property: property, getter: getter)
        registerProperty(property,
                         getter: StringName("\(registeredPrefix)_get_\(name)"),
                         setter: StringName("\(registeredPrefix)_set_\(name)"))
    }

    /// Registers a file picker in the editor.
    /// - Parameter name: The name of the property that will appear in the editor.
    /// - Parameter allowedTypes: The types of files allowed in the file picker.
    /// - Parameter prefix: The prefix to apply to the property name. Defaults to the class's name if not provided.
    /// - Parameter getter: The getter method the editor will call to get the property.
    /// - Parameter setter: The setter method the editor will call to set the property.
    #if canImport(UniformTypeIdentifiers)
    @available(macOS 11.0, *)
    public func registerFilePicker(named name: String,
                                   allowedTypes: [UTType],
                                   prefix: String? = nil,
                                   getter: @escaping ClassInfoFunction,
                                   setter: @escaping ClassInfoFunction) {
        let registeredPrefix = prefix ?? "\(T.self)"
        let fileExtensions = allowedTypes.map(\.preferredFilenameExtension)
            .map { "*.\($0 ?? "*")" }
            .joined(separator: ",")
        let property = PropInfo(propertyType: .string,
                                propertyName: StringName(name),
                                className: StringName("\(T.self)"),
                                hint: .file,
                                hintStr: GString(fileExtensions),
                                usage: .default)
        registerSetter(prefix: registeredPrefix, name: name, property: property, setter: setter)
        registerGetter(prefix: registeredPrefix, name: name, property: property, getter: getter)
        registerProperty(property,
                         getter: StringName("\(registeredPrefix)_get_\(name)"),
                         setter: StringName("\(registeredPrefix)_set_\(name)"))
    }
    #endif

    /// Registers a number field in the number that can be adjusted in a range.
    /// - Parameter string: The name of the property that will appear in the editor.
    /// - Parameter range: The range that the number must fall between.
    /// - Parameter stride: The number to decrease or increase by. Defaults to 1.
    /// - Parameter prefix: The prefix to apply to the property name. Defaults to the class's name if not provided.
    /// - Parameter getter: The getter method the editor will call to get the property.
    /// - Parameter setter: The setter method the editor will call to set the property.
    public func registerInt(named name: String,
                            range: ClosedRange<Int>,
                            stride: Int = 1,
                            prefix: String? = nil,
                            getter: @escaping ClassInfoFunction,
                            setter: @escaping ClassInfoFunction) {
        let registeredPrefix = prefix ?? "\(T.self)"
        let property = PropInfo(propertyType: .int,
                                propertyName: StringName("\(registeredPrefix)_\(name)"),
                                className: StringName("\(T.self)"),
                                hint: .range,
                                hintStr: GString("\(range.lowerBound),\(range.upperBound),\(stride)"),
                                usage: .default)
        registerSetter(prefix: registeredPrefix, name: name, property: property, setter: setter)
        registerGetter(prefix: registeredPrefix, name: name, property: property, getter: getter)
        registerProperty(property,
                         getter: StringName("\(registeredPrefix)_get_\(name)"),
                         setter: StringName("\(registeredPrefix)_set_\(name)"))
    }

    /// Registers a text field.
    /// - Parameter name: The name of the property that will appear in the editor.
    /// - Parameter prefix: The prefix to apply to the property name. Defaults to the class's name if not provided.
    /// - Parameter getter: The getter method the editor will call to get the property.
    /// - Parameter setter: The setter method the editor will call to set the property.
    public func registerTextField(named name: String,
                                  prefix: String? = nil,
                                  getter: @escaping ClassInfoFunction,
                                  setter: @escaping ClassInfoFunction) {
        let registeredPrefix = prefix ?? "\(T.self)"
        let property = PropInfo(propertyType: .string,
                                propertyName: StringName("\(registeredPrefix)_\(name)"),
                                className: StringName("\(T.self)"),
                                hint: .none,
                                hintStr: "",
                                usage: .default)
        registerSetter(prefix: registeredPrefix, name: name, property: property, setter: setter)
        registerGetter(prefix: registeredPrefix, name: name, property: property, getter: getter)
        registerProperty(property,
                         getter: StringName("\(registeredPrefix)_get_\(name)"),
                         setter: StringName("\(registeredPrefix)_set_\(name)"))
    }

    /// Registers a multiline text view in the editor.
    /// - Parameter name: The name of the property that will appear in the editor.
    /// - Parameter prefix: The prefix to apply to the property name. Defaults to the class's name if not provided.
    /// - Parameter getter: The getter method the editor will call to get the property.
    /// - Parameter setter: The setter method the editor will call to set the property.
    public func registerTextView(named name: String,
                                 prefix: String? = nil,
                                 getter: @escaping ClassInfoFunction,
                                 setter: @escaping ClassInfoFunction) {
        let registeredPrefix = prefix ?? "\(T.self)"
        let property = PropInfo(propertyType: .string,
                                propertyName: StringName("\(registeredPrefix)_\(name)"),
                                className: StringName("\(T.self)"),
                                hint: .multilineText,
                                hintStr: "",
                                usage: .default)
        registerSetter(prefix: registeredPrefix, name: name, property: property, setter: setter)
        registerGetter(prefix: registeredPrefix, name: name, property: property, getter: getter)
        registerProperty(property,
                         getter: StringName("\(registeredPrefix)_get_\(name)"),
                         setter: StringName("\(registeredPrefix)_set_\(name)"))
    }

    /// Registers a node path picker in the editor.
    /// - Parameter name: The name of the property that will appear in the editor.
    /// - Parameter prefix: The prefix to apply to the property name. Defaults to the class's name if not provided.
    /// - Parameter getter: The getter method the editor will call to get the property.
    /// - Paramater setter: The setter method the editor will call to set the property.
    public func registerNodePath(named name: String,
                                 prefix: String? = nil,
                                 getter: @escaping ClassInfoFunction,
                                 setter: @escaping ClassInfoFunction) {
        let registeredPrefix = prefix ?? "\(T.self)"
        let property = PropInfo(propertyType: .nodePath,
                                propertyName: StringName("\(registeredPrefix)_\(name)"),
                                className: StringName("\(T.self)"),
                                hint: .nodePathValidTypes,
                                hintStr: "",
                                usage: .default)
        registerSetter(prefix: registeredPrefix, name: name, property: property, setter: setter)
        registerGetter(prefix: registeredPrefix, name: name, property: property, getter: getter)
        registerProperty(property,
                         getter: StringName("\(registeredPrefix)_get_\(name)"),
                         setter: StringName("\(registeredPrefix)_set_\(name)"))
    }

    private func registerGetter(prefix: String, name: String, property: PropInfo, getter: @escaping ClassInfoFunction) {
        registerMethod(name: StringName("\(prefix)_get_\(name)"),
                       flags: .default,
                       returnValue: property,
                       arguments: [],
                       function: getter)
    }

    private func registerSetter(prefix: String, name: String, property: PropInfo, setter: @escaping ClassInfoFunction) {
        registerMethod(name: StringName("\(prefix)_set_\(name)"),
                       flags: .default,
                       returnValue: nil,
                       arguments: [property],
                       function: setter)
    }
}
