USE CEP

EXEC [dbo].[stpAtualizacao_Cep] @Ds_Caminho_Pasta_Arquivos = 'C:\SQLServer\CEP\Fixo\'

/*
-- CONFERE O RESULTADO FINAL:

SELECT TOP 100 *
FROM Cep_New
*-/