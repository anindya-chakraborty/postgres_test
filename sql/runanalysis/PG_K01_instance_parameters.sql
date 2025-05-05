-- File :        ORA_K01_instance_parameters.sql
--
-- Title :       Health-check data analysis script
--
-- Description : This script will list all of the Oracle instance parameters
--               (using v$system_parameter) plus the current instance setttings,
--               particularly the ArchiveLogMode.
--
--               This SQL file is called by the health-check analysis script.
--
-- Author :      Andy Coleman
--
-- Date :        5 April 2020
--
-- Copyright :   Netcracker Technology Corporation 2020
--

\t
SELECT ' SCRIPT: ORA_K01_instance_parameters' as message;
\t
\t
SELECT ' CHECK: display the date/time when this info was collected' as message;
\t
SELECT 'Parameters at: ' || TO_CHAR(CURRENT_TIMESTAMP, 'DD/MM/YYYY HH24:MI:SS') AS "Comment";

\t
SELECT ' CHECK: display information about the database' as message;
\t
SELECT name AS property_name, setting AS property_value
FROM pg_settings;

SELECT * FROM pg_stat_database;

\t
SELECT ' CHECK: display information about this instance' as message;
\t
SELECT * FROM pg_stat_activity;
SELECT * FROM pg_stat_bgwriter;


\t
SELECT ' CHECK: display the TNS and domain name' as message;
\t
SELECT current_database() AS database_name;


\t
SELECT ' CHECK: display all of the instance parameters' as message;
\t
SELECT name, setting AS value, short_desc AS description
FROM pg_settings
ORDER BY name;
\t
SELECT ' CHECK: display all amended instance parameters' as message;
\t
select * from pg_settings;

SELECT name, setting AS value, short_desc AS description
FROM pg_settings
WHERE setting <> boot_val
ORDER BY name;

\t
SELECT ' CHECK: display values of instance parameters related to memory' as message;
\t
SELECT name, setting
FROM pg_settings
WHERE name LIKE '%cache_size%'
   OR name LIKE '%pool_size%'
   OR name LIKE 'pga_aggregate%'
   OR name IN ('shared_buffers', 'work_mem', 'maintenance_work_mem', 'effective_cache_size')
ORDER BY name;
\t
SELECT ' CHECK: display size information about the SGA for each instance' as message;
\t
SELECT name, setting
FROM pg_settings
WHERE name IN ('shared_buffers', 'work_mem', 'maintenance_work_mem', 'effective_cache_size')
ORDER BY name;


\t
SELECT ' View the open status of each database' as message;
\t
SELECT datname, state
FROM pg_stat_activity
WHERE datname <> 'template1' AND datname <> 'template0';

-- End of script.
