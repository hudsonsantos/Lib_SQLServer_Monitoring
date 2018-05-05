/* monitor de bloqueios*/

-- começa a rodar as 19:00hs
SET TRANSACTION ISOLATION LEVEL READ
UNCOMMITTED
--WAITFOR TIME  '19:00:00'
GO

PRINT GETDATE()
EXEC master.dbo.dba_BlockTracer
IF @@ROWCOUNT > 0 
BEGIN

SELECT GETDATE() AS TIME
EXEC master.dbo.dba_WhatSQLIsExcecuting
END
WAITFOR DELAY '00:00:15'
GO 50  --roda 500 vezes