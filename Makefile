ODOCS=../SwiftGodotDocs/docs

build-docs:
	GENERATE_DOCS=1 swift package --allow-writing-to-directory $(ODOCS) generate-documentation --target SwiftGodot --disable-indexing --transform-for-static-hosting --hosting-base-path /SwiftGodotDocs --emit-digest --output-path $(ODOCS)
