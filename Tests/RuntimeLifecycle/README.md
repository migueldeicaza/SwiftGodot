# Runtime lifecycle checks

Use Godot 4.7 or later.

Build the three dynamic products from this fixture package. Use a separate
scratch directory. Each fixture uses the root package's dynamic SwiftGodot
product. Thus A and B use the same runtime instance.

```sh
swift build --package-path Tests/RuntimeLifecycle --scratch-path .build/lifecycle-fixtures --product LifecycleDefaultExtension
swift build --package-path Tests/RuntimeLifecycle --scratch-path .build/lifecycle-fixtures --product LifecycleExtensionA
swift build --package-path Tests/RuntimeLifecycle --scratch-path .build/lifecycle-fixtures --product LifecycleExtensionB
scripts/test-runtime-lifecycle --bin-path .build/lifecycle-fixtures/debug --godot /path/to/godot --output-dir /tmp/lifecycle-fixed
```

On macOS, check the link dependencies before the test:

```sh
otool -L .build/lifecycle-fixtures/debug/libLifecycleExtensionA.dylib
otool -L .build/lifecycle-fixtures/debug/libLifecycleExtensionB.dylib
```

Both outputs must include the same `libSwiftGodot.dylib`. On Linux, use
`ldd` on each `.so` file. Root-package target dependencies can include a
separate static runtime in each fixture. Do not use that package arrangement
for this check.

The runner copies all shared libraries from `--bin-path` to each temporary
project. It deletes each temporary project after the check. It saves process
output in `defaults.log` and `unload.log`. It saves exit codes and check results
in `results.json`. The default timeout is 90 seconds per process.

Use `--scenario defaults` or `--scenario unload` to run one check.
Use `--timeout SECONDS` to change the timeout.

The defaults check starts the headless editor. The main scene contains a
`LifecycleDefaultNode` with a custom Resource instance as its property default.
Godot reads the default through ClassDB. The editor
must complete its import and exit with status zero. The runner uses
`--headless --editor --import` so the first filesystem scan can finish. The
log must contain this native warning:

```text
Instantiated LifecycleDefaultResource used as default value for LifecycleDefaultNode's "data" property.
```

This fixture uses a manual entry point, as the ManualExtension sample does.
It registers the Resource before the Node at the scene initialization stage.
Its deinitialization hook leaves both classes registered. Thus Godot releases
the cached Resource default during final ClassDB cleanup. The generated
entry point would unregister the class at scene deinitialization and release
the default too early to reproduce this crash.

The unload check loads extension A, then extension B. It creates and frees a
node from A. Both nodes create 16 native Resources and return their instance
IDs. Each local Swift reference is then released. After eight frames, all IDs
must be invalid. The check repeats with B after A is unloaded and after A is
loaded again.
The check then unloads A and B. Both classes must be absent from ClassDB.
The log must contain `LIFECYCLE_UNLOAD_OK`.
The runner also rejects any native ObjectDB leak warning from this check.

The defaults check permits the one cached default reference left at process
exit. Godot frees that default after its last extension callback and after
it deletes MessageQueue. The runtime discards this late release. It does not
carry its native handle into a later engine session.

The runtime drains releases through a main-loop callback for each library.
It drains before and after deinitialization hooks, until no pending handles
remain. Removing one library leaves the other library's callback active.
Embedded hosts register the callback through `setExtensionInterface`.
They must call `clearPendingReleaseState(forDomain:)` before engine destruction;
this call closes that domain to further releases. A new session reopens it.

The root `LifecycleTests.testReleasePendingObjectsDrainsNativeReferenceChain`
test also checks a parent Resource that owns a child through native metadata.
One explicit drain must release both native objects.

To check a version with the shutdown crash, use:

```sh
scripts/test-runtime-lifecycle --bin-path /path/to/baseline/bin --godot /path/to/godot --output-dir /tmp/lifecycle-baseline --scenario defaults --expect-shutdown-crash
```

This mode requires a process crash, the native defaults warning, and deferred
release evidence. A crash without that evidence fails the check.
Use a Godot executable that prints crash backtraces. Keep Swift symbols in the
build so the runner can identify the deferred release path.

On macOS, the runner also waits up to 10 seconds for a DiagnosticReports `.ips`
file with the Godot process ID. It copies that report to the output directory
and records the triggered thread's symbols in the log and `results.json`.
The stack must show deferred call scheduling and Resource or wrapper release.

To check a version with the extension unload leak, use:

```sh
scripts/test-runtime-lifecycle --bin-path /path/to/guard/bin --godot /path/to/godot --output-dir /tmp/lifecycle-guard --scenario unload --expect-unload-leak
```

This mode requires exit status 2 and `LIFECYCLE_UNLOAD_LEAK`. Other assertion
failures use exit status 1. Timeouts and script errors always fail the check.
Both expected-failure options can be used with `--scenario both`.
