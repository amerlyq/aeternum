O := ./build

NM   := func
BIN  := $(O)/$(NM).bin
SRC  := $(NM).c
OBJS := $(addprefix $(O)/,$(SRC:.c=.o))

CFLAGS := -g -Wall

all: $(BIN)

$(BIN): $(OBJS)
	$(CC) $(CFLAGS) -o $@ $<

$(OBJS): $(SRC)
	@mkdir -p $(O)
	$(CC) $(CFLAGS) -o $@ -c $<

clean:
	rm -rf $(O)
	@# rm -rf $(OBJS) $(BIN)
