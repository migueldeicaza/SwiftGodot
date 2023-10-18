//
//  ExtensionApiJson.swift
//
//
//  Created by Mikhail Tishin on 17.10.2023.
//

import Foundation

extension URL {
    
    public static var extensionApiJson: URL? {
        return Bundle.module.url(forResource: "extension_api", withExtension: "json")
    }
    
}
