KDIR := /lib/modules/$(shell uname -r)/build
PWD  := $(shell pwd)

obj-m := hello.o
hello-objs := main.o

build:
	$(MAKE) -C $(KDIR) M=$(PWD) modules

clean:
	$(MAKE) -C $(KDIR) M=$(PWD) clean
