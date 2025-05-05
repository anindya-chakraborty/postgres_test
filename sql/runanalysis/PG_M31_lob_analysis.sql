-- File :        ORA_M31_lob_analysis.sql
--
-- Title :       Health-check data analysis script
--
-- Description : This script examines the LOBs used by RB.
--
--               This SQL file is called by the health-check analysis script
--               "runanalysis.sh" which supplies the SQL*Plus variables.
--
-- Author :      Andy Coleman
--
-- Date :        25th August 2010
--
-- Version :     %full_filespec: ORA_M31_lob_analysis.sql-1:sql:1 %
--
-- Copyright :   NetCracker Technology Corporation 2012
--
/*
prompt SCRIPT: ORA_M31_lob_analysis

prompt STATS: show information about LOB columns (for non-system LOBs) such as which tablespace stores their data

column OWNER		format a20
column tablespace_name	format a30
column table_name	format a30
column index_name       format a30
column column_name	format a30
column segment_name	format a36
column index_name	format a30
column buffer_pool      format a11
column in_row           format a6
column partitioned	format a11
column securefile	format a10
column segment_created	format a15
column retention_type	format a14

SELECT	a.*,
	d.bytes/1024/1024/1024 Gbytes,
	d.freelists,
	d.freelist_groups,
	d.buffer_pool
FROM	all_lobs a, dba_segments d
WHERE	a.owner not in (&gOracleSpecialUsers)
AND	a.owner = d.owner
AND	a.segment_name = d.segment_name
AND	a.table_name in
	(
		SELECT distinct table_name
		FROM all_tab_columns
		WHERE owner = '&vSchemaOwner'
		AND DATA_TYPE in ('BLOB', 'CLOB', 'NCLOB', 'BFILE')
		AND table_name not like 'PV%'
	)
order by a.owner, a.table_name, a.column_name;

prompt STATS: show information about non-system LOB indexes

SELECT	a.owner,
	a.table_name,
	a.index_name,
	a.index_type,
	a.status,
	a.tablespace_name,
	d.bytes/1024/1024/1024 Gbytes,
	d.freelists,
	d.freelist_groups,
	a.buffer_pool
FROM	all_indexes a, dba_segments d
WHERE	a.owner not in (&gOracleSpecialUsers)
AND	a.owner = d.owner
AND	a.index_name = d.segment_name
AND     d.segment_type = 'LOBINDEX'
AND	a.table_name in
	(
		SELECT distinct table_name
		FROM all_tab_columns
		WHERE owner = '&vSchemaOwner'
		AND DATA_TYPE in ('BLOB', 'CLOB', 'NCLOB', 'BFILE')
		AND table_name not like 'PV%'
	)
AND	a.index_type = 'LOB'
order by a.owner, a.table_name, a.index_name;


-- prompt STATS: there is more information about the BILLDATA.data LOB (and BILLDATA.compressed_data LOB if it exists) in ORA_M16_space_usage.lst

-- End of script.




##############################################################
##############################################################
*/




-- Define the list of system schemas to exclude
\t
SELECT 'SCRIPT: ORA_M31_lob_analysis (PostgreSQL Version)' as message;



-- STATS: show information about LOB columns and their storage
SELECT 'STATS: show information about LOB columns and their storage (non-system schemas)' as message;
\t

SELECT
    n.nspname AS owner,
    c.relname AS table_name,
    a.attname AS column_name,
    pg_tablespace.spcname AS tablespace_name,
    pg_relation_size(c.oid) / 1024 / 1024 / 1024 AS gbytes
FROM
    pg_class c
JOIN
    pg_namespace n ON n.oid = c.relnamespace
JOIN
    pg_attribute a ON a.attrelid = c.oid
JOIN
    pg_type t ON a.atttypid = t.oid
LEFT JOIN
    pg_tablespace ON pg_tablespace.oid = c.reltablespace
WHERE
    a.attnum > 0
    AND NOT a.attisdropped
    AND t.typname IN ('text', 'bytea')
    AND n.nspname NOT IN ('pg_catalog', 'information_schema', 'pg_toast')
    AND c.relname NOT LIKE 'pv%'
ORDER BY
    owner, table_name, column_name;

-- STATS: show information about LOB indexes
\t
SELECT 'STATS: show information about associated TOAST tables and LOB indexes' as message;
\t

SELECT 
    n.nspname AS owner,
    c.relname AS table_name,
    t.relname AS toast_table,
    pg_relation_size(t.oid) / 1024 / 1024 / 1024 AS gbytes
FROM 
    pg_class c
JOIN 
    pg_namespace n ON n.oid = c.relnamespace
JOIN 
    pg_class t ON c.reltoastrelid = t.oid
WHERE 
    n.nspname NOT IN ('pg_catalog', 'information_schema', 'pg_toast')
    AND c.relname NOT LIKE 'pv%'
ORDER BY 
    owner, table_name, toast_table;    

