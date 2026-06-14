//
//  Errors.swift
//

import Foundation

/// Errors that can occur during macro expansion
public enum SwiftGodotTestMacroError: Error, CustomStringConvertible {
    case notAClass

    public var description: String {
        switch self {
        case .notAClass:
            return "@SwiftGodotTestSuite can only be applied to classes"
        }
    }
}
