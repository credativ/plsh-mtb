PGVERSION ?= 13

PREFIX ?= /usr
EXTDIR ?= ${PREFIX}/share/postgresql/${PGVERSION}/extension
BINDIR ?= ${PREFIX}/bin

install:
	/bin/install -D -m 0644 sql/plsh-mtb-1.0.sql "${EXTDIR}"/plsh-mtb-1.0.sql
	/bin/install -D -m 0755 src/plsh-mtb.sh "${BINDIR}"/plsh-mtb

uninstall:
	rm "${BINDIR}"/plsh-mtb
	rm "${EXTDIR}"/plsh-mtb-1.0.sql

.PHONY: install uninstall
