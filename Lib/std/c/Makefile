# Makefile for STDexecDTS.c
# File ID: STDuuidDTS
# Author: Øyvind A. Holm <sunny@sunbase.org>

PREFIX = /usr/local

EXEC = STDexecDTS

CC = cc
LD = cc
CCFLAGS = -Wall -Wextra -Werror -O0 -c -g -ansi -pedantic
CCFLAGS += $$(test -n "$(GCOV)" && \
              echo -n "-fprofile-arcs -ftest-coverage")
LDFLAGS = -Wall -Wextra -Werror
LIBS =
LIBS += $$(test -n "$(GCOV)" && echo "-lgcov --coverage");

OBJS = STDexecDTS.o selftest.o
CFILES = STDexecDTS.c selftest.c
HFILES = STDexecDTS.h
DEPS = $(HFILES) Makefile

.PHONY: all
all: $(EXEC)

$(EXEC): $(OBJS)
	$(LD) -o $(EXEC) $(LDFLAGS) $(OBJS) $(LIBS)

version.h: Gen-version $(CFILES) $(DEPS)
	./Gen-version

STDexecDTS.o: version.h STDexecDTS.c $(DEPS)
	$(CC) $(CCFLAGS) STDexecDTS.c

selftest.o: selftest.c $(DEPS)
	$(CC) $(CCFLAGS) selftest.c

.PHONY: clean
clean:
	rm -f $(EXEC) $(OBJS)
	rm -f *.gcda *.gcno *.gcov
	rm -f version.h
	cd t && $(MAKE) clean

.PHONY: edit
edit: tags
	$(EDITOR) $$(git ls-files)

.PHONY: gcov
gcov:
	$(MAKE) clean test GCOV=1
	gcov $(CFILES)
	@echo $$(grep -E '^ +#####:' *.c.gcov | wc -l) untested lines >&2

.PHONY: gcov-cmt
gcov-cmt: gcov
	gcov-cmt $(CFILES)

.PHONY: gcov-cmt-clean
gcov-cmt-clean:
	gcov-cmt -d $(CFILES)

.PHONY: gdb
gdb: $(EXEC)
	gdb -x gdbrc $$(cat gdbopts 2>/dev/null) $(EXEC)

.PHONY: install
install: $(PREFIX)/bin/$(EXEC)

$(PREFIX)/bin/$(EXEC): $(EXEC)
	install $(EXEC) $(PREFIX)/bin/$(EXEC)

tags: $(CFILES) $(HFILES)
	ctags $(CFILES) $(HFILES)

.PHONY: test
test: $(EXEC)
	cd t && $(MAKE) test

.PHONY: uninstall
uninstall:
	rm -f $(PREFIX)/bin/$(EXEC)

.PHONY: valgrind
valgrind:
	cd t && $(MAKE) valgrind
