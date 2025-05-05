-- File :        ORA_S01_bespoke_triggers_defined.sql
--
-- Title :       Health-check data analysis script
--
-- Description : This script will list all of the bespoke triggers defined on
--               the tables used in Geneva which do not have the standard names
--               used in the Geneva product.
--
--               Note: there are no standard trigger rules on Geneva tables,
--               except that they beign TR[DIU][AB] and do not include any
--               punctuation. Many triggers include the name of the table
--               often with a suffix (e.g name, desc, cancel) but this is not
--               always the case.
--
--               This SQL file is called by the health-check analysis script.
--
-- Author :      Jerry Alderson
--
-- Date :        12th November 2001
--
-- Version :     @(#) (%full_filespec: ORA_S01_bespoke_triggers_defined.sql-2:sql:1 %)
--
-- Copyright :   NetCracker Technology Corporation 2012
--
/*
set long 5000

column comment format a80

prompt SCRIPT: ORA_S01_bespoke_triggers_defined

prompt CHECK: list the bespoke triggers defined on the tables used in Geneva which do not have the standard names used in the Geneva product

col TRIGGER_NAME for a40
col TRIGGERING_EVENT for a40
col REFERENCING_NAMES for a33
col WHEN_CLAUSE for a100

select	*
from	all_triggers
where	owner = '%vSchemaOwner'
and    (trigger_name not like 'TRDA%'
and	trigger_name not like 'TRDB%'
and	trigger_name not like 'TRIA%'
and	trigger_name not like 'TRIB%'
and	trigger_name not like 'TRUA%'
and	trigger_name not like 'TRUB%')
or	trigger_name like '%\_%' escape '\'
order by table_name;

set long 80





##########################################################################
##########################################################################
*/


-- File :        S01_bespoke_triggers_defined.sql
--
-- Title :       Health-check data analysis script
--
-- Description : This script will list all of the bespoke triggers defined on
--               the tables used in Geneva which do not have the standard names
--               used in the Geneva product.
--
-- Author :      Jerry Alderson
--
-- Date :        12th November 2001
--


-- List bespoke triggers defined on tables that don't follow standard Geneva names
\t
select 'SCRIPT: S01_bespoke_triggers_defined' as message;
\t

SELECT
    tgname AS trigger_name,
    CASE
        WHEN tgtype::integer & 1 = 1 THEN 'BEFORE'
        WHEN tgtype::integer & 2 = 2 THEN 'AFTER'
        ELSE 'UNKNOWN'
    END AS triggering_event,
    tgargs AS referencing_names,
    tgqual AS when_clause,
    relname AS table_name
FROM
    pg_trigger
    JOIN pg_class ON pg_trigger.tgrelid = pg_class.oid
    JOIN pg_namespace ON pg_class.relnamespace = pg_namespace.oid
WHERE
    pg_namespace.nspname = 'test'  -- Replace with actual schema owner
    AND (
        tgname NOT LIKE 'TRDA%' AND
        tgname NOT LIKE 'TRDB%' AND
        tgname NOT LIKE 'TRIA%' AND
        tgname NOT LIKE 'TRIB%' AND
        tgname NOT LIKE 'TRUA%' AND
        tgname NOT LIKE 'TRUB%' OR
        tgname LIKE '%\_%' 
    )
ORDER BY
    table_name;

-- End of script.
