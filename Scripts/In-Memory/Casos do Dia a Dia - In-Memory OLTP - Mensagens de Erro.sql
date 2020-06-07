------------------------------------------------------------------------------------------
-- CRIA DATABASE COM IN-MEMORY
------------------------------------------------------------------------------------------
-- https://www.red-gate.com/simple-talk/sql/sql-development/beginner-guide-to-in-memory-optimized-tables-in-sql-server/

USE master
GO

-- DROP DATABASE Teste

--	CRIA A DATABASE - ALTERAR O CAMINHO para um local existente no seu servidor.
CREATE DATABASE Teste 
	ON  PRIMARY ( 
		NAME = N'Teste', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL14.SQL2017\MSSQL\DATA\Teste.mdf' , 
		SIZE = 102400KB , FILEGROWTH = 102400KB 
	)
	LOG ON ( 
		NAME = N'Teste_log', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL14.SQL2017\MSSQL\DATA\Teste_log.ldf' , 
		SIZE = 30720KB , FILEGROWTH = 30720KB 
	)
GO

-- BASE DE TESTE - Alterar o Recovery Model para SIMPLE
ALTER DATABASE Teste SET RECOVERY SIMPLE

ALTER DATABASE Teste 
SET MEMORY_OPTIMIZED_ELEVATE_TO_SNAPSHOT = ON;

ALTER DATABASE Teste 
ADD FILEGROUP Teste_In_Memory CONTAINS MEMORY_OPTIMIZED_DATA;

ALTER DATABASE Teste 
ADD FILE (
	name='Teste_In_Memory', 
	filename='C:\Program Files\Microsoft SQL Server\MSSQL14.SQL2017\MSSQL\DATA\Teste_In_Memory'
) 
TO FILEGROUP Teste_In_Memory

-- Valida a Configuração da Database
SELECT database_id, name, recovery_model_desc, is_memory_optimized_elevate_to_snapshot_on
FROM sys.databases
where name = 'teste'
	

------------------------------------------------------------------------------------------
-- IN-MEMORY - CREATE TABLE
------------------------------------------------------------------------------------------
USE Teste

IF (OBJECT_ID('InMemorySchemaWithoutIndex') IS NOT NULL)
	DROP TABLE InMemorySchemaWithoutIndex

CREATE TABLE dbo.InMemorySchemaWithoutIndex (
    [ID]   INTEGER   NOT NULL ,--  IDENTITY PRIMARY KEY NONCLUSTERED,
    [Message]   VARCHAR(4000)    NOT NULL
)
WITH
    (MEMORY_OPTIMIZED = ON,
    DURABILITY = SCHEMA_ONLY);

/*
Msg 41327, Level 16, State 7, Line 53
The memory optimized table 'InMemorySchemaWithoutIndex' must have at least one index or a primary key.

Msg 1750, Level 16, State 0, Line 53
Could not create constraint or index. See previous errors.
*/

IF (OBJECT_ID('InMemoryDataWithoutIndex') IS NOT NULL)
	DROP TABLE InMemoryDataWithoutIndex

CREATE TABLE dbo.InMemoryDataWithoutIndex (
    [ID]   INTEGER   NOT NULL ,--  IDENTITY PRIMARY KEY NONCLUSTERED,
    [Message]   VARCHAR(4000)    NOT NULL
)
WITH
    (MEMORY_OPTIMIZED = ON,
    DURABILITY = SCHEMA_AND_DATA);

/*
Msg 41321, Level 16, State 7, Line 72
The memory optimized table 'InMemoryDataWithoutIndex' with DURABILITY=SCHEMA_AND_DATA must have a primary key.

Msg 1750, Level 16, State 0, Line 72
Could not create constraint or index. See previous errors.
*/

GO

USE Traces

IF (OBJECT_ID('DatabaseWithoutInMemory') IS NOT NULL)
	DROP TABLE DatabaseWithoutInMemory

CREATE TABLE dbo.DatabaseWithoutInMemory (
    [ID]   INTEGER   NOT NULL  IDENTITY PRIMARY KEY NONCLUSTERED,
    [Message]   VARCHAR(4000)    NOT NULL
)
WITH
    (MEMORY_OPTIMIZED = ON,
    DURABILITY = SCHEMA_ONLY);

/*
Msg 41337, Level 16, State 100, Line 94
Cannot create memory optimized tables. To create memory optimized tables, the database must have a MEMORY_OPTIMIZED_FILEGROUP that is online and has at least one container.
*/

GO
USE Teste
GO

------------------------------------------------------------------------------------------
-- IN-MEMORY - TRUNCATE TABLE
------------------------------------------------------------------------------------------
-- Tenta excluir todos os registros da tabela
TRUNCATE TABLE InMemoryExample

/*
Msg 10794, Level 16, State 96, Line 116
The statement 'TRUNCATE TABLE' is not supported with memory optimized tables.
*/


