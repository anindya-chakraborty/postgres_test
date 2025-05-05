-- File :        ORA_M01_object_storage_analysis.sql
--
-- Title :       Health check data analysis script
--
-- Description : This script will list the storage attributes for each of
--               the objects.
--
--               This SQL file is called by the health-check analysis script
--               "runanalysis.sh" which supplies the SQL*Plus variables.
--
-- Author :      Andy Coleman
--
-- Date :        5 April 2020
--
-- Copyright :   NetCracker Technology Corporation 2020
--

\t
SELECT ' SCRIPT: ORA_M01_object_storage_analysis' as message;

SELECT ' STATS: show how all the segments are managed in each tablespace as message';
\t

SELECT
    n.nspname AS schema_name,
    'TABLE' AS segment_type,
    c.relname AS segment_name,
    c.reltuples AS num_rows,
    c.reloptions AS storage_options
FROM
    pg_class c
JOIN
    pg_namespace n ON n.oid = c.relnamespace
WHERE
    c.relkind = 'r'
    AND n.nspname = 'pg_catalog'
UNION ALL
SELECT
    n.nspname AS schema_name,
    'INDEX' AS segment_type,
    c.relname AS segment_name,
    c.reltuples AS num_rows,
    c.reloptions AS storage_options
FROM
    pg_class c
JOIN
    pg_namespace n ON n.oid = c.relnamespace
WHERE
    c.relkind = 'i'
    AND n.nspname = 'pg_catalog'
ORDER BY
    schema_name, segment_type, segment_name;

\t
SELECT ' STATS: list compressed tables' as message;
\t

SELECT
    t.tablename AS table_name,
    'YES' AS compression
FROM
    pg_tables t
JOIN
    pg_class c ON t.tablename = c.relname
WHERE
    c.reltoastrelid <> 0
    AND t.schemaname = 'pg_catalog';
\t
SELECT ' STATS: list compressed table partitions' as message;
\t
SELECT
    t.tablename AS table_name,
    p.relname AS partition_name
FROM
    pg_tables t
JOIN
    pg_inherits i ON t.tablename = i.inhrelid::regclass::text
JOIN
    pg_class p ON i.inhparent = p.oid
WHERE
    t.schemaname = 'pg_catalog';




-- End of script.

