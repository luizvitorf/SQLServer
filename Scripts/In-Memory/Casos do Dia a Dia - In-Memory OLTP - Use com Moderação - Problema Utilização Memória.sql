-- https://www.red-gate.com/simple-talk/sql/sql-development/beginner-guide-to-in-memory-optimized-tables-in-sql-server/

USE master
GO

-- DROP DATABASE teste

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
	

-- Agora vamos criar a nossa tabela In-Memory utilizando o DURABILITY = SCHEMA_AND_DATA.
USE Teste

IF(OBJECT_ID('InMemoryExample') IS NOT NULL)
	DROP TABLE InMemoryExample

CREATE TABLE dbo.InMemoryExample (
    OrderID   INTEGER   NOT NULL   IDENTITY PRIMARY KEY NONCLUSTERED,
    Nome   VARCHAR(4000)    NOT NULL
)
WITH
    (MEMORY_OPTIMIZED = ON,
    DURABILITY = SCHEMA_AND_DATA);

-- Verifica as tabelas com in-memory
SELECT * 
FROM sys.tables
WHERE is_memory_optimized = 1


-- OBS: Vou utilizar esses dois SELECTs para validar cada uma das próximas etapas OK.
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


-- Insere os dados na tabela In_Memory para utilizar o MEMORYCLERK_XTP
SET NOCOUNT ON

INSERT INTO InMemoryExample
SELECT TOP 500000
	REPLICATE('A',4000) 
FROM	Master.sys.All_Columns ac1,
		Master.sys.All_Columns ac2,
Master.sys.All_Columns ac3;

EXEC sp_spaceused InMemoryExample

-- Insere os dados na tabela normal para utilizar o MEMORYCLERK_SQLBUFFERPOOL
IF(OBJECT_ID('MemoryPressure') IS NOT NULL)
	DROP TABLE MemoryPressure

SELECT TOP 1000000
	REPLICATE('A',4000) AS Name
INTO MemoryPressure
FROM	Master.sys.All_Columns ac1,
		Master.sys.All_Columns ac2,
Master.sys.All_Columns ac3;

EXEC sp_spaceused MemoryPressure

-- Insere os dados na tabela normal 2 para utilizar o MEMORYCLERK_SQLBUFFERPOOL
IF(OBJECT_ID('MemoryPressure2') IS NOT NULL)
	DROP TABLE MemoryPressure2

SELECT TOP 1000000
	REPLICATE('A',4000) AS Name
INTO MemoryPressure2
FROM	Master.sys.All_Columns ac1,
		Master.sys.All_Columns ac2,
Master.sys.All_Columns ac3;

EXEC sp_spaceused MemoryPressure2

-- Exclui os registos da tabela In-Memory
TRUNCATE TABLE InMemoryExample

/*
Msg 10794, Level 16, State 96, Line 98
The statement 'TRUNCATE TABLE' is not supported with memory optimized tables.
*/

DELETE FROM InMemoryExample

EXEC sp_spaceused InMemoryExample

-- Insere novamente os dados na tabela normal para utilizar o MEMORYCLERK_SQLBUFFERPOOL
IF(OBJECT_ID('MemoryPressure') IS NOT NULL)
	DROP TABLE MemoryPressure

SELECT TOP 1000000
	REPLICATE('A',4000) AS Name
INTO MemoryPressure
FROM	Master.sys.All_Columns ac1,
		Master.sys.All_Columns ac2,
Master.sys.All_Columns ac3;

EXEC sp_spaceused MemoryPressure

-- Insere novamente os dados na tabela normal 2 para utilizar o MEMORYCLERK_SQLBUFFERPOOL
IF(OBJECT_ID('MemoryPressure2') IS NOT NULL)
	DROP TABLE MemoryPressure2

SELECT TOP 1000000
	REPLICATE('A',4000) AS Name
INTO MemoryPressure2
FROM	Master.sys.All_Columns ac1,
		Master.sys.All_Columns ac2,
Master.sys.All_Columns ac3;

EXEC sp_spaceused MemoryPressure2

-- GERA UMA PRESSAO NA MEMORIA
-- Up to 3 minutes to run...
-- 10416MB table size...
USE Teste

IF(OBJECT_ID('MemoryPressure10GB') IS NOT NULL)
	DROP TABLE MemoryPressure10GB

CREATE TABLE MemoryPressure10GB(Col1 CHAR(500));

INSERT INTO MemoryPressure10GB
SELECT TOP 20000000
       CONVERT(CHAR(100), 'Test, fixed data to be used on test') AS Col1
FROM master.dbo.sysobjects A,
     master.dbo.sysobjects B,
     master.dbo.sysobjects C,
     master.dbo.sysobjects D
OPTION (MAXDOP 1);
GO

EXEC sp_spaceused 'MemoryPressure10GB'

-- Exclui a Tabela do In-Memory
DROP TABLE InMemoryExample

-- 2 MINUTOS
-- Executa novamente o INSERT da tabela de 10 GB
USE Teste

IF(OBJECT_ID('MemoryPressure10GB') IS NOT NULL)
	DROP TABLE MemoryPressure10GB

CREATE TABLE MemoryPressure10GB(Col1 CHAR(500));

INSERT INTO MemoryPressure10GB
SELECT TOP 20000000
       CONVERT(CHAR(100), 'Test, fixed data to be used on test') AS Col1
FROM master.dbo.sysobjects A,
     master.dbo.sysobjects B,
     master.dbo.sysobjects C,
     master.dbo.sysobjects D
OPTION (MAXDOP 1);
GO


------------------------------------------------------------------------
-- SOLUCAO PALIATIVA - DATABASE OFFLINE / ONLINE
------------------------------------------------------------------------
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

GO

USE Teste
GO

IF(OBJECT_ID('InMemoryExample') IS NOT NULL)
	DROP TABLE InMemoryExample

CREATE TABLE InMemoryExample (
    OrderID   INTEGER   NOT NULL   IDENTITY PRIMARY KEY NONCLUSTERED,
    Nome   VARCHAR(4000)    NOT NULL
)
WITH
    (MEMORY_OPTIMIZED = ON,
    DURABILITY = SCHEMA_AND_DATA);

-- Insere os dados na tabela In_Memory para utilizar o MEMORYCLERK_XTP
INSERT INTO InMemoryExample
SELECT TOP 500000
	REPLICATE('A',4000) 
FROM	Master.sys.All_Columns ac1,
		Master.sys.All_Columns ac2,
Master.sys.All_Columns ac3;

EXEC sp_spaceused 'InMemoryExample'

-- Exclui os registros da tabela
DELETE InMemoryExample

EXEC sp_spaceused 'InMemoryExample'

GO

USE master
GO

ALTER DATABASE Teste SET OFFLINE WITH ROLLBACK IMMEDIATE

ALTER DATABASE Teste SET ONLINE