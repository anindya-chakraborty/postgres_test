-- File :        ORA_U02_database_links.sql
--
-- Title :       Health-check data analysis script
--
-- Description : This script will list any database links being used. This is
--               useful as is gives an idea of what integration is in place.
--
--               This SQL file is called by the health-check analysis script
--               "runanalysis.sh" which supplies the SQL*Plus variables.
--
-- Author :      Jerry Alderson
--
-- Date :        30th January 2002
--
-- Version :     @(#) (%full_filespec: ORA_U02_database_links.sql-2:sql:1 %)
--
-- Copyright :   NetCracker Technology Corporation 2012
--
/*
column db_link	format a60
column host	format a200
column DB_LINK  format a40

prompt SCRIPT: ORA_U02_database_links

prompt CHECK: if integration is using database links

SELECT  *
FROM    dba_db_links;




################################################################################
################################################################################
*/


-- File :        U02_database_links.sql
--
-- Title :       Health-check data analysis script
--
-- Description : This script will list any database links being used.
--
-- Author :      Jerry Alderson
--
-- Date :        30th January 2002
--


-- Script: U02_database_links
\t
select 'SCRIPT: U02_database_links' as message;
\t
-- Check if integration is using database links
-- PostgreSQL uses the dblink extension for cross-database connections.
-- List all dblink connections used in the database.

SELECT *
FROM
    pg_catalog.pg_extension
WHERE
    extname = 'dblink';

-- Alternatively, you can check if there are any active connections or foreign data wrappers used:
SELECT *
FROM
    pg_foreign_server;

-- End of script.
