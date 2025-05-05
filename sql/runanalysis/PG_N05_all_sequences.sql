-- File :        ORA_N05_all_sequences.sql
--
-- Title :       Health-check data analysis script
--
-- Description : This script lists all of the non-system sequences/
--
--               This SQL file is called by the health-check analysis script
--               "runanalysis.sh" which supplies the SQL*Plus variables.
--
-- Author :      Andy Coleman
--
-- Date :        19th March 2012
--
-- Version :     %full_filespec: ORA_N05_all_sequences.sql-1:sql:1 %
--
-- Copyright :   NetCracker Technology Corporation 2015
--
/*
prompt SCRIPT: ORA_N05_all_sequences

column SEQUENCE_OWNER  format a20
column SEQUENCE_NAME   format a30
column CYCLE_FLAG      format a10
column ORDER_FLAG      format a10
column INCREMENT_BY    format 999999999999
column CACHE_SIZE      format 9999999999

prompt
prompt WARNINGs: List any non-system database sequence which has
prompt               - a LAST_NUMBER greater than 20% of its MAX_VALUE, or
prompt               - a LAST_NUMBER greater than 20% of 1 billion, or
prompt               - CACHE_SIZE > 1000
prompt

select	SEQUENCE_OWNER,
	SEQUENCE_NAME,
	MIN_VALUE,
	MAX_VALUE,
	INCREMENT_BY,
	CYCLE_FLAG,
	ORDER_FLAG,
	CACHE_SIZE,
	LAST_NUMBER
        from ALL_SEQUENCES
where   SEQUENCE_OWNER not in (&gOracleSpecialUsers)
and	(LAST_NUMBER > 0.2*MAX_VALUE or LAST_NUMBER > 0.2*1000000000)
UNION ALL
select	SEQUENCE_OWNER,
	SEQUENCE_NAME,
	MIN_VALUE,
	MAX_VALUE,
	INCREMENT_BY,
	CYCLE_FLAG,
	ORDER_FLAG,
	CACHE_SIZE,
	LAST_NUMBER
        from ALL_SEQUENCES
where   SEQUENCE_OWNER not in (&gOracleSpecialUsers)
and	CACHE_SIZE > 1000
order by SEQUENCE_OWNER, SEQUENCE_NAME;


prompt
prompt STATS: List all non-system database sequences
prompt        Note that the Oracle monitoring script also captures similar information hourly.
prompt

select	SEQUENCE_OWNER,
	SEQUENCE_NAME,
	MIN_VALUE,
	MAX_VALUE,
	INCREMENT_BY,
	CYCLE_FLAG,
	ORDER_FLAG,
	CACHE_SIZE,
	LAST_NUMBER
        from ALL_SEQUENCES
where   SEQUENCE_OWNER not in (&gOracleSpecialUsers)
order by SEQUENCE_OWNER, SEQUENCE_NAME;

-- End of script.





################################################################################
################################################################################
*/


-- File :        N05_all_sequences.sql
--
-- Title :       Health-check data analysis script
--
-- Description : This script lists all of the non-system sequences.
--
-- Author :      Andy Coleman
--
-- Date :        19th March 2012
--


-- WARNINGs: List any non-system database sequence which has:
--   - a LAST_NUMBER greater than 20% of its MAX_VALUE, or
--   - a LAST_NUMBER greater than 20% of 1 billion, or
--   - CACHE_SIZE > 1000
\t
select 'SCRIPT: N05_all_sequences' as message;
\t

SELECT
    schemaname AS sequence_owner,
    sequencename AS sequence_name,
    min_value,
    max_value,
    increment_by,
    CASE WHEN cycle THEN 'YES' ELSE 'NO' END AS cycle_flag,
    CASE WHEN cycle THEN 'YES' ELSE 'NO' END AS order_flag,
    cache_size,
    last_value AS last_number
FROM
    pg_sequences
WHERE
    schemaname NOT IN ('pg_catalog', 'information_schema')
    AND (last_value > 0.2 * max_value OR last_value > 0.2 * 1000000000)
UNION ALL
SELECT
    schemaname AS sequence_owner,
    sequencename AS sequence_name,
    min_value,
    max_value,
    increment_by,
    CASE WHEN cycle THEN 'YES' ELSE 'NO' END AS cycle_flag,
    CASE WHEN cycle THEN 'YES' ELSE 'NO' END AS order_flag,
    cache_size,
    last_value AS last_number
FROM
    pg_sequences
WHERE
    schemaname NOT IN ('pg_catalog', 'information_schema')
    AND last_value > 1000
ORDER BY
    sequence_owner, sequence_name;

-- List all non-system database sequences
\t
select 'STATS: List all non-system database sequences' as message;
\t

SELECT
    schemaname AS sequence_owner,
    sequencename AS sequence_name,
    min_value,
    max_value,
    increment_by,
    CASE WHEN cycle THEN 'YES' ELSE 'NO' END AS cycle_flag,
    cache_size,
    last_value AS last_number
FROM
    pg_sequences
WHERE
    schemaname NOT IN ('pg_catalog', 'information_schema')
ORDER BY
    sequence_owner, sequence_name;

-- End of script.



