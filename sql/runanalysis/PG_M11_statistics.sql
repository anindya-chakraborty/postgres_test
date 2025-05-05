\t
select 'Script : PG_M11_statistics.sql' as message;
select 'Check : Table level statistics' as message;
\t

SELECT
    n.nspname AS owner,
    c.relname AS table_name,
    pg_stat_all_tables.last_analyze::date AS last_analyzed,
    pg_stat_all_tables.n_live_tup AS num_rows,
    pg_relation_size(c.oid) AS table_size_bytes,
    pg_total_relation_size(c.oid) - pg_relation_size(c.oid) AS index_size_bytes
FROM pg_class c
JOIN pg_namespace n ON n.oid = c.relnamespace
LEFT JOIN pg_stat_all_tables ON pg_stat_all_tables.relid = c.oid
WHERE c.relkind = 'r'  -- only tables
AND n.nspname NOT IN ('pg_catalog', 'information_schema')
ORDER BY owner, table_name;


\t
select 'Check : Index statistics' as message;
\t

SELECT
    ns.nspname AS owner,
    t.relname AS table_name,
    i.relname AS index_name,
    ix.indisunique AS is_unique,
    pg_stat_all_indexes.idx_scan,
    pg_relation_size(i.oid) AS index_size_bytes
FROM pg_index ix
JOIN pg_class t ON t.oid = ix.indrelid
JOIN pg_class i ON i.oid = ix.indexrelid
JOIN pg_namespace ns ON ns.oid = t.relnamespace
LEFT JOIN pg_stat_all_indexes ON pg_stat_all_indexes.indexrelid = i.oid
WHERE ns.nspname NOT IN ('pg_catalog', 'information_schema')
ORDER BY owner, table_name, index_name;


\t
select 'Check : Table data shape' as message;
\t

SELECT
    schemaname AS owner,
    tablename AS table_name,
    attname AS column_name,
    null_frac,
    avg_width,
    n_distinct,
    most_common_vals,
    most_common_freqs
FROM pg_stats
WHERE schemaname NOT IN ('pg_catalog', 'information_schema')
ORDER BY owner, table_name, column_name;

