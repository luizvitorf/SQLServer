USE master

GO

--------------------------------------------------------------------------------------------------------------------------------
--	Criando uma Database de Teste - Alterar o caminho para um local existente no seu servidor.
--------------------------------------------------------------------------------------------------------------------------------
CREATE DATABASE [BASE_CLIENTES_OLD] 
	ON  PRIMARY ( 
		NAME = N'BASE_CLIENTES_OLD', FILENAME = N'C:\SQLServer\Data\BASE_CLIENTES_OLD\BASE_CLIENTES_OLD.mdf' , 
		SIZE = 102400KB , FILEGROWTH = 102400KB 
	)
	LOG ON ( 
		NAME = N'BASE_CLIENTES_OLD_log', FILENAME = N'C:\SQLServer\Data\BASE_CLIENTES_OLD\BASE_CLIENTES_OLD_log.ldf' , 
		SIZE = 30720KB , FILEGROWTH = 30720KB 
	)
GO

ALTER DATABASE BASE_CLIENTES_OLD SET OFFLINE WITH ROLLBACK IMMEDIATE

GO

-- Verifica o status da database
select name, state_desc, is_read_only
from sys.databases
where name = 'BASE_CLIENTES_OLD'

GO

USE master

GO

BACKUP DATABASE [BASE_CLIENTES_OLD]
TO DISK = 'C:\SQLServer\Data\BASE_CLIENTES_OLD\BASE_CLIENTES_OLD.bak'
WITH INIT, CHECKSUM, COMPRESSION, STATS = 1

/*
Msg 942, Level 14, State 4, Line 1
Database 'BASE_CLIENTES_OLD' cannot be opened because it is offline.
Msg 3013, Level 16, State 1, Line 1
BACKUP DATABASE is terminating abnormally.
*/

GO

ALTER DATABASE [BASE_CLIENTES_OLD] SET READ_ONLY

GO

ALTER DATABASE [BASE_CLIENTES_OLD] SET ONLINE

GO

BACKUP DATABASE [BASE_CLIENTES_OLD]
TO DISK = 'C:\SQLServer\Data\BASE_CLIENTES_OLD\BASE_CLIENTES_OLD.bak'
WITH INIT, CHECKSUM, COMPRESSION, STATS = 1

GO

ALTER DATABASE [BASE_CLIENTES_OLD] SET OFFLINE

GO 

ALTER DATABASE [BASE_CLIENTES_OLD] SET READ_WRITE

GO

-- Verifica o status da database
select name, state_desc, is_read_only
from sys.databases
where name = 'BASE_CLIENTES_OLD'


GO

DROP DATABASE BASE_CLIENTES_OLD

GO