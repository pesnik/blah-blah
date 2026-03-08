```sh
make full_run              # full pipeline with today's backup filename
make snapshot              # re-snapshot DuckDB only (Postgres already running)
make clean                 # tear down container, keep DuckDB file
make full_run BACKUP_FILE=airflow_postgres_backup_20260308003008.sql.gz  # override specific file
```

```sh
BACKUP_FILE := $(shell ls -1t $(BACKUP_DIR)/airflow_postgres_backup_*.sql.gz 2>/dev/null | head -1 | xargs basename)
```
