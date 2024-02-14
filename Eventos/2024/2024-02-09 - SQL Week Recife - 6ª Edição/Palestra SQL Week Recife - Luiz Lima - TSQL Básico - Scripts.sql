----------------------------------------------------------------------------------
--	Tipos de Dados / Variáveis
----------------------------------------------------------------------------------

-- DATETIME / DATE / TIME
USE Traces

DECLARE @D1 DATETIME, @D2 DATE, @T1 TIME

SELECT 
	@D1 = GETDATE(),
	@D2 = GETDATE(),
	@T1 = GETDATE()

SELECT @D1 AS [DATETIME], @D2 AS [DATE], @T1 AS [TIME]
GO

/*
-- COMANDO "GO"
"GO" is not a Transact-SQL statement; it is a command recognized by the 
sqlcmd and osql utilities and SQL Server Management Studio Code editor.

"GO" signals the end of a batch of Transact-SQL statements to the SQL Server utilities.

https://learn.microsoft.com/en-us/sql/t-sql/language-elements/sql-server-utilities-statements-go?view=sql-server-ver16
*/
SELECT @D1
GO

/*
Msg 137, Level 15, State 2, Line 18
Must declare the scalar variable "@D1".
*/

-- EXEMPLO DE VARIÁVEL DECLARADA E SEM VALOR ATRIBUÍDO = NULL
USE Traces

DECLARE @D1 DATETIME, @D2 DATE, @T1 TIME

--SELECT 
--	@D1 = GETDATE(),
--	@D2 = GETDATE(),
--	@T1 = GETDATE()

SELECT @D1 AS [DATETIME], @D2 AS [DATE], @T1 AS [TIME]
GO

-- TINYINT / INT / BIGINT
USE Traces

DECLARE @IDADE1 TINYINT = 34, @IDADE2 INT = 34, @IDADE3 BIGINT = 34

SELECT @IDADE1 AS [IDADE1], @IDADE2 AS [IDADE2], @IDADE3 AS [IDADE3]

-- FUNÇÃO DATALENGTH = RETORNA O TAMANHO EM BYTES
-- https://learn.microsoft.com/en-us/sql/t-sql/functions/datalength-transact-sql?view=sql-server-ver16
SELECT 
	DATALENGTH(@IDADE1) AS [TAM_IDADE1], 
	DATALENGTH(@IDADE2) AS [TAM_IDADE2], 
	DATALENGTH(@IDADE3) AS [TAM_IDADE3]
GO

-- CHAR e VARCHAR / NCHAR e NVARCHAR
USE Traces

DECLARE 
	@NOME1 CHAR(100)	 = 'Luiz Vitor França Lima',
	@NOME2 VARCHAR(100)  = 'Luiz Vitor França Lima',
	@NOME3 NCHAR(100)	 = 'Luiz Vitor França Lima',
	@NOME4 NVARCHAR(100) = 'Luiz Vitor França Lima'

SELECT @NOME1 AS [NOME1], @NOME2 AS [NOME2], @NOME3 AS [NOME3], @NOME4 AS [NOME4]

-- FUNÇÃO DATALENGTH = RETORNA O TAMANHO EM BYTES
-- https://learn.microsoft.com/en-us/sql/t-sql/functions/datalength-transact-sql?view=sql-server-ver16
SELECT 
	DATALENGTH(@NOME1) AS [TAM_NOME1], 
	DATALENGTH(@NOME2) AS [TAM_NOME2], 
	DATALENGTH(@NOME3) AS [TAM_NOME3],
	DATALENGTH(@NOME4) AS [TAM_NOME4]
GO

DECLARE 
	@NOME1 CHAR(100)	 = 'Luiz Lima',
	@NOME2 VARCHAR(100)  = 'Luiz Lima',
	@NOME3 NCHAR(100)	 = 'Luiz Lima',
	@NOME4 NVARCHAR(100) = 'Luiz Lima'

-- FUNÇÃO DATALENGTH = RETORNA O TAMANHO EM BYTES
-- https://learn.microsoft.com/en-us/sql/t-sql/functions/datalength-transact-sql?view=sql-server-ver16
SELECT 
	DATALENGTH(@NOME1) AS [TAM_NOME1], 
	DATALENGTH(@NOME2) AS [TAM_NOME2], 
	DATALENGTH(@NOME3) AS [TAM_NOME3],
	DATALENGTH(@NOME4) AS [TAM_NOME4]
