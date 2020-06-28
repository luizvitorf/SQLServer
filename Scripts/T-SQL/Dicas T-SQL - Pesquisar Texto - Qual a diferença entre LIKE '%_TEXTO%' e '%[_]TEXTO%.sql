USE Traces

-----------------------------------------------------------------------------------------------
-- Exemplo – LIKE ‘%_TEXTO%’:
-----------------------------------------------------------------------------------------------
-- 2017
CREATE TABLE TABELA_BKP20170101 (ID INT)

-- 2018
CREATE TABLE TABELA_BKP20180101 (ID INT)

-- 2019
CREATE TABLE TABELABKP20190101 (ID INT)

-- 2020
CREATE TABLE TABELABKP20200101 (ID INT)

-- RETORNA AS TABELAS DO BANCO DE DADOS COM TEXTO "BKP"
SELECT name, create_date, modify_date
FROM sys.tables
WHERE name LIKE '%_BKP%'

-- RETORNA AS TABELAS DO BANCO DE DADOS COM TEXTO "_BKP"
SELECT name, create_date, modify_date
FROM sys.tables
WHERE name LIKE '%[_]BKP%'


-----------------------------------------------------------------------------------------------
-- OPERADOR LIKE
-----------------------------------------------------------------------------------------------
USE Traces

CREATE TABLE Cliente (Nome VARCHAR(100))

INSERT INTO Cliente 
VALUES ('Dirceu Resende'),('Fabricio Lima'), ('Luiz Lima'), ('Rodrigo Ribeiro')

SELECT * FROM Cliente

-- LIKE %TEXTO%
SELECT * 
FROM Cliente
WHERE Nome LIKE '%sen%'

-- LIKE TEXTO%
SELECT * 
FROM Cliente
WHERE Nome LIKE 'Rod%'

-- LIKE %TEXTO
SELECT * 
FROM Cliente
WHERE Nome LIKE '%Lima'

-- LIKE COMBINAÇÃO - ‘TEXTO%TEXTO%TEXTO’ 
SELECT * 
FROM Cliente
WHERE Nome LIKE 'L%Li%a'


-----------------------------------------------------------------------------------------------
-- WILDCARD CHARACTER
-----------------------------------------------------------------------------------------------
SELECT name, create_date, modify_date
FROM sys.tables
WHERE name LIKE '%_BKP%'

SELECT name, create_date, modify_date
FROM sys.tables
WHERE name LIKE '%[_]BKP%'


-----------------------------------------------------------------------------------------------
-- DIFERENÇA ENTRE ‘_’ E ‘%’:
-----------------------------------------------------------------------------------------------
CREATE TABLE Teste_Tamanho (Nome VARCHAR(100))

INSERT INTO Teste_Tamanho 
VALUES ('Aqui tem uma string'),('Aqui tem uma string e mais alguma coisa'),('a')

SELECT * FROM Teste_Tamanho

SELECT * 
FROM Teste_Tamanho
WHERE Nome LIKE '_a'

SELECT * 
FROM Teste_Tamanho
WHERE Nome LIKE '%a'


-----------------------------------------------------------------------------------------------
-- LIKE ‘%’ – STRING COM TAMANHO FIXO X VARIÁVEL:
-----------------------------------------------------------------------------------------------
SELECT * 
FROM Teste_Tamanho
WHERE Nome LIKE 'Aqui tem uma string'

-- TAMANHO VARIAVEL
SELECT * 
FROM Teste_Tamanho
WHERE Nome LIKE 'Aqui tem uma string%'


-----------------------------------------------------------------------------------------------
--  LISTA E RANGE – LIKE ‘[ABCD]’ x LIKE ‘[A-Z]’ x LIKE ‘[^ABCD]’
-----------------------------------------------------------------------------------------------
-- 1) RANGE - NOMES QUE INICIAM DE "A" ATE "F"
SELECT *
FROM Cliente
WHERE Nome LIKE '[A-F]%'

-- 2) RANGE - NOMES QUE INICIAM DE "G" ATE "Z"
SELECT *
FROM Cliente
WHERE Nome LIKE '[G-Z]%'

-- 3) LISTA - NOMES QUE INICIAM COM "D" OU "L"
SELECT *
FROM Cliente
WHERE Nome LIKE '[DL]%'

-- 4) DESCONSIDERAR - NOMES QUE NÃO INICIAM DE "A" ATE "F"
SELECT *
FROM Cliente
WHERE Nome LIKE '[^A-F]%'


-----------------------------------------------------------------------------------------------
-- NOT LIKE
-----------------------------------------------------------------------------------------------
SELECT *
FROM Cliente
WHERE Nome NOT LIKE '%Lima%'


-----------------------------------------------------------------------------------------------
-- ESCAPE - WILDCARDS ("%", "_", "[", "]")
-----------------------------------------------------------------------------------------------
CREATE TABLE Teste_Wildcard (Nome VARCHAR(100))

INSERT INTO Teste_Wildcard
VALUES 
	('Eu sou o wildcard "%" e vou ser retornado! Uhhuuu =)'),
	('Eu sou o wildcard "_" e vou ser retornado! Uhhuuu =)'),
	('Eu sou o wildcard "[" e vou ser retornado! Uhhuuu =)'),
	('Eu sou o wildcard "]" e vou ser retornado! Uhhuuu =)')

SELECT * FROM Teste_Wildcard

-- CARACTERE "%"
SELECT *
FROM Teste_Wildcard
WHERE Nome LIKE '%%%'

SELECT *
FROM Teste_Wildcard
WHERE Nome LIKE '%!%%' ESCAPE '!'

-- CARACTERE "_"
SELECT *
FROM Teste_Wildcard
WHERE Nome LIKE '%_%'

SELECT *
FROM Teste_Wildcard
WHERE Nome LIKE '%?_%' ESCAPE '?'

-- CARACTERE "["
SELECT *
FROM Teste_Wildcard
WHERE Nome LIKE '%[%'

SELECT *
FROM Teste_Wildcard
WHERE Nome LIKE '%+[%' ESCAPE '+'

-- CARACTERE "]"
SELECT *
FROM Teste_Wildcard
WHERE Nome LIKE '%]%'