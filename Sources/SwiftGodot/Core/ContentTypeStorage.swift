//
//  File.swift
//  
//
//  Created by Padraig O Cinneide on 2023-10-22.
//

import Foundation

/// Some of Godot's build-in classes use ContentType for storage.
/// This needs to be public because it affects their initialization, but
/// SwiftGodot users should never need to conform their types
/// to`ContentTypeStoring`.
public protocol ContentTypeStoring: AnyObject {
    associatedtype ContentType
    var content: ContentType { get }
    static var zero: ContentType { get }
    
    init (content: ContentType)
}

extension StringName: ContentTypeStoring {}
extension NodePath: ContentTypeStoring {}
extension RID: ContentTypeStoring {}
extension Callable: ContentTypeStoring {}
extension Signal: ContentTypeStoring {}
extension GDictionary: ContentTypeStoring {}
extension GArray: ContentTypeStoring {}
extension GString: ContentTypeStoring {}
extension Nil: ContentTypeStoring {}
extension PackedByteArray: ContentTypeStoring {}
extension PackedInt32Array: ContentTypeStoring {}
extension PackedInt64Array: ContentTypeStoring {}
extension PackedFloat32Array: ContentTypeStoring {}
extension PackedFloat64Array: ContentTypeStoring {}
extension PackedStringArray: ContentTypeStoring {}
extension PackedVector2Array: ContentTypeStoring {}
extension PackedVector3Array: ContentTypeStoring {}
extension PackedColorArray: ContentTypeStoring {}
