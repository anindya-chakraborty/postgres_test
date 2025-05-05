-- File :        ORA_A01_software_installed.sql
--
-- Title :       Health-check data analysis script
-- File :        ORA_A01_software_installed.sql
--
-- Title :       Health-check data analysis script
--
-- Description : This script will identify the software (version and options)
--               used by the Oracle database.
--
--               This SQL file is called by the health-check analysis script.
--
-- Author :      Andy Coleman
--
-- Date :        8th February 2017
--
-- Version :     @(#) (%full_filespec: ORA_A01_software_installed.sql-2:sql:1 %)
--
-- Copyright :   Netcracker Technology Corporation 2017
--

-- Script marker
\t
select 'SCRIPT: ORA_A01_software_installed' as message;
\t

\t
select 'CHECK: list the software installed (versions and options)' as message;
\t
SELECT version();

\t
SELECT 'CHECK: list pg_settings' as message;
\t

SELECT name, setting, unit, sourcefile, short_desc
FROM pg_settings
ORDER BY name;

\t
select 'CHECK: list pg_file_settings' as message;
\t

--SELECT 'CHECK: list pg_file_settings';
SELECT name, setting, sourcefile, applied, error
FROM pg_file_settings
ORDER BY name;

\t
select 'Check 4: List all databases' as message;
\t
SELECT datname, oid
FROM pg_database;
    

