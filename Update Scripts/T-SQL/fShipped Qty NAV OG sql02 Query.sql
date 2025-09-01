SELECT 'Org Ltd' AS 'Entity'
	,[No_] AS 'Item No'
	,[Shipped in Last 360 Days]
	,[Shipped in Last 180 Days]
	,[Shipped 331 to 360 Days Ago]
	,[Shipped 301 to 330 Days Ago]
	,[Shipped 271 to 300 Days Ago]
	,[Shipped 241 to 270 Days Ago]
	,[Shipped 211 to 240 Days Ago]
	,[Shipped 181 to 210 Days Ago]
	,[Shipped 151 to 180 Days Ago]
	,[Shipped 121 to 150 Days Ago]
	,[Shipped 91 to 120 Days Ago]
	,[Shipped 61 to 90 Days Ago]
	,[Shipped 31 to 60 Days Ago]
	,[Shipped 1 to 30 Days Ago]
	,[Shipped 30 Day Avg_] AS 'Shipped 30 Day Avg'
	,[Shipped 30 Day Avg 6M_] AS 'Shipped 30 Day Avg 6M'

FROM [Item]

WHERE [No_] <> ''
	AND [Shipped in Last 360 Days] > 0


UNION ALL

SELECT 'Org B.V' AS 'Entity'
	,[No_] AS 'Item No'
	,[Shipped in Last 360 Days]
	,[Shipped in Last 180 Days]
	,[Shipped 331 to 360 Days Ago]
	,[Shipped 301 to 330 Days Ago]
	,[Shipped 271 to 300 Days Ago]
	,[Shipped 241 to 270 Days Ago]
	,[Shipped 211 to 240 Days Ago]
	,[Shipped 181 to 210 Days Ago]
	,[Shipped 151 to 180 Days Ago]
	,[Shipped 121 to 150 Days Ago]
	,[Shipped 91 to 120 Days Ago]
	,[Shipped 61 to 90 Days Ago]
	,[Shipped 31 to 60 Days Ago]
	,[Shipped 1 to 30 Days Ago]
	,[Shipped 30 Day Avg_] AS 'Shipped 30 Day Avg'
	,[Shipped 30 Day Avg 6M_] AS 'Shipped 30 Day Avg 6M'

FROM [EU Item]

WHERE [No_] <> ''
	AND [Shipped in Last 360 Days] > 0;