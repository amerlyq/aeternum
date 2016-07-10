MODNM=test_lkm

ifneq ($(KERNELRELEASE),)
  obj-m := $(MODNM).o
  $(MODNM)-objs := main.o funcs.o
else

# Comment next line to build under native
KDIR := ~/sdk/linux-3.10.28
KDIR ?= /lib/modules/$(shell uname -r)/build
PWD  := $(shell pwd)

.PHONY: all build install clean remove
all: build install clean

build:
	$(MAKE) -C $(KDIR) M=$(PWD) modules

clean:
	mv $(MODNM).ko $(MODNM).ko_
	$(MAKE) -C $(KDIR) M=$(PWD) clean
	mv $(MODNM).ko_ $(MODNM).ko

remove:
	rm -f $(MODNM).ko

endif
