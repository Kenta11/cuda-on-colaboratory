COMMON_DIR := $(abspath $(dir $(lastword $(MAKEFILE_LIST)))../c)

CC       := gcc
CFLAGS   := -O2 -Wall -I$(COMMON_DIR)
CXX      := g++
CXXFLAGS := -O2 -Wall -I$(COMMON_DIR)

SRC        ?= $(wildcard *.c *.cpp)
COMMON_SRC := $(wildcard $(COMMON_DIR)/*.c)
OBJ        := $(patsubst %.cpp,%.o,$(SRC:.c=.o)) $(notdir $(COMMON_SRC:.c=.o))
TARGET     := $(notdir $(CURDIR))

LD := $(if $(filter %.cpp,$(SRC)),$(CXX),$(CC))

vpath %.c $(COMMON_DIR)

.PHONY: all run clean

all: $(TARGET)

$(TARGET): $(OBJ)
	$(LD) -o $@ $^

%.o: %.c
	$(CC) $(CFLAGS) -c -o $@ $<

%.o: %.cpp
	$(CXX) $(CXXFLAGS) -c -o $@ $<

run: $(TARGET)
	./$(TARGET)

clean:
	$(RM) $(TARGET) $(OBJ)
