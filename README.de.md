# PL/SH-MTB

PostgreSQL mandantenfähige Backuplösung basierend auf PL/SH und Korn Shell.

## Konzept
Diese Lösung zielt darauf ab,
dass unpreviligierte Benutzer einer Postgres-Datenbank Backups erstellen, stoppen und abbrechen können,
aber nicht selber wieder herstellen können.

## Installation
Zuerst muss das Repository geklont werden. 
Danach wird in das Verzeichnis gewechselt und installiert.
```
git clone git@github.com:credativ/plsh-mtb.git
cd plsh-mtb
make instal
```
Sobald das erflogreich abgeschlossen wurde,
muss nur noch in der Datenbank der Wahl die Extension installiert werden.

```
CREATE EXTENSION plsh_mtb;
```


## Konfiguration
Die Konfiguration der Extension geschieht über die postgresql.conf.


```
plsh_mtb.dump = 'pg_dump -Z 5 %d -f %f.gz'
plsh_mtb.dir = '/tmp/backups'
plsh_mtb.log = 'syslog'
```
## Verwendung
Benutzern biete diese Extension die Funktion customer\_backup,
welche verwendet wird,
um die Backups zu steuern.
```
SELECT customer_backup(<cmd>);
```
Die möglichen Kommandos für customer\_backup sind:
+ **start**
Beginnt ein Backup
+ **abort**
Bricht das Backup mit dem Status 'running' ab.
+ **stop**
Unterbricht das Backup mit dem Status 'running'.
+ **continue**
Setzt das Backup mit dem Status 'stopped' fort.

Darüberhinaus wird der Status eines Backups in der Tabelle plsh\_mtb\_backups gepflegt
```
SELECT * FROM plsh_mbt_backups
```

Mögliche Status sind:
+ **running**
Markiert aktives Backup.
+ **stopped**
Markiert angehaltenes Backup.
+ **aborted**
Markiert abgebrochenes Backup.
+ **failed**
Markiert gescheitertes Backup
+ **done**
Markiert erfolgreiches Backup.



