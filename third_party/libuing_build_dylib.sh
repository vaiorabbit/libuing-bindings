meson setup --buildtype=release ./build ./libui-ng/
ninja -C build
cp -R build/meson-out/libui.A.dylib ../lib/libui.dylib
