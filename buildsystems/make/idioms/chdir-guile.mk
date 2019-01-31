#!/usr/bin/env -S make --question -f
#%SUMMARY: change CWD without recusion

dst := /tmp

# Create $(dst) directory if it is not exist (just for example)
# $(guile (if (not (access? "$(dst)" F_OK)) (mkdir "$(dst)") ))
$(guile (if (not (file-exists? "$(dst)")) (mkdir "$(dst)") ))

# WARN: must set correct CURDIR before changing directory
#   => after only "chdir" realpath works correctly, but NOT abspath (relative to CURDIR)
# OR: CURDIR := $(shell pwd)
CURDIR := $(realpath $(dst))

$(guile (chdir "$(dst)"))
$(MAKEFILE_LIST): ;

$(info CURDIR = $(CURDIR)     )
$(info    PWD = $(shell pwd)  )
