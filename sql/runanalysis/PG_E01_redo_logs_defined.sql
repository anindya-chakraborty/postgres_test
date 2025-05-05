-- File :        ORA_E01_redo_logs_defined.sql
--
-- Title :       Health-check data analysis script
--
-- Description:	This script will list information about the redo logs.
--
--		This SQL file is called by the health-check analysis script.
--
--		This script uses V$ rather than GV$ views because V$LOG, for example, contains entries for all nodes in a RAC environment.
--		This is necessary because, even though each node WRITES to a dedicated set of redo logs, a mode may need to READ logs
--		from another node during database recovery.
--
--		So, if there are 3 log file groups per instance and there are 2 instances, V$LOG on any instance will show all 6 logfile
--		groups, not just the 3 "local" ones.  But GV$LOG gets the information from other instances as well, effectively duplicating the
--		information, so will contain 2*6=12 records - which is confusing!  It's much simpler just to select from V$LOG, V$LOGFILE and V$THREAD.
--
-- Author :      Andy Coleman
--
-- Date :        17th December 2014
--
-- Version :     @(#) (%full_filespec: ORA_E01_redo_logs_defined.sql-4:sql:1 %)
--
-- Copyright :   NetCracker Technology Corporation 2012
--

-- Marker
\t
SELECT 'SCRIPT: ORA_E01_redo_logs_defined' as message;

-- PostgreSQL does not have redo logs per se; it uses Write-Ahead Logs (WAL)

-- Check 1: Display current WAL configuration
SELECT 'CHECK: WAL-related settings' as message;
\t
SELECT name, setting, unit, short_desc
FROM pg_settings
WHERE name ~ 'wal'
ORDER BY name;

-- Check 2: Current WAL statistics (if track_wal_io_timing is enabled)
\t
SELECT 'CHECK: WAL activity from pg_stat_bgwriter' as message;
\t
SELECT checkpoints_timed, checkpoints_req, checkpoint_write_time, checkpoint_sync_time, buffers_checkpoint
FROM pg_stat_bgwriter;

-- Check 3: Check if WAL archiving is enabled
\t
SELECT 'CHECK: WAL Archiving Status' as message;
\t
SELECT setting AS archive_mode
FROM pg_settings
WHERE name = 'archive_mode';

-- Check 4: Check for replication slots (used for streaming replication)
\t
SELECT 'CHECK: Replication Slots' as message;
\t
SELECT * FROM pg_replication_slots;

-- Check 5: Check WAL file size
\t
SELECT 'CHECK: WAL Segment Size' as message;
\t
SELECT setting || ' bytes' AS wal_segment_size
FROM pg_settings
WHERE name = 'wal_segment_size';

-- Check 6: Check if synchronous_commit is enabled
\t
SELECT 'CHECK: synchronous_commit setting' as message;
\t
SELECT setting
FROM pg_settings
WHERE name = 'synchronous_commit';

-- End of script.
