USE CEP

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[vwCep]
AS

SELECT
	C.Nr_Cep, 
	C.Sg_Uf, 
	L.Nm_Localidade, 
	B.Nm_Bairro, 
	C.Tp_Logradouro,
	C.Nm_Patente, 
	C.Nm_Preposicao,
	C.Nm_Logradouro,
	C.Nm_Abreviatura,
	C.Ds_Info_Adicional
FROM Cep C
JOIN Localidade L ON C.Cd_Localidade = L.Cd_Localidade
JOIN Bairro B ON C.Cd_Bairro = B.Cd_Bairro;
