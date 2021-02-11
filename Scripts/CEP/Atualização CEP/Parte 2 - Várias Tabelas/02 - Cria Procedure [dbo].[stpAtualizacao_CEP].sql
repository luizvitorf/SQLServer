USE CEP

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- ================================================================================
-- PROCEDURE UTILIZADA PARA ATUALIZAR AS TABELAS DE CEP!
-- O RESULTADO DELA SERÃO VARIAS TABELAS QUE DEVEM SER UTILIZADAS PARA ATUALIZAR A PRODUÇÃO DEPOIS.
-- CRIADO POR: LUIZ VITOR
-- DATA: 09/02/2021

-- EXEMPLO EXECUÇÃO:

-- OBS: INFORMAR O CAMINHO DA PASTA COM UM "\" NO FINAL OK!
-- EXEC [dbo].[stpAtualizacao_Cep] @Ds_Caminho_Pasta_Arquivos = 'C:\SQLServer\CEP\Fixo\'
-- ================================================================================
	-------------------------------------------------------------------------------

CREATE PROCEDURE [dbo].[stpAtualizacao_Cep]
	@Ds_Caminho_Pasta_Arquivos VARCHAR(300) 
AS
BEGIN
	SET NOCOUNT ON

	/*
	-- P/ TESTE
	DECLARE @Ds_Caminho_Pasta_Arquivos VARCHAR(300) = 'C:\SQLServer\CEP\Fixo\'
	*/

	-- DECLARA AS VARIÁVEIS QUE SERÃO UTILIZADAS NA ROTINA
	DECLARE @Nm_Arquivo VARCHAR(300), @Nm_Arquivo_Loop VARCHAR(25), @Ds_Comando NVARCHAR(1000)	
	
	-------------------------------------------------------------------------------
	-- CRIAÇÃO DAS TABELAS DO CEP
	-------------------------------------------------------------------------------
	-- Cep
	IF(OBJECT_ID('Cep') IS NOT NULL)
		DROP TABLE Cep

	CREATE TABLE [dbo].[Cep] (
		[Nr_Cep] [char](8) NOT NULL,
		[Sg_Uf] [char](2) NOT NULL,
		[Cd_Localidade] [int] NOT NULL,		
		[Cd_Bairro] [int] NULL,		
		[Tp_Logradouro] [varchar](26) NULL,
		[Nm_Patente] [varchar](72) NULL,
		[Nm_Preposicao] [varchar](3) NULL,		
		[Cd_Logradouro] [int] NULL,
		[Nm_Logradouro] [varchar](72) NULL,
		[Nm_Abreviatura] [varchar](36) NULL,
		[Ds_Info_Adicional] [varchar](36) NULL,
		PRIMARY KEY CLUSTERED 
		(
			[Nr_Cep] ASC
		) WITH (FILLFACTOR = 90) ON [PRIMARY]
	) ON [PRIMARY]

	-- Bairro
	IF(OBJECT_ID('Bairro') IS NOT NULL)
		DROP TABLE Bairro

	CREATE TABLE [dbo].[Bairro] (
		[Sg_Uf] [char](2) NOT NULL,
		[Cd_Localidade] [int] NOT NULL,
		[Cd_Bairro] [int] NOT NULL,
		[Nm_Bairro] [varchar](72) NOT NULL,		
		[Nm_Bairro_Abrev] [varchar](36) NULL,
		PRIMARY KEY CLUSTERED 
		(
			[Cd_Bairro] ASC
		) WITH (FILLFACTOR = 90) ON [PRIMARY]
	) ON [PRIMARY]

	-- Localidade
	IF(OBJECT_ID('Localidade') IS NOT NULL)
		DROP TABLE Localidade

	CREATE TABLE [dbo].[Localidade] (
		[Nr_Cep] [char](8) NULL,
		[Sg_Uf] [char](2) NOT NULL,
		[Cd_Localidade] [int] NOT NULL,
		[Nm_Localidade] [varchar](72) NOT NULL,		
		[Nm_Abreviatura] [varchar](36) NULL,
		PRIMARY KEY CLUSTERED 
		(
			[Cd_Localidade] ASC
		) WITH (FILLFACTOR = 90) ON [PRIMARY]
	) ON [PRIMARY]	

	-- Estado
	IF(OBJECT_ID('Estado') IS NOT NULL)
		DROP TABLE Estado

	CREATE TABLE [dbo].[Estado] (
		[Sg_Pais] [char](2) NOT NULL,
		[Sg_Uf] [char](2) NOT NULL,
		[Cd_Uf] INT NOT NULL,		
		[Nm_Estado] [varchar](72) NOT NULL,		
		PRIMARY KEY CLUSTERED 
		(
			[Sg_Uf] ASC
		) WITH (FILLFACTOR = 90) ON [PRIMARY]
	) ON [PRIMARY]

	-- Pais
	IF(OBJECT_ID('Pais') IS NOT NULL)
		DROP TABLE Pais

	CREATE TABLE [dbo].[Pais] (
		[Sg_Pais] [char](2) NOT NULL,
		[Sg_Pais_2] [char](3) NOT NULL,
		[Nm_Pais] [varchar](72) NOT NULL,		
		[Nm_Pais_ENG] [varchar](72) NOT NULL,		
		[Nm_Pais_FRA] [varchar](72) NOT NULL,		
		PRIMARY KEY CLUSTERED 
		(
			[Sg_Pais] ASC
		) WITH (FILLFACTOR = 90) ON [PRIMARY]
	) ON [PRIMARY]

	-- Tipo Logradouro
	IF(OBJECT_ID('Tipo_Logradouro') IS NOT NULL)
		DROP TABLE Tipo_Logradouro

	CREATE TABLE [dbo].[Tipo_Logradouro] (
		[Cd_Tipo_Logradouro] INT NOT NULL,
		[Tp_Logradouro] [varchar](26) NOT NULL,
		[Tp_Logradouro_Abrev] [varchar](15) NOT NULL	
		PRIMARY KEY CLUSTERED 
		(
			[Tp_Logradouro] ASC
		) WITH (FILLFACTOR = 90) ON [PRIMARY]
	) ON [PRIMARY]

	-- Tipo Patente
	IF(OBJECT_ID('Titulo_Patente') IS NOT NULL)
		DROP TABLE Titulo_Patente

	CREATE TABLE [dbo].[Titulo_Patente] (
		[Cd_Titulo_Patente] INT NOT NULL,
		[Nm_Patente] [varchar](72) NOT NULL,
		[Nm_Patente_Abrev] [varchar](15) NOT NULL	
		PRIMARY KEY CLUSTERED 
		(
			[Nm_Patente] ASC
		) WITH (FILLFACTOR = 90) ON [PRIMARY]
	) ON [PRIMARY]

	-------------------------------------------------------------------------------
	-- CRIA A TABELA COM O NOME DOS ARQUIVOS DE LOGRADOURO
	-------------------------------------------------------------------------------
	IF(OBJECT_ID('tempdb..##CEP_IMPORTACAO_ARQUIVOS_LOGRADOUROS') IS NOT NULL)
		DROP TABLE ##CEP_IMPORTACAO_ARQUIVOS_LOGRADOUROS
	
	CREATE TABLE ##CEP_IMPORTACAO_ARQUIVOS_LOGRADOUROS (
		Nm_Arquivo CHAR(25)
	)

	INSERT INTO ##CEP_IMPORTACAO_ARQUIVOS_LOGRADOUROS (Nm_Arquivo)
	VALUES
		('DNE_GU_AC_LOGRADOUROS.TXT'),
		('DNE_GU_AL_LOGRADOUROS.TXT'),
		('DNE_GU_AM_LOGRADOUROS.TXT'),
		('DNE_GU_AP_LOGRADOUROS.TXT'),
		('DNE_GU_BA_LOGRADOUROS.TXT'),
		('DNE_GU_CE_LOGRADOUROS.TXT'),
		('DNE_GU_DF_LOGRADOUROS.TXT'),
		('DNE_GU_ES_LOGRADOUROS.TXT'),
		('DNE_GU_GO_LOGRADOUROS.TXT'),
		('DNE_GU_MA_LOGRADOUROS.TXT'),
		('DNE_GU_MG_LOGRADOUROS.TXT'),
		('DNE_GU_MS_LOGRADOUROS.TXT'),
		('DNE_GU_MT_LOGRADOUROS.TXT'),
		('DNE_GU_PA_LOGRADOUROS.TXT'),
		('DNE_GU_PB_LOGRADOUROS.TXT'),
		('DNE_GU_PE_LOGRADOUROS.TXT'),
		('DNE_GU_PI_LOGRADOUROS.TXT'),
		('DNE_GU_PR_LOGRADOUROS.TXT'),
		('DNE_GU_RJ_LOGRADOUROS.TXT'),
		('DNE_GU_RN_LOGRADOUROS.TXT'),
		('DNE_GU_RO_LOGRADOUROS.TXT'),
		('DNE_GU_RR_LOGRADOUROS.TXT'),
		('DNE_GU_RS_LOGRADOUROS.TXT'),
		('DNE_GU_SC_LOGRADOUROS.TXT'),
		('DNE_GU_SE_LOGRADOUROS.TXT'),
		('DNE_GU_SP_LOGRADOUROS.TXT'),
		('DNE_GU_TO_LOGRADOUROS.TXT')
		
	-- SELECT * FROM ##CEP_IMPORTACAO_ARQUIVOS_LOGRADOUROS
	
	-------------------------------------------------------------------------------
	-- IMPORTAÇÃO DOS DADOS DOS ARQUIVOS TXT
	-------------------------------------------------------------------------------

	-------------------------------------------------------------------------------
	-- ARQUIVO: DNE_GU_UF_LOGRADOUROS.TXT
	-------------------------------------------------------------------------------
	-- C = Cabeçalho - PODEMOS IGNORAR!!!
	-- D = Dados de Logradouro
	-- S = Dados do Seccionamento
	-- N = Dados de Numeração de Lote
	-- K = Dados de Complemento_1
	-- Q = Dados de Complemento_2 -- DESCONSIDERADO, POIS NAO TEM REGISTROS!
	-------------------------------------------------------------------------------
	WHILE EXISTS (SELECT TOP 1 Nm_Arquivo FROM ##CEP_IMPORTACAO_ARQUIVOS_LOGRADOUROS)
	BEGIN
		SELECT TOP 1 @Nm_Arquivo_Loop = Nm_Arquivo FROM ##CEP_IMPORTACAO_ARQUIVOS_LOGRADOUROS

		SELECT @Nm_Arquivo = @Ds_Caminho_Pasta_Arquivos + @Nm_Arquivo_Loop
	
		IF (OBJECT_ID('tempdb..##CEP_IMPORTACAO_DADOS_LOGRADOUROS') IS NOT NULL)
			DROP TABLE ##CEP_IMPORTACAO_DADOS_LOGRADOUROS

		CREATE TABLE ##CEP_IMPORTACAO_DADOS_LOGRADOUROS (
			Ds_Linha VARCHAR(634)
		)

		-- IMPORTA O ARQUIVO
		SELECT @Ds_Comando = 'BULK INSERT ##CEP_IMPORTACAO_DADOS_LOGRADOUROS 
		FROM ''' + @Nm_Arquivo + '''
		WITH 
		(
			CODEPAGE		= ''1252'',
			DATAFILETYPE    = ''char'',
			ROWTERMINATOR   = ''\n''
		);'

		EXEC sp_executesql @Ds_Comando
	
		INSERT INTO [Cep] (
			[Nr_Cep], 
			[Sg_Uf], 
			[Cd_Localidade], 			
			[Cd_Bairro], 			
			[Tp_Logradouro], 
			[Nm_Patente], 
			[Nm_Preposicao], 			
			[Cd_Logradouro], 
			[Nm_Logradouro], 
			[Nm_Abreviatura], 
			[Ds_Info_Adicional]
		)
		SELECT 
			RTRIM(LTRIM(SUBSTRING(Ds_Linha, 519, 8))) AS [Nr_Cep], 		
			RTRIM(LTRIM(SUBSTRING(Ds_Linha, 2, 2))) AS [Sg_Uf], 
			RTRIM(LTRIM(SUBSTRING(Ds_Linha, 10, 8))) AS [Cd_Localidade], 			
			RTRIM(LTRIM(SUBSTRING(Ds_Linha, 95, 8))) AS [Cd_Bairro], 			
			CASE SUBSTRING(Ds_Linha, 260, 26) WHEN REPLICATE(' ', 26)
				THEN NULL
				ELSE RTRIM(LTRIM(SUBSTRING(Ds_Linha, 260, 26)))
			END	AS [Tp_Logradouro], 	
			CASE SUBSTRING(Ds_Linha, 289, 72) WHEN REPLICATE(' ', 72)
				THEN NULL
				ELSE RTRIM(LTRIM(SUBSTRING(Ds_Linha, 289, 72)))
			END	AS [Nm_Patente], 
			CASE SUBSTRING(Ds_Linha, 286, 3) WHEN '   '
				THEN NULL
				ELSE RTRIM(LTRIM(SUBSTRING(Ds_Linha, 286, 3)))
			END	AS [Nm_Preposicao],
			RTRIM(LTRIM(SUBSTRING(Ds_Linha, 367, 8))) AS [Cd_Logradouro], 
			RTRIM(LTRIM(SUBSTRING(Ds_Linha, 375, 72))) AS [Nm_Logradouro], 
			RTRIM(LTRIM(SUBSTRING(Ds_Linha, 447, 36))) AS [Nm_Abreviatura], 
			CASE SUBSTRING(Ds_Linha, 483, 36) WHEN REPLICATE(' ', 36)
				THEN NULL
				ELSE RTRIM(LTRIM(SUBSTRING(Ds_Linha, 483, 36)))
			END	AS [Ds_Info_Adicional]
		FROM ##CEP_IMPORTACAO_DADOS_LOGRADOUROS
		WHERE SUBSTRING(Ds_Linha, 1, 1) IN ('D','S','N','K')		-- TIPO DO REGISTRO

		-- DELETA O ARQUIVO DA TABELA
		DELETE FROM ##CEP_IMPORTACAO_ARQUIVOS_LOGRADOUROS
		WHERE Nm_Arquivo = @Nm_Arquivo_Loop
	END
				
	-------------------------------------------------------------------------------
	--	ARQUIVO: DNE_GU_GRANDES_USUARIOS.TXT
	-------------------------------------------------------------------------------
	IF (OBJECT_ID('tempdb..##CEP_IMPORTACAO_GRANDES_USUARIOS') IS NOT NULL)
		DROP TABLE ##CEP_IMPORTACAO_GRANDES_USUARIOS

	CREATE TABLE ##CEP_IMPORTACAO_GRANDES_USUARIOS (
		Ds_Linha VARCHAR(428)
	)

	SELECT @Nm_Arquivo = @Ds_Caminho_Pasta_Arquivos + 'DNE_GU_GRANDES_USUARIOS.TXT'

	-- IMPORTA O ARQUIVO
	SELECT @Ds_Comando = 'BULK INSERT ##CEP_IMPORTACAO_GRANDES_USUARIOS
	FROM ''' + @Nm_Arquivo + '''
	WITH 
	(
		CODEPAGE		= ''1252'',
		DATAFILETYPE    = ''char'',
		ROWTERMINATOR   = ''\n''
	);'

	EXEC sp_executesql @Ds_Comando

	INSERT INTO [Cep] (
			[Nr_Cep], 
			[Sg_Uf], 
			[Cd_Localidade], 			
			[Cd_Bairro], 			
			[Tp_Logradouro], 
			[Nm_Patente], 
			[Nm_Preposicao], 			
			[Cd_Logradouro], 
			[Nm_Logradouro], 
			[Nm_Abreviatura], 
			[Ds_Info_Adicional]
		)
	SELECT
		RTRIM(LTRIM(SUBSTRING(Ds_Linha, 261, 8))) AS [Nr_Cep], 		
		RTRIM(LTRIM(SUBSTRING(Ds_Linha, 2, 2))) AS [Sg_Uf], 
		RTRIM(LTRIM(SUBSTRING(Ds_Linha, 10, 8))) AS [Cd_Localidade], 		
		RTRIM(LTRIM(SUBSTRING(Ds_Linha, 95, 8))) AS [Cd_Bairro], 		 		
		NULL AS [Tp_Logradouro], 	
		NULL AS [Nm_Patente], 
		NULL AS [Nm_Preposicao], 			
		RTRIM(LTRIM(SUBSTRING(Ds_Linha, 181, 8))) AS [Cd_Logradouro], 
		RTRIM(LTRIM(SUBSTRING(Ds_Linha, 189, 72))) AS [Nm_Logradouro], 
		RTRIM(LTRIM(SUBSTRING(Ds_Linha, 269, 36))) AS [Nm_Abreviatura], 
		NULL AS [Ds_Info_Adicional]
	FROM ##CEP_IMPORTACAO_GRANDES_USUARIOS
	WHERE SUBSTRING(Ds_Linha, 1, 1) = 'D'
		

	-------------------------------------------------------------------------------
	--	ARQUIVO: DNE_GU_CAIXAS_POSTAIS_COMUNIT.TXT
	-------------------------------------------------------------------------------
	IF (OBJECT_ID('tempdb..##CEP_IMPORTACAO_CAIXAS_POSTAIS') IS NOT NULL)
		DROP TABLE ##CEP_IMPORTACAO_CAIXAS_POSTAIS

	CREATE TABLE ##CEP_IMPORTACAO_CAIXAS_POSTAIS (
		Ds_Linha VARCHAR(336)
	)

	SELECT @Nm_Arquivo = @Ds_Caminho_Pasta_Arquivos + 'DNE_GU_CAIXAS_POSTAIS_COMUNITA.TXT'

	-- IMPORTA O ARQUIVO
	SELECT @Ds_Comando = 'BULK INSERT ##CEP_IMPORTACAO_CAIXAS_POSTAIS
	FROM ''' + @Nm_Arquivo + '''
	WITH 
	(
		CODEPAGE		= ''1252'',
		DATAFILETYPE    = ''char'',
		ROWTERMINATOR   = ''\n''
	);'

	EXEC sp_executesql @Ds_Comando

	INSERT INTO [Cep] (
			[Nr_Cep], 
			[Sg_Uf], 
			[Cd_Localidade], 			
			[Cd_Bairro], 			
			[Tp_Logradouro], 
			[Nm_Patente], 
			[Nm_Preposicao], 			
			[Cd_Logradouro], 
			[Nm_Logradouro], 
			[Nm_Abreviatura], 
			[Ds_Info_Adicional]
		)
	SELECT
		RTRIM(LTRIM(SUBSTRING(Ds_Linha, 90, 8))) AS [Nr_Cep], 		
		RTRIM(LTRIM(SUBSTRING(Ds_Linha, 2, 2))) AS [Sg_Uf], 
		RTRIM(LTRIM(SUBSTRING(Ds_Linha, 10, 8))) AS [Cd_Localidade], 		
		NULL AS [Cd_Bairro], 				
		NULL AS [Tp_Logradouro], 	
		NULL AS [Nm_Patente], 
		NULL AS [Nm_Preposicao], 			
		RTRIM(LTRIM(SUBSTRING(Ds_Linha, 170, 8))) AS [Cd_Logradouro], 
		RTRIM(LTRIM(SUBSTRING(Ds_Linha, 178, 72))) AS [Nm_Logradouro], 
		NULL AS [Nm_Abreviatura], 
		NULL AS [Ds_Info_Adicional]
	FROM ##CEP_IMPORTACAO_CAIXAS_POSTAIS
	WHERE SUBSTRING(Ds_Linha, 1, 1) = 'D'

		
	-------------------------------------------------------------------------------
	--	ARQUIVO: DNE_GU_UNIDADES_OPERACIONAIS.TXT
	-------------------------------------------------------------------------------
	IF (OBJECT_ID('tempdb..##CEP_IMPORTACAO_UNIDADES_OPERACIONAIS') IS NOT NULL)
		DROP TABLE ##CEP_IMPORTACAO_UNIDADES_OPERACIONAIS

	CREATE TABLE ##CEP_IMPORTACAO_UNIDADES_OPERACIONAIS (
		Ds_Linha VARCHAR(428)
	)

	SELECT @Nm_Arquivo = @Ds_Caminho_Pasta_Arquivos + 'DNE_GU_UNIDADES_OPERACIONAIS.TXT'

	-- IMPORTA O ARQUIVO
	SELECT @Ds_Comando = 'BULK INSERT ##CEP_IMPORTACAO_UNIDADES_OPERACIONAIS
	FROM ''' + @Nm_Arquivo + '''
	WITH 
	(
		CODEPAGE		= ''1252'',
		DATAFILETYPE    = ''char'',
		ROWTERMINATOR   = ''\n''
	);'

	EXEC sp_executesql @Ds_Comando

	INSERT INTO [Cep] (
			[Nr_Cep], 
			[Sg_Uf], 
			[Cd_Localidade], 			
			[Cd_Bairro], 			
			[Tp_Logradouro], 
			[Nm_Patente], 
			[Nm_Preposicao], 			
			[Cd_Logradouro], 
			[Nm_Logradouro], 
			[Nm_Abreviatura], 
			[Ds_Info_Adicional]
		)
	SELECT	
		RTRIM(LTRIM(SUBSTRING(Ds_Linha, 247, 8))) AS [Nr_Cep],
		RTRIM(LTRIM(SUBSTRING(Ds_Linha, 2, 2))) AS [Sg_Uf], 
		RTRIM(LTRIM(SUBSTRING(Ds_Linha, 10, 8))) AS [Cd_Localidade], 		
		RTRIM(LTRIM(SUBSTRING(Ds_Linha, 95, 8))) AS [Cd_Bairro], 			
		NULL AS [Tp_Logradouro], 	
		NULL AS [Nm_Patente], 
		NULL AS [Nm_Preposicao], 			
		RTRIM(LTRIM(SUBSTRING(Ds_Linha, 261, 8))) AS [Cd_Logradouro], 
		RTRIM(LTRIM(SUBSTRING(Ds_Linha, 269, 72))) AS [Nm_Logradouro], 
		RTRIM(LTRIM(SUBSTRING(Ds_Linha, 341, 36))) AS [Nm_Abreviatura], 
		NULL AS [Ds_Info_Adicional]
	FROM ##CEP_IMPORTACAO_UNIDADES_OPERACIONAIS
	WHERE SUBSTRING(Ds_Linha, 1, 1) = 'D'


	-------------------------------------------------------------------------------
	--	ARQUIVO: DNE_GU_LOCALIDADES.TXT
	-------------------------------------------------------------------------------
	/*
	(1)	O campo “CEP da Localidade” será preenchido com o valor correspondente caso a localidade não seja codificada por logradouros, 
	isto é, caso os logradouros daquela localidade não tenham CEP individual. Caso a localidade possua CEP por logradouros, este campo ficará vazio.
	*/
	
	IF (OBJECT_ID('tempdb..##CEP_IMPORTACAO_LOCALIDADES') IS NOT NULL)
		DROP TABLE ##CEP_IMPORTACAO_LOCALIDADES

	CREATE TABLE ##CEP_IMPORTACAO_LOCALIDADES (
		Ds_Linha VARCHAR(164)
	)

	SELECT @Nm_Arquivo = @Ds_Caminho_Pasta_Arquivos + 'DNE_GU_LOCALIDADES.TXT'

	-- IMPORTA O ARQUIVO
	SELECT @Ds_Comando = 'BULK INSERT ##CEP_IMPORTACAO_LOCALIDADES
	FROM ''' + @Nm_Arquivo + '''
	WITH 
	(
		CODEPAGE		= ''1252'',
		DATAFILETYPE    = ''char'',
		ROWTERMINATOR   = ''\n''
	);'

	EXEC sp_executesql @Ds_Comando

	INSERT INTO [Localidade] (
			[Nr_Cep], 
			[Sg_Uf], 
			[Cd_Localidade], 
			[Nm_Localidade], 
			[Nm_Abreviatura]
		)
	SELECT
		CASE SUBSTRING(Ds_Linha, 92, 8) WHEN REPLICATE(' ', 8)
				THEN NULL
				ELSE RTRIM(LTRIM(SUBSTRING(Ds_Linha, 92, 8)))
		END	AS [Nr_Cep],		 		
		RTRIM(LTRIM(SUBSTRING(Ds_Linha, 4, 2))) AS [Sg_Uf], 
		RTRIM(LTRIM(SUBSTRING(Ds_Linha, 12, 8))) AS [Cd_Localidade], 
		RTRIM(LTRIM(SUBSTRING(Ds_Linha, 20, 72))) AS [Nm_Localidade], 		
		RTRIM(LTRIM(SUBSTRING(Ds_Linha, 100, 36))) AS [Nm_Abreviatura]
	FROM ##CEP_IMPORTACAO_LOCALIDADES
	WHERE 
		SUBSTRING(Ds_Linha, 1, 1) = 'D'


	-------------------------------------------------------------------------------
	--	ARQUIVO: DNE_GU_BAIRROS.TXT
	-------------------------------------------------------------------------------	
	IF (OBJECT_ID('tempdb..##CEP_IMPORTACAO_BAIRROS') IS NOT NULL)
		DROP TABLE ##CEP_IMPORTACAO_BAIRROS

	CREATE TABLE ##CEP_IMPORTACAO_BAIRROS (
		Ds_Linha VARCHAR(213)
	)

	SELECT @Nm_Arquivo = @Ds_Caminho_Pasta_Arquivos + 'DNE_GU_BAIRROS.TXT'

	-- IMPORTA O ARQUIVO
	SELECT @Ds_Comando = 'BULK INSERT ##CEP_IMPORTACAO_BAIRROS
	FROM ''' + @Nm_Arquivo + '''
	WITH 
	(
		CODEPAGE		= ''1252'',
		DATAFILETYPE    = ''char'',
		ROWTERMINATOR   = ''\n''
	);'

	EXEC sp_executesql @Ds_Comando

	INSERT INTO [Bairro] (			 
			[Sg_Uf], 
			[Cd_Localidade], 
			[Cd_Bairro], 
			[Nm_Bairro], 
			[Nm_Bairro_Abrev]
		)
	SELECT	
		RTRIM(LTRIM(SUBSTRING(Ds_Linha, 2, 2))) AS [Sg_Uf], 
		RTRIM(LTRIM(SUBSTRING(Ds_Linha, 10, 8))) AS [Cd_Localidade], 
		RTRIM(LTRIM(SUBSTRING(Ds_Linha, 95, 8))) AS [Cd_Bairro],
		RTRIM(LTRIM(SUBSTRING(Ds_Linha, 103, 72))) AS [Nm_Bairro], 		
		RTRIM(LTRIM(SUBSTRING(Ds_Linha, 175, 36))) AS [Nm_Bairro_Abrev]
	FROM ##CEP_IMPORTACAO_BAIRROS
	WHERE 
		SUBSTRING(Ds_Linha, 1, 1) = 'D'
	

	-------------------------------------------------------------------------------
	--	ARQUIVO: DNE_GU_UNIDADES_FEDERACAO.TXT
	-------------------------------------------------------------------------------	
	IF (OBJECT_ID('tempdb..##CEP_IMPORTACAO_ESTADOS') IS NOT NULL)
		DROP TABLE ##CEP_IMPORTACAO_ESTADOS

	CREATE TABLE ##CEP_IMPORTACAO_ESTADOS (
		Ds_Linha VARCHAR(120)
	)

	SELECT @Nm_Arquivo = @Ds_Caminho_Pasta_Arquivos + 'DNE_GU_UNIDADES_FEDERACAO.TXT'

	-- IMPORTA O ARQUIVO
	SELECT @Ds_Comando = 'BULK INSERT ##CEP_IMPORTACAO_ESTADOS
	FROM ''' + @Nm_Arquivo + '''
	WITH 
	(
		CODEPAGE		= ''1252'',
		DATAFILETYPE    = ''char'',
		ROWTERMINATOR   = ''\n''
	);'

	EXEC sp_executesql @Ds_Comando

	INSERT INTO [Estado] (			 
			[Sg_Pais], 
			[Sg_Uf], 
			[Cd_Uf], 
			[Nm_Estado]
		)
	SELECT	
		RTRIM(LTRIM(SUBSTRING(Ds_Linha, 2, 2))) AS [Sg_Pais], 
		RTRIM(LTRIM(SUBSTRING(Ds_Linha, 4, 2))) AS [Sg_Uf], 
		RTRIM(LTRIM(SUBSTRING(Ds_Linha, 8, 2))) AS [Cd_Uf],
		RTRIM(LTRIM(SUBSTRING(Ds_Linha, 10, 72))) AS [Nm_Estado]
	FROM ##CEP_IMPORTACAO_ESTADOS
	WHERE 
		SUBSTRING(Ds_Linha, 1, 1) = 'D'


	-------------------------------------------------------------------------------
	--	ARQUIVO: DNE_GU_PAISES.TXT
	-------------------------------------------------------------------------------	
	IF (OBJECT_ID('tempdb..##CEP_IMPORTACAO_PAIS') IS NOT NULL)
		DROP TABLE ##CEP_IMPORTACAO_PAIS

	CREATE TABLE ##CEP_IMPORTACAO_PAIS (
		Ds_Linha VARCHAR(261)
	)

	SELECT @Nm_Arquivo = @Ds_Caminho_Pasta_Arquivos + 'DNE_GU_PAISES.TXT'

	-- IMPORTA O ARQUIVO
	SELECT @Ds_Comando = 'BULK INSERT ##CEP_IMPORTACAO_PAIS
	FROM ''' + @Nm_Arquivo + '''
	WITH 
	(
		CODEPAGE		= ''1252'',
		DATAFILETYPE    = ''char'',
		ROWTERMINATOR   = ''\n''
	);'

	EXEC sp_executesql @Ds_Comando

	INSERT INTO [Pais] (			 
			[Sg_Pais], 
			[Sg_Pais_2], 
			[Nm_Pais], 
			[Nm_Pais_ENG],
			[Nm_Pais_FRA]
		)
	SELECT	
		RTRIM(LTRIM(SUBSTRING(Ds_Linha, 2, 2))) AS [Sg_Pais], 
		RTRIM(LTRIM(SUBSTRING(Ds_Linha, 4, 3))) AS [Sg_Pais_2], 
		RTRIM(LTRIM(SUBSTRING(Ds_Linha, 7, 72))) AS [Nm_Pais],
		RTRIM(LTRIM(SUBSTRING(Ds_Linha, 79, 72))) AS [Nm_Pais_ENG],
		RTRIM(LTRIM(SUBSTRING(Ds_Linha, 151, 72))) AS [Nm_Pais_FRA]
	FROM ##CEP_IMPORTACAO_PAIS
	WHERE 
		SUBSTRING(Ds_Linha, 1, 1) = 'D'
	

	-------------------------------------------------------------------------------
	--	ARQUIVO: DNE_GU_TIPOS_LOGRADOURO.TXT
	-------------------------------------------------------------------------------	
	IF (OBJECT_ID('tempdb..##CEP_IMPORTACAO_TIPO_LOGRADOURO') IS NOT NULL)
		DROP TABLE ##CEP_IMPORTACAO_TIPO_LOGRADOURO

	CREATE TABLE ##CEP_IMPORTACAO_TIPO_LOGRADOURO (
		Ds_Linha VARCHAR(97)
	)

	SELECT @Nm_Arquivo = @Ds_Caminho_Pasta_Arquivos + 'DNE_GU_TIPOS_LOGRADOURO.TXT'

	-- IMPORTA O ARQUIVO
	SELECT @Ds_Comando = 'BULK INSERT ##CEP_IMPORTACAO_TIPO_LOGRADOURO
	FROM ''' + @Nm_Arquivo + '''
	WITH 
	(
		CODEPAGE		= ''1252'',
		DATAFILETYPE    = ''char'',
		ROWTERMINATOR   = ''\n''
	);'

	EXEC sp_executesql @Ds_Comando

	INSERT INTO [Tipo_Logradouro] (		
			[Cd_Tipo_Logradouro],
			[Tp_Logradouro], 
			[Tp_Logradouro_Abrev]
		)
	SELECT	
		RTRIM(LTRIM(SUBSTRING(Ds_Linha, 5, 3))) AS [Cd_Tipo_Logradouro], 
		RTRIM(LTRIM(SUBSTRING(Ds_Linha, 8, 26))) AS [Tp_Logradouro], 
		RTRIM(LTRIM(SUBSTRING(Ds_Linha, 80, 15))) AS [Tp_Logradouro_Abrev]
	FROM ##CEP_IMPORTACAO_TIPO_LOGRADOURO
	WHERE 
		SUBSTRING(Ds_Linha, 1, 1) = 'D'
	

	-------------------------------------------------------------------------------
	--	ARQUIVO: DNE_GU_TITULOS_PATENTES.TXT
	-------------------------------------------------------------------------------	
	IF (OBJECT_ID('tempdb..##CEP_IMPORTACAO_TITULO_PATENTE') IS NOT NULL)
		DROP TABLE ##CEP_IMPORTACAO_TITULO_PATENTE

	CREATE TABLE ##CEP_IMPORTACAO_TITULO_PATENTE (
		Ds_Linha VARCHAR(97)
	)

	SELECT @Nm_Arquivo = @Ds_Caminho_Pasta_Arquivos + 'DNE_GU_TITULOS_PATENTES.TXT'

	-- IMPORTA O ARQUIVO
	SELECT @Ds_Comando = 'BULK INSERT ##CEP_IMPORTACAO_TITULO_PATENTE
	FROM ''' + @Nm_Arquivo + '''
	WITH 
	(
		CODEPAGE		= ''1252'',
		DATAFILETYPE    = ''char'',
		ROWTERMINATOR   = ''\n''
	);'

	EXEC sp_executesql @Ds_Comando

	INSERT INTO [Titulo_Patente] (		
			[Cd_Titulo_Patente],
			[Nm_Patente], 
			[Nm_Patente_Abrev]
		)
	SELECT	
		RTRIM(LTRIM(SUBSTRING(Ds_Linha, 5, 4))) AS [Cd_Titulo_Patente], 
		RTRIM(LTRIM(SUBSTRING(Ds_Linha, 9, 72))) AS [Nm_Patente], 
		RTRIM(LTRIM(SUBSTRING(Ds_Linha, 81, 15))) AS [Nm_Patente_Abrev]
	FROM ##CEP_IMPORTACAO_TITULO_PATENTE
	WHERE 
		SUBSTRING(Ds_Linha, 1, 1) = 'D'

	-------------------------------------------------------------------------------
	--	CRIA RELACIONAMENTOS ENTRE AS TABELAS
	-------------------------------------------------------------------------------	
	ALTER TABLE [Estado]
	ADD CONSTRAINT [FK_Estado_Pais]
	FOREIGN KEY ([Sg_Pais])
	REFERENCES [Pais]([Sg_Pais])

	ALTER TABLE [Bairro]
	ADD CONSTRAINT [FK_Bairro_Estado]
	FOREIGN KEY ([Sg_Uf])
	REFERENCES [Estado]([Sg_Uf])

	ALTER TABLE [Bairro]
	ADD CONSTRAINT [FK_Bairro_Localidade]
	FOREIGN KEY ([Cd_Localidade])
	REFERENCES [Localidade]([Cd_Localidade])

	ALTER TABLE [Localidade]
	ADD CONSTRAINT [FK_Localidade_Estado]
	FOREIGN KEY ([Sg_Uf])
	REFERENCES [Estado]([Sg_Uf])

	ALTER TABLE [Cep]
	ADD CONSTRAINT [FK_Cep_Estado]
	FOREIGN KEY ([Sg_Uf])
	REFERENCES [Estado]([Sg_Uf])

	ALTER TABLE [Cep]
	ADD CONSTRAINT [FK_Cep_Localidade]
	FOREIGN KEY ([Cd_Localidade])
	REFERENCES [Localidade]([Cd_Localidade])

	ALTER TABLE [Cep]
	ADD CONSTRAINT [FK_Cep_Bairro]
	FOREIGN KEY ([Cd_Bairro])
	REFERENCES [Bairro]([Cd_Bairro])

	ALTER TABLE [Cep]
	ADD CONSTRAINT [FK_Cep_Tipo_Logradouro]
	FOREIGN KEY ([Tp_Logradouro])
	REFERENCES [Tipo_Logradouro]([Tp_Logradouro])

	ALTER TABLE [Cep]
	ADD CONSTRAINT [FK_Cep_Titulo_Patente]
	FOREIGN KEY ([Nm_Patente])
	REFERENCES [Titulo_Patente]([Nm_Patente])
END
GO