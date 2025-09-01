SELECT it.[No_] AS [Item No]
	,LEFT(it.No_, 3) AS [Brand Code]
	,it.[Vendor Item No_] AS [Vendor Reference]
	,it.[Description]
	,it.[Description 2]
	,'' AS [Colours]
	,'' AS [Size 1]
	,'' AS [Size 1 Unit]
	,'' AS [EU Size]
	,'' AS [EU Size Unit]
	,'' AS [US Size]
	,'' AS [US Size Unit]
	,it.[Base Unit of Measure] AS [UOM]
	,'' AS [Season]
	,'US Item Only' AS [Item Info]
	,'' AS [Category]
	,REPLACE(LEFT(it.[Item Category Code], CHARINDEX(CHAR(95), it.[Item Category Code])), CHAR(95), '') AS [Category Code]
	,'' AS [Group]
	,SUBSTRING(it.[Item Category Code], CHARINDEX(CHAR(95), it.[Item Category Code]) + 1, LEN(it.[Item Category Code]) - CHARINDEX(CHAR(95), it.
			[Item Category Code])) AS [Group Code]
	,it.[GTIN] AS [EAN Barcode]
	,'' AS [Tariff No]
	,it.[Tariff No_] AS [HTS No]
	,CONCAT (
		it.[Description]
		,'-'
		,it.[Description 2]
		,'-'
		,it.[Vendor Item No_]
		,REPLACE(LEFT(it.[Item Category Code], CHARINDEX(CHAR(95), it.[Item Category Code])), CHAR(95), '')
		,'-'
		,SUBSTRING(it.[Item Category Code], CHARINDEX(CHAR(95), it.[Item Category Code]) + 1, LEN(it.[Item Category Code]) - CHARINDEX(CHAR(95), it.
				[Item Category Code]))
		) AS [Style Ref]
	,0 AS [GBP Trade]
	,0 AS [GBP SRP]
	,0 AS [EUR Trade]
	,0 AS [EUR SRP]
	,it.[Unit Price] AS [USD Trade]
	,rp.[RRP] AS [USD SRP]
	,'' AS [Nav Vendor No]
	,it.[Vendor No_] AS [BC Vendor No]
	,ve.[Name] AS [Vendor Name]
	,0 AS [Ltd Blocked]
	,0 AS [B.V Blocked]
	,it.[Blocked] AS [LLC Blocked]
	,0 AS [On Sale]
	,0 AS [Hot Product]
	,'' AS [Lead Time]
	,it.[Country_Region of Origin Code] AS [COO]
	,0 AS [Bread & Butter]
	,0 AS [Ltd Buffer Stock]
	,0 AS [B.V Buffer Stock]
	,0 AS [LLC Buffer Stock]
	,'' AS [Common Item No]
	,0 AS [Ltd GBP Unit Cost]
	,0 AS [B.V EUR Unit Cost]
	,0 AS [LLC USD Unit Cost]
	,0 AS [D2C Web Item]
	,0 AS [Owtanet Export]
	,0 AS [Web Item]
	,NULL AS [Record ID]

FROM [US Item] AS it

LEFT JOIN [US Item Ext] AS rp
	ON it.[No_] = rp.No_

LEFT JOIN [US Vendor] AS ve
	ON it.[Vendor No_] = ve.No_

WHERE LEN(it.[No_]) <= 30;