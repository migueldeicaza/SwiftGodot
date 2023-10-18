//
//  ExtensionApiJson.swift
//
//
//  Created by Mikhail Tishin on 17.10.2023.
//

import Foundation
@exported import ExtensionApi

extension URL {
    
    public static var extensionApiJson: URL? {
        return Bundle.module.url(forResource: "extension_api", withExtension: "json")
    }
    
}
