COMMON_DIR := $(abspath $(dir $(lastword $(MAKEFILE_LIST)))../c)

CC        := gcc
CFLAGS    := -O2 -Wall -I$(COMMON_DIR)
NVCC      := nvcc
NVCCFLAGS := -O2 -arch=sm_75 -I$(COMMON_DIR)

SRC        ?= $(wildcard *.cu)
COMMON_SRC := $(wildcard $(COMMON_DIR)/*.c)
OBJ        := $(SRC:.cu=.o) $(notdir $(COMMON_SRC:.c=.o))
TARGET     := $(notdir $(CURDIR))

vpath %.c $(COMMON_DIR)

.PHONY: all run clean

all: $(TARGET)

$(TARGET): $(OBJ)
	$(NVCC) $(NVCCFLAGS) -o $@ $^

%.o: %.cu
	$(NVCC) $(NVCCFLAGS) -c -o $@ $<

%.o: %.c
	$(CC) $(CFLAGS) -c -o $@ $<

run: $(TARGET)
	./$(TARGET)

clean:
	$(RM) $(TARGET) $(OBJ)
