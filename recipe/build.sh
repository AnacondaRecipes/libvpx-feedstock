#!/bin/bash

set -ex

# Get an updated config.sub and config.guess
cp $BUILD_PREFIX/share/libtool/build-aux/config.* .

if [[ $(uname) == MSYS* ]]; then
    HOST_BUILD="--host=x86_64-w64-mingw32 --build=x86_64-w64-mingw32"
    PREFIX=${PREFIX}/Library/mingw-w64
fi

if [[ ${target_platform} == linux-* ]]; then
    LDFLAGS="$LDFLAGS -pthread"
fi

CPU_DETECT=""
if [[ ${target_platform} == osx-* ]]; then
    CPU_DETECT="${CPU_DETECT} --disable-avx512 --disable-runtime-cpu-detect"
else
    CPU_DETECT="${CPU_DETECT} --enable-runtime-cpu-detect"
fi

./configure --prefix=${PREFIX} ${HOST_BUILD} \
--as=yasm                    \
--enable-shared              \
--disable-static             \
--disable-install-docs       \
--disable-install-srcs       \
--enable-vp8                 \
--enable-postproc            \
--enable-vp9                 \
--enable-vp9-highbitdepth    \
--enable-pic                 \
${CPU_DETECT}                \
--enable-experimental || { cat config.log; exit 1; }

make -j${CPU_COUNT} ${VERBOSE_AT}
make install
