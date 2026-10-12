COMMON_DIR := $(abspath $(dir $(lastword $(MAKEFILE_LIST)))../c)

CC     := gcc
CFLAGS := -O2 -Wall -I$(COMMON_DIR)

SRC        ?= $(wildcard *.c)
COMMON_SRC := $(wildcard $(COMMON_DIR)/*.c)
OBJ        := $(SRC:.c=.o) $(notdir $(COMMON_SRC:.c=.o))
TARGET     := $(notdir $(CURDIR))

vpath %.c $(COMMON_DIR)

.PHONY: all run clean

all: $(TARGET)

$(TARGET): $(OBJ)
	$(CC) $(CFLAGS) -o $@ $^

%.o: %.c
	$(CC) $(CFLAGS) -c -o $@ $<

run: $(TARGET)
	./$(TARGET)

clean:
	$(RM) $(TARGET) $(OBJ)
