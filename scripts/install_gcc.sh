#!/bin/bash -e

INSTALL_PATH="$HOME/.local/cross"
GCC_VERSION=12.1.0

function main {
  local macopt=
  if [ `uname` = "Darwin" ]; then
    macopt="--with-gmp=/opt/homebrew --with-mpfr=/opt/homebrew --with-mpc=/opt/homebrew"
  fi

  if [ ! -f gcc-${GCC_VERSION}.tar.xz ]; then
    curl -L http://ftp.gnu.org/gnu/gcc/gcc-${GCC_VERSION}/gcc-${GCC_VERSION}.tar.xz -O
  fi
  if [ ! -d gcc-${GCC_VERSION} ]; then
    tar xf gcc-${GCC_VERSION}.tar.xz
  fi
  for TARGET in i686-elf x86_64-elf
  do
    (
      echo "[] gcc-${GCC_VERSION}: ${TARGET}"
      mkdir -p build-gcc-${GCC_VERSION}-${TARGET}
      cd build-gcc-${GCC_VERSION}-${TARGET}
      ../gcc-${GCC_VERSION}/configure \
        --prefix="${INSTALL_PATH}" \
        --target="${TARGET}" \
        --enable-language=c,c++ --without-headers \
        --enable-interwork --enable-multilib \
        --disable-bootstrap --disable-libmpx \
        --disable-nls \
        --with-system-zlib ${macopt}
      make -j8 all-gcc
      make -j8 all-target-libgcc
      make install-gcc
      make install-target-libgcc
    )
  done
}

BASEDIR=$(cd $(dirname "$0") && pwd)
(
    cd "${BASEDIR}"
    main $@
)
