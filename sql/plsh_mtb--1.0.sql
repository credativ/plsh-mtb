-- Copyright (c) 2021 Dominik George, credativ GmbH <dominik.george@credativ.de>
-- Copyright (c) 2021 Mathis Rudolf, credativ GmbH <mathis.rudolf@credativ.de>
--
-- Permission to use, copy, modify, and distribute this software and its
-- documentation for any purpose, without fee, and without a written agreement
-- is hereby granted, provided that the above copyright notice and this
-- paragraph and the following two paragraphs appear in all copies.
--
-- IN NO EVENT SHALL THE UNIVERSITY OF CALIFORNIA BE LIABLE TO ANY PARTY FOR
-- DIRECT, INDIRECT, SPECIAL, INCIDENTAL, OR CONSEQUENTIAL DAMAGES, INCLUDING
-- LOST PROFITS, ARISING OUT OF THE USE OF THIS SOFTWARE AND ITS
-- DOCUMENTATION, EVEN IF THE UNIVERSITY OF CALIFORNIA HAS BEEN ADVISED OF THE
-- POSSIBILITY OF SUCH DAMAGE.
--
-- THE UNIVERSITY OF CALIFORNIA SPECIFICALLY DISCLAIMS ANY WARRANTIES,
-- INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY
-- AND FITNESS FOR A PARTICULAR PURPOSE.  THE SOFTWARE PROVIDED HEREUNDER IS
-- ON AN "AS IS" BASIS, AND THE UNIVERSITY OF CALIFORNIA HAS NO OBLIGATIONS TO
-- PROVIDE MAINTENANCE, SUPPORT, UPDATES, ENHANCEMENTS, OR MODIFICATIONS.

CREATE TYPE plsh_mtb_backup_cmd AS ENUM ('start', 'stop', 'abort', 'continue');
CREATE FUNCTION customer_backup(cmd plsh_mtb_backup_cmd) RETURNS text
LANGUAGE plsh
AS $$
#!/bin/sh

PGBINDIR=$(pg_config --bindir)
exec "$PGBINDIR/plsh_mtb" "$cmd"
$$;

CREATE TYPE plsh_mtb_backup_state AS ENUM ('running', 'done', 'aborted', 'failed', 'stopped');
CREATE TABLE plsh_mtb_backups (
    filename text PRIMARY KEY,
    started timestamp NOT NULL,
    ended timestamp,
    state plsh_mtb_backup_state NOT NULL,
    pid integer CHECK (pid > 0),
    CHECK (ended >= started),
    CHECK ((state IN ('running', 'stopped') AND pid IS NOT NULL AND ended IS NULL) OR
          (state NOT IN ('running', 'stopped') AND pid IS NULL AND ended IS NOT NULL))
);
CREATE UNIQUE INDEX ON plsh_mtb_backups (state) WHERE state IN ('running', 'stopped');
REVOKE ALL ON plsh_mtb_backups FROM PUBLIC;
GRANT SELECT ON plsh_mtb_backups TO PUBLIC;
