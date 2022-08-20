.PHONY: build lint run run-debug gdb isoimage clean

BASE_PATH_SRC=src/
BASE_PATH_OBJ=obj/
BASE_PATH_BIN=bin/
BASE_PATH_LIB=lib/
BASE_PATH_DIST=dist/

ifeq ("$(ARCH)", "i686")
    CROSS_TARGET=i686-elf
    CROSS_AS=$(CROSS_TARGET)-as
    CROSS_ASFLAGS=-g
    CROSS_CC=$(CROSS_TARGET)-gcc
    CROSS_CXX=$(CROSS_TARGET)-g++
    CROSS_CCFLAGS=-ffreestanding -std=c17 -masm=intel \
                 -mno-mmx -mno-sse -mno-sse2 -mno-sse3 -mno-3dnow \
			     -O2 -Wall -Wextra -g
    CROSS_CXXFLAGS=-ffreestanding -std=c++17 -masm=intel \
				   -mno-mmx -mno-sse -mno-sse2 -mno-sse3 -mno-3dnow \
                   -fno-use-cxa-atexit \
				   -fno-exceptions -fno-rtti -fno-stack-protector \
				   -O2 -Wall -Wextra -g
    CROSS_LD=$(CROSS_TARGET)-gcc
    CROSS_LDFLAGS=-ffreestanding -O2 -nostdlib
    CROSS_AR=$(CROSS_TARGET)-ar
    CROSS_ARFLAGS=-rcs
    CROSS_OBJCOPY=$(CROSS_TARGET)-objcopy
    CROSS_GDB=$(CROSS_TARGET)-gdb
endif
ifeq ("$(ARCH)", "x86_64")
    CROSS_TARGET=x86_64-elf
    CROSS_AS=$(CROSS_TARGET)-as
    CROSS_ASFLAGS=-g
    CROSS_CC=$(CROSS_TARGET)-gcc
    CROSS_CXX=$(CROSS_TARGET)-g++
    CROSS_CCFLAGS=-ffreestanding -std=c17 -masm=intel \
                 -mno-mmx -mno-sse -mno-sse2 -mno-sse3 -mno-3dnow \
				 -mcmodel=kernel -mno-red-zone \
			     -O2 -Wall -Wextra -g
    CROSS_CXXFLAGS=-ffreestanding -std=c++17 -masm=intel \
                   -mcmodel=kernel -mno-red-zone \
				   -mno-mmx -mno-sse -mno-sse2 -mno-sse3 -mno-3dnow \
                   -fno-use-cxa-atexit \
				   -fno-exceptions -fno-rtti -fno-stack-protector \
				   -O2 -Wall -Wextra -g
    CROSS_LD=$(CROSS_TARGET)-gcc
    CROSS_LDFLAGS=-ffreestanding -O2 -nostdlib -z max-page-size=0x1000
    CROSS_AR=$(CROSS_TARGET)-ar
    CROSS_ARFLAGS=-rcs
    CROSS_OBJCOPY=$(CROSS_TARGET)-objcopy
    CROSS_GDB=$(CROSS_TARGET)-gdb
endif

CPPLINTFLAGS=--quiet --filter=-legal/copyright,-build/include_subdir,-build/c++11,-readability/todo --linelength=200

# Top-Level Command
###########################################################
build:
	@if [ "$(MACHINE)" = "pc" ]; then \
	  if [ "$(ARCH)" = "i686" ]; then \
	    MACHINE=pc ARCH=i686 make kernel-build; \
	  elif [ "$(ARCH)" = "x86_64" ]; then \
	    MACHINE=pc ARCH=x86_64 make kernel-build; \
	  else \
	    MACHINE=pc ARCH=i686 make kernel-build; \
	    MACHINE=pc ARCH=x86_64 make kernel-build; \
	  fi \
	else \
	  echo "usage: MACHINE=pc make build"; \
	  false; \
	fi

lint: kernel-lint
	@:

