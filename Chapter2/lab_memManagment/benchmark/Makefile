TARGET = bench-malloc-thread
LIBS = -lpthread -L../build/lib -lhack
CC = gcc
CFLAGS = -g -Wall -O2 -std=gnu99 -I../lib/include

.PHONY: default all clean

default: $(TARGET)

all: default

OBJECTS = $(patsubst %.c, %.o, $(wildcard *.c))
HEADERS = $(wildcard *.h)

%.o: %.c $(HEADERS)
	$(CC) $(CFLAGS) -c $< -o $@

.PRECIOUS: $(TARGET) $(OBJECTS)

$(TARGET): $(OBJECTS)
	$(CC) $(OBJECTS) -Wall $(LIBS) -o $@

clean:
	-rm -f *.o
	-rm -f $(TARGET)
