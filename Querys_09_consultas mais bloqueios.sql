-- Verifica consultas que est�o sendo bloqueadas.

SELECT
Blocking.session_id as BlockingSessionId
, Sess.login_name AS BlockingUser
, BlockingSQL.text AS BlockingSQL
, Waits.wait_type WhyBlocked
, Blocked.session_id AS BlockedSessionId
, USER_NAME(Blocked.user_id) AS BlockedUser
, BlockedSQL.text AS BlockedSQL
, DB_NAME(Blocked.database_id) AS DatabaseName
FROM sys.dm_exec_connections AS Blocking
INNER JOIN sys.dm_exec_requests AS Blocked
ON Blocking.session_id = Blocked.blocking_session_id
INNER JOIN sys.dm_os_waiting_tasks AS Waits
ON Blocked.session_id = Waits.session_id
RIGHT OUTER JOIN sys.dm_exec_sessions Sess
ON Blocking.session_id = sess.session_id
CROSS APPLY sys.dm_exec_sql_text(Blocking.most_recent_sql_handle)
AS BlockingSQL
CROSS APPLY sys.dm_exec_sql_text(Blocked.sql_handle) AS BlockedSQL
ORDER BY BlockingSessionId, BlockedSessionId