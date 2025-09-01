SELECT 'Org LLC' AS [Entity]
    ,we.[Item No_] AS [Item No]
	,CAST(SUM(we.[Quantity]) - ISNULL((
			SELECT sum([Quantity])
			FROM [dbo].[US Entry Reservation]
			WHERE [Item No_] = we.[Item No_]
				AND [Source Type] = 32
				AND -- ILE
				[Source Subtype] = 0
				AND [Reservation Status] = 0
				AND -- Reservation
				[Location Code] = 'POMONA'
			), 0) AS INTEGER) AS 'Free Stock'
	,CAST(SUM(we.[Quantity]) AS INTEGER) AS 'Inventory'
FROM [US Entry Warehouse] AS we
GROUP BY [Item No_]
HAVING SUM([Quantity]) > 0;