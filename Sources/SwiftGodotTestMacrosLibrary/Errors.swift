//
//  Errors.swift
//

import Foundation

/// Errors that can occur during macro expansion
public enum SwiftGodotTestMacroError: Error, CustomStringConvertible {
    case notAFunction
    case notAClass

    public var description: String {
        switch self {
        case .notAFunction:
            return "@SwiftGodotTest can only be applied to functions"
        case .notAClass:
            return "@SwiftGodotTestSuite can only be applied to classes"
        }
    }
}
