LIBGODOT=~/cvs/libgodot

run:
	(cd $(LIBGODOT); scons platform=macos target=template_debug dev_build=yes library_type=shared_library use_asan=yes) 
	sh make-libgodot.framework $(LIBGODOT) ..
