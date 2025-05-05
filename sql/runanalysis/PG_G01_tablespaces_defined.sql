-- File :        ORA_G01_tablespaces_defined.sql
--
-- Title :       Health-check data analysis script
--
-- Description : This script will list all of the tablespaces defined.
--
--               This SQL file is called by the health-check analysis script
--               "runanalysis.sh" which supplies the SQL*Plus variables.
--
-- Author :      Jerry Alderson
--
-- Date :        17th July 2001
--
-- Version :     @(#) (%full_filespec: ORA_G01_tablespaces_defined.sql-5:sql:1 %)
--
-- Copyright :   NetCracker Technology Corporation 2012
--

\t
SELECT 'SCRIPT: ORA_E03_archive_logs_defined' as message;

SELECT ' List all tablespaces defined in PostgreSQL' as message;
\t

SELECT spcname AS tablespace_name
FROM pg_tablespace
ORDER BY tablespace_name;

\t
SELECT ' Check attributes of all tablespaces except TEMP and UNDO (assuming no such categories in PostgreSQL)' as message;
\t

SELECT spcname AS tablespace_name,
       pg_size_pretty(pg_tablespace_size(spcname)) AS size
FROM pg_tablespace
WHERE spcname NOT IN ('pg_default', 'pg_global')  -- pg_default is analogous to SYSTEM
ORDER BY tablespace_name;


\t
SELECT ' List the sizes of non-temporary tablespaces in PostgreSQL' as message;
\t

SELECT spcname AS tablespace_name,
       pg_size_pretty(pg_tablespace_size(spcname)) AS size
FROM pg_tablespace
WHERE spcname NOT IN ('pg_default', 'pg_global')  -- Ignore the system tablespaces
ORDER BY tablespace_name;


\t
SELECT ' Show how much space is used in each permanent tablespace' as message;
\t

SELECT spcname AS tablespace_name,
       pg_size_pretty(pg_tablespace_size(spcname)) AS total_size,
       pg_size_pretty(sum(pg_table_size(c.oid))) AS used_size
FROM pg_tablespace spc
JOIN pg_class c ON c.relnamespace = (SELECT oid FROM pg_namespace WHERE nspname = 'public') -- or your namespace
WHERE spcname NOT IN ('pg_default', 'pg_global')
GROUP BY spcname
ORDER BY spcname;


\t
SELECT ' List the file locations for tablespaces in PostgreSQL' as message;
\t
SELECT spcname AS tablespace_name,
       pg_tablespace_location(spc.oid) AS location
FROM pg_tablespace spc
WHERE spcname NOT IN ('pg_default', 'pg_global')
ORDER BY tablespace_name;



\t
SELECT ' Check I/O statistics in PostgreSQL' as message;
\t
SELECT * FROM pg_stat_bgwriter as message;


\t
SELECT ' List the sizes and utilization of each temporary tablespace' as message;
\t
SELECT spcname AS tablespace_name,
       pg_size_pretty(pg_tablespace_size(spcname)) AS size
FROM pg_tablespace
WHERE spcname LIKE 'pg_temp%'
ORDER BY tablespace_name;


\t
SELECT ' List the data files associated with temporary tablespaces' as message;
\t
SELECT f.relname AS temp_file,
       pg_size_pretty(pg_total_relation_size(f.oid)) AS size
FROM pg_class f
WHERE f.relnamespace = (SELECT oid FROM pg_namespace WHERE nspname = 'pg_temp')
ORDER BY f.relname;







-- End of script.