------------------------------------------------------------------------------------------
-- IN-MEMORY - ALTER INDEX – REBUILD / COMPRESSION
------------------------------------------------------------------------------------------
IF (OBJECT_ID('InMemoryExampleCompression') IS NOT NULL)
	DROP TABLE InMemoryExampleCompression

CREATE TABLE dbo.InMemoryExampleCompression (
    [ID]   INTEGER   NOT NULL   IDENTITY,
    [Message]   VARCHAR(4000)    NOT NULL,
	CONSTRAINT PK_InMemoryExampleCompression PRIMARY KEY NONCLUSTERED([ID])
)
WITH
    (MEMORY_OPTIMIZED = ON,
    DURABILITY = SCHEMA_AND_DATA);

ALTER INDEX PK_InMemoryExampleCompression ON dbo.InMemoryExampleCompression REBUILD WITH(DATA_COMPRESSION = PAGE)

/*
Msg 10794, Level 16, State 12, Line 140
The operation 'ALTER INDEX' is not supported with memory optimized tables.
*/

ALTER TABLE InMemoryExampleCompression
ALTER INDEX PK_InMemoryExampleCompression REBUILD WITH(DATA_COMPRESSION = PAGE)

/*
Msg 10794, Level 16, State 89, Line 148
The index option 'data_compression' is not supported with indexes on memory optimized tables.
*/


------------------------------------------------------------------------------------------
-- IN-MEMORY - ALTER INDEX – CHECKDB / CHECKTABLE
------------------------------------------------------------------------------------------
DBCC CHECKDB('Teste')

/*
Object ID 50099219 (object 'InMemoryExample'): The operation is not supported with memory optimized tables. This object has been skipped and will not be processed.

CHECKDB found 0 allocation errors and 0 consistency errors in database 'Teste'.
DBCC execution completed. If DBCC printed error messages, contact your system administrator.

*/

DBCC CHECKTABLE ('InMemoryExample')

/*
Msg 5296, Level 16, State 1, Line 169
Object ID 50099219 (object 'InMemoryExample'): The operation is not supported with memory optimized tables. This object has been skipped and will not be processed.
*/


------------------------------------------------------------------------------------------
-- IN-MEMORY - FOREIGN KEY
------------------------------------------------------------------------------------------
IF (OBJECT_ID('InMemoryTable1') IS NOT NULL)
	DROP TABLE InMemoryTable1

CREATE TABLE dbo.InMemoryTable1 (
    [ID_1]   INTEGER   NOT NULL   IDENTITY,
    [Message]   VARCHAR(4000)    NOT NULL,
	CONSTRAINT PK_InMemoryTable1 PRIMARY KEY NONCLUSTERED([ID_1])
)
WITH
    (MEMORY_OPTIMIZED = ON,
    DURABILITY = SCHEMA_AND_DATA);

IF (OBJECT_ID('InMemoryTable2') IS NOT NULL)
	DROP TABLE InMemoryTable2

CREATE TABLE dbo.InMemoryTable2 (
    [ID_2]   INTEGER   NOT NULL   IDENTITY,
	[ID_1]   INTEGER   NOT NULL,
    [Message]   VARCHAR(4000)    NOT NULL,
	CONSTRAINT PK_InMemoryTable2 PRIMARY KEY NONCLUSTERED([ID_2])
)
WITH
    (MEMORY_OPTIMIZED = ON,
    DURABILITY = SCHEMA_AND_DATA);

GO
	
-- CRIANDO A FOREIGN KEY
ALTER TABLE dbo.InMemoryTable2
ADD CONSTRAINT FK_InMemoryTable2
FOREIGN KEY([ID_1])
REFERENCES InMemoryTable1

GO

INSERT INTO dbo.InMemoryTable1
VALUES('TESTE TABELA 1')

SELECT * FROM dbo.InMemoryTable1

INSERT INTO dbo.InMemoryTable2
VALUES(1, 'TESTE TABELA 2')

SELECT * FROM dbo.InMemoryTable2

GO

INSERT INTO dbo.InMemoryTable2
VALUES(2, 'TESTE INCONSISTENTE TABELA 2')

/*
Msg 547, Level 16, State 0, Line 227
The INSERT statement conflicted with the FOREIGN KEY constraint "FK_InMemoryTable2". The conflict occurred in database "Teste", table "dbo.InMemoryTable1", column 'ID_1'.
*/


------------------------------------------------------------------------------------------
-- IN-MEMORY - FOREIGN KEY -> IN-MEMORY x DISK BASED
------------------------------------------------------------------------------------------
-- TABLE DISK-BASED
IF (OBJECT_ID('DiskBasedTable') IS NOT NULL)
	DROP TABLE DiskBasedTable

CREATE TABLE dbo.DiskBasedTable (
    [ID_2]   INTEGER   NOT NULL   IDENTITY,
	[ID_1]   INTEGER   NOT NULL,
    [Message]   VARCHAR(4000)    NOT NULL,
	CONSTRAINT PK_DiskBasedTable PRIMARY KEY NONCLUSTERED([ID_2])
)

