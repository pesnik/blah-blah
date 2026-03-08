INSTALL postgres;
LOAD postgres;
ATTACH 'dbname=airflow host=localhost port=55432 user=airflow password=secret' AS af (TYPE postgres, READ_ONLY);
CREATE OR REPLACE TABLE dag_run       AS SELECT * FROM af.dag_run;
CREATE OR REPLACE TABLE task_instance AS SELECT * FROM af.task_instance;
CREATE OR REPLACE TABLE log           AS SELECT * FROM af.log;
CREATE OR REPLACE TABLE sla_miss      AS SELECT * FROM af.sla_miss;
SHOW TABLES;
