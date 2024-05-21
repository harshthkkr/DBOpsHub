-- This query displays fragmented indexes

SELECT dbschemas.[name] as 'Schema',
dbtables.[name] as 'Table',
dbindexes.[name] as 'Index',
indexstats.avg_fragmentation_in_percent,
indexstats.page_count * 8 / 1024.0 / 1024 AS IndexSizeGB,
indexstats.page_count
FROM sys.dm_db_index_physical_stats (DB_ID(), NULL, NULL, NULL, NULL) AS indexstats
INNER JOIN sys.tables dbtables on dbtables.[object_id] = indexstats.[object_id]
INNER JOIN sys.schemas dbschemas on dbtables.[schema_id] = dbschemas.[schema_id]
INNER JOIN sys.indexes AS dbindexes ON dbindexes.[object_id] = indexstats.[object_id]
AND indexstats.index_id = dbindexes.index_id
WHERE indexstats.database_id = DB_ID()
and indexstats.page_count > 500
and indexstats.avg_fragmentation_in_percent > 18 --and indexstats.avg_fragmentation_in_percent < 50
and indexstats.index_type_desc <> 'HEAP'
ORDER BY indexstats.page_count desc, indexstats.avg_fragmentation_in_percent desc
