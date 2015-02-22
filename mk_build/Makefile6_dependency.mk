O       := ./build
DAT     := ./data
MOD_DIR := ./src

NM      := prog
BIN     := $(O)/$(NM).bin
MODS    := . prog lessons screen
SRC_DIR := $(subst /.,,$(addprefix $(MOD_DIR)/,$(MODS)))
INC_DIR := $(SRC_DIR)
INCS    := $(addprefix -I,$(INC_DIR))
SRC     := $(foreach sdir,$(SRC_DIR),$(wildcard $(sdir)/*.cpp))
HDS     := $(foreach sdir,$(SRC_DIR),$(wildcard $(sdir)/*.h))
OBJS    := $(patsubst %.cpp,$(O)/%.o,$(SRC))

LIB_LST := m ncurses GL GLU SDL2 SDL2_image SDL2_ttf SDL2_gfx
LIBS    := $(addprefix -l,$(LIB_LST))
DEFS    := -DUSE_SDL -DUSE_GL # -DUSE_NCURSES

CFLAGS  := -g -Wall -Werror

.PHONY: all pure clean run
all: $(BIN)

$(BIN): $(OBJS)
	$(CXX) -o $@ $^ $(LIBS)

$(O)/%.o: %.cpp
	@mkdir -p $(@D)
	$(CXX) $(CFLAGS) $(INCS) -MMD -o $@ -c $<

pure:
	rm -rf $(OBJS) $(BIN)

clean:
	rm -rf $(O)

run: $(BIN)
	@cp -ur -t $(O) $(DAT)
	@$(BIN)

gdb: $(BIN)
	gdb --args $(BIN)
	@#urxvt -hold -cd "$(PWD)" -e $$SHELL -c "gdb --args $(BIN)" &

-include $(OBJS:.o=.d)
