
--Verifica causas do tempo de espera de uma SQL

--o script que eu uso para identificar quais bancos de dados estão usando a maioria das leituras e gravações.

SELECT TOP 10 
        [Total Reads] = SUM(total_logical_reads)
        ,[Execution count] = SUM(qs.execution_count)
        ,DatabaseName = DB_NAME(qt.dbid)
FROM sys.dm_exec_query_stats qs
CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) as qt
GROUP BY DB_NAME(qt.dbid)
ORDER BY [Total Reads] DESC;

SELECT TOP 10 
        [Total Writes] = SUM(total_logical_writes)
        ,[Execution count] = SUM(qs.execution_count)
        ,DatabaseName = DB_NAME(qt.dbid)
FROM sys.dm_exec_query_stats qs
CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) as qt
GROUP BY DB_NAME(qt.dbid)
ORDER BY [Total Writes] DESC;