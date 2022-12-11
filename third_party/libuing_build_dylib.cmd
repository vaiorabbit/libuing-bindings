:: [NOTE]
:: - Make sure to run 'pip install meson' in advance
:: - Run this script in 'x64 Native Tools Command Prompt for VS 2022', or meson would detect wrong build target (Win32, not x64)
@echo off
setlocal enabledelayedexpansion
py -m mesonbuild.mesonmain --backend=vs2022 --buildtype=release -Dtests=false -Dexamples=false ./build ./libui-ng/
devenv build\libui.sln /Build
copy build\meson-out\libui.dll ..\lib
