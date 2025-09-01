SELECT tp.[Id]
      ,tp.[Item No]
      ,tp.[Old File Name]
      ,tp.[New File Name]
	  ,it.[Common Item No]
	  ,it.[Vendor Reference]
	  ,it.[Brand Code]
	  ,it.[Description]
	  ,it.[Description 2]
	  ,it.[Colours]
	  ,it.[Size 1]
	  ,it.[Size 1 Unit]
	  ,it.[UOM]
	  ,it.[Season]
	  ,it.[Category Code]
	  ,it.[Group Code]
	  ,it.[EAN Barcode]
	  ,it.[Tariff No]
	  ,it.[COO]

FROM [dThumbnail Process] AS tp
LEFT JOIN [dItem] AS it
	ON tp.[Item No] = it.[Item No];