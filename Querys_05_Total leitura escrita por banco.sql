SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SELECT SUM(qs.total_logical_reads) AS [Total Reads]
, SUM(qs.total_logical_writes) AS [Total Writes]
, DB_NAME(qt.dbid) AS DatabaseName
FROM sys.dm_exec_query_stats qs
CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) as qt
--WHERE DB_NAME(qt.dbid) = 'STOK_J2EE'
GROUP BY DB_NAME(qt.dbid)