GO

-- CRIANDO A FOREIGN KEY
ALTER TABLE dbo.DiskBasedTable
ADD CONSTRAINT FK_DiskBasedTable
FOREIGN KEY([ID_1])
REFERENCES InMemoryTable1

/*
Msg 10778, Level 16, State 0, Line 253
Foreign key relationships between memory optimized tables and non-memory optimized tables are not supported.

Msg 1750, Level 16, State 1, Line 253
Could not create constraint or index. See previous errors.
*/

GO

INSERT INTO dbo.DiskBasedTable
VALUES(666, 'FURANDO A INTEGRIDADE DE DADOS!!!')

SELECT * FROM dbo.InMemoryTable1

SELECT * FROM dbo.DiskBasedTable


------------------------------------------------------------------------------------------
-- IN-MEMORY - INSUFFICIENT MEMORY
------------------------------------------------------------------------------------------
-- AJUSTA O MAX SERVER MEMORY PARA 5 GB APENAS!
EXEC sys.sp_configure N'show advanced options', N'1'  RECONFIGURE WITH OVERRIDE
GO
EXEC sys.sp_configure N'max server memory (MB)', N'5000'
GO
RECONFIGURE WITH OVERRIDE
GO
EXEC sys.sp_configure N'show advanced options', N'0'  RECONFIGURE WITH OVERRIDE
GO

USE Teste

IF(OBJECT_ID('InMemoryExample1') IS NOT NULL)
	DROP TABLE InMemoryExample1

CREATE TABLE dbo.InMemoryExample1 (
    OrderID   INTEGER   NOT NULL   IDENTITY PRIMARY KEY NONCLUSTERED,
    Nome   VARCHAR(4000)    NOT NULL
)
WITH
    (MEMORY_OPTIMIZED = ON,
    DURABILITY = SCHEMA_AND_DATA);
		
-- Insere os dados na tabela In_Memory para utilizar o MEMORYCLERK_XTP
SET NOCOUNT ON

INSERT INTO InMemoryExample1
SELECT TOP 400000
	REPLICATE('A',4000) 
FROM	Master.sys.All_Columns ac1,
		Master.sys.All_Columns ac2,
Master.sys.All_Columns ac3;

GO

-- TOP CLERKS - Ordenado pelo Consumo de Memória
-- SQL Server 2012 version
SELECT TOP(10) [type] as [Memory Clerk Name], SUM(pages_kb)/1024 AS [SPA Memory (MB)]
FROM sys.dm_os_memory_clerks
GROUP BY [type]
ORDER BY SUM(pages_kb) DESC;

-- PLE (Page Life Expectancy)
SELECT cntr_value 
FROM sys.dm_os_performance_counters
WHERE 	
	counter_name = 'Page life expectancy'
	and object_name like '%Buffer Manager%'

GO

IF(OBJECT_ID('InMemoryExample2') IS NOT NULL)
	DROP TABLE InMemoryExample2

CREATE TABLE dbo.InMemoryExample2 (
    OrderID   INTEGER   NOT NULL   IDENTITY PRIMARY KEY NONCLUSTERED,
    Nome   VARCHAR(4000)    NOT NULL
)
WITH
    (MEMORY_OPTIMIZED = ON,
    DURABILITY = SCHEMA_AND_DATA);
		
-- Insere os dados na tabela In_Memory para utilizar o MEMORYCLERK_XTP
SET NOCOUNT ON

INSERT INTO InMemoryExample2
SELECT TOP 300000
	REPLICATE('A',4000) 
FROM	Master.sys.All_Columns ac1,
		Master.sys.All_Columns ac2,
Master.sys.All_Columns ac3;

/*
Msg 701, Level 17, State 137, Line 329
There is insufficient system memory in resource pool 'default' to run this query.
*/

-- EXCLUI AS TABELAS IN-MEMORY
IF(OBJECT_ID('InMemoryExample1') IS NOT NULL)
	DROP TABLE InMemoryExample1

IF(OBJECT_ID('InMemoryExample2') IS NOT NULL)
	DROP TABLE InMemoryExample2

------------------------------------------------------------------------------------------
-- IN-MEMORY - REMOVE FILEGROUP
------------------------------------------------------------------------------------------
-- https://www.sqlpassion.at/archive/2019/03/19/removing-an-in-memory-oltp-file-group/

USE [Teste]
GO
ALTER DATABASE [Teste]  REMOVE FILE [Teste_In_Memory]
GO
ALTER DATABASE [Teste] REMOVE FILEGROUP [Teste_In_Memory]
GO

/*
Msg 41802, Level 16, State 1, Line 151
Cannot drop the last memory-optimized container 'Teste_In_Memory'.

Msg 5042, Level 16, State 8, Line 153
The filegroup 'Teste_In_Memory' cannot be removed because it is not empty.
*/

USE master
GO
DROP DATABASE Teste

/*
Commands completed successfully.
*/