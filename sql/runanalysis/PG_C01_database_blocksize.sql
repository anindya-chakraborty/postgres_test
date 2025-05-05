-- File :        ORA_C01_database_blocksize.sql
--
-- Title :       Health-check data analysis script
--
-- Description : This script will identify the block size used by the Oracle
--               database.
--
--               This SQL file is called by the health-check analysis script.
--
-- Author :      Andy Coleman
--
-- Date :        19th January 2015
--
-- Version :     @(#) (%full_filespec: ORA_C01_database_blocksize.sql-5:sql:1 %)
--
-- Copyright :   NetCracker Technology Corporation 2015
--
\t
  SELECT '----------------------------------------' AS message; 
  SELECT 'SCRIPT: ORA_C01_database_blocksize' as message;

   SELECT 'CHECK: List the database block size' as message;
\t

SELECT setting || ' bytes' AS block_size
FROM pg_settings
WHERE name = 'block_size';
