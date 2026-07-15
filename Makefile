ODOCS=../SwiftGodotDocs/docs

all:
	echo Targets:
	echo    - build-docs: Builds the documentation
	echo    - preview-docs: Start local web server serving the documentation
	echo    - push-docs: Pushes the existing documentation, requires SwiftGodotDocs peer checked out
	echo    - release: Dispatches binary publishing for an existing GitHub release
	echo    - binary-artifacts: Builds binary XCFrameworks locally

build-docs:
	GENERATE_DOCS=1 DOCC_HTML_DIR=/Users/miguel/cvs/swift-docc-render-artifact/dist swift package \
		--allow-writing-to-directory $(ODOCS) \
		generate-documentation \
		--target SwiftGodot \
		--disable-indexing \
		--transform-for-static-hosting \
		--hosting-base-path /SwiftGodotDocs \
		--source-service github \
		--source-service-base-url https://github.com/migueldeicaza/SwiftGodot/blob/main \
		--checkout-path . \
		--emit-digest \
		--output-path $(ODOCS) \
		--verbose \
		>& build-docs.log

preview-docs:
	GENERATE_DOCS=1 swift package --disable-sandbox preview-documentation --target SwiftGodot --disable-indexing --emit-digest

release: check-version
	scripts/release $(VERSION)

check-version:
	@if test x$(VERSION) = x; then echo You need to provide VERSION=TAG; exit 1; fi

binary-artifacts:
	scripts/build-binary-artifacts .build/binary-artifacts

lint:
	swiftlint lint Sources
