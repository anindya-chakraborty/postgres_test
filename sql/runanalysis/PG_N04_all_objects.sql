-- File :        ORA_N04_all_objects.sql
--
-- Title :       Health-check data analysis script
--
-- Description : This script lists all of the non-system database objects.
--
--               This SQL file is called by the health-check analysis script
--               "runanalysis.sh" which supplies the SQL*Plus variables.
--
-- Author :      Andy Coleman
--
-- Date :        19th March 2012
--
-- Version :     %full_filespec: ORA_N04_all_objects.sql-1:sql:1 %
--
-- Copyright :   NetCracker Technology Corporation 2012
--
/*
prompt SCRIPT: ORA_N04_all_objects

column owner           format a20
column object_name     format a30
column SUBOBJECT_NAME  format a20

prompt
prompt STATS: List all non-system database objects
prompt

select  OWNER,
	OBJECT_NAME,
	OBJECT_TYPE,
	SUBOBJECT_NAME,
	OBJECT_ID,
	DATA_OBJECT_ID,
	STATUS
        from ALL_OBJECTS
where   OWNER not in (&gOracleSpecialUsers)
order by OWNER, OBJECT_NAME, SUBOBJECT_NAME;

set long 80
-- End of script.




##########################################################
##########################################################
*/


-- File :        N04_all_objects.sql
--
-- Title :       Health-check data analysis script
--
-- Description : This script lists all of the non-system database objects.
--
-- Author :      Andy Coleman
--
-- Date :        19th March 2012
--


-- List all non-system database objects
\t
select 'SCRIPT: N04_all_objects' as message;
\t

SELECT
    nspname AS owner,
    relname AS object_name,
    CASE
        WHEN relkind = 'r' THEN 'table'
        WHEN relkind = 'v' THEN 'view'
        WHEN relkind = 'i' THEN 'index'
        WHEN relkind = 'S' THEN 'sequence'
        WHEN relkind = 't' THEN 'toast'
        ELSE 'other'
    END AS object_type,
    NULL::text AS subobject_name,  -- PostgreSQL does not have subobjects in the same way as Oracle
    pg_class.oid AS object_id,
    NULL::text AS data_object_id,  -- No direct equivalent in PostgreSQL
    CASE
        WHEN relkind IN ('r', 'v', 'i') AND relhastriggers THEN 'active'
        ELSE 'inactive'
    END AS status
FROM
    pg_class pg_class 
    JOIN
     pg_namespace pg_namespace ON pg_class.relnamespace = pg_namespace.oid
WHERE
    nspname NOT IN ('pg_catalog', 'information_schema')
    AND pg_class.relkind IN ('r', 'v', 'i', 'S', 't')
ORDER BY
    nspname, relname;

-- End of script.
