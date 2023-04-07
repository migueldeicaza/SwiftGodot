ODOCS=../SwiftGodotDocs/docs

build-docs:
	GENERATE_DOCS=1 swift package --allow-writing-to-directory $(ODOCS) generate-documentation --target SwiftGodot --disable-indexing --transform-for-static-hosting --hosting-base-path /SwiftGodotDocs --emit-digest --output-path $(ODOCS)

push-docs:
	(cd ../SwiftGodotDocs; mv docs tmp; git reset --hard 8b5f69a631f42a37176a040aeb5cfa1620249ff1; git mv docs; git add docs/*; git commit -m "Import Docs"; git push -f; git prune)
