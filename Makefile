CC = gcc
LEX = flex
YACC = bison

CFLAGS = -Wall -Wextra -Wpedantic -std=gnu99
YFLAGS = -d

TARGET = jaci

OBJ = main.o lexer.o parser.o

all: $(TARGET)


# target
$(TARGET): $(OBJ)
	$(CC) $(CFLAGS) -o $@ $^


# object files
main.o: main.c
	$(CC) $(CFLAGS) -c $<

lexer.o: lexer.c
	$(CC) $(CFLAGS) -c $<

parser.o: parser.c
	$(CC) $(CFLAGS) -c $<


# lex/yacc
lexer.c: lexer.l parser.h
	$(LEX) -o $@ $<

parser.c parser.h: parser.y
	$(YACC) $(YFLAGS) $<


# clean
clean:
	rm -f $(TARGET) $(OBJ) lexer.c parser.c parser.h

.PHONY: all clean
