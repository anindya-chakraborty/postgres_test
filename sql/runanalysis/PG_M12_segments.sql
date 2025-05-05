-- File :        ORA_M12_segments.sql
--
-- Title :       Health-check data analysis script
--
-- Description : This script will report information about all segments
--
--               This SQL file is called by the health-check analysis script
--               "runanalysis.sh" which supplies the SQL*Plus variables.
--
-- Author :      Andy Coleman
--
-- Date :        28th October 2016
--
-- Version :     @(#) (%full_filespec: ORA_M12_segments.sql-1:sql:1 %)
--
-- Copyright :   NetCracker Technology Corporation 2016
--


\t
select 'SCRIPT: ORA_M12_segments' as message;
\t


-- File : PG_M12_segments.sql
-- Description : PostgreSQL version of Oracle's ORA_M12_segments.sql

\t
select 'Segments owned by non-system users (excluding pg_catalog, information_schema)' as message;
\t

SELECT
    n.nspname AS owner,
    c.relname AS segment_name,
    NULL::text AS partition_name,
    c.relkind AS segment_type,
    pg_tablespace.spcname AS tablespace_name,
    NULL::integer AS header_file,
    NULL::integer AS header_block,
    pg_total_relation_size(c.oid) / 1024 / 1024 / 1024.0 AS gbytes,
    pg_relation_size(c.oid) / current_setting('block_size')::int AS blocks,
    NULL::integer AS extents,
    NULL::integer AS initial_extent,
    NULL::integer AS next_extent,
    NULL::integer AS min_extents,
    NULL::integer AS max_extents,
    NULL::integer AS pct_increase,
    NULL::integer AS freelists,
    NULL::integer AS freelist_groups,
    NULL::integer AS relative_fno,
    NULL::text AS buffer_pool
FROM pg_class c
JOIN pg_namespace n ON c.relnamespace = n.oid
LEFT JOIN pg_tablespace ON c.reltablespace = pg_tablespace.oid
WHERE n.nspname NOT IN ('pg_catalog', 'information_schema', 'pg_toast')
AND c.relkind IN ('r', 'i', 't', 'm') -- table, index, toast, materialized view
ORDER BY 2, 3;

\t
select 'Segments larger than 100MB for a specific schema' as message;
\t


SELECT
    c.relname AS segment_name,
    NULL::text AS partition_name,
    c.relkind AS segment_type,
    pg_total_relation_size(c.oid) / 1024 / 1024 / 1024.0 AS gbytes
FROM pg_class c
JOIN pg_namespace n ON c.relnamespace = n.oid
WHERE pg_total_relation_size(c.oid) / 1024 / 1024 > 100
ORDER BY gbytes DESC, c.relname;


\t
select 'All segments > 1GB (excluding system schemas)' as message;
\t

SELECT
    n.nspname AS owner,
    c.relname AS segment_name,
    c.relkind AS segment_type,
    pg_total_relation_size(c.oid) / 1024 / 1024 / 1024.0 AS gbytes
FROM pg_class c
JOIN pg_namespace n ON c.relnamespace = n.oid
WHERE n.nspname NOT IN ('pg_catalog', 'information_schema', 'pg_toast')
AND pg_total_relation_size(c.oid) / 1024 / 1024 / 1024.0 > 1
ORDER BY gbytes DESC, n.nspname, c.relname;

\t
select 'Tables listed in DATAMANAGEMENTCONTROL > 1GB' as message;
\t

-- This assumes you have a datamanagementcontrol table with similar structure
SELECT
    s.owner,
    s.segment_name,
    s.segment_type,
    s.gbytes,
    CASE WHEN s.segment_type = 'i' THEN '' ELSE dmc.active_boo END AS active_boo,
    CASE
        WHEN dmc.active_boo = 'F' THEN ''
        ELSE TO_CHAR(dmc.last_delete_dat, 'YYYY.MM.DD')
    END AS last_delete_dat
FROM (
    SELECT
        n.nspname AS owner,
        c.relname AS segment_name,
        c.relkind AS segment_type,
        pg_total_relation_size(c.oid) / 1024 / 1024 / 1024.0 AS gbytes
    FROM pg_class c
    JOIN pg_namespace n ON c.relnamespace = n.oid
    WHERE n.nspname NOT IN ('pg_catalog', 'information_schema', 'pg_toast')
    GROUP BY n.nspname, c.relname, c.relkind, c.oid
    HAVING pg_total_relation_size(c.oid) / 1024 / 1024 / 1024.0 > 1
) s
JOIN datamanagementcontrol dmc ON s.segment_name = dmc.table_name_ora
ORDER BY s.gbytes DESC, s.owner, s.segment_name;

\t
select 'Total space per user (schema) > 5GB' as message;
\t

SELECT
    n.nspname AS owner,
    SUM(pg_total_relation_size(c.oid)) / 1024 / 1024 / 1024.0 AS gbytes
FROM pg_class c
JOIN pg_namespace n ON c.relnamespace = n.oid
WHERE n.nspname NOT IN ('pg_catalog', 'information_schema', 'pg_toast')
GROUP BY n.nspname
HAVING SUM(pg_total_relation_size(c.oid)) / 1024 / 1024 / 1024.0 >= 1
ORDER BY gbytes DESC;

\t
select 'Size of system schemas' as message;
\t
SELECT
    SUM(pg_total_relation_size(c.oid)) / 1024 / 1024 / 1024.0 AS sys_gbytes
FROM pg_class c
JOIN pg_namespace n ON c.relnamespace = n.oid
WHERE n.nspname IN ('pg_catalog', 'information_schema', 'pg_toast');
