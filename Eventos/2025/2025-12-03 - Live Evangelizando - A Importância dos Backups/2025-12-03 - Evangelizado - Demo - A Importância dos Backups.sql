/*
Autor: Luiz Vitor França Lima

Linkedin: https://www.linkedin.com/in/luizvitorlima/

Blog: https://luizlima.net/

Youtube: https://www.youtube.com/channel/UCkomEA1Yef6DEa6vB4WYfWw/

---------------------------------------------------------
-- Assunto: A Importância dos Backups!
---------------------------------------------------------

Referências:

-- Script Restore – Restaurando vários arquivos de Backup de Log – Plano de Manutenção
https://luizlima.net/script-restore-restaurando-varios-arquivos-de-backup-de-log-plano-de-manutencao/

-- Script Restore – Restaurando vários arquivos de Backup de Log – Opções STOPAT e STANDBY
https://luizlima.net/script-restore-restaurando-varios-arquivos-de-backup-de-log-opcoes-stopat-e-standby/

-- Casos do Dia a Dia – Erro Restore Log “The log in this backup set begins at LSN XXX, which is too recent to apply to the database.”
https://luizlima.net/casos-do-dia-a-dia-erro-restore-log-the-log-in-this-backup-set-begins-at-lsn-xxx-which-is-too-recent-to-apply-to-the-database/

-- Automatizar Backups Armazenando em Blob – Azure usando Microsoft SSMS
https://ederlelis.com.br/blog/automatizar_backups_armazenando_em_blob_no_azure/


-- Microsoft Docs:

-- Back up and restore of SQL Server databases
https://learn.microsoft.com/en-us/sql/relational-databases/backup-restore/back-up-and-restore-of-sql-server-databases?view=sql-server-ver17

-- BACKUP (Transact-SQL)
https://learn.microsoft.com/en-us/sql/t-sql/statements/backup-transact-sql?view=sql-server-ver17

-- RESTORE Statements (Transact-SQL)
https://learn.microsoft.com/en-us/sql/t-sql/statements/restore-statements-transact-sql?view=sql-server-ver17
*/


---------------------------------------------------------
-- 1) Por que fazer Backups?
---------------------------------------------------------

--> Para EVITAR PERDA DE DADOS em casos de DESASTRES:
	-- Invasão (Ransomware - Criptografa arquivos e pede um resgate em $$ ou bitcoin)
	-- Desastres Naturais (inundação, incêndio, furação, terremoto, etc.) 	 
	-- Corrupção de Dados (queda de energia, problemas de hardware/rede)
	-- Alterações Indevidas (UPDATE/DELETE SEM WHERE)
	-- Entre Outros...

--> Também são UTILIZADOS para:
	-- Recuperar informações (através do RESTORE)
	-- Bases de teste / homologação
	-- Migração
	-- Por segurança, antes de atualizações ou alterações mais críticas
	-- Importante: Teste de Restore - periódico - boa prática, mas que infelizmente muita gente não faz!

--> IMPORTANTE: Ter uma rotina de CHECKDB, para validar CORRUPÇÃO DE DADOS nas bases.
			--	Cuidado com bases grandes, pois pode demorar muito!


---------------------------------------------------------
-- 2) Recovery Model (Modelo de Recuperação):
---------------------------------------------------------

--> FULL:
	-- Recomendado para BASES CRÍTICAS DE PRODUÇÃO, para evitar perda de dados
	-- Fully Logged - armazena no arquivo de log todas as alterações
	-- Point-in-time Recovery - conseguimos restaurar em um horário específico do dia!
	-- PRECISA fazer Backup de Log

--> SIMPLE:
	-- Recomendado para bases de produção que não são críticas (ex: pode perder 24 horas de dados), 
		-- Bases de teste / homologação, pois pode ter perda de dados
	-- Minimally Logged - NÃO armazena no arquivo de log todas as alterações, elas são truncadas no próximo CHECKPOINT
	-- NÃO possui point-in-time Recovery
	-- NÃO precisa fazer Backup de Log

--> BULK-LOGGED:
	-- Minimally Logged para alguns tipos de operações:
		-- Ex: BCP, BULK INSERT, CREATE INDEX, ALTER INDEX REBUILD
	-- Pode ter perda de dados, pode impactar o Point-in-time Recovery
	-- Luiz: Quase não é utilizado na prática.


---------------------------------------------------------
-- 3) Tipos de Backup:
---------------------------------------------------------