isoimage: build
	@if [ "$(MACHINE)" = "pc" ]; then \
	  mkdir -p dist/pc/iso/boot/grub; \
	  cp src/boot/pc/grub.cfg dist/pc/iso/boot/grub/; \
	  mkdir -p dist/pc/iso/boot/i686 dist/pc/initrd/i686/; \
	  cp bin/kernel/pc/i686/kernel.bin dist/pc/iso/boot/i686/kernel.bin; \
	  rsync -qavr src/initrd/i686/ dist/pc/initrd/i686/; \
	  find dist/pc/initrd/i686/ -maxdepth 1 -printf "%P\n" | tar -C dist/pc/initrd/i686/ -czf dist/pc/iso/boot/i686/initrd --owner=0 --group=0 --no-same-owner --no-same-permissions -T -; \
	  \
	  mkdir -p dist/pc/iso/boot/x86_64 dist/pc/initrd/x86_64/; \
	  cp bin/kernel/pc/x86_64/kernel.bin dist/pc/iso/boot/x86_64/kernel.bin; \
	  rsync -qavr src/initrd/x86_64/ dist/pc/initrd/x86_64/; \
	  find dist/pc/initrd/x86_64/ -maxdepth 1 -printf "%P\n" | tar -C dist/pc/initrd/x86_64/ -czf dist/pc/iso/boot/x86_64/initrd --owner=0 --group=0 --no-same-owner --no-same-permissions -T -; \
	  \
	  grub-mkrescue -o dist/pc/hobbyos.iso dist/pc/iso; \
	else \
	  echo "usage: MACHINE=pc make dist"; \
	  false; \
	fi

run:
	@if [ "$(MACHINE)" = "pc" ]; then \
	  if [ "$(ARCH)" = "i686" ]; then \
	    qemu-system-i386 -m 32 -display curses -cdrom dist/pc/hobbyos.iso; \
	  elif [ "$(ARCH)" = "x86_64" ]; then \
	    qemu-system-x86_64 -m 32 -display curses -cdrom dist/pc/hobbyos.iso; \
	  else \
	    echo "usage: MACHINE=pc ARCH=i686|x86_64 make run"; \
	  fi \
	else \
	  echo "usage: MACHINE=pc make run"; \
	fi

run-debug:
	@if [ "$(MACHINE)" = "pc" ]; then \
	  if [ "$(ARCH)" = "i686" ]; then \
	    qemu-system-i386 -s -S -m 32 -display curses -cdrom dist/pc/hobbyos.iso; \
	  elif [ "$(ARCH)" = "x86_64" ]; then \
	    qemu-system-x86_64 -s -S -m 32 -display curses -cdrom dist/pc/hobbyos.iso; \
	  else \
	    echo "usage: MACHINE=pc ARCH=i686|x86_64 make run"; \
	  fi \
	else \
	  echo "usage: MACHINE=pc make run"; \
	fi

gdb:
	@if [ "$(MACHINE)" = "pc" ]; then \
	  if [ "$(ARCH)" = "i686" ]; then \
	    i686-elf-gdb \
	      --eval-command="set disassembly-flavor intel" \
		  --eval-command="set architecture i386" \
		  --eval-command="target remote localhost:1234" \
		  --eval-command="set history save on" \
		  --symbols=bin/kernel/pc/i686/kernel.sym; \
	  elif [ "$(ARCH)" = "x86_64" ]; then \
	    x86_64-elf-gdb \
	      --eval-command="set disassembly-flavor intel" \
		  --eval-command="target remote localhost:1234" \
		  --eval-command="set history save on" \
		  --symbols=bin/kernel/pc/x86_64/kernel.sym; \
	  else \
	    echo "usage: MACHINE=pc ARCH=i686|x86_64 make gdb"; \
	  fi \
	else \
	  echo "usage: MACHINE=pc make gdb"; \
	fi

clean:
	@if [ "$(MACHINE)" = "pc" ]; then \
	  MACHINE=pc ARCH=i686 make kernel-clean; \
	  MACHINE=pc ARCH=x86_64 make kernel-clean; \
	else \
	  MACHINE=pc make clean; \
	fi

# Kernel
###########################################################
KERNEL_PATH_SRC=$(BASE_PATH_SRC)kernel/
KERNEL_PATH_OBJ=$(BASE_PATH_OBJ)kernel/$(ARCH)/
KERNEL_PATH_BIN=$(BASE_PATH_BIN)kernel/
KERNEL_CORE_ASM:=$(sort $(wildcard $(KERNEL_PATH_SRC)*.asm))
KERNEL_CORE_C  :=$(sort $(wildcard $(KERNEL_PATH_SRC)*.c))
KERNEL_CORE_CPP:=$(sort $(wildcard $(KERNEL_PATH_SRC)*.cpp))
KERNEL_CORE_H:=$(sort $(wildcard $(KERNEL_PATH_SRC)*.h))
KERNEL_CORE_OBJ:=$(patsubst $(KERNEL_PATH_SRC)%.asm,$(KERNEL_PATH_OBJ)%_asm.o,$(KERNEL_CORE_ASM)) \
                 $(patsubst $(KERNEL_PATH_SRC)%.c,$(KERNEL_PATH_OBJ)%_c.o,$(KERNEL_CORE_C)) \
                 $(patsubst $(KERNEL_PATH_SRC)%.cpp,$(KERNEL_PATH_OBJ)%_cpp.o,$(KERNEL_CORE_CPP))
