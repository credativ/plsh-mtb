EXTENSION = plsh_mtb
DATA = sql/plsh_mtb--1.0.sql
SCRIPTS = src/plsh_mtb

PG_CONFIG = pg_config
PGXS := $(shell $(PG_CONFIG) --pgxs)
include $(PGXS)
