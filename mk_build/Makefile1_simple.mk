all: func.o
	gcc -g -o func.bin func.o

func.o:
	gcc -g -c func.c

clean:
	rm -rf *.o *.bin