GO

----------------------------------------------------------------------------------
--	Estrutura de uma Query
----------------------------------------------------------------------------------

-- RETORNA A VERSÃO DO SQL SERVER INSTALADA!
SELECT @@VERSION


/*
Microsoft SQL Server 2019 (RTM) - 15.0.2000.5 (X64)   
Sep 24 2019 13:48:23   Copyright (C) 2019 Microsoft Corporation  
Developer Edition (64-bit) on Windows 10 Pro 10.0 <X64> (Build 19045: ) 
*/

---------------------------------------------------------------------------------------------------------------
--	Processamento de uma Query – Passo a Passo – RESUMO:
---------------------------------------------------------------------------------------------------------------
--	1)    FROM		-> Consulta as linhas da tabela “[Sales].[SalesOrderHeader]”.
--	2)    WHERE		-> Filtra apenas as linhas onde a coluna “SalesPersonID” é igual a 279.
--	3)    GROUP BY	-> Agrupa o resultado anterior pelo ano da venda "YEAR(OrderDate)".
--	4)    HAVING	-> Filtra o resultado anterior (que já está agrupado) para 
--					   retornar apenas o ano que teve mais de 100 vendas "COUNT(*) > 100".
--	5)    SELECT	-> Retorna o ano da venda "YEAR(OrderDate)", a quantidade "COUNT(*)"
--					   e o valor total das vendas "SUM(SubTotal)".
--	6)    ORDER BY	-> Retorna o resultado final ordenado pelo ano da venda "Nr_Ano" de forma crescente.
---------------------------------------------------------------------------------------------------------------

USE AdventureWorks2019

-- QUERY ORIGINAL
SELECT 
	YEAR(OrderDate) AS Nr_Ano, COUNT(*) AS Qt_Vendas, SUM(SubTotal) AS Vl_SubTotal
FROM [Sales].[SalesOrderHeader]
WHERE SalesPersonID = 279
GROUP BY YEAR(OrderDate)
HAVING COUNT(*) > 100
ORDER BY Nr_Ano


--	1) FROM -> Consulta as linhas da tabela “[Sales].[SalesOrderHeader]”.
--	OBS: Validar a quantidade total de linhas na tabela, sem usar nenhum filtro.
--	(31465 rows affected)
SELECT COUNT(*) 
FROM [Sales].[SalesOrderHeader]

EXEC sp_spaceused 'Sales.SalesOrderHeader'


--	2) WHERE -> Filtra apenas as linhas onde a coluna “SalesPersonID” é igual a 279.
--	(429 rows affected)
SELECT *
FROM [Sales].[SalesOrderHeader]
WHERE SalesPersonID = 279


--	3) GROUP BY -> Agrupa o resultado anterior pelo ano da venda "YEAR(OrderDate)".
--	(4 rows affected)
SELECT 
	YEAR(OrderDate) AS Nr_Ano
FROM [Sales].[SalesOrderHeader]
WHERE SalesPersonID = 279
GROUP BY YEAR(OrderDate)

SELECT 
	YEAR(OrderDate) AS Nr_Ano, COUNT(*) AS Qt_Vendas, SUM(SubTotal) AS Vl_SubTotal
FROM [Sales].[SalesOrderHeader]
WHERE SalesPersonID = 279
GROUP BY YEAR(OrderDate)

-- OBS: ERRO SE NÃO AGRUPAR A COLUNA QUE NÃO É UMA FUNÇÃO DE AGREGAÇÃO!
SELECT 
	YEAR(OrderDate) AS Nr_Ano, COUNT(*) AS Qt_Vendas, SUM(SubTotal) AS Vl_SubTotal
FROM [Sales].[SalesOrderHeader]
WHERE SalesPersonID = 279
--GROUP BY YEAR(OrderDate)

/*
Msg 8120, Level 16, State 1, Line 170
Column 'Sales.SalesOrderHeader.OrderDate' is invalid in the select list because it is not 
contained in either an aggregate function or the GROUP BY clause.
*/

