-- File :        ORA_E03_archive_logs_defined.sql
--
-- Title :       Health-check data analysis script
--
-- Description : This script will list all of the archive destinations defined
--               and will list any problems.
--
--               This SQL file is called by the health-check analysis script.
--
-- Author :      Jerry Alderson
--
-- Date :        12th November 2001
--
-- Version :     @(#) (%full_filespec: ORA_E03_archive_logs_defined.sql-2:sql:1 %)
--
-- Copyright :   NetCracker Technology Corporation 2012
--

\t
SELECT 'SCRIPT: ORA_E03_archive_logs_defined' as message;
SELECT 'Show archive-related configuration' as message;
\t
SELECT name, setting, unit, category, short_desc
FROM pg_settings
WHERE name LIKE 'archive%';
\t
SELECT 'Show if archiving is enabled' as message;
\t
SELECT
    CASE
        WHEN setting = 'on' THEN 'Archiving is ENABLED'
        ELSE 'Archiving is DISABLED'
    END AS archive_status
FROM pg_settings
WHERE name = 'archive_mode';
\t
SELECT 'Show archive file destination' as message;
\t
SELECT setting FROM pg_settings WHERE name = 'archive_command';
