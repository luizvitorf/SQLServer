---------------------------------------------------------------------------
-- DESAFIO
---------------------------------------------------------------------------
USE Traces

CREATE TABLE Teste_Rollback (
	Id INT IDENTITY,
	Data DATETIME
)

GO
CREATE PROCEDURE stpTeste_Rollback
AS
BEGIN	
	INSERT INTO Teste_Rollback
	VALUES(GETDATE())
END
GO

-- TESTE ROLLBACK
EXEC stpTeste_Rollback
 
BEGIN TRAN
	EXEC stpTeste_Rollback

	EXEC stpTeste_Rollback
ROLLBACK

EXEC stpTeste_Rollback

-- RESULTADO
SELECT * FROM Teste_Rollback
GO
/*
A) Vai executar com sucesso e irá retornar 1 linha
B) Vai executar com sucesso e irá retornar 2 linha
C) Vai executar com sucesso e irá retornar 3 linha
D) Vai executar com sucesso e irá retornar 4 linha
E) Vai gerar um erro após o ROLLBACK e não vai retornar nenhuma linha
*/


---------------------------------------------------------------------------
-- EXEMPLOS
---------------------------------------------------------------------------
USE Traces

CREATE TABLE Teste_Rollback_1 (
	Id INT,
	Data DATETIME
)

CREATE TABLE Teste_Rollback_2 (
	Id INT,
	Data DATETIME
)

CREATE TABLE Teste_Rollback_3 (
	Id INT,
	Data DATETIME
)

CREATE TABLE Teste_Rollback_4 (
	Id INT,
	Data DATETIME
)

GO
CREATE PROCEDURE stpTeste_Rollback_4
AS
BEGIN	
	INSERT INTO Teste_Rollback_4
	VALUES(4, GETDATE())
END
GO

CREATE PROCEDURE stpTeste_Rollback_3
AS
BEGIN	
	INSERT INTO Teste_Rollback_3
	VALUES(3, GETDATE())

	EXEC stpTeste_Rollback_4
END
GO

CREATE PROCEDURE stpTeste_Rollback_2
AS
BEGIN	
	INSERT INTO Teste_Rollback_2
	VALUES(2, GETDATE())

	EXEC stpTeste_Rollback_3
END
GO

CREATE PROCEDURE stpTeste_Rollback_1
AS
BEGIN	
	INSERT INTO Teste_Rollback_1
	VALUES(1, GETDATE())

	EXEC stpTeste_Rollback_2
END
GO

---------------------------------------------------------------------------
-- EXEMPLO 1
---------------------------------------------------------------------------
EXEC stpTeste_Rollback_1

/*
(1 row affected)

(1 row affected)

(1 row affected)

(1 row affected)
*/

-- EXEMPLO 1 - RESULTADO
SELECT * FROM Teste_Rollback_1
SELECT * FROM Teste_Rollback_2
SELECT * FROM Teste_Rollback_3
SELECT * FROM Teste_Rollback_4
GO

-- Limpa o Resultado
TRUNCATE TABLE Teste_Rollback_1
TRUNCATE TABLE Teste_Rollback_2
TRUNCATE TABLE Teste_Rollback_3
TRUNCATE TABLE Teste_Rollback_4
GO


---------------------------------------------------------------------------
-- EXEMPLO 2
---------------------------------------------------------------------------
GO
ALTER PROCEDURE stpTeste_Rollback_4
AS
BEGIN	
	INSERT INTO Teste_Rollback_4
	VALUES(4, GETDATE())

	SELECT 1/0
END
GO

EXEC stpTeste_Rollback_1

/*
(1 row affected)

(1 row affected)

(1 row affected)

(1 row affected)

Msg 8134, Level 16, State 1, Procedure stpTeste_Rollback_4, Line 7 [Batch Start Line 150]
Divide by zero error encountered.
*/

-- EXEMPLO 2 - RESULTADO
SELECT * FROM Teste_Rollback_1
SELECT * FROM Teste_Rollback_2
SELECT * FROM Teste_Rollback_3
SELECT * FROM Teste_Rollback_4
GO