--	4) HAVING -> Filtra o resultado anterior (que já está agrupado) para 
--			     retornar apenas o ano que teve mais de 100 vendas "COUNT(*) > 100".
-- (2 rows affected)
SELECT 
	YEAR(OrderDate) AS Nr_Ano, COUNT(*) AS Qt_Vendas, SUM(SubTotal) AS Vl_SubTotal
FROM [Sales].[SalesOrderHeader]
WHERE SalesPersonID = 279
GROUP BY YEAR(OrderDate)
HAVING COUNT(*) > 100


--	5) SELECT -> Retorna o ano da venda "YEAR(OrderDate)", a quantidade "COUNT(*)"
--				 e o valor total das vendas "SUM(SubTotal)".
-- (2 rows affected)
SELECT 
	YEAR(OrderDate) AS Nr_Ano, COUNT(*) AS Qt_Vendas, SUM(SubTotal) AS Vl_SubTotal
FROM [Sales].[SalesOrderHeader]
WHERE SalesPersonID = 279
GROUP BY YEAR(OrderDate)
HAVING COUNT(*) > 100

-- OBS: MOSTRAR ERRO DO FILTRO COM O ALIAS DO SELECT NO GROUP BY!
SELECT 
	YEAR(OrderDate) AS Nr_Ano, COUNT(*) AS Qt_Vendas, SUM(SubTotal) AS Vl_SubTotal
FROM [Sales].[SalesOrderHeader]
WHERE SalesPersonID = 279
--GROUP BY Nr_Ano
GROUP BY YEAR(OrderDate)
HAVING COUNT(*) > 100

/*
Msg 207, Level 16, State 1, Line 206
Invalid column name 'Nr_Ano'.
*/


--	6) ORDER BY -> Retorna o resultado final ordenado pelo ano da venda "Nr_Ano".
--	(6 rows affected)

--	AN0 - CRESCENTE
SELECT 
	YEAR(OrderDate) AS Nr_Ano, COUNT(*) AS Qt_Vendas, SUM(SubTotal) AS Vl_SubTotal
FROM [Sales].[SalesOrderHeader]
WHERE SalesPersonID = 279
GROUP BY YEAR(OrderDate)
HAVING COUNT(*) > 100
ORDER BY Nr_Ano ASC

--	AN0 - DECRESCENTE
SELECT 
	YEAR(OrderDate) AS Nr_Ano, COUNT(*) AS Qt_Vendas, SUM(SubTotal) AS Vl_SubTotal
FROM [Sales].[SalesOrderHeader]
WHERE SalesPersonID = 279
GROUP BY YEAR(OrderDate)
HAVING COUNT(*) > 100
ORDER BY Nr_Ano DESC


--	BÔNUS: Incluindo a média
SELECT 
	YEAR(OrderDate) AS Nr_Ano, 
	COUNT(*) AS Qt_Vendas, 
	SUM(SubTotal) AS Vl_SubTotal, 
	AVG(SubTotal) AS Avg_SubTotal
FROM [Sales].[SalesOrderHeader]
WHERE SalesPersonID = 279
GROUP BY YEAR(OrderDate)
HAVING COUNT(*) > 100
ORDER BY Nr_Ano


----------------------------------------------------------------------------------
--	Joins
----------------------------------------------------------------------------------

/*
TABELAS UTILIZADAS:

[Sales].[Customer]
[Sales].[SalesOrderHeader]
[Sales].[SalesOrderDetail]
[Sales].[SalesTerritory]
[Person].[Person]
*/

-- RETORNA AS VENDAS E OS DETALHES
USE AdventureWorks2019

SELECT TOP 5 *
FROM [Sales].[SalesOrderHeader]

SELECT TOP 5 * 
FROM [Sales].[SalesOrderDetail]

-- VALIDANDO UMA VENDA ESPECÍFICA
SELECT  *
FROM [Sales].[SalesOrderHeader]
WHERE SalesOrderID = 43659

SELECT * 
FROM [Sales].[SalesOrderDetail]
WHERE SalesOrderID = 43659
ORDER BY SalesOrderDetailID

SELECT *
FROM [Sales].[Customer]
WHERE CustomerID = 29825