--> BACKUP FULL:	
	--		Backup Completo da database. Inicia uma nova cadeia de backups.
	--		NÃO CONFUNDA: Recorery Model Full <> Backup Full

--> BACKUP DIFERENCIAL: 
	--		Backup APENAS das alterações realizadas desde o último Backup Full. 
	--		Com isso, pode ficar muito menor do que um Backup Full.
	--		Ter atenção se a base tiver muitas alterações, pois o arquivo pode ficar muito grande!
	--		Portanto, depende de um backup full inicial.
	--		Desconsidera os backups diferenciais anteriores.	
	
--> BACKUP LOG:	
	--		Backup das alterações realizadas desde o último Backup de Log. 
	--		É um backup SEQUENCIAL, ou seja, depende do backup de log anterior.
	--		LSN: Log Sequence Number -> utilizado para controle da sequência dos logs.
	--		Também depende de um backup full inicial.

--> OBS 1:	"WITH COPY_ONLY"
	--		Utilizado quando for necessário fazer um backup sem afetar a cadeia de backups.
	--		Ex: fazer um Backup Full avulso da produção para restaurar no ambiente de homologação.

--> OBS 2:	Existem outros tipos de backups também, mas não irei abordar nessa live.


---------------------------------------------------------
-- 4) Montando uma Estratégia de Backup:
---------------------------------------------------------

--> BASES GRANDES: 
	
	--	Backup Full - Todo domingo - semanal
	--	Backup Diff - Segunda a sábado - uma vez por dia à noite. 
		--	OBS: Pode economizar bastante espaço, ao invés de fazer um Backup Full diário
	--	Backup Log  - Todos os dias, a cada 10 minutos 

--> BASES PEQUENAS:

	--	Backup Full - Todos os dias, uma vez por dia à noite
	--	Backup Log  - Todos os dias, a cada 10 minutos 

--> OBS: Bases que não são críticas não precisam de backup de log (deixar com o Recovery Model SIMPLE)!

--	Resumo:
--	Bases Críticas - perda de dados de até 10 minutos.
--	Bases Não Críticas - perda de dados de até 24 horas.

--	BORA PRA PARTE MAIS LEGAL!!! DEMO!!!

--	ALGUMA DÚVIDA ATÉ AQUI???


---------------------------------------------------------
-- 5) DEMO: Recuperando os registros de um UPDATE SEM WHERE
--	CRIA A DATABASE [Live_Evangelizando]
--	OBS: se você for executar o script também, substitua pelo seu caminho
---------------------------------------------------------

USE master
GO

DROP DATABASE IF EXISTS [Live_Evangelizando]

CREATE DATABASE [Live_Evangelizando] 
	ON  PRIMARY ( 
		NAME = N'Live_Evangelizando', FILENAME = N'D:\SQLServer\SQL2022\Dados\Live_Evangelizando.mdf' , 
		SIZE = 102400KB , FILEGROWTH = 102400KB 
	)
	LOG ON ( 
		NAME = N'Live_Evangelizando_log', FILENAME = N'D:\SQLServer\SQL2022\Log\Live_Evangelizando_log.ldf' , 
		SIZE = 30720KB , FILEGROWTH = 30720KB 
	)
GO

--  Altera o Recovery Model para FULL
ALTER DATABASE [Live_Evangelizando] SET RECOVERY FULL
GO

-- Confere o Recovery Model das bases
SELECT name, recovery_model_desc, create_date, compatibility_level
FROM sys.databases
order by create_date DESC
GO

--	Tentar executar um Backup Diferencial e Backup Log
--	DIFF
BACKUP DATABASE [Live_Evangelizando]
TO DISK = 'D:\SQLServer\SQL2022\Backup\Live_Evangelizando_Diff_Init.bak'
WITH STATS = 1, CHECKSUM, COMPRESSION, DIFFERENTIAL, INIT

/*
Msg 3035, Level 16, State 1, Line 168
Cannot perform a differential backup for database "Live_Evangelizando", 
because a current database backup does not exist. 
Perform a full database backup by reissuing BACKUP DATABASE, omitting the WITH DIFFERENTIAL option.
Msg 3013, Level 16, State 1, Line 168
BACKUP DATABASE is terminating abnormally.
*/

