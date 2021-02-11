USE master

GO

-- Criar a base "CEP".
-- OBS: Alterar o caminho para um local existente no seu servidor.

CREATE DATABASE [CEP] 
	ON  PRIMARY ( 
		NAME = N'CEP', FILENAME = N'C:\SQLServer\Data\CEP.mdf' , 
		SIZE = 102400KB , FILEGROWTH = 102400KB 
	)
	LOG ON ( 
		NAME = N'CEP_log', FILENAME = N'C:\SQLServer\Log\CEP_log.ldf' , 
		SIZE = 30720KB , FILEGROWTH = 30720KB 
	)
GO

-- Alterar o Recovery Model da base para SIMPLE.
ALTER DATABASE [CEP] SET RECOVERY SIMPLE