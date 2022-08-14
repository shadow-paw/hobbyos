# Hobby OS
> osdev as a hobby, not because they are easy, but because they are hard.

## Get Started
### Install Prerequisite Packages
#### Ubuntu
```
sudo apt-get install -y build-essential curl libgmp3-dev libmpfr-dev libmpc-dev zlib1g-dev texinfo libexpat-dev
sudo apt-get install qemu-system-x86
```
#### Mac
```
brew install gmp mpfr libmpc texinfo
brew install qemu
```

### Setup Toolchain
```
scripts/install_binutils.sh
scripts/install_gcc.sh
scripts/install_gdb.sh
```
#### Configure PATH
```
export PATH=$PATH:$HOME/.local/cross/bin
```

### Install Grub2 Tools
Our OS leverage GRUB2 as boot loader, so we need to use the grub2 tools to pack our disk image.
💡 It is not recommended to mess with boot loader on your working machine. You should be very careful when working with
GRUB and make sure it apply on a disk image only.

#### Ubuntu
```
sudo apt-get install grub2-common grub-pc-bin xorriso
```
#### Mac
GRUB2 is not supported on mac, to use the grub tools, one way is to use docker run the grub tools:
```
docker run --rm -it --platform linux/amd64 --name osdev \
  -v "$PWD:/mnt/data" \
  ubuntu:22.04 \
  bash -c "apt-get update \
           && apt-get install -y grub2-common grub-pc-bin xorriso \
           && grub-mkrescue -o /mnt/data/myos.iso /mnt/data/iso"
```
> Makefile will launch similar docker command on mac when building image.