KERNEL_MACHINE_PATH_SRC= $(KERNEL_PATH_SRC)machine/$(MACHINE)/
KERNEL_MACHINE_PATH_OBJ= $(KERNEL_PATH_OBJ)machine/$(MACHINE)/
KERNEL_MACHINE_ASM:=$(sort $(wildcard $(KERNEL_MACHINE_PATH_SRC)*.asm))
KERNEL_MACHINE_C  :=$(sort $(wildcard $(KERNEL_MACHINE_PATH_SRC)*.c))
KERNEL_MACHINE_CPP:=$(sort $(wildcard $(KERNEL_MACHINE_PATH_SRC)*.cpp))
KERNEL_MACHINE_H:=$(sort $(wildcard $(KERNEL_MACHINE_PATH_SRC)*.h))
KERNEL_MACHINE_OBJ:=$(patsubst $(KERNEL_MACHINE_PATH_SRC)%.asm,$(KERNEL_MACHINE_PATH_OBJ)%_asm.o,$(KERNEL_MACHINE_ASM)) \
                   $(patsubst $(KERNEL_MACHINE_PATH_SRC)%.c,$(KERNEL_MACHINE_PATH_OBJ)%_c.o,$(KERNEL_MACHINE_C)) \
                   $(patsubst $(KERNEL_MACHINE_PATH_SRC)%.cpp,$(KERNEL_MACHINE_PATH_OBJ)%_cpp.o,$(KERNEL_MACHINE_CPP))
KERNEL_ARCH_PATH_SRC= $(KERNEL_PATH_SRC)machine/$(MACHINE)/$(ARCH)/
KERNEL_ARCH_PATH_OBJ= $(KERNEL_PATH_OBJ)machine/$(MACHINE)/$(ARCH)/
KERNEL_ARCH_ASM:=$(sort $(wildcard $(KERNEL_ARCH_PATH_SRC)*.asm))
KERNEL_ARCH_C  :=$(sort $(wildcard $(KERNEL_ARCH_PATH_SRC)*.c))
KERNEL_ARCH_CPP:=$(sort $(wildcard $(KERNEL_ARCH_PATH_SRC)*.cpp))
KERNEL_ARCH_H:=$(sort $(wildcard $(KERNEL_ARCH_PATH_SRC)*.h))
KERNEL_ARCH_OBJ:=$(patsubst $(KERNEL_ARCH_PATH_SRC)%.asm,$(KERNEL_ARCH_PATH_OBJ)%_asm.o,$(KERNEL_ARCH_ASM)) \
                   $(patsubst $(KERNEL_ARCH_PATH_SRC)%.c,$(KERNEL_ARCH_PATH_OBJ)%_c.o,$(KERNEL_ARCH_C)) \
                   $(patsubst $(KERNEL_ARCH_PATH_SRC)%.cpp,$(KERNEL_ARCH_PATH_OBJ)%_cpp.o,$(KERNEL_ARCH_CPP))
KERNEL_ALL_OBJ:=$(KERNEL_CORE_OBJ) $(KERNEL_MACHINE_OBJ) $(KERNEL_ARCH_OBJ)
KERNEL_ALL_DEP:=$(patsubst %.o,%.d,$(KERNEL_ALL_OBJ))
KERNEL_BIN=$(KERNEL_PATH_BIN)$(MACHINE)/$(ARCH)/kernel.bin
KERNEL_SYM=$(KERNEL_BIN:.bin=.sym)

-include $(KERNEL_ALL_DEP)

kernel-build: $(KERNEL_BIN)
	@:

kernel-mkdir:
	@mkdir -p $(KERNEL_PATH_BIN) $(KERNEL_PATH_BIN)$(MACHINE)/$(ARCH) \
	          $(KERNEL_PATH_OBJ) $(KERNEL_PATH_OBJ)machine/$(MACHINE)/$(ARCH)

$(KERNEL_BIN): kernel-mkdir $(KERNEL_ALL_OBJ) Makefile
	@echo "[LINK] $@"
	@$(CROSS_LD) $(CROSS_LDFLAGS) \
	  -T $(KERNEL_ARCH_PATH_SRC)kernel.ld \
	  -lgcc \
	  -o $@ \
	  $(KERNEL_ALL_OBJ)
	@$(CROSS_OBJCOPY) --only-keep-debug $@ $(KERNEL_SYM)
	@$(CROSS_OBJCOPY) --strip-debug --strip-unneeded $@
