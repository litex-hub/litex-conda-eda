#!/bin/bash

set -e
set -x

INSTALL_PATH=${PWD}/image

export PKG_CONFIG_PATH="$BUILD_PREFIX/lib/pkgconfig/"
export CXXFLAGS="$CXXFLAGS -I$BUILD_PREFIX/include"
export LDFLAGS="$CXXFLAGS -L$BUILD_PREFIX/lib -lrt -ltinfo"
export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:$BUILD_PREFIX/lib"

cd Surelog && \
	cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=$INSTALL_PATH -DCMAKE_POSITION_INDEPENDENT_CODE=ON -S . -B build && \
	cmake --build build -j$(nproc) && \
	cmake --install build && \
	cd ..

#Create aliases for gcc/gxx as `abc` uses them directly in Makefile
alias gcc=x86_64-conda_cos6-linux-gnu-gcc
alias gxx=x86_64-conda_cos6-linux-gnu-gcc
cd yosys && make ENABLE_READLINE=0 CONFIG=conda-linux PROGRAM_PREFIX=uhdm- PREFIX=$INSTALL_PATH install -j$(nproc) && cd ..

export PATH=$INSTALL_PATH/bin:${PATH}

UHDM_INSTALL_DIR=$INSTALL_PATH make -C $PWD/yosys-symbiflow-plugins/ install -j$(nproc)

mkdir -p "$PREFIX/"

cp -r $SRC_DIR/image/* "$PREFIX/"

