LUALIB_SRC = ..
LUA_CLIB_DIR = ../../clib/cjson

uname_S := $(shell sh -c 'uname -s 2>/dev/null || echo not')
ifeq ($(uname_S), Darwin)
	SHARED = -fPIC
	CFLAGS = -O3 -Wall -pedantic -DNDEBUG 
	CJSON_LDFLAGS = -bundle -undefined dynamic_lookup
else
	SHARED = -fPIC --shared
	CFLAGS = -g -O2 -Wall 	
endif

# lua
LUA_INC ?= ../../../skynet/3rd/lua

# cjson
JSON_DIR = $(LUALIB_SRC)/lua-cjson
JSON_OBJS = $(JSON_DIR)/lua_cjson.o $(JSON_DIR)/strbuf.o $(JSON_DIR)/fpconv.o
JSON_TARGET = $(LUA_CLIB_DIR)/cjson.so


all: $(JSON_TARGET)

.PHONY: all clean

.c.o:
	$(CC) -c $(SHARED) $(CFLAGS) -I$(LUA_INC) $(BUILD_CFLAGS) -o $@ $<

$(JSON_TARGET): $(JSON_OBJS)
ifeq ($(uname_S), Darwin)
	$(CC) $(LDFLAGS) $(CJSON_LDFLAGS) $^ -o $@
else
	$(CC) $(CFLAGS) -I$(LUA_INC) $(SHARED) $^ -o $@
endif
	

clean:
	rm -f $(JSON_DIR)/*.o 
	rm -f $(LUA_CLIB_DIR)/*.so
