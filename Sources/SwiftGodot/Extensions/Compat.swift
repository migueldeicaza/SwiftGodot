//
//  Compat.swift
//  SwiftGodot
//
//  Created by Miguel de Icaza on 10/3/24.
//

public extension Vector2 {
    @available(*, deprecated, message: "The method was renamed reflect(line:) by Godot")
    func reflect(n: Vector2)-> Vector2 {
        reflect(line: n)
    }
}