-- Limpa o Resultado
TRUNCATE TABLE Teste_Rollback_1
TRUNCATE TABLE Teste_Rollback_2
TRUNCATE TABLE Teste_Rollback_3
TRUNCATE TABLE Teste_Rollback_4
GO


---------------------------------------------------------------------------
-- EXEMPLO 3
---------------------------------------------------------------------------
GO
ALTER PROCEDURE stpTeste_Rollback_4
AS
BEGIN
	BEGIN TRAN
		INSERT INTO Teste_Rollback_4
		VALUES(1, GETDATE())

		SELECT 1/0

	IF(@@ERROR = 0)
		COMMIT
	ELSE
		ROLLBACK
END
GO

EXEC stpTeste_Rollback_1

/*
(1 row affected)

(1 row affected)

(1 row affected)

(1 row affected)

Msg 8134, Level 16, State 1, Procedure stpTeste_Rollback_4, Line 7 [Batch Start Line 200]
Divide by zero error encountered.
*/

-- EXEMPLO 3 - RESULTADO
SELECT * FROM Teste_Rollback_1
SELECT * FROM Teste_Rollback_2
SELECT * FROM Teste_Rollback_3
SELECT * FROM Teste_Rollback_4
GO

-- Limpa o Resultado
TRUNCATE TABLE Teste_Rollback_1
TRUNCATE TABLE Teste_Rollback_2
TRUNCATE TABLE Teste_Rollback_3
TRUNCATE TABLE Teste_Rollback_4
GO


---------------------------------------------------------------------------
-- EXEMPLO 4
---------------------------------------------------------------------------
GO
ALTER PROCEDURE stpTeste_Rollback_4
AS
BEGIN
	INSERT INTO Teste_Rollback_4
	VALUES(1, GETDATE())

	SELECT 1/0
END

GO
ALTER PROCEDURE stpTeste_Rollback_3
AS
BEGIN
	BEGIN TRAN
		INSERT INTO Teste_Rollback_3
		VALUES(3, GETDATE())

		EXEC stpTeste_Rollback_4

	IF(@@ERROR = 0)
		COMMIT
	ELSE
		ROLLBACK	
END
GO

-- TESTE 4 - EXECUTA AS PROCEDURES
EXEC stpTeste_Rollback_1

/*
(1 row affected)

(1 row affected)

(1 row affected)

(1 row affected)

Msg 8134, Level 16, State 1, Procedure stpTeste_Rollback_4, Line 7 [Batch Start Line 261]
Divide by zero error encountered.
*/

-- Valida o Resultado Final
SELECT * FROM Teste_Rollback_1
SELECT * FROM Teste_Rollback_2
SELECT * FROM Teste_Rollback_3
SELECT * FROM Teste_Rollback_4
GO

-- Limpa o Resultado
TRUNCATE TABLE Teste_Rollback_1
TRUNCATE TABLE Teste_Rollback_2
TRUNCATE TABLE Teste_Rollback_3
TRUNCATE TABLE Teste_Rollback_4
GO


---------------------------------------------------------------------------
-- EXEMPLO 5
---------------------------------------------------------------------------
GO
ALTER PROCEDURE stpTeste_Rollback_3
AS
BEGIN
	INSERT INTO Teste_Rollback_3
	VALUES(3, GETDATE())

	EXEC stpTeste_Rollback_4
END

GO
ALTER PROCEDURE stpTeste_Rollback_1
AS
BEGIN
	BEGIN TRAN
		INSERT INTO Teste_Rollback_1
		VALUES(1, GETDATE())

		EXEC stpTeste_Rollback_2

	IF(@@ERROR = 0)
		COMMIT
	ELSE
		ROLLBACK	
END
GO

EXEC stpTeste_Rollback_1

/*
(1 row affected)

(1 row affected)

(1 row affected)

(1 row affected)

Msg 8134, Level 16, State 1, Procedure stpTeste_Rollback_4, Line 7 [Batch Start Line 321]
Divide by zero error encountered.
*/

-- EXEMPLO 5 - RESULTADO
SELECT * FROM Teste_Rollback_1
SELECT * FROM Teste_Rollback_2
SELECT * FROM Teste_Rollback_3
SELECT * FROM Teste_Rollback_4
GO