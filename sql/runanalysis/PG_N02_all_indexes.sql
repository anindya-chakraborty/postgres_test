-- File :        ORA_N02_all_indexes.sql
--
-- Title :       Health-check data analysis script
--
-- Description : This script lists all of the non-system indexes.
--		 (Information on Geneva/RB indexes is collected during a health
--               check by running the dumpschema.sql script, but this does not capture
--		 the indexes for users other than the owner of the Geneva/RB schema.)
--
--               This SQL file is called by the health-check analysis script
--               "runanalysis.sh" which supplies the SQL*Plus variables.
--
-- Author :      Andy Coleman
--
-- Date :        25th March 2010
--
-- Version :     @(#) (%full_filespec: ORA_N02_all_indexes.sql-1:sql:1 %)
--
-- Copyright :   NetCracker Technology Corporation 2012
--
/*
column comment format a80

prompt SCRIPT: ORA_N02_all_indexes

prompt STATS: List all non-system indexes.

column index_owner      format a20      heading "Index|Owner"
column index_name       format a30      heading "Index|Name"
column table_owner      format a20      heading "Table|Owner"
column table_name       format a30      heading "Table|Name"
column column_position  format 999      heading "Col|Pos"
column column_name      format a30      heading "Column|Name"
column partition_name	format a14
column subpartition_name format a14

select  INDEX_OWNER,
        INDEX_NAME,
	TABLE_OWNER,
        TABLE_NAME,
        COLUMN_POSITION,
        COLUMN_NAME
from    ALL_IND_COLUMNS
where   TABLE_OWNER not in (&gOracleSpecialUsers)
  and     INDEX_NAME NOT LIKE 'SYS%'
order by INDEX_OWNER, INDEX_NAME, COLUMN_POSITION;

prompt STATS: List all non-system function-based indexes (and columns which have default values)

set long 5000
col column_expression heading 'Expression' format a300
column data_default format a300

select	OWNER,
	TABLE_NAME,
	COLUMN_NAME,
	DATA_DEFAULT
from DBA_TAB_COLS
where DATA_DEFAULT is not null
  and OWNER not in (&gOracleSpecialUsers)
order by 1, 2, 3;

select	INDEX_OWNER,
	INDEX_NAME,
	TABLE_NAME,
	COLUMN_POSITION,
	COLUMN_EXPRESSION
from	DBA_IND_EXPRESSIONS
where	TABLE_OWNER not in (&gOracleSpecialUsers)
order by INDEX_OWNER, INDEX_NAME, COLUMN_POSITION;

prompt STATS: List INVISIBLE indexes

SELECT owner, index_name
FROM   dba_indexes
WHERE  VISIBILITY != 'VISIBLE';

prompt STATS: List UNUSABLE indexes

prompt Unusable indexes:

SELECT owner, index_name
FROM   dba_indexes
WHERE  status = 'UNUSABLE';

prompt Unusable index partitions:

SELECT index_owner, index_name, partition_name
FROM   dba_ind_PARTITIONS
WHERE  status = 'UNUSABLE';

prompt Unusable index subpartitions:

SELECT index_owner, index_name, partition_name, subpartition_name
FROM   dba_ind_SUBPARTITIONS
WHERE  status = 'UNUSABLE';


prompt STATS: List INVISIBLE indexes

 
-- End of script.






####################################################
####################################################
*/

-- File :        N02_all_indexes.sql
--
-- Title :       Health-check data analysis script
--
-- Description : This script lists all of the non-system indexes.
--              Information on Geneva/RB indexes is captured during health checks.
--
-- Author :      Andy Coleman
--
-- Date :        25th March 2010
--


-- List all non-system indexes
\t
select 'SCRIPT: N02_all_indexes' as message;
select 'STATS: List all non-system indexes.' as message;
\t

SELECT
    schemaname AS schema,
    tablename AS table,
    indexname AS index_name,
    indexdef AS index_definition
FROM
    pg_indexes
ORDER BY
    schemaname,
    tablename,
    indexname;

-- List all function-based indexes 
\t
select 'STATS: List all non-system function-based indexes' as message;
\t

    SELECT
    n.nspname AS schema,
    t.relname AS table_name,
    i.relname AS index_name,
    pg_get_indexdef(ix.indexrelid) AS index_definition,
    pg_get_expr(ix.indexprs, ix.indrelid) as func_expr
FROM
    pg_index ix
JOIN pg_class i ON i.oid = ix.indexrelid
JOIN pg_class t ON t.oid = ix.indrelid
JOIN pg_namespace n ON n.oid = t.relnamespace
where ix.indexprs is not null
ORDER BY
    n.nspname,
    t.relname,
    i.relname;  

-- List unused indexes
\t
select  'STATS: List unused indexes' as message;
\t

SELECT
    schemaname,
    relname AS table_name,
    indexrelname AS index_name,
    idx_scan,
    pg_size_pretty(pg_relation_size(i.indexrelid)) AS index_size
FROM
    pg_stat_user_indexes ui
JOIN
    pg_index i ON ui.indexrelid = i.indexrelid
WHERE
    idx_scan = 0  -- Index has never been used
    AND NOT indisprimary  -- Exclude primary keys
ORDER BY
    pg_relation_size(i.indexrelid) DESC;



-- End of script.
