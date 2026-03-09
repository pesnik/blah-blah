DB_NAME     := airflow
DB_USER     := airflow
DB_PASS     := airflow
DB_PORT     := 5432
CONTAINER   := airflow-timescaledb
NETWORK     := airflow_airflow-cluster-networks
PG_IMAGE    := postgres:15.7-alpine
DUCKDB_IMG  := duckdb/duckdb
DUCKDB_FILE := data/airflow_analytics.db
DUCKDB_SQL  := snapshot.sql

.PHONY: snapshot clean help

help:
	@echo "Targets:"
	@echo "  snapshot   - Snapshot Postgres tables into DuckDB ($(DUCKDB_FILE))"
	@echo "  clean      - Remove DuckDB file and SQL file"

snapshot:
	@mkdir -p data
	@echo "Generating $(DUCKDB_SQL)..."
	@printf '%s\n' \
		"INSTALL postgres;" \
		"LOAD postgres;" \
		"ATTACH 'dbname=$(DB_NAME) host=$(CONTAINER) port=$(DB_PORT) user=$(DB_USER) password=$(DB_PASS)' AS af (TYPE postgres, READ_ONLY);" \
		"CREATE OR REPLACE TABLE dag_run       AS SELECT * FROM af.public.dag_run;" \
		"CREATE OR REPLACE TABLE task_instance AS SELECT * FROM af.public.task_instance;" \
		"CREATE OR REPLACE TABLE log           AS SELECT * FROM af.public.log;" \
		"CREATE OR REPLACE TABLE sla_miss      AS SELECT * FROM af.public.sla_miss;" \
		"SHOW TABLES;" \
		> $(DUCKDB_SQL)
	@echo "Running DuckDB snapshot via Docker..."
	docker run --rm -i \
		--network $(NETWORK) \
		-v ${PWD}:/workspace \
		-w /workspace \
		$(DUCKDB_IMG) \
		$(DUCKDB_FILE) < $(DUCKDB_SQL)
	@echo "Done. $(DUCKDB_FILE) is ready."

clean:
	rm -f $(DUCKDB_SQL) $(DUCKDB_FILE)
	@echo "Cleaned up."
