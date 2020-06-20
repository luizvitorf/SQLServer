/*
Referência: https://sqlperformance.com/2012/10/t-sql-queries/sp_prefix
*/

------------------------------------------------------------------------------------------------------
-- 1) Criar uma procedure chamada "sp_teste" apenas na base "master"
------------------------------------------------------------------------------------------------------
USE master

GO
CREATE PROC sp_teste
AS
BEGIN
	SELECT DB_NAME() AS Nm_Database, 'Executei na MASTER!!!' AS Ds_Observacao
END
GO


------------------------------------------------------------------------------------------------------
-- 2) Executar a procedure "sp_teste" nas databases "Traces" e "master"
------------------------------------------------------------------------------------------------------
USE Traces
GO
EXEC sp_teste
GO

/*
Resultado: Executei na MASTER!!!
*/

USE master
GO
EXEC sp_teste
GO

/*
Resultado: Executei na MASTER!!!
*/


------------------------------------------------------------------------------------------------------
-- 3) Criar uma outra procedure com o mesmo nome "sp_teste", mas dessa vez na base "Traces"
------------------------------------------------------------------------------------------------------
USE Traces

GO
CREATE PROC sp_teste
AS
BEGIN
	SELECT DB_NAME() AS Nm_Database, 'Executei na TRACES!!!' AS Ds_Observacao
END
GO


------------------------------------------------------------------------------------------------------
-- 4) Executar a procedure "sp_teste" nas databases "Traces" e "master"
------------------------------------------------------------------------------------------------------
USE Traces
GO
EXEC sp_teste
GO

/*
Resultado: Executei na TRACES!!!
*/

USE master
GO
EXEC sp_teste
GO

/*
Resultado: Executei na MASTER!!!
*/


------------------------------------------------------------------------------------------------------
-- 5) Criar uma outra procedure com o nome "spteste" apenas na database "master"
------------------------------------------------------------------------------------------------------
USE master
GO
CREATE PROC spteste
AS
BEGIN
	SELECT DB_NAME() AS Nm_Database, 'Executei na MASTER!!!' AS Ds_Observacao
END
GO


------------------------------------------------------------------------------------------------------
-- 6) Executar a procedure "spteste" nas databases "Traces" e "master"
------------------------------------------------------------------------------------------------------
USE Traces
GO
EXEC spteste
GO

/*
Msg 2812, Level 16, State 62, Line 100
Could not find stored procedure 'spteste'.
*/

USE master
GO
EXEC spteste
GO

/*
Resultado: Executei na MASTER!!!
*/

/*
Resultado:

Msg 2812, Level 16, State 62, Line 95
Could not find stored procedure 'spteste'.
*/


------------------------------------------------------------------------------------------------------
-- 7) Executar a procedure "sp_teste2" que não existe em nenhuma database
------------------------------------------------------------------------------------------------------
GO
USE Traces
GO
EXEC sp_teste2

/*
Resultado:

Msg 2812, Level 16, State 62, Line 123
Could not find stored procedure 'sp_teste2'.
*/