-- LOG
BACKUP LOG [Live_Evangelizando]
TO DISK = 'D:\SQLServer\SQL2022\Backup\Live_Evangelizando_Log_Init.bak'
WITH STATS = 1, CHECKSUM, COMPRESSION, INIT

/*
Msg 4214, Level 16, State 1, Line 182
BACKUP LOG cannot be performed because there is no current database backup.
Msg 3013, Level 16, State 1, Line 182
BACKUP LOG is terminating abnormally.
*/

--	BOA PRÁTICA: 
--	Ao CRIAR ou RESTAURAR uma base, execute um Backup Full para ela!
--	Se a base não precisar de backups, deixar ela com o Recovery Model SIMPLE.

-- Cria uma tabela e insere os dados
USE [Live_Evangelizando]
GO

DROP TABLE IF EXISTS [Palestrantes]

CREATE TABLE [Palestrantes] (
	Id INT IDENTITY(1,1) NOT NULL,
	Nome VARCHAR(100) NOT NULL,
	DataNascimento DATE NOT NULL
)

INSERT INTO [Palestrantes] (Nome, DataNascimento)
VALUES 
	('Luiz Lima', '19891225'),
	('Ítalo Mesquita', '19900104'),
	('Raphael Amorim', '19850613'),
	('Wallace Camargo', '19801019')

SELECT * FROM [Palestrantes]
GO

---------------------------------------------------------
-- 6) BACKUP FULL - Backup COMPLETO da base!
---------------------------------------------------------

-- OBS: Validar o caminho dos backups e apagar os arquivos antigos.

BACKUP DATABASE [Live_Evangelizando]
TO DISK = 'D:\SQLServer\SQL2022\Backup\Live_Evangelizando_Full.bak'
WITH STATS = 1, CHECKSUM, COMPRESSION, INIT

GO

-- Automatizar Backups Armazenando em Blob – Azure usando Microsoft SSMS
-- https://ederlelis.com.br/blog/automatizar_backups_armazenando_em_blob_no_azure/

---------------------------------------------------------
-- 7) BACKUP DIFFERENTIAL - Backup APENAS com as alterações desde o último Backup Full
---------------------------------------------------------

-- Insere mais um registro na tabela
INSERT INTO [Palestrantes] (Nome, DataNascimento)
VALUES ('Gabriel Quintella', '19740301'), ('Luciano Borba', '19900528')

SELECT * FROM [Palestrantes]

-- Executa o Backup Diferencial
BACKUP DATABASE [Live_Evangelizando]
TO DISK = 'D:\SQLServer\SQL2022\Backup\Live_Evangelizando_Diff_1.bak'
WITH STATS = 1, CHECKSUM, COMPRESSION, DIFFERENTIAL, INIT

-- OBS: Mostrar a pasta e comparar o tamanho dos backups full e diff!

GO

---------------------------------------------------------
-- 8) BACKUP LOG - Backup com as alterações desde o último Backup de Log - é SEQUENCIAL!
---------------------------------------------------------

-- Deleta um registro
DELETE [Palestrantes]
WHERE Nome = 'Luciano Borba'

SELECT * FROM [Palestrantes]

-- Faz o Backup de Log - 1
BACKUP LOG [Live_Evangelizando]
TO DISK = 'D:\SQLServer\SQL2022\Backup\Live_Evangelizando_Log_1.bak'
WITH STATS = 1, CHECKSUM, COMPRESSION, INIT

-- Deleta outro registro
DELETE [Palestrantes]
WHERE Nome = 'Gabriel Quintella'

SELECT * FROM [Palestrantes]

-- Faz o Backup de Log - 2
BACKUP LOG [Live_Evangelizando]
TO DISK = 'D:\SQLServer\SQL2022\Backup\Live_Evangelizando_Log_2.bak'
WITH STATS = 1, CHECKSUM, COMPRESSION, INIT


---------------------------------------------------------
-- 9) UPDATE - USANDO BEGIN TRAN - CORRETO!
--	  OBS: COMO O LUIZ LIMA FAZ UPDATE!
---------------------------------------------------------
-- ANTES:
SELECT * FROM [Palestrantes]

BEGIN TRAN

	UPDATE [Palestrantes]
	SET Nome = 'Luiz Vasco'

-- COMMIT
-- ROLLBACK

-- DEPOIS:
SELECT * FROM [Palestrantes]

-- COMENTAR SOBRE TRANSAÇÃO EXPLÍCITA - BEGIN TRAN - COMMIT / ROLLBACK!!!


