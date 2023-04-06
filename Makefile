ODOCS=docs

build-docs:
	swift package --allow-writing-to-directory $(ODOCS) generate-documentation --target SwiftGodot --disable-indexing --transform-for-static-hosting --hosting-base-path https://migueldeicaza.github.io/SwiftGodot --emit-digest --output-path $(ODOCS)
