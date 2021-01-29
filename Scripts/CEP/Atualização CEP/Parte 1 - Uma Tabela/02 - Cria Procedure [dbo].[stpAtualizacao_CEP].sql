USE CEP

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- ================================================================================
-- PROCEDURE UTILIZADA PARA ATUALIZAR AS TABELAS DE CEP!
-- O RESULTADO DELA SERA APENAS UMA TABELA CHAMADA "Cep_New" QUE DEVE SER UTILIZADA PARA ATUALIZAR A TABELA DE PRODUÇÃO DEPOIS.
-- CRIADO POR: LUIZ VITOR
-- DATA: 06/01/2021

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
	-- CRIA A NOVA TABELA DO CEP
	-------------------------------------------------------------------------------
	IF(OBJECT_ID('Cep_New') IS NOT NULL)
		DROP TABLE Cep_New

	CREATE TABLE [dbo].[Cep_New] (
		[Nr_Cep] [char](8) NOT NULL,
		[Sg_Uf] [char](2) NOT NULL,
		[Cd_Localidade] [int] NOT NULL,
		[Nm_Localidade] [varchar](72) NOT NULL,
		[Cd_Bairro] [int] NULL,
		[Nm_Bairro] [varchar](72) NULL,
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
	
		INSERT INTO Cep_New (
			[Nr_Cep], 
			[Sg_Uf], 
			[Cd_Localidade], 
			[Nm_Localidade], 
			[Cd_Bairro], 
			[Nm_Bairro], 
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
			RTRIM(LTRIM(SUBSTRING(Ds_Linha, 18, 72))) AS [Nm_Localidade], 
			RTRIM(LTRIM(SUBSTRING(Ds_Linha, 95, 8))) AS [Cd_Bairro], 
			RTRIM(LTRIM(SUBSTRING(Ds_Linha, 103, 72))) AS [Nm_Bairro], 
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

	INSERT INTO Cep_New (
			[Nr_Cep], 
			[Sg_Uf], 
			[Cd_Localidade], 
			[Nm_Localidade], 
			[Cd_Bairro], 
			[Nm_Bairro], 
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
		RTRIM(LTRIM(SUBSTRING(Ds_Linha, 18, 72))) AS [Nm_Localidade], 
		RTRIM(LTRIM(SUBSTRING(Ds_Linha, 95, 8))) AS [Cd_Bairro], 
		RTRIM(LTRIM(SUBSTRING(Ds_Linha, 103, 72))) AS [Nm_Bairro], 		
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

	INSERT INTO Cep_New (
			[Nr_Cep], 
			[Sg_Uf], 
			[Cd_Localidade], 
			[Nm_Localidade], 
			[Cd_Bairro], 
			[Nm_Bairro], 
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
		RTRIM(LTRIM(SUBSTRING(Ds_Linha, 18, 72))) AS [Nm_Localidade], 
		NULL AS [Cd_Bairro], 
		NULL AS [Nm_Bairro], 		
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

	INSERT INTO Cep_New (
			[Nr_Cep], 
			[Sg_Uf], 
			[Cd_Localidade], 
			[Nm_Localidade], 
			[Cd_Bairro], 
			[Nm_Bairro], 
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
		RTRIM(LTRIM(SUBSTRING(Ds_Linha, 18, 72))) AS [Nm_Localidade], 
		RTRIM(LTRIM(SUBSTRING(Ds_Linha, 95, 8))) AS [Cd_Bairro], 
		RTRIM(LTRIM(SUBSTRING(Ds_Linha, 103, 72))) AS [Nm_Bairro], 		
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

	INSERT INTO Cep_New (
			[Nr_Cep], 
			[Sg_Uf], 
			[Cd_Localidade], 
			[Nm_Localidade], 
			[Cd_Bairro], 
			[Nm_Bairro], 
			[Tp_Logradouro], 
			[Nm_Patente], 
			[Nm_Preposicao], 			
			[Cd_Logradouro], 
			[Nm_Logradouro], 
			[Nm_Abreviatura], 
			[Ds_Info_Adicional]
		)
	SELECT
		RTRIM(LTRIM(SUBSTRING(Ds_Linha, 92, 8))) AS [Nr_Cep], 		
		RTRIM(LTRIM(SUBSTRING(Ds_Linha, 4, 2))) AS [Sg_Uf], 
		RTRIM(LTRIM(SUBSTRING(Ds_Linha, 12, 8))) AS [Cd_Localidade], 
		RTRIM(LTRIM(SUBSTRING(Ds_Linha, 20, 72))) AS [Nm_Localidade], 
		NULL AS [Cd_Bairro], 
		NULL AS [Nm_Bairro], 		
		NULL AS [Tp_Logradouro], 	
		NULL AS [Nm_Patente], 
		NULL AS [Nm_Preposicao], 			
		NULL AS [Cd_Logradouro], 
		RTRIM(LTRIM(SUBSTRING(Ds_Linha, 20, 72))) AS [Nm_Logradouro], 
		RTRIM(LTRIM(SUBSTRING(Ds_Linha, 100, 36))) AS [Nm_Abreviatura], 
		NULL AS [Ds_Info_Adicional]
	FROM ##CEP_IMPORTACAO_LOCALIDADES
	WHERE 
		SUBSTRING(Ds_Linha, 1, 1) = 'D'
		AND SUBSTRING(Ds_Linha, 92, 8) <> REPLICATE(' ', 8) -- APENAS CEP GERAL
END
GO