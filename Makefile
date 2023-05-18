ODOCS=../SwiftGodotDocs/docs

all:
	echo Targets:
	echo    - build-docs: Builds the documentation
	echo    - push-docs: Pushes the existing documentation, requires SwiftGodotDocs peer checked out
	echo    - release: Builds an xcframework package, documentation and pushes documentation

build-docs:
	GENERATE_DOCS=1 swift package --allow-writing-to-directory $(ODOCS) generate-documentation Documentation.docc --target SwiftGodot --disable-indexing --transform-for-static-hosting --hosting-base-path /SwiftGodotDocs --emit-digest --output-path $(ODOCS)

push-docs:
	(cd ../SwiftGodotDocs; mv docs tmp; git reset --hard 8b5f69a631f42a37176a040aeb5cfa1620249ff1; mv tmp docs; git add docs/*; git commit -m "Import Docs"; git push -f; git prune)

release: build-release build-docs push-docs

build-release:
	sh scripts/release $(VERSION)
