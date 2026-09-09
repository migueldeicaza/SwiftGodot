ODOCS=../SwiftGodotDocs/docs
PREPARED_TOOLS_DIR=.build-tools
PREPARED_GENERATOR=$(PREPARED_TOOLS_DIR)/Generator
PREP_ENV=CLANG_MODULE_CACHE_PATH="$(CURDIR)/.build/module-cache"
PREP_SWIFT_BUILD_FLAGS=--disable-sandbox
PREP_GENERATOR_SOURCE=

.PHONY: prep prepare-generator

all:
	echo Targets:
	echo    - build-docs: Builds the documentation
	echo    - preview-docs: Start local web server serving the documentation
	echo    - push-docs: Pushes the existing documentation, requires SwiftGodotDocs peer checked out
	echo    - release: Dispatches binary publishing for an existing GitHub release
	echo    - binary-artifacts: Builds binary XCFrameworks locally
	echo    - prep: Builds the prepared Generator used by CodeGeneratorPlugin

prep: prepare-generator

# SwiftPM plans build-tool plugins before building Generator. When the prepared
# binary is absent, use a temporary executable placeholder for that planning.
prepare-generator:
	@mkdir -p .build/module-cache
	@set -e; \
	if test -n "$(PREP_GENERATOR_SOURCE)"; then \
		bin="$(PREP_GENERATOR_SOURCE)"; \
	else \
		mkdir -p $(PREPARED_TOOLS_DIR); \
		placeholder=0; \
		if ! test -x "$(PREPARED_GENERATOR)"; then \
			: > "$(PREPARED_GENERATOR)"; \
			chmod +x "$(PREPARED_GENERATOR)"; \
			placeholder=1; \
		fi; \
		if ! $(PREP_ENV) swift build $(PREP_SWIFT_BUILD_FLAGS) --product Generator; then \
			if test $$placeholder -eq 1; then rm -f "$(PREPARED_GENERATOR)"; fi; \
			exit 1; \
		fi; \
		bin="$$($(PREP_ENV) swift build $(PREP_SWIFT_BUILD_FLAGS) --show-bin-path)/Generator"; \
	fi; \
	if ! test -x "$$bin"; then \
		echo "Generator is not executable: $$bin"; \
		exit 1; \
	fi; \
	mkdir -p $(PREPARED_TOOLS_DIR); \
	if ! cmp -s "$$bin" "$(PREPARED_GENERATOR)"; then \
		cp "$$bin" "$(PREPARED_GENERATOR)"; \
		chmod +x "$(PREPARED_GENERATOR)"; \
		echo "Updated $(PREPARED_GENERATOR)"; \
	else \
		chmod +x "$(PREPARED_GENERATOR)"; \
		echo "$(PREPARED_GENERATOR) is up to date"; \
	fi

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
