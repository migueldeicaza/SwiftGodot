# Documenting your Godot Extension

If you are developing a Godot extension that is intended to be consumed from
Godot you might want to provide documentation for it.

During the development process, Godot has a mechanism to generate a skeleton XML
file based on your API that you can update with the information that you want
to surface.   Then, as your plugin evolves, you will be updating the API and
Godot would update the XML files in place with changes - so the documentation
you have written is not wiped out on every run.

In the Godot world, plugins surface documentation when they are loaded by the
Godot editor as part of the initialization sequence.   

How the documentation is distributed is up to you.  You might want to embed the
documentation inside your Swift library, or you could distribute it as a
set of standalone XML files - what is important is that when your plugin is
initialized during the '.editor' phase, that you provide the documentation to
Godot using one of the `EditorInterop.loadHelp` methods.

In MacOS the preferred distribution mechanism for libraries are called
"frameworks", and SwiftGodot has built-in support for registering the
documentation on your behalf.  In other platforms, you need to manually
configure this.

Alternatively, SwiftGodot can build the documentation from the documentation
comments in your Swift code, as described in the next section.

## Documentation Comments

SwiftGodot can turn the documentation comments (`///` or `/** */`) of a
`@Godot` class and its exported members into Godot's class reference, which the
editor shows in its help pages and inspector tooltips.  This takes two steps.

First, enable the `with_editor_documentation` package trait where you depend on
SwiftGodot, so that the `@Godot` macro generates the documentation:

```swift
.package(
    url: "https://github.com/migueldeicaza/SwiftGodot",
    branch: "main",
    traits: ["with_editor_documentation"]
)
```

Second, define `SWIFTGODOT_INCLUDE_EDITOR_DOCUMENTATION` in each target that
declares `@Godot` classes, for the build configurations that you use in the
editor.  The documentation is compiled into your library as text, so this keeps
your comments out of the builds you ship to players.  For example, if you use
debug builds in the editor and release builds in exported games:

```swift
.target(
    name: "MyExtension",
    dependencies: ["SwiftGodot"],
    swiftSettings: [
        .define("SWIFTGODOT_INCLUDE_EDITOR_DOCUMENTATION", .when(configuration: .debug)),
    ]
)
```

The following comments are used for the generated documentation:

* Comments on the class itself. The first paragraph becomes the brief description shown in
  lists such as the Create New Node dialog. The reset is added to the full description.
* Properties marked with `@Export`.
* Methods marked with `@Callable`.
* Signals declared with `@Signal` or `#signal`.
* Enumerations nested in the class. Godot doesn't support the description of the enumeration
  as a whole, but it does pick up the comments on each case within.

Members are matched with the names Godot sees, so properties are documented
under their snake-cased or `explicitName:` names.  Any Markdown in the Swift comments
is converted to Godot's BBCode: code spans, emphasis, links, lists, code
blocks and callouts such as `- Note:` are supported, `- Parameter`,
`- Returns:` and `- Throws:` fields are listed at the end, and symbol
references such as ` ``speed`` `, ` ``jump(height:)`` ` or ` ``Mode/fast`` `
become links to the class's members.  Other capitalized references, such as
` ``Node`` `, become links to the class of that name.  Members marked
`@available(*, deprecated)` are shown as deprecated.

The documentation is loaded into the editor when the extension reaches the
`.editor` initialization level, so no files need to be distributed with it.

## Generating XML API Definitions

Once you have a working extension, you need to invoke the Godot editor from
a directory that contains a Godot project that uses your extension, and then
invoke the editor like this:

```
$ cd your-test-game
$ godot.editor --headless --path . --doctool . --gdextension-docs
```

That will generate the documentation in the "doc_classes" directory, and it will
contain one XML file per class.

Then you can edit the contents of those XML files, and when you change your API,
you just need to re-run the command above.

## Distributing Your Documentation

As mentioned above, you need to decide how you want to ship your documentation.

### Distributing Your Documentation on MacOS

On MacOS, the best way of doing that is by creating a framework package with
your library code.  When you build your project with Xcode in release mode, it
will generate a `framework` package.   Copy the 'doc_classes' directory into the
'Resources' directory inside the framework.

## Loading the Documentation at Startup

On MacOS, if you are using the '#initSwiftExtension' macro, merely set the
'registerDocs' parameter to 'true' and the runtime will load the documentation
from the framework bundle for you.

If you are not using the '#initSwiftExtension' macro, you need to call the
EditorInterop.loadHelp during the `.editor` initialization stage with the
XML contents of your documentation.   And it is up to you to fetch the
documentation from the location you stored it.

If you are not on MacOS, and you are using the '#initSwiftExtesion' macro, pass
the 'hookMethod' parameter, which is a function that takes a
ExtensionInitializationLevel (you will test this to be '.editor' to register the
documentation) and whether it is initializating or deinitializing.

From this hook method, you can call the EditorInterop.loadHelp method with your documentation.