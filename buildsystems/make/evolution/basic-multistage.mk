#!/usr/bin/make -rRBf
#%SUMMARY: evolution from zero (correct dependencies)
#%
#%NOTE: we use *.o for faster builds
#%  ATT!! use "bash" instead of "make" if you don't need intermediate results "caching" !!
#%
all: ./src/main

./src/main: ./src/minimal.o
	g++ -o ./src/gradual ./src/minimal.o

./src/minimal.o: ./src/minimal.cpp
	g++ -g -c -o ./src/minimal.o ./src/minimal.cpp

clean:
	rm -f ./src/main ./src/minimal.o
