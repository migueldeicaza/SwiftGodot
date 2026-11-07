#!/bin/bash
set -euo pipefail

# GODOT can select a Godot executable that is not on PATH.
autoload_godot="${GODOT:-godot}"
autoload_repo="$(cd "$(dirname "$0")/.." && pwd)"
autoload_temp="$(mktemp -d /tmp/swiftgodot-autoloads.XXXXXX)"
cleanup() {
    if [ "$?" -eq 0 ]; then
        rm -rf "$autoload_temp"
    else
        echo "Test files retained at $autoload_temp"
    fi
}
trap cleanup EXIT
cd "$autoload_repo"

for autoload_product in SwiftGodotTestExtension SwiftGodot SwiftGodotRuntime; do
    if ! swift build --disable-sandbox --product "$autoload_product" > "$autoload_temp/build.log" 2>&1; then
        cat "$autoload_temp/build.log"
        exit 1
    fi
done
autoload_bin="$(swift build --disable-sandbox --show-bin-path)"

prepare_project() {
    local destination="$1"
    local fixture="$2"
    mkdir -p "$destination/bin"
    cp "$fixture"/* "$destination/"
    cp Tests/SwiftGodotTestProject/SwiftTests.gdextension "$destination/"
    for product in SwiftGodotTestExtension SwiftGodot SwiftGodotRuntime; do
        case "$(uname -s)" in
            Darwin) cp "$autoload_bin/lib$product.dylib" "$destination/bin/" ;;
            Linux) cp "$autoload_bin/lib$product.so" "$destination/bin/" ;;
            *) echo "This test script supports macOS and Linux."; exit 1 ;;
        esac
    done
}

prepare_project "$autoload_temp/integration" Tests/SwiftGodotAutoloadProject
"$autoload_godot" --headless --editor --quit-after 120 --path "$autoload_temp/integration" --log-file "$autoload_temp/editor.log"
cp "$autoload_temp/integration/project.godot" "$autoload_temp/first.godot"
"$autoload_godot" --headless --editor --quit-after 120 --path "$autoload_temp/integration" --log-file "$autoload_temp/editor.log"
cmp "$autoload_temp/first.godot" "$autoload_temp/integration/project.godot"
"$autoload_godot" --headless --path "$autoload_temp/integration" --log-file "$autoload_temp/game.log" --quit-after 240 | tee "$autoload_temp/integration.log"
grep -q "SwiftGodot autoload integration passed" "$autoload_temp/integration.log"

mkdir -p "$autoload_temp/runtime/bin"
cp Tests/SwiftGodotTestProject/{project.godot,main.tscn,test_orchestrator.gd} "$autoload_temp/runtime/"
cp "$autoload_temp/integration/SwiftTests.gdextension" "$autoload_temp/runtime/"
cp "$autoload_temp/integration/bin/"* "$autoload_temp/runtime/bin/"
"$autoload_godot" --headless --editor --quit-after 120 --path "$autoload_temp/runtime" --log-file "$autoload_temp/editor.log"
SWIFTGODOT_TEST_FILTER=AutoloadTests "$autoload_godot" --headless --path "$autoload_temp/runtime" --log-file "$autoload_temp/runtime.log" --quit-after 240

python3 - "$autoload_temp/runtime/test_results.json" <<'PY'
import json
import sys

with open(sys.argv[1]) as results:
    summary = json.load(results)["summary"]
assert summary["failed"] == 0 and summary["passed"] == 4, summary
print("SwiftGodot autoload runtime tests passed")
PY

# Add a manual entry. The plugin must retain it when declarations change.
python3 - "$autoload_temp/runtime" <<'PY'
from pathlib import Path
import sys

project = Path(sys.argv[1])
(project / "kept.tscn").write_text('[gd_scene format=3]\n[node name="Kept" type="Node"]\n')
settings = project / "project.godot"
text = settings.read_text().replace('[autoload]\n', '[autoload]\nKeptAutoload="*res://kept.tscn"\n')
settings.write_text(text)
PY
SWIFTGODOT_AUTOLOAD_TEST_MODE=reverse "$autoload_godot" --headless --editor --quit-after 120 --path "$autoload_temp/runtime" --log-file "$autoload_temp/editor.log"
python3 - "$autoload_temp/runtime/project.godot" <<'PY'
from pathlib import Path
import sys

settings = Path(sys.argv[1]).read_text()
assert settings.index('SwiftTestObserver="*') < settings.index('SwiftTestState="*')
assert 'KeptAutoload="*res://kept.tscn"' in settings
PY
SWIFTGODOT_AUTOLOAD_TEST_MODE=empty "$autoload_godot" --headless --editor --quit-after 120 --path "$autoload_temp/runtime" --log-file "$autoload_temp/editor.log"
python3 - "$autoload_temp/runtime" <<'PY'
from pathlib import Path
import sys

project = Path(sys.argv[1])
settings = (project / "project.godot").read_text()
assert 'SwiftTestState="*' not in settings and 'SwiftTestObserver="*' not in settings
assert 'KeptAutoload="*res://kept.tscn"' in settings
assert not list((project / "swiftgodot" / "autoloads").rglob("*.tscn"))
print("SwiftGodot autoload order and removal tests passed")
PY
