-- File :        N03_all_views.sql
--
-- Title :       Health-check data analysis script
--
-- Description : This script lists all of the non-system views (except those for queues).
--              Information on Geneva/RB views is captured during health checks.
--
-- Author :      Andy Coleman
--
-- Date :        14th September 2011
--

\t
select 'SCRIPT: N03_all_views' as message;
\t

SELECT
    viewowner AS owner,
    viewname AS view_name,
    definition AS text
FROM
    pg_views
WHERE
    schemaname NOT IN ('pg_catalog', 'information_schema')
    AND viewname NOT LIKE 'AQ$%'
ORDER BY
    viewowner, viewname;

-- End of script.
