WITH CTE_POReserve
AS (
	SELECT 'Org Ltd' AS [Entity]
		,[Item No_]
		,[Source ID]
		,SUM([Quantity]) AS [Qty]
	
	FROM [Entry Reservation]
	
	WHERE [Source Type] = 39
	
	GROUP BY [Item No_]
		,[Source ID]
	
	
	UNION ALL
	
	SELECT 'Org B.V' AS [Entity]
		,[Item No_]
		,[Source ID]
		,SUM([Quantity]) AS [Qty]
	
	FROM [EU Entry Reservation]
	
	WHERE [Source Type] = 39
	
	GROUP BY [Item No_]
		,[Source ID]
	)
	,CTE_Combined
AS (
	SELECT pl.[Expected Receipt Date] AS [ETA Date]
		,pl.[Document No_] AS [Document No]
		,pl.[Buy-from Vendor No_] AS [Vendor No]
		,pl.[Location Code]
		,ph.[Your Reference]
		,ph.[Vendor Invoice No_] AS [Invoice No]
		,pl.[No_] AS [Item No]
		,'Org Ltd' AS [Entity]
		,CASE 
			WHEN ph.[Currency Code] = ''
				THEN 'GBP'
			ELSE ph.[Currency Code]
			END AS [Currency]
		,CAST(SUM(pl.[Quantity]) AS INTEGER) AS [Quantity]
		,CAST(SUM(pl.[Line Amount]) AS DECIMAL(20, 8)) AS [Line Total]
		,CAST(SUM(pl.[Quantity Received]) AS INTEGER) AS [Qty Received]
		,CAST(SUM(pl.[Quantity] - pl.[Quantity Received]) AS INTEGER) AS [Outstanding Qty]
		,CAST(SUM(pl.[Outstanding Amount]) AS DECIMAL(20, 8)) AS [Outstanding Value]
	
	FROM [Line Purchase] AS pl
	
	LEFT JOIN [Header Purchase] AS ph
		ON pl.[Document No_] = ph.[No_]
	
	WHERE pl.[Type] = 2
		AND pl.[Document Type] = 1
	
	GROUP BY pl.[Expected Receipt Date]
		,pl.[Document No_]
		,pl.[Buy-from Vendor No_]
		,pl.[Location Code]
		,ph.[Your Reference]
		,ph.[Vendor Invoice No_]
		,pl.[No_]
		,CASE 
			WHEN ph.[Currency Code] = ''
				THEN 'GBP'
			ELSE ph.[Currency Code]
			END
	
	
	UNION ALL
	
	SELECT pl.[Expected Receipt Date] AS [ETA Date]
		,pl.[Document No_] AS [Document No]
		,pl.[Buy-from Vendor No_] AS [Vendor No]
		,pl.[Location Code]
		,ph.[Your Reference]
		,ph.[Vendor Invoice No_] AS [Invoice No]
		,pl.[No_] AS [Item No]
		,'Org B.V' AS [Entity]
		,CASE 
			WHEN ph.[Currency Code] = ''
				THEN 'EUR'
			ELSE ph.[Currency Code]
			END AS [Currency]
		,CAST(SUM(pl.[Quantity]) AS INTEGER) AS [Quantity]
		,CAST(SUM(pl.[Line Amount]) AS DECIMAL(20, 8)) AS [Line Total]
		,CAST(SUM(pl.[Quantity Received]) AS INTEGER) AS [Qty Received]
		,CAST(SUM(pl.[Quantity] - pl.[Quantity Received]) AS INTEGER) AS [Outstanding Qty]
		,CAST(SUM(pl.[Outstanding Amount]) AS DECIMAL(20, 8)) AS [Outstanding Value]
	
	FROM [EU Line Purchase] AS pl
	
	LEFT JOIN [EU Header Purchase] AS ph
		ON pl.[Document No_] = ph.[No_]
	
	WHERE pl.[Type] = 2
		AND pl.[Document Type] = 1
	
	GROUP BY pl.[Expected Receipt Date]
		,pl.[Document No_]
		,pl.[Buy-from Vendor No_]
		,pl.[Location Code]
		,ph.[Your Reference]
		,ph.[Vendor Invoice No_]
		,pl.[No_]
		,CASE 
			WHEN ph.[Currency Code] = ''
				THEN 'EUR'
			ELSE ph.[Currency Code]
			END
	)

SELECT pl.[Entity]
	,CAST(pl.[ETA Date] AS DATE) AS [ETA Date]
	,pl.[Document No]
	,pl.[Vendor No]
	,pl.[Location Code]
	,pl.[Your Reference]
	,pl.[Invoice No]
	,pl.[Item No]
	,pl.[Currency]
	,pl.[Quantity]
	,pl.[Line Total]
	,pl.[Qty Received]
	,pl.[Outstanding Qty]
	,pl.[Outstanding Value]
	,CAST(ISNULL(pr.[Qty], 0) AS INTEGER) AS [Reserved Qty]
	,CAST(pl.[Outstanding Qty] - ISNULL(pr.[Qty], 0) AS INTEGER) AS [PO Freestock]

FROM CTE_Combined AS pl

LEFT JOIN CTE_POReserve AS pr
	ON pl.[Document No] = pr.[Source ID]
		AND pl.[Item No] = pr.[Item No_]
		AND pl.[Entity] = pr.[Entity];