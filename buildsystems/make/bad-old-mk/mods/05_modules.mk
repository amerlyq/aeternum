O   := ./build
DAT := ./data

NM      := prog
BIN     := $(O)/$(NM).bin
MOD_DIR := src
MODS    := . prog lessons screen
SRC_DIR := $(addprefix $(MOD_DIR)/,$(MODS))
INC_DIR := $(SRC_DIR)
INCS    := $(addprefix -I,$(INC_DIR))
SRC     := $(foreach sdir,$(SRC_DIR),$(wildcard $(sdir)/*.c))
OBJS    := $(patsubst %.c,$(O)/%.o,$(SRC))

LIB_LST := m ncurses GL GLU SDL2 SDL2_image SDL2_ttf SDL2_gfx
LIBS    := $(addprefix -l,$(LIB_LST))
DEFS    := -DUSE_SDL -DUSE_GL # -DUSE_NCURSES

CFLAGS  := -g -Wall

all: $(BIN)

$(BIN): $(OBJS)
	$(CC) -o $@ $^ $(LIBS)

$(O)/%.o: %.c
	@mkdir -p $(@D)
	$(CC) $(CFLAGS) $(INCS) -o $@ -c $<

pure:
	rm -rf $(OBJS) $(BIN)

clean:
	rm -rf $(O)

run:
	@cp -ur -t $(O) $(DAT)
	@$(BIN)
