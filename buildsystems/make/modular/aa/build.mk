--build--: main.bin
--install-bin--: main.bin

vpath %.cpp $(S)
main.o: main.cpp
	g++ -c '$<' -o '$@'

main.bin: main.o
	g++ '$<' -o '$@'
