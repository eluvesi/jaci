CC = gcc
LEX = flex

CFLAGS = -Wall -Wextra -Wpedantic -std=gnu99

TARGET = jaci

OBJ = lexer.o

all: $(TARGET)


# target
$(TARGET): $(OBJ)
	$(CC) $(CFLAGS) -o $@ $^


# object files
lexer.o: lexer.c
	$(CC) $(CFLAGS) -c $<


# lex
lexer.c: lexer.l
	$(LEX) -o $@ $<


# clean
clean:
	rm -f $(TARGET) $(OBJ) lexer.c

.PHONY: all clean
