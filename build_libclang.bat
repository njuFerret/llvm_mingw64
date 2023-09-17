: 说明：
:     由于mingw-w64-x86_64-13.1.0无法使用qt提供的libclang，使用该批处理编译libclang
:     llvm-clang的源码在清华镜像上有，可以用git下载
:     Qt 6.5.2编译时，必须对libclang进行静态编译，但静态编译后，库体积过大，因此采用2次编译方法
:     静态编译后，用于编译Qt；动态编译，用于qtcreator内的相关支持
:     注意，如果要编译 clang-tidy 和 clangd，必须启用 clang-tools-extra，
:         即： -DLLVM_ENABLE_PROJECTS=clang;clang-tools-extra
:     以下采用选项3，用于编译qtcreator支持的动态链接方案
:         采用选项4，用于编译qt 6.5.2的静态链接方案
:     注： 不要包含其他第三方库，如zlib等
:     另外还有去除除x86架构外其他支持，见编译说明



@echo off


set ROOT=%CD%
set BUILD_DEPS_DIR=%ROOT%\deps

set OPENSSL_DIR=%BUILD_DEPS_DIR%/3rdParty/openssl
set ZLIB_DIR=%BUILD_DEPS_DIR%/3rdParty/zlib
set LLVM_DIR=%ROOT%\llvm-project
set LLVM_INSTALL_DIR=%ROOT%\libclang
set LLVM_INSTALL_SHARED=%LLVM_INSTALL_DIR%\shared
set LLVM_INSTALL_STATIC=%LLVM_INSTALL_DIR%\static
:set LLVM_INSTALL_DIR=D:\Dev\libclang

:set path=C:\Windows;C:\Windows\System32
set path=%path%;%BUILD_DEPS_DIR%\cmake\bin
set path=%path%;%CD%\mingw64\bin

set path=%path%;%BUILD_DEPS_DIR%\python
set path=%path%;%BUILD_DEPS_DIR%\ninja
set path=%path%;%BUILD_DEPS_DIR%\perl\bin

set MINGW=mingw64-x86_64.7z


curl -L -o 7zr.exe https://github.com/FetheredSerpent/qt-mingw64/releases/download/dependencies/7zr.exe
curl -L -o deps.7z https://github.com/njuFerret/llvm_mingw64/releases/download/dependencies/deps.7z
curl -L -o %MINGW% https://github.com/niXman/mingw-builds-binaries/releases/download/13.1.0-rt_v11-rev1/x86_64-13.1.0-release-posix-seh-ucrt-rt_v11-rev1.7z

tree .

echo 解压deps.7z
7zr x deps.7z 

echo 解压%MinGW%
7zr x %MINGW%

del deps.7z 
del %MINGW%

python -V
perl -v
ninja -v

echo LLVM路径: %LLVM_DIR%，构建路径: %LLVM_DIR%\build, 安装路径%LLVM_INSTALL_DIR%

: 3. 配置为动态库，启用clang和clang-tools-extra（包含clangd和clang-tidy），不包括zlib，注意动态库时qt 6.5.2编译不通过
:cmake -GNinja -DBUILD_SHARED_LIBS:BOOL=ON -DLIBCLANG_LIBRARY_VERSION=16.0.6 -DLLVM_ENABLE_PROJECTS=clang;clang-tools-extra -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=%LLVM_INSTALL_DIR% -S%LLVM_DIR%/llvm -B%LLVM_DIR%/build
cmake -GNinja -DBUILD_SHARED_LIBS:BOOL=ON -DLLVM_ENABLE_PROJECTS=clang;clang-tools-extra -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=%LLVM_INSTALL_SHARED% -S%LLVM_DIR%/llvm -B%LLVM_DIR%/build

cmake --build %LLVM_DIR%/build --parallel 

cmake --build %LLVM_DIR%/build --parallel --target install  

7zr a %LLVM_INSTALL_DIR%.7z %LLVM_INSTALL_DIR%

: 4. 配置为静态库，启用clang和clang-tools-extra（包含clangd和clang-tidy），不包括zlib，（包括zlib，会导致lupdate.exe链接到libzlib.dll）
:cmake -GNinja -DBUILD_SHARED_LIBS:BOOL=OFF -DLIBCLANG_BUILD_STATIC:BOOL=ON -DLLVM_ENABLE_PROJECTS=clang;clang-tools-extra -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=%LLVM_INSTALL_DIR% %LLVM_DIR%/llvm -B%LLVM_DIR%/build

: 编译
::cmake --build %LLVM_DIR%/build --parallel 

: 安装
cmake --build %LLVM_DIR%/build --parallel --target install  
:或
:cmake --install %LLVM_DIR%/build

