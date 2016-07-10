NM   := func
BIN  := $(NM).bin
SRC  := $(NM).c
OBJS := $(SRC:.c=.o)

CFLAGS := -g

all: $(BIN)

$(BIN): $(OBJS)
	$(CC) $(CFLAGS) -o $(BIN) $(OBJS)

$(OBJS):
	$(CC) $(CFLAGS) -c $(SRC)

clean:
	rm -rf *.o *.bin
