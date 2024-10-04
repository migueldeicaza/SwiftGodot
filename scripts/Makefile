LIBGODOT=~/cvs/libgodot-4.3

run:
	(cd $(LIBGODOT); scons platform=macos target=template_debug dev_build=yes library_type=shared_library vulkan_sdk_path=~/MoltenVK/) 
	sh make-libgodot.framework $(LIBGODOT) .. .

