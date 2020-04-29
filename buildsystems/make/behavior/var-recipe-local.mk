&here = thisdir
immed := empty
var3 = initial
override var4 := fixed
var5 = keepvalue

all: var1 := $(&here)
all: var2 = $(&here)
all: var3 = $(immed)
all: var4 = $(immed)
all: var5 ?= $(immed)
all:
	echo 1=$(var1) 2=$(var2) 3=$(var3) 4=$(var4) 5=$(var5)

&here = wrongdir
immed := different
var3 = final
var5 = changed
