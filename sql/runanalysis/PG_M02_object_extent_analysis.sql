-- File :        ORA_M02_object_extent_analysis.sql
--
-- Title :       Health-check data analysis script
--
-- Description : This script will list the extent allocation for each of
--               the objects.
--
--               This SQL file is called by the health-check analysis script
--               "runanalysis.sh" which supplies the SQL*Plus variables.
--
-- Author :      Jerry Alderson
--
-- Date :        30th January 2002
--
-- Version :     @(#) (%full_filespec: ORA_M02_object_extent_analysis.sql-3:sql:1 %)
--
-- Copyright :   NetCracker Technology Corporation 2012
--



\t
select ' List size (in bytes) for each relation (table, index, etc.)' as message;
\t

SELECT
    n.nspname AS schema_name,
    c.relkind AS segment_type,
    t.spcname AS tablespace_name,
    c.relname AS segment_name,
    pg_table_size(c.oid) AS segment_size_bytes
FROM
    pg_class c
JOIN pg_namespace n ON n.oid = c.relnamespace
LEFT JOIN pg_tablespace t ON t.oid = c.reltablespace
WHERE c.relkind IN ('r', 'i', 't') -- table, index, toast
ORDER BY
    tablespace_name,
    segment_type,
    segment_name;







\t
select ' Simulate "lots of extents" with large size thresholds' as message;
\t
SELECT
    n.nspname AS schema_name,
    c.relkind AS segment_type,
    t.spcname AS tablespace_name,
    c.relname AS segment_name,
    pg_table_size(c.oid) AS size_bytes
FROM
    pg_class c
JOIN pg_namespace n ON n.oid = c.relnamespace
LEFT JOIN pg_tablespace t ON t.oid = c.reltablespace
WHERE pg_table_size(c.oid) > 1000000000  -- larger than ~1GB
ORDER BY
    size_bytes DESC;




\t
select ' For LOB (TOAST) sizes' as message;
\t

SELECT
    reltoast.relname AS toast_table,
    pg_total_relation_size(reltoast.oid) AS total_toast_size_bytes
FROM
    pg_class rel
JOIN pg_namespace n ON n.oid = rel.relnamespace
JOIN pg_class reltoast ON rel.reltoastrelid = reltoast.oid
WHERE
    n.nspname = 'geneva_admin'
    AND rel.relname = 'billdata';




