//
//  Various.swift: Support functions
//  
//
//  Created by Miguel de Icaza on 3/26/23.
//

extension Object: CustomStringConvertible {
    public var description: String {
        return toString().description
    }
}
