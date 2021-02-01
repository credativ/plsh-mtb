PGVERSION ?= 13

EXTENSION = plsh_mtb
PREFIX ?= /usr
EXTDIR ?= ${PREFIX}/share/postgresql/${PGVERSION}/extension
BINDIR ?= ${PREFIX}/bin

install:
	/bin/install -D -m 0644 ${EXTENSION}.control "${EXTDIR}"/${EXTENSION}.control
	/bin/install -D -m 0644 sql/${EXTENSION}--1.0.sql "${EXTDIR}"/${EXTENSION}--1.0.sql
	/bin/install -D -m 0755 src/${EXTENSION}.sh "${BINDIR}"/${EXTENSION}

uninstall:
	rm "${BINDIR}"/${EXTENSION}
	rm "${EXTDIR}"/${EXTENSION}--1.0.sql
	rm "${EXTDIR}"/${EXTENSION}.control

.PHONY: install uninstall