-- EXECUTAR UM ALT+F1 NA TABELA "[Sales].[Customer]" E MOSTRAR A FOREIGN KEY COM A TABELA "[Person].[Person]"

SELECT *
FROM [Person].[Person]
WHERE BusinessEntityID = 1045


--	OBS: MOSTRAR O "DATABASE DIAGRAMS" E COMENTAR SOBRE AS CONSTRAINTS (PK E FK)

--	RETORNANDO AS VENDAS E O NOME DO CLIENTE
SELECT 
	O.SalesOrderID, 
	O.OrderDate, 
	O.SubTotal, 
	O.CustomerID, 
	P.FirstName, 
	P.LastName
FROM [Sales].[SalesOrderHeader] O
INNER JOIN [Sales].[Customer] C ON O.CustomerID = C.CustomerID
INNER JOIN [Person].[Person] P ON C.PersonID = P.BusinessEntityID


--	OBS: ERRO COMUM - COLUNA AMBIGUA
SELECT 
	O.SalesOrderID, 
	O.OrderDate, 
	O.SubTotal, 
	--CustomerID, 
	 O.CustomerID, 
	P.FirstName, 
	P.LastName
FROM [Sales].[SalesOrderHeader] O
INNER JOIN [Sales].[Customer] C ON O.CustomerID = C.CustomerID
INNER JOIN [Person].[Person] P ON C.PersonID = P.BusinessEntityID

/*
Msg 209, Level 16, State 1, Line 316
Ambiguous column name 'CustomerID'.
*/

--	FILTRANDO UM CLIENTE ESPECÍFICO (Gavin Wood)
SELECT 
	O.SalesOrderID, 
	O.OrderDate, 
	O.SubTotal, 
	O.CustomerID, 
	P.FirstName, 
	P.LastName
FROM [Sales].[SalesOrderHeader] O
INNER JOIN [Sales].[Customer] C ON O.CustomerID = C.CustomerID
INNER JOIN [Person].[Person] P ON C.PersonID = P.BusinessEntityID
WHERE
	O.CustomerID = 16964

-- FILTRANDO CLIENTES QUE O NOME COMEÇA COM "A"
SELECT 
	O.SalesOrderID, 
	O.OrderDate, 
	O.SubTotal, 
	O.CustomerID, 
	P.FirstName, 
	P.LastName
FROM [Sales].[SalesOrderHeader] O
INNER JOIN [Sales].[Customer] C ON O.CustomerID = C.CustomerID
INNER JOIN [Person].[Person] P ON C.PersonID = P.BusinessEntityID
WHERE
	P.FirstName LIKE 'A%'
ORDER BY FirstName

-- FILTRANDO SOMENTE AS VENDAS DE JANEIRO/2013
SELECT 
	O.SalesOrderID, 
	O.OrderDate, 
	O.SubTotal, 
	O.CustomerID, 
	P.FirstName, 
	P.LastName
FROM [Sales].[SalesOrderHeader] O
INNER JOIN [Sales].[Customer] C ON O.CustomerID = C.CustomerID
INNER JOIN [Person].[Person] P ON C.PersonID = P.BusinessEntityID
WHERE
	O.OrderDate >= '20130101'
	AND O.OrderDate < '20130201'
ORDER BY OrderDate


--	EXEMPLO COM LEFT JOIN

--	RETORNAR OS CLIENTES QUE NÃO FIZERAM COMPRAS NO ANO DE 2013
SELECT 	
	C.CustomerID,
	P.FirstName, 
	P.LastName
	--,O.*
FROM [Person].[Person] P
INNER JOIN [Sales].[Customer] C ON C.PersonID = P.BusinessEntityID
LEFT JOIN [Sales].[SalesOrderHeader] O 
	ON  O.CustomerID = C.CustomerID 
		AND O.OrderDate >= '20130101'
		AND O.OrderDate < '20140101'
WHERE	
	O.SalesOrderID IS NULL
ORDER BY P.FirstName

--	VALIDANDO O RESULTADO DO LEFT JOIN
SELECT *
FROM [Sales].[SalesOrderHeader]
WHERE 
	CustomerID IN (20285,20075,17862)
	--AND OrderDate >= '20130101'
	--AND OrderDate < '20140101'