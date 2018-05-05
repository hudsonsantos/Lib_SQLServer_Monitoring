use master
GO
CREATE PROC [dbo].[dba_BlockTracer]
AS
/*--------------------------------------------------
 
Purpose: Shows details of the root blocking process, together with details of any blocked processed
----------------------------------------------------
Parameters: None.
Revision History:
      19/07/2007   Ian_Stirk@yahoo.com Initial version
Example Usage:
   1. exec YourServerName.master.dbo.dba_BlockTracer
--------------------------------------------------*/

BEGIN

   -- Do not lock anything, and do not get held up by any locks. 
   SET TRANSACTION ISOLATION LEVEL READ 
      UNCOMMITTED

   -- If there are blocked processes...
   IF EXISTS(SELECT 1 FROM sys.sysprocesses WHERE 
      blocked != 0) 
   BEGIN

      -- Identify the root-blocking spid(s)
      SELECT  distinct t1.spid  AS [Root blocking spids]
         , t1.[loginame] AS [Owner]
         , master.dbo.dba_GetSQLForSpid(t1.spid) AS 
            'SQL Text' 
         , t1.[cpu]
         , t1.[physical_io]
         , DatabaseName = DB_NAME(t1.[dbid])
         , t1.[program_name]
         , t1.[hostname]
         , t1.[status]
         , t1.[cmd]
         , t1.[blocked]
         , t1.[ecid] 
      FROM  sys.sysprocesses t1, sys.sysprocesses t2
      WHERE t1.spid = t2.blocked
        AND t1.ecid = t2.ecid
        AND t1.blocked = 0 
      ORDER BY t1.spid, t1.ecid

      -- Identify the spids being blocked.
      SELECT t2.spid AS 'Blocked spid'
         , t2.blocked AS 'Blocked By'
         , t2.[loginame] AS [Owner]
         , master.dbo.dba_GetSQLForSpid(t2.spid) AS 
            'SQL Text' 
         , t2.[cpu]
         , t2.[physical_io]
         , DatabaseName = DB_NAME(t2.[dbid])
         , t2.[program_name]
         , t2.[hostname]
         , t2.[status]
         , t2.[cmd]
         , t2.ecid
      FROM sys.sysprocesses t1, sys.sysprocesses t2 
      WHERE t1.spid = t2.blocked
        AND t1.ecid = t2.ecid
      ORDER BY t2.blocked, t2.spid, t2.ecid
   END

   ELSE -- No blocked processes.
      PRINT 'No processes blocked.' 

END
GO

-- CREATE PROC dba_WhatSQLIsExecuting

CREATE PROC [dbo].[dba_WhatSQLIsExecuting]
AS

BEGIN
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

SELECT [Spid] = session_Id
, ecid
, [Database] = DB_NAME(sp.dbid)
, [User] = nt_username
, [Status] = er.status
, [Wait] = wait_type
, [Individual Query] = SUBSTRING (qt.text,
er.statement_start_offset/2,
(CASE WHEN er.statement_end_offset = -1
THEN LEN(CONVERT(NVARCHAR(MAX), qt.text)) * 2
ELSE er.statement_end_offset END -
er.statement_start_offset)/2)
,[Parent Query] = qt.text
, Program = program_name
, Hostname
, nt_domain
, start_time
FROM sys.dm_exec_requests er
INNER JOIN sys.sysprocesses sp ON er.session_id = sp.spid
CROSS APPLY sys.dm_exec_sql_text(er.sql_handle)as qt
WHERE session_Id > 50
AND session_Id NOT IN (@@SPID)
ORDER BY 1, 2
END


-- CREATE Function [dbo].[dba_GetSQLForSpid]

USE [master]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create Function [dbo].[dba_GetSQLForSpid]
(
   @spid SMALLINT
)
RETURNS NVARCHAR(4000)
BEGIN
   DECLARE @SqlHandle BINARY(20)
   DECLARE @SqlText NVARCHAR(4000)
  -- Get sql_handle for the given spid.
   SELECT @SqlHandle = sql_handle
      FROM sys.sysprocesses WITH (nolock) WHERE
      spid = @spid
   -- Get the SQL text for the given sql_handle.
   SELECT @SqlText = [text] FROM
      sys.dm_exec_sql_text(@SqlHandle)
   RETURN @SqlText
END