# Kernel core
$(KERNEL_PATH_OBJ)%_asm.o: $(KERNEL_PATH_SRC)%.asm Makefile
	@echo "[AS  ] $<"
	@$(CROSS_AS) $(CROSS_ASFLAGS) -I$(KERNEL_PATH_SRC) -MD $(KERNEL_PATH_OBJ)$*_asm.d -c $< -o $@
$(KERNEL_PATH_OBJ)%_c.o: $(KERNEL_PATH_SRC)%.c Makefile
	@echo "[CC  ] $<"
	@$(CROSS_CC) $(CROSS_CCFLAGS) -I$(KERNEL_PATH_SRC) -I$(KERNEL_MACHINE_PATH_SRC) -MD -MP -c $< -o $@
$(KERNEL_PATH_OBJ)%_cpp.o: $(KERNEL_PATH_SRC)%.cpp Makefile
	@echo "[C++ ] $<"
	@$(CROSS_CXX) $(CROSS_CXXFLAGS) -I$(KERNEL_PATH_SRC) -I$(KERNEL_MACHINE_PATH_SRC) -MD -MP -c $< -o $@
# Kernel machine
$(KERNEL_MACHINE_PATH_OBJ)%_asm.o: $(KERNEL_MACHINE_PATH_SRC)%.asm Makefile
	@echo "[AS  ] $<"
	@$(CROSS_AS) $(CROSS_ASMFLAGS) -I$(KERNEL_MACHINE_PATH_SRC) -MD $(KERNEL_MACHINE_PATH_OBJ)$*_asm.d -c $< -o $@
$(KERNEL_MACHINE_PATH_OBJ)%_c.o: $(KERNEL_MACHINE_PATH_SRC)%.c Makefile
	@echo "[CC  ] $<"
	@$(CROSS_CC) $(CROSS_CCFLAGS) -I$(KERNEL_MACHINE_PATH_SRC) -I$(KERNEL_ARCH_PATH_SRC) -MD -MP -c $< -o $@
$(KERNEL_MACHINE_PATH_OBJ)%_cpp.o: $(KERNEL_MACHINE_PATH_SRC)%.cpp Makefile
	@echo "[C++ ] $<"
	@$(CROSS_CXX) $(CROSS_CXXFLAGS) -I$(KERNEL_MACHINE_PATH_SRC) -I$(KERNEL_ARCH_PATH_SRC) -MD -MP -c $< -o $@
# Kernel machine/arch
$(KERNEL_ARCH_PATH_OBJ)%_asm.o: $(KERNEL_ARCH_PATH_SRC)%.asm Makefile
	@echo "[AS  ] $<"
	@$(CROSS_AS) $(CROSS_ASMFLAGS) -I$(KERNEL_ARCH_PATH_SRC) -MD $(KERNEL_ARCH_PATH_OBJ)$*_asm.d -c $< -o $@
$(KERNEL_ARCH_PATH_OBJ)%_c.o: $(KERNEL_ARCH_PATH_SRC)%.c Makefile
	@echo "[CC  ] $<"
	@$(CROSS_CC) $(CROSS_CCFLAGS) -I$(KERNEL_ARCH_PATH_SRC) -MD -MP -c $< -o $@
$(KERNEL_ARCH_PATH_OBJ)%_cpp.o: $(KERNEL_ARCH_PATH_SRC)%.cpp Makefile
	@echo "[C++ ] $<"
	@$(CROSS_CXX) $(CROSS_CXXFLAGS) -I$(KERNEL_ARCH_PATH_SRC) -MD -MP -c $< -o $@

kernel-lint:
	@echo "[LINT] kernel"
	@cpplint $(CPPLINTFLAGS) --root=src --linelength=120 \
	  --filter=-legal/copyright,-build/include_subdir,-readability/casting \
	  $(KERNEL_CORE_H) $(KERNEL_CORE_C) $(KERNEL_CORE_CPP) \
	  $(KERNEL_MACHINE_H) $(KERNEL_MACHINE_C) $(KERNEL_MACHINE_CPP) \
	  $(KERNEL_ARCH_H) $(KERNEL_ARCH_C) $(KERNEL_ARCH_CPP)

kernel-clean:
	@-rm $(KERNEL_ALL_OBJ) $(KERNEL_ALL_DEP) $(KERNEL_BIN) $(KERNEL_SYM)
