ODOCS=docs

build-docs:
	swift package --allow-writing-to-directory $(ODOCS) generate-documentation --target SwiftGodot --disable-indexing --transform-for-static-hosting --hosting-base-path /SwiftGodot --emit-digest --output-path $(ODOCS)
