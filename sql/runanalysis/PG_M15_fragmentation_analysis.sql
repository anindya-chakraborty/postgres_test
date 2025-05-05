--
-- Title :       Health-check data analysis script
--
-- Description : This script might help identify tables that need to be reorganized.
--
--               This SQL file is called by the health-check analysis script
--               "runanalysis.sh" which supplies the SQL*Plus variables.
--
-- Author :      Andy Coleman
--
-- Date :        27th April 2018
--
-- Version :     @(#) (%full_filespec: ORA_M15_fragmentation_analysis.sql-1:sql:1 %)
--
-- Copyright :   Netcracker Technology Corporation 2018
--

\t
select  'SCRIPT: ORA_M15_fragmentation_analysis' as message;
select 'Bloating estimate' as message;
\t

WITH bloat_info AS (
  SELECT 
    schemaname,
    tablename,
    reltuples::BIGINT AS live_tuples,
    relpages::BIGINT AS total_pages,
    otta::BIGINT AS expected_pages,
	100 * (relpages - otta) / relpages as pct,
    ROUND(100 * (relpages - otta::BIGINT) / relpages, 2) AS bloat_pct,
    (relpages - otta) * 8 / 1024 AS wasted_space_mb
  FROM (
    SELECT
      schemaname,
      tablename,
      reltuples,
      relpages,
      CEIL(reltuples / (block_size / (data_width + 23))) AS otta
    FROM (
      SELECT 
        schemaname, 
        tablename,
        reltuples,
        relpages,
        pg_table_size(schemaname || '.' || tablename) / 8192 AS table_size_pages,
        current_setting('block_size')::NUMERIC AS block_size,
        SUM((CASE WHEN avg_width IS NOT NULL THEN avg_width ELSE 24 END)) AS data_width
      FROM pg_stats
      JOIN pg_class ON tablename = relname
	  where relpages > 0
      GROUP BY schemaname, tablename, reltuples, relpages
    ) AS table_info
  ) AS calc
)
SELECT * FROM bloat_info
ORDER BY bloat_pct DESC
LIMIT 50;

\t
select 'See dead tuple count per table:' as message;
\t

SELECT 
  relname AS table_name,
  n_dead_tup AS dead_tuples,
  n_live_tup AS live_tuples
FROM pg_stat_user_tables
ORDER BY n_dead_tup DESC
LIMIT 50;


\t
select 'Table size vs Index size' as message;
\t

SELECT 
  schemaname, 
  relname AS table_name, 
  pg_size_pretty(pg_total_relation_size(relid)) AS total_size, 
  pg_size_pretty(pg_relation_size(relid)) AS table_size, 
  pg_size_pretty(pg_total_relation_size(relid) - pg_relation_size(relid)) AS index_size
FROM pg_catalog.pg_statio_user_tables
ORDER BY pg_total_relation_size(relid) DESC
LIMIT 50;
