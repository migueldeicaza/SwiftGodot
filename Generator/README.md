This contains the "Generator" command line tool that consumes the
Godot extension-api.json file and produces the Swift bindings for it.

When used with the SwiftGodot package, this is automatically
invoked with the Godot 4.0 API description and will generate
the documentation.

It can optionally produce inline documentation if you have Godot
installed locally, but you currently must edit the main.swift
source file to point it to your Godot documentation checkout.