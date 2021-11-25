# PL/SH-MTB

Mandantenfähige Backuplösung für PostgreSQL basierend auf PL/SH und Korn Shell.

## Konzept
Diese Lösung zielt darauf ab,
dass unprivilegierte Benutzer einer PostgreSQL-Datenbank Backups erstellen, stoppen und abbrechen können,
aber nicht selber wiederherstellen können. Dabei sollen die Backups unter der Kontrolle des
System-Users des PostgreSQL-Dienstes im Dateisystem auf dem Server selber abgelegt werden.

## Installation

Als Abhängigkeiten muss die Shell `mksh` sowie die PostgreSQL-Erweiterung PL/SH installiert sein.
Auf Debian-basierten Systemen z.B. mit:

```shell
sudo apt install mksh postgresql-13-plsh
```

Danach kann plsh-mtb z.B. direkt aus einem Klon des Git-Repositories installiert werden:

```shell
git clone git@github.com:credativ/plsh-mtb.git
cd plsh-mtb
sudo make install
```

Sobald das erfolgreich abgeschlossen wurde, kann in den entsprechenden Datenbanken
die Extension installiert werden.

```sql
CREATE EXTENSION plsh_mtb;
```


## Konfiguration

Die Konfiguration der Extension geschieht über die `postgresql.conf` (oder über
entsprechende Mechanismen, wie z.B. `ALTER SYSTEM`.

```plain
plsh_mtb.dump = 'pg_dump -Z 5 PGDATABASE -f BACKUPFILE.gz'
plsh_mtb.dir = '/tmp/backups'
plsh_mtb.log = 'syslog'
```

+ plsh\_mtb.dump

    Frei konfigurierbares Dump-Kommando.
    + **PGDATABASE** Platzhalter für den Datenbanknamen.
    + **BACKUPFILE** Platzhalter für den Pfad und Dateinamen des Backups.
+ plsh\_mtb.dir

    Gibt das Verzeichnis an in dem die Backup-Ordner für die Datenbanken angelegt werden.

## Verwendung

### Steuern von Backups

Benutzern bietet diese Extension die Funktion `customer_backup`, welche verwendet wird,
um die Backups zu steuern.

```sql
SELECT customer_backup('<Kommando>')
```

Die möglichen Kommandos als Argument für `customer_backup` sind:
+ **start**
Beginnt ein Backup
+ **abort**
Bricht ein aktuell laufendes Backup ab
+ **stop**
Pausiert ein aktuell laufendes Backup
+ **continue**
Setzt ein pausiertes Backup fort

Darüberhinaus wird der Status aller Backups in der Tabelle `plsh_mtb_backups` gepflegt.

### Backup-Statūs

```sql
test=# SELECT * FROM plsh_mtb_backups;
      filename      |       started       |        ended        |  state  | pid
--------------------+---------------------+---------------------+---------+------
 20210204120523.sql | 2021-02-04 00:05:23 | 2021-02-04 00:05:23 | done    |
 20210204120622.sql | 2021-02-04 00:06:22 | 2021-02-04 00:06:41 | aborted |
 20210204133214.sql | 2021-02-04 13:32:14 | 2021-02-04 13:33:14 | done    |
 20210204133608.sql | 2021-02-04 13:36:08 |                     | running | 6705
(4 Zeilen)

```
#### Spalten:
+ **filename**

    Diese Spalte ist der Name des Backups und wird gleichzeitig als Primärschlüssel verwendet.

+ **started**

    Zeitstempel für den Start des Backups.

+ **ended**

    Zeitstempel für das Ende des Backups.

+ **state**
    
    Diese Spalte zeigt den aktuellen Status eines Backups.
    Mögliche Statūs sind:
    + `running`
    Markiert aktives Backup.
    + `stopped`
    Markiert angehaltenes Backup.
    + `aborted`
    Markiert abgebrochenes Backup.
    + `failed`
    Markiert gescheitertes Backup
    + `done`
    Markiert erfolgreiches Backup.

+ **pid**
    
    Diese spalte zeigt die ID des aktuellen Backup-Prozess
    und wird nur gesetzt für den Status `running` oder `stopped`.
### Rechte-Management

Es können separat Rechte für das Steuern ovn Backups und für das Auslesen von Status
gesetzt werden. Nach der Installation der Extension haben nur Superuser und die Rolle,
die die Datenbank besitzt, alle Rechte. Rechte können vergeben werden mit:

```sql
GRANT SELECT ON plsh_mtb_backups TO '<Rolle>';
GRANT EXECUTE ON customer_backup TO '<Rolle>';
```
