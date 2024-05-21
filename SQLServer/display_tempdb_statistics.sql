-- Display tempdb statistics

-- Tempdb size summary
SELECT instance_name AS 'Database',
[Data File(s) Size (KB)]/1024 AS [Data file (MB)],
[Log File(s) Size (KB)]/1024 AS [Log file (MB)],
[Log File(s) Used Size (KB)]/1024 AS [Log file space used (MB)]
FROM (SELECT * FROM sys.dm_os_performance_counters
WHERE counter_name IN
('Data File(s) Size (KB)',
'Log File(s) Size (KB)',
'Log File(s) Used Size (KB)')
AND instance_name = 'tempdb') AS A
PIVOT
(MAX(cntr_value) FOR counter_name IN
([Data File(s) Size (KB)],
[LOG File(s) Size (KB)],
[Log File(s) Used Size (KB)])) AS B
GO

-- Tempdb properties
SELECT create_date AS [Creation date],
recovery_model_desc [Recovery model]
FROM sys.databases WHERE name = 'tempdb'
GO

-- Tempdb table size statistics
SELECT tb.name AS [Temporary table name],
stt.row_count AS [Number of rows],
stt.used_page_count * 8 AS [Used space (KB)],
stt.reserved_page_count * 8 AS [Reserved space (KB)] FROM tempdb.sys.partitions AS prt
INNER JOIN tempdb.sys.dm_db_partition_stats AS stt
ON prt.partition_id = stt.partition_id
AND prt.partition_number = stt.partition_number
INNER JOIN tempdb.sys.tables AS tb
ON stt.object_id = tb.object_id
ORDER BY stt.reserved_page_count desc,tb.name
