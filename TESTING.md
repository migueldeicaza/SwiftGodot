# How to run tests

`godot` executable must be in PATH (needed by SwiftGodotTestRunner).

## Run tests that require embedding in a Godot instance

```bash
swift run SwiftGodotTestRunner
```

## Run a specific test suite that requires embedding in a Godot instance

```bash
SWIFTGODOT_TEST_FILTER="SnappingTests" swift run SwiftGodotTestRunner
```

## Run a specific test that requires embedding in a Godot instance

```bash
SWIFTGODOT_TEST_FILTER="SnappingTests.testSnapDouble" swift run SwiftGodotTestRunner
```

## Run other tests

```bash
swift test
```
