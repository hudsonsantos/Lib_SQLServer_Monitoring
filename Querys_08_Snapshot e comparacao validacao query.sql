SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SELECT sql_handle, plan_handle, total_elapsed_time
, execution_count, statement_start_offset, statement_end_offset
INTO #PreWorkSnapShot
FROM sys.dm_exec_query_stats

/* pode-se colocar uma consulta para verificação da duração da mesma na base
use controle_processo
SELECT * FROM log_documento

*/
use master
SELECT sql_handle, plan_handle, total_elapsed_time
, execution_count, statement_start_offset, statement_end_offset
INTO #PostWorkSnapShot
FROM sys.dm_exec_query_stats

SELECT
p2.total_elapsed_time - ISNULL(p1.total_elapsed_time, 0) AS [Duration]
, SUBSTRING (qt.text,p2.statement_start_offset/2 + 1,
((CASE WHEN p2.statement_end_offset = -1
THEN LEN(CONVERT(NVARCHAR(MAX), qt.text)) * 2
ELSE p2.statement_end_offset
END - p2.statement_start_offset)/2) + 1) AS [Individual Query]
, qt.text AS [Parent Query]
, DB_NAME(qt.dbid) AS DatabaseName
FROM #PreWorkSnapShot p1
RIGHT OUTER JOIN
#PostWorkSnapShot p2 ON p2.sql_handle =
ISNULL(p1.sql_handle, p2.sql_handle)
AND p2.plan_handle = ISNULL(p1.plan_handle, p2.plan_handle)
AND p2.statement_start_offset =
ISNULL(p1.statement_start_offset, p2.statement_start_offset)
AND p2.statement_end_offset =
ISNULL(p1.statement_end_offset, p2.statement_end_offset)
CROSS APPLY sys.dm_exec_sql_text(p2.sql_handle) as qt
WHERE p2.execution_count != ISNULL(p1.execution_count, 0)
ORDER BY [Duration] DESC
DROP TABLE #PreWorkSnapShot
DROP TABLE #PostWorkSnapShot