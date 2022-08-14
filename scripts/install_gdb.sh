#!/bin/bash -e

INSTALL_PATH="$HOME/.local/cross"
GDB_VERSION=12.1

function main {
  local macopt=
  if [ `uname` = "Darwin" ]; then
    macopt="--with-libgmp-prefix=/opt/homebrew"
  fi

  if [ ! -f gdb-${GDB_VERSION}.tar.xz ]; then
    curl -L http://ftp.gnu.org/gnu/gdb/gdb-${GDB_VERSION}.tar.xz -O
  fi
  if [ ! -d gdb-${GDB_VERSION} ]; then
    tar xf gdb-${GDB_VERSION}.tar.xz
  fi
  for TARGET in i686-elf x86_64-elf
  do
    (
      echo "[] gdb-${GDB_VERSION}: ${TARGET}"
      mkdir -p build-gdb-${GDB_VERSION}-${TARGET}
      cd build-gdb-${GDB_VERSION}-${TARGET}
      ../gdb-${GDB_VERSION}/configure \
        --prefix="${INSTALL_PATH}" \
        --target="${TARGET}" \
        --program-prefix="${TARGET}-" \
        --with-gmp=/usr/local \
        --with-libelf=/usr/local \
        --with-build-libsubdir=/usr/local ${macopt} \
        CFLAGS="-I/usr/local/include"
      make -j8
      make install
    )
  done
}

BASEDIR=$(cd $(dirname "$0") && pwd)
(
    cd "${BASEDIR}"
    main $@
)
