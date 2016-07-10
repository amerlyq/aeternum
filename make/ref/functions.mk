## Functions

# use success result in condition
distro = $(shell grep -isqF $(1) /etc/os-release /etc/lsb-release || echo $$?)
ifeq ($(call distro,arch),)
env-setup:
	pacman -S cmake
endif
