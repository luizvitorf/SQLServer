-----------------------------------------------------------------------------------------------
-- SQL SERVER – TIPOS DE DADOS:
-----------------------------------------------------------------------------------------------

-----------------------------------------------------------------------------------------------
-- TESTE INT
-----------------------------------------------------------------------------------------------
DECLARE @TESTE_INT_1 INT = 2147483647

SELECT @TESTE_INT_1 AS TESTE_INT_1

GO

DECLARE @TESTE_INT_2 INT = 2147483648

SELECT @TESTE_INT_2 AS TESTE_INT_2

GO


-----------------------------------------------------------------------------------------------
-- TESTE BIGINT
-----------------------------------------------------------------------------------------------
DECLARE @TESTE_BIGINT_1 BIGINT = 2147483648

SELECT @TESTE_BIGINT_1 AS TESTE_BIGINT_1

GO

DECLARE @TESTE_BIGINT_2 BIGINT = 06149776069

SELECT @TESTE_BIGINT_2 AS TESTE_BIGINT_2

GO


-----------------------------------------------------------------------------------------------
-- TESTE CHAR, VARCHAR E NVARCHAR
-----------------------------------------------------------------------------------------------
DECLARE @TESTE_CHAR CHAR(11) = '06149776069'

SELECT @TESTE_CHAR AS TESTE_CHAR, DATALENGTH(@TESTE_CHAR) AS [DATA_SIZE (BYTES)]

GO

DECLARE @TESTE_VARCHAR VARCHAR(11) = '06149776069'

SELECT @TESTE_VARCHAR AS TESTE_VARCHAR, DATALENGTH(@TESTE_VARCHAR) AS [DATA_SIZE (BYTES)]

GO

DECLARE @TESTE_NVARCHAR NVARCHAR(11) = '06149776069'

SELECT @TESTE_NVARCHAR AS TESTE_NVARCHAR, DATALENGTH(@TESTE_NVARCHAR) AS [DATA_SIZE (BYTES)]

GO


-----------------------------------------------------------------------------------------------
-- TESTE - BIGINT x CHAR(11)
-----------------------------------------------------------------------------------------------
DECLARE @TESTE_BIGINT_1 BIGINT = 6149776069

SELECT @TESTE_BIGINT_1 AS TESTE_BIGINT_1, DATALENGTH(@TESTE_BIGINT_1) AS [DATA_SIZE (BYTES)]

GO

DECLARE @TESTE_CHAR CHAR(11) = '06149776069'

SELECT @TESTE_CHAR AS TESTE_CHAR, DATALENGTH(@TESTE_CHAR) AS [DATA_SIZE (BYTES)]


-----------------------------------------------------------------------------------------------
-- SQL SERVER – TESTE DE PERFORMANCE:
-----------------------------------------------------------------------------------------------

-----------------------------------------------------------------------------------------------
-- TESTE PERFORMANCE – CLUSTERED INDEX SCAN
-----------------------------------------------------------------------------------------------
USE Traces

-- CRIA AS TABELAS DE TESTE
CREATE TABLE TESTE_CPF_BIGINT(
	CPF BIGINT
)

CREATE TABLE TESTE_CPF_CHAR(
	CPF CHAR(11)
)

SET NOCOUNT ON

-- POPULA A TABELA COM 1 MILHÃO DE REGISTROS
DECLARE @CPF BIGINT = 11111111111

WHILE(@CPF < 11112111111)
BEGIN
	INSERT INTO TESTE_CPF_BIGINT VALUES (@CPF)
	INSERT INTO TESTE_CPF_CHAR VALUES (@CPF)

	SELECT @CPF += 1
END

GO

-- CRIA INDICES NAS TABELAS PARA MELHORAR O DESEMPENHO
CREATE CLUSTERED INDEX PK_TESTE_CPF_BIGINT
ON TESTE_CPF_BIGINT(CPF)

CREATE CLUSTERED INDEX PK_TESTE_CPF_CHAR
ON TESTE_CPF_CHAR(CPF)

-- COMPARATIVO - TAMANHO TABELAS
EXEC sp_spaceused 'TESTE_CPF_BIGINT'

EXEC sp_spaceused 'TESTE_CPF_CHAR'


-----------------------------------------------------------------------------------------------
-- TESTE PERFORMANCE – CLUSTERED INDEX SCAN
-----------------------------------------------------------------------------------------------
SET STATISTICS IO, TIME ON

IF(OBJECT_ID('TESTE_CPF_BIGINT_PERFORMANCE') IS NOT NULL)
	DROP TABLE TESTE_CPF_BIGINT_PERFORMANCE

SELECT A.CPF
INTO TESTE_CPF_BIGINT_PERFORMANCE
FROM TESTE_CPF_BIGINT A
JOIN TESTE_CPF_BIGINT B ON A.CPF = B.CPF

/*
Table 'TESTE_CPF_BIGINT'. Scan count 10, logical reads 4284

SQL Server Execution Times:
   CPU time = 2093 ms,  elapsed time = 615 ms.
*/

IF(OBJECT_ID('TESTE_CPF_CHAR_PERFORMANCE') IS NOT NULL)
	DROP TABLE TESTE_CPF_CHAR_PERFORMANCE

SELECT A.CPF
INTO TESTE_CPF_CHAR_PERFORMANCE
FROM TESTE_CPF_CHAR A
JOIN TESTE_CPF_CHAR B ON A.CPF = B.CPF

/*
Table 'TESTE_CPF_CHAR'. Scan count 10, logical reads 5034

SQL Server Execution Times:
   CPU time = 2420 ms,  elapsed time = 681 ms.
*/

-----------------------------------------------------------------------------------------------
-- TESTE PERFORMANCE – CLUSTERED INDEX SEEK
-----------------------------------------------------------------------------------------------
SELECT * 
FROM TESTE_CPF_BIGINT
WHERE CPF = 11111121346

/*
Table 'TESTE_CPF_BIGINT'. Scan count 1, logical reads 3

SQL Server Execution Times:
   CPU time = 0 ms,  elapsed time = 0 ms.
*/

SELECT * 
FROM TESTE_CPF_CHAR
WHERE CPF = '11111121346'

/*
Table 'TESTE_CPF_CHAR'. Scan count 1, logical reads 3

SQL Server Execution Times:
   CPU time = 0 ms,  elapsed time = 0 ms.
*/