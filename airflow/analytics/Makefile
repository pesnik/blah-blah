BACKUP_DIR  := db_backup
BACKUP_FILE := $(shell ls -1t $(BACKUP_DIR)/airflow_postgres_backup_*.sql.gz 2>/dev/null | head -1 | xargs basename)
BACKUP_PATH := $(BACKUP_DIR)/$(BACKUP_FILE)

DB_NAME     := airflow
DB_USER     := airflow
DB_PASS     := secret
DB_PORT     := 55432
CONTAINER   := airflow-analytics
PG_IMAGE    := postgres:15.7-alpine
DUCKDB_FILE := airflow_analytics.db
DUCKDB_SQL  := snapshot.sql

.PHONY: setup full_run snapshot clean help

help:
        @echo "Targets:"
        @echo "  setup      - Download and install DuckDB CLI"
        @echo "  full_run   - Full pipeline: restore backup -> snapshot into DuckDB"
        @echo "  snapshot   - Re-snapshot DuckDB from running Postgres (skip restore)"
        @echo "  clean      - Stop and remove Postgres container"

setup:
        curl -L https://github.com/duckdb/duckdb/releases/latest/download/duckdb_cli-linux-amd64.zip \
                -o duckdb.zip && unzip -o duckdb.zip
        chmod +x duckdb

full_run: _pg_start _pg_restore snapshot

_pg_start:
        -docker stop $(CONTAINER) && docker rm $(CONTAINER)
        docker run -d \
                --name $(CONTAINER) \
                -e POSTGRES_PASSWORD=$(DB_PASS) \
                -e POSTGRES_DB=$(DB_NAME) \
                -e POSTGRES_USER=$(DB_USER) \
                -p $(DB_PORT):5432 \
                -v airflow_analytics_data:/var/lib/postgresql/data \
                $(PG_IMAGE)
        @echo "Waiting for Postgres to be ready..."
        @until docker exec $(CONTAINER) pg_isready -U $(DB_USER) -q; do sleep 1; done
        @echo "Postgres is ready."

_pg_restore:
        @echo "Restoring backup: $(BACKUP_PATH)"
        @test -f $(BACKUP_PATH) || (echo "ERROR: Backup not found: $(BACKUP_PATH)" && exit 1)
        gunzip -c $(BACKUP_PATH) | docker exec -i $(CONTAINER) psql -U $(DB_USER) -d $(DB_NAME)
        @echo "Restore complete."

snapshot:
        @echo "Snapshotting Postgres tables into DuckDB: $(DUCKDB_FILE)"
        @printf '%s\n' \
                "INSTALL postgres;" \
                "LOAD postgres;" \
                "ATTACH 'dbname=$(DB_NAME) host=localhost port=$(DB_PORT) user=$(DB_USER) password=$(DB_PASS)' AS af (TYPE postgres, READ_ONLY);" \
                "CREATE OR REPLACE TABLE dag_run       AS SELECT * FROM af.dag_run;" \
                "CREATE OR REPLACE TABLE task_instance AS SELECT * FROM af.task_instance;" \
                "CREATE OR REPLACE TABLE log           AS SELECT * FROM af.log;" \
                "CREATE OR REPLACE TABLE sla_miss      AS SELECT * FROM af.sla_miss;" \
                "SHOW TABLES;" \
                > $(DUCKDB_SQL)
        ./duckdb $(DUCKDB_FILE) < $(DUCKDB_SQL)
        @echo "Snapshot complete. DuckDB is self-contained, Postgres can be stopped."

clean:
        -docker stop $(CONTAINER) && docker rm $(CONTAINER)
        @echo "Container removed. DuckDB file $(DUCKDB_FILE) retained."
