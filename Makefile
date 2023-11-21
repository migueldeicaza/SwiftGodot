ODOCS=../SwiftGodotDocs/docs

all:
	echo Targets:
	echo    - build-docs: Builds the documentation
	echo    - preview-docs: Start local web server serving the documentation
	echo    - push-docs: Pushes the existing documentation, requires SwiftGodotDocs peer checked out
	echo    - release: Builds an xcframework package, documentation and pushes documentation
	echo    - sync: synchronizes the Macro system to the ../SwiftGodotBinary module

build-docs:
	GENERATE_DOCS=1 swift package --allow-writing-to-directory $(ODOCS) generate-documentation --target SwiftGodot --disable-indexing --transform-for-static-hosting --hosting-base-path /SwiftGodotDocs --emit-digest --output-path $(ODOCS) >& build-docs.log

preview-docs:
	GENERATE_DOCS=1 swift package --disable-sandbox preview-documentation --target SwiftGodot --disable-indexing --emit-digest

push-docs:
	(cd ../SwiftGodotDocs; mv docs tmp; git reset --hard 8b5f69a631f42a37176a040aeb5cfa1620249ff1; mv tmp docs; touch .nojekyll docs/.nojekyll; git add docs/* .nojekyll docs/.nojekyll; git commit -m "Import Docs"; git push -f; git prune)

release: check-args build-release build-docs push-docs

build-release: check-args
	sh -x scripts/release $(VERSION) $(NOTES) `git rev-parse HEAD`

check-args:
	@if test x$(VERSION)$(NOTES) = x; then echo You need to provide both VERSION=XX NOTES=FILENAME arguments to this makefile target; exit 1; fi

sync:
	@if test ../SwiftGodotBinary; then rsync -a Sources/SwiftGodotMacroLibrary ../SwiftGodotBinary/Sources; else echo "missing directory ../SwiftGodotBinary"; fi
