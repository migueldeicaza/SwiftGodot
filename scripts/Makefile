LIBGODOT=~/cvs/libgodot-4.3

build-libgodot:
	(cd $(LIBGODOT); scons platform=macos target=template_debug dev_build=yes library_type=shared_library vulkan_sdk_path=~/MoltenVK/)

package: libgodot.dylib
	sh make-libgodot.framework $(LIBGODOT) . .
	ditto -c -k --sequesterRsrc --keepParent libgodot.xcframework libgodot.xcframework.zip
	swift package compute-checksum libgodot.xcframework.zip

libgodot.dylib:
	install_name_tool -id libgodot.macos.template_debug.dev.arm64.dylib libgodot.macos.template_debug.dev.arm64.dylib
	install_name_tool -id libgodot.macos.template_debug.dev.x86_64.dylib libgodot.macos.template_debug.dev.x86_64.dylib
	lipo -create -output libgodot.dylib libgodot.macos.template_debug.dev.x86_64.dylib libgodot.macos.template_debug.dev.arm64.dylib
