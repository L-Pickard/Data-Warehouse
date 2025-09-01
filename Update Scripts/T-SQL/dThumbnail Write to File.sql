SELECT tp.[New File Name] AS [File Name]
	  ,tp.[Item No]
	  ,it.[Common Item No]
	  ,it.[Vendor Reference]
	  ,it.[Brand Code]
	  ,it.[Description]
	  ,it.[Description 2]
	  ,it.[Colours]
	  ,it.[Size 1]
	  ,it.[Size 1 Unit]
	  ,it.[UOM] AS [Unit of Measure]
	  ,it.[Season]
	  ,it.[Category Code] AS [Category]
	  ,it.[Group Code] AS [Group]
	  ,it.[EAN Barcode] AS [EAN]
	  ,it.[Tariff No]
	  ,it.[COO]

FROM [dThumbnail Process] AS tp
LEFT JOIN [dItem] AS it
	ON tp.[Item No] = it.[Item No];