---------------------------------------------------------
-- 10) UPDATE SEM WHERE (E SEM BEGIN TRAN)!!!
--	   OBS: COMO O RAPHAEL AMORIM FAZ UPDATE, NA SEXTA-FEIRA AS 16:59 horas! kkkkkk
---------------------------------------------------------

-- ANTES:
SELECT * FROM [Palestrantes]

UPDATE [Palestrantes]
SET Nome = 'Luiz Vasco'

-- DEPOIS:
SELECT * FROM [Palestrantes]

ROLLBACK

/*
Msg 3903, Level 16, State 1, Line 256
The ROLLBACK TRANSACTION request has no corresponding BEGIN TRANSACTION.
*/

SELECT * FROM [Palestrantes]

-- CITAR AQUI OS TIPOS DE TRANSAÇÕES: EXPLÍTICAS x IMPLÍCITAS

-- MEU DEUS!!! E AGORA!!! ME AJUDA LUIZ!!! VOU PERDER MEU EMPREGO!!!

-- AGORA O DBA ENTRA EM AÇÃO PARA SALVAR O DIA!!!

---------------------------------------------------------
-- 11) Restaurar os backups para recuperar os dados
---------------------------------------------------------

-- Validando as informações do backup antes do RESTORE
RESTORE FILELISTONLY
FROM DISK = 'D:\SQLServer\SQL2022\Backup\Live_Evangelizando_Full.bak'

-- 11.1) Restaura o Backup Full
USE master

RESTORE DATABASE [Restore_Live_Evangelizando]
FROM DISK = 'D:\SQLServer\SQL2022\Backup\Live_Evangelizando_Full.bak'
WITH STATS = 1, --	NORECOVERY, -- COMENTADO DEVIDO AO USO DO STANDBY
	MOVE 'Live_Evangelizando' TO 'D:\SQLServer\SQL2022\Dados\Restore_Live_Evangelizando.mdf',
	MOVE 'Live_Evangelizando_log' TO 'D:\SQLServer\SQL2022\Log\Restore_Live_Evangelizando_log.ldf',
	STANDBY = N'D:\SQLServer\SQL2022\Dados\Live_Evangelizando_StandBy'	-- BONUS!!!

GO

-- Conectar na base restaurada e validar os dados da tabela
USE [Restore_Live_Evangelizando]

SELECT * FROM [Palestrantes]

GO

-- Tentar fazer alguma alteração na database restaurada
USE [Restore_Live_Evangelizando]

UPDATE [Palestrantes]
SET Nome = 'Luiz Vasco'

GO

/*
Msg 3906, Level 16, State 1, Line 357
Failed to update database "Restore_Live_Evangelizando" because the database is read-only.
*/

-- Comando para validar as sessoes na database - se der LOCK
SELECT *
FROM sys.dm_exec_sessions
where DB_NAME(database_id) = 'Restore_Live_Evangelizando'


-- 11.2) Restaura o Backup Diff 1
USE master

RESTORE DATABASE [Restore_Live_Evangelizando]
FROM DISK = 'D:\SQLServer\SQL2022\Backup\Live_Evangelizando_Diff_1.bak'
WITH STATS = 1, --	NORECOVERY, -- COMENTADO DEVIDO AO USO DO STANDBY
	STANDBY = N'D:\SQLServer\SQL2022\Log\Live_Evangelizando_StandBy'	-- BONUS!!!

GO

-- Conectar na base restaurada e validar os dados da tabela
USE [Restore_Live_Evangelizando]

SELECT * FROM [Palestrantes]

GO


-- 11.3) Restaura o Backup Log 1
USE master

RESTORE LOG [Restore_Live_Evangelizando]
FROM DISK = 'D:\SQLServer\SQL2022\Backup\Live_Evangelizando_Log_1.bak'
WITH STATS = 1, --	NORECOVERY, -- COMENTADO DEVIDO AO USO DO STANDBY
	STANDBY = N'D:\SQLServer\SQL2022\Log\Live_Evangelizando_StandBy'	-- BONUS!!!

GO

-- Conectar na base restaurada e validar os dados da tabela
USE [Restore_Live_Evangelizando]

SELECT * FROM [Palestrantes]

GO

-- 11.4) Restaura o Backup Log 2
USE master

RESTORE LOG [Restore_Live_Evangelizando]
FROM DISK = 'D:\SQLServer\SQL2022\Backup\Live_Evangelizando_Log_2.bak'
WITH STATS = 1, --	NORECOVERY, -- COMENTADO DEVIDO AO USO DO STANDBY
	STANDBY = N'D:\SQLServer\SQL2022\Log\Live_Evangelizando_StandBy'	-- BONUS!!!

GO

-- Conectar na base restaurada e validar os dados da tabela
USE [Restore_Live_Evangelizando]

SELECT * FROM [Palestrantes]

GO

-- Pronto! Chegamos no ponto de recuperar os dados!

-- Comparando os dados
SELECT * FROM [Live_Evangelizando]..[Palestrantes]				-- Base Produção 
SELECT * FROM [Restore_Live_Evangelizando]..[Palestrantes]		-- Base Restaurada

-- Validando o SELECT da correcao
SELECT * 
FROM [Live_Evangelizando]..[Palestrantes] P
JOIN [Restore_Live_Evangelizando]..[Palestrantes] R ON P.Id = R.Id

GO

-- Recuperando os dados!
USE [Live_Evangelizando]

BEGIN TRAN
	UPDATE P
	SET P.Nome = R.Nome
	FROM [Live_Evangelizando]..[Palestrantes] P
	JOIN [Restore_Live_Evangelizando]..[Palestrantes] R ON P.Id = R.Id
	
	-- Validando se está tudo OK
	SELECT * 
	FROM [Live_Evangelizando]..[Palestrantes] P
	JOIN [Restore_Live_Evangelizando]..[Palestrantes] R ON P.Id = R.Id

COMMIT


-- Validando se está tudo OK - Double Check!!
SELECT * FROM [Live_Evangelizando]..[Palestrantes]				-- Base Produção 
SELECT * FROM [Restore_Live_Evangelizando]..[Palestrantes]		-- Base Restaurada


-- PRONTO!! DADOS RECUPERADOS!!! MUITO OBRIGADO LUIZ!!! VOCE SALVOU O DIA (E O MEU EMPREGO KKK)!!!

-- TUDO ISSO SÓ FOI POSSÍVEL GRAÇAS AOS BACKUPS! BACKUPS TAMBÉM SALVAM VIDAS KKK!


-- Deixando o banco restaurado ONLINE e disponivel pra uso!
RESTORE DATABASE [Restore_Live_Evangelizando] WITH RECOVERY

GO

-- Agora já é possível fazer outro UPDATE SEM WHERE kkk
USE [Restore_Live_Evangelizando]

UPDATE [Palestrantes]
SET Nome = 'Luiz Vasco'

SELECT * FROM [Palestrantes]

GO

--	Executar um CHECKDB - Validação de Corrupção!
--	Cuidado com bases grandes, pois pode demorar muito!
DBCC CHECKDB('Live_Evangelizando')

/*
CHECKDB found 0 allocation errors and 0 consistency errors in database 'Live_Evangelizando'.
DBCC execution completed. If DBCC printed error messages, contact your system administrator.
*/

-- EXECUTAR O RESTORE ABAIXO NA INSTÂNCIA COM O SQL SERVER 2019!
USE master

RESTORE DATABASE [Restore_Live_Evangelizando]
FROM DISK = 'D:\SQLServer\Backup\Live_Evangelizando_Full.bak'
WITH STATS = 1, --	NORECOVERY, -- COMENTADO DEVIDO AO USO DO STANDBY
	MOVE 'Live_Evangelizando' TO 'D:\SQLServer\Backup\Dados\Restore_Live_Evangelizando.mdf',
	MOVE 'Live_Evangelizando_log' TO 'D:\SQLServer\Backup\Log\Restore_Live_Evangelizando_log.ldf'

GO

/*
Msg 3169, Level 16, State 1, Line 3
The database was backed up on a server running version 16.00.1000. 
That version is incompatible with this server, which is running version 15.00.2000. 
Either restore the database on a server that supports the backup, or use a backup that is compatible with this server.
Msg 3013, Level 16, State 1, Line 3
RESTORE DATABASE is terminating abnormally.

Completion time: 2025-12-03T19:58:09.6048839-03:00
*/


-- Por fim, apagar os bancos utilizados na DEMO e os arquivos de backup
/*
USE master

DROP DATABASE [Live_Evangelizando]
DROP DATABASE [Restore_Live_Evangelizando]

-- Caminho Backups:
D:\SQLServer\SQL2022\Backup
*/