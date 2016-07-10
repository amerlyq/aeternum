O := ./build

NM      := main
BIN     := $(O)/$(NM).bin
SRC_DIR := src
SRC     := $(wildcard $(SRC_DIR)/*.cpp)
OBJS    := $(patsubst $(SRC_DIR)/%.cpp,$(O)/%.o,$(SRC))

CFLAGS := -g -Wall

all: $(BIN)

$(BIN): $(OBJS)
	$(CXX) $(CFLAGS) -o $@ $^

$(O)/%.o: $(SRC_DIR)/%.cpp
	$(CXX) $(CFLAGS) -o $@ -c $<

$(OBJS): | $(O)
$(O):
	@mkdir -p $@

pure:
	rm -rf $(OBJS) $(BIN)

clean:
	rm -rf $(O)
