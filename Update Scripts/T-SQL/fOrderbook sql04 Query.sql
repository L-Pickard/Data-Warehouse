/*===============================================================================================================================================
Project: Data Warehouse - fOrderbook US
Language: T-SQL
Author: Leo Pickard
Version: 1.0
Date: 31/07/2024
=================================================================================================================================================
This query will run against US server each day to update the forderbook table in warehouse db.
================================================================================================================================================*/
WITH LLC_Reservations
AS (
	SELECT CASE 
			WHEN rs.[Source Type] = 32
				THEN 'Item Ledger'
			WHEN rs.[Source Type] = 39
				THEN 'Purchase Order'
			ELSE NULL
			END AS [Reservation Type]
		,re.[Item No_] AS [Item No]
		,re.[Location Code]
		,re.[Source ID]
		,ABS(SUM(re.[Quantity])) AS [Quantity]
	
	FROM [US Entry Reservation] AS re
	
	LEFT JOIN [US Entry Reservation] AS rs
		ON re.[Entry No_] = rs.[Entry No_]
			AND re.[Item No_] = rs.[Item No_]
			AND re.[Location Code] = rs.[Location Code]
			AND rs.[Source Type] <> 37
	
	WHERE re.[Source Type] = 37
	
	GROUP BY CASE 
			WHEN rs.[Source Type] = 32
				THEN 'Item Ledger'
			WHEN rs.[Source Type] = 39
				THEN 'Purchase Order'
			ELSE NULL
			END
		,rs.[Source Type]
		,re.[Item No_]
		,re.[Location Code]
		,re.[Source ID]
	)
	,Orderbook
AS (
	SELECT 'Org LLC' AS [Entity]
		,sl.[Document No_] AS [Document No]
		,CAST(sh.[Order Date] AS DATE) AS [Order Date]
		,sl.[Location Code]
		,sl.[Sell-to Customer No_] AS [Customer No]
		,sh.[Sell-to Customer Name] AS [Customer Name]
		,sh.[Salesperson Code]
		,CAST(sh.[Shipment Date] AS DATE) AS [Shipment Date]
		,sr.[Shiner Reference] AS [Shiner Ref]
		,sh.[Your Reference]
		,sh.[Ship-to Country_Region Code] AS [Country Code]
		,sl.[No_] AS [Item No]
		,CASE 
			WHEN sh.[Currency Code] = ''
				THEN 'USD'
			ELSE sh.[Currency Code]
			END AS 'Currency'
		,CAST(SUM(sl.[Quantity]) AS INTEGER) AS [Quantity]
		,CAST(SUM(sl.[Line Amount]) AS DECIMAL(20, 8)) AS [Line Total]
		,CAST(SUM(sl.[Outstanding Quantity]) AS DECIMAL(20, 8)) AS [Outstanding Qty]
		,ISNULL(CAST((SUM(sl.[Line Amount]) / NULLIF(SUM(sl.[Quantity]), 0)) * SUM(sl.[Outstanding Quantity]) AS DECIMAL(20, 8)), 0) AS 
		[Outstanding Value]
		,CAST(ISNULL(SUM(ir.[Quantity]), 0) AS INTEGER) AS [Item Ledger Qty]
		,CAST(ISNULL(SUM(pr.[Quantity]), 0) AS INTEGER) AS [PO Qty]
		,CASE 
			WHEN SUM(ir.[Quantity]) >= SUM(sl.[Outstanding Quantity])
				THEN 'SKU Ready'
			WHEN ISNULL(SUM(pr.[Quantity]), 0) >= SUM(sl.[Outstanding Quantity])
				AND SUM(sl.[Outstanding Quantity]) > 0
				THEN 'SKU PO Reserved'
			WHEN ISNULL(SUM(ir.[Quantity]), 0) > 0
				AND ISNULL(SUM(ir.[Quantity]), 0) < SUM(sl.[Outstanding Quantity])
				AND (ISNULL(SUM(ir.[Quantity]), 0) + ISNULL(SUM(pr.[Quantity]), 0)) = SUM(sl.[Outstanding Quantity])
				THEN 'SKU Mixed Reservations'
			WHEN ISNULL(SUM(ir.[Quantity]), 0) + ISNULL(SUM(pr.[Quantity]), 0) > 0
				AND ISNULL(SUM(ir.[Quantity]), 0) + ISNULL(SUM(pr.[Quantity]), 0) < SUM(sl.[Outstanding Quantity])
				THEN 'SKU Not Fully Reserved'
			WHEN ISNULL(SUM(ir.[Quantity]), 0) + ISNULL(SUM(Pr.[Quantity]), 0) = 0
				THEN 'Not Reserved'
			ELSE NULL
			END AS [SKU Status]
		,CASE 
			WHEN sh.[Status] = 0
				THEN 'Open'
			WHEN sh.[Status] = 1
				THEN 'Released'
			WHEN sh.[Status] = 2
				THEN 'Pending Aproval'
			END AS [Release Status]
		,CASE 
			WHEN SUBSTRING(sr.[Shiner Reference], CHARINDEX('_', sr.[Shiner Reference]), 6) = '_STOCK'
				THEN 1
			ELSE 0
			END AS [Pre Order]
	
	FROM [US Line Sales] AS sl
	
	LEFT JOIN [US Header Sales] AS sh
		ON sl.[Document No_] = sh.No_
	
	LEFT JOIN [US Header Sales] AS sr
		ON sl.[Document No_] = sr.No_
	
	LEFT JOIN LLC_Reservations AS ir
		ON sl.[No_] = ir.[Item No]
			AND sl.[Location Code] = ir.[Location Code]
			AND sl.[Document No_] = ir.[Source ID]
			AND ir.[Reservation Type] = 'Item Ledger'
	
	LEFT JOIN LLC_Reservations AS pr
		ON sl.[No_] = pr.[Item No]
			AND sl.[Location Code] = pr.[Location Code]
			AND sl.[Document No_] = pr.[Source ID]
			AND pr.[Reservation Type] = 'Purchase Order'
	
	WHERE sl.[Type] = 2
		AND sl.[Document Type] = 1
	
	GROUP BY [Document No_]
		,sh.[Order Date]
		,sl.[Location Code]
		,sl.[Sell-to Customer No_]
		,sh.[Sell-to Customer Name]
		,sh.[Salesperson Code]
		,sh.[Shipment Date]
		,sr.[Shiner Reference]
		,sh.[Your Reference]
		,sh.[Ship-to Country_Region Code]
		,sh.[Currency Code]
		,sl.[No_]
		,sh.[Status]
		,CASE 
			WHEN SUBSTRING(sr.[Shiner Reference], CHARINDEX('_', sr.[Shiner Reference]), 6) = '_STOCK'
				THEN 1
			ELSE 0
			END
	)

SELECT ob.[Entity]
	,ob.[Document No]
	,ob.[Order Date]
	,ob.[Shipment Date]
	,CASE 
		WHEN ob.[Customer No] IN (
				SELECT [No_]
				
				FROM [US Customer]
				
				WHERE [Name] LIKE '%D2C%'
				)
			THEN ob.[Shipment Date]
		WHEN ob.[Shiner Ref] IS NULL
			THEN ob.[Shipment Date]
		WHEN ob.[Shiner Ref] NOT LIKE '[0-9][0-9][wW][kK][0-9][0-9]%'
			THEN ob.[Shipment Date]
		WHEN ob.[Shiner Ref] LIKE '[0-9][0-9][wW][kK][0-9][0-9]%'
			THEN CAST(DATEADD(DAY, - 1, DATEADD(DAY, (
								8 - DATEPART(WEEKDAY, DATEADD(WEEK, CAST(SUBSTRING(ob.[Shiner Ref], 5, 2) AS INT) - 1, DATEADD(YEAR, (CAST(LEFT(ob.[Shiner Ref], 2) AS INT) + 2000
												) - 1900, 0))) + 1
								) % 7, DATEADD(WEEK, CAST(SUBSTRING(ob.[Shiner Ref], 5, 2) AS INT) - 1, DATEADD(YEAR, (CAST(LEFT(ob.[Shiner Ref], 2) AS INT) + 2000
										) - 1900, 0)))) AS DATE)
		END AS [Reporting Date]
	,ob.[Location Code]
	,ob.[Customer No]
	,ob.[Customer Name]
	,ob.[Salesperson Code]
	,ob.[Shiner Ref]
	,ob.[Your Reference]
	,ob.[Country Code]
	,ob.[Item No]
	,ob.[Currency]
	,ob.[Quantity]
	,ob.[Line Total]
	,ob.[Outstanding Qty]
	,ob.[Outstanding Value]
	,ob.[Item Ledger Qty]
	,ob.[PO Qty]
	,ob.[SKU Status]
	,ob.[Pre Order]
	,CASE 
		WHEN (
				SELECT COUNT(*)
				
				FROM Orderbook
				
				WHERE [Entity] = ob.[Entity]
					AND [Document No] = ob.[Document No]
					AND [Location Code] = ob.[Location Code]
				) = (
				SELECT COUNT(*)
				
				FROM Orderbook
				
				WHERE [Entity] = ob.[Entity]
					AND [Document No] = ob.[Document No]
					AND [Location Code] = ob.[Location Code]
					AND [SKU Status] = 'SKU Ready'
				)
			THEN 'Ready'
		ELSE 'Not Ready'
		END AS 'Order Status'
	,ob.[Release Status]
	,CASE 
		WHEN ob.[Release Status] = 'Released'
			THEN 'Released'
		WHEN ob.[Release Status] = 'Pending Aproval'
			THEN 'Pending Approval'
		WHEN (
				SELECT COUNT(*)
				
				FROM Orderbook
				
				WHERE [Item No] IS NOT NULL
					AND LEFT([Document No], 3) NOT IN ('SRO', 'USR', 'USI', 'SQ-')
					AND [Outstanding Value] > 0
					AND [Document No] = ob.[Document No]
					AND [Entity] = ob.[Entity]
				) = (
				SELECT COUNT(*)
				
				FROM Orderbook
				
				WHERE [Item No] IS NOT NULL
					AND LEFT([Document No], 3) NOT IN ('SRO', 'USR', 'USI', 'SQ-')
					AND [Outstanding Value] > 0
					AND [Document No] = ob.[Document No]
					AND [Entity] = ob.[Entity]
					AND [SKU Status] = 'SKU Ready'
				)
			THEN 'Ready'
		WHEN (
				SELECT COUNT(*)
				
				FROM Orderbook
				
				WHERE [Item No] IS NOT NULL
					AND LEFT([Document No], 3) NOT IN ('SRO', 'USR', 'USI', 'SQ-')
					AND [Outstanding Value] > 0
					AND [Document No] = ob.[Document No]
					AND [Entity] = ob.[Entity]
					AND [SKU Status] = 'SKU Ready'
					AND CASE 
						WHEN (
								SELECT COUNT(*)
								
								FROM Orderbook
								
								WHERE [Entity] = ob.[Entity]
									AND [Document No] = ob.[Document No]
									AND [Location Code] = ob.[Location Code]
								) = (
								SELECT COUNT(*)
								
								FROM Orderbook
								
								WHERE [Entity] = ob.[Entity]
									AND [Document No] = ob.[Document No]
									AND [Location Code] = ob.[Location Code]
									AND [SKU Status] = 'SKU Ready'
								)
							THEN 'Ready'
						ELSE 'Not Ready'
						END = 'Not Ready'
				) > 0
			THEN 'Part Ready'
		WHEN (
				SELECT COUNT(*)
				
				FROM Orderbook
				
				WHERE [Item No] IS NOT NULL
					AND LEFT([Document No], 3) NOT IN ('SRO', 'USR', 'USI', 'SQ-')
					AND [Outstanding Value] > 0
					AND [Document No] = ob.[Document No]
					AND [Entity] = ob.[Entity]
				) = (
				SELECT COUNT(*)
				
				FROM Orderbook
				
				WHERE [Item No] IS NOT NULL
					AND LEFT([Document No], 3) NOT IN ('SRO', 'USR', 'USI', 'SQ-')
					AND [Outstanding Value] > 0
					AND [Document No] = ob.[Document No]
					AND [Entity] = ob.[Entity]
					AND [SKU Status] IN ('SKU PO Reserved', 'SKU Mixed Reservations')
				)
			THEN 'Reserved'
		WHEN (
				SELECT COUNT(*)
				
				FROM Orderbook
				
				WHERE [Item No] IS NOT NULL
					AND LEFT([Document No], 3) NOT IN ('SRO', 'USR', 'USI', 'SQ-')
					AND [Outstanding Value] > 0
					AND [Document No] = ob.[Document No]
					AND [Entity] = ob.[Entity]
					AND [SKU Status] IN ('Not Reserved', 'SKU Not Fully Reserved')
				) > 0
			THEN 'Pending'
		END AS [Sys Status]
	,CASE 
		WHEN ob.[Pre Order] = 0
			AND DATEADD(DAY, 14, ob.[Shipment Date]) < GETDATE()
			THEN 'Overdue'
		WHEN ob.[Pre Order] = 1
			AND DATEADD(DAY, 42, ob.[Shipment Date]) < GETDATE()
			THEN 'Overdue'
		ELSE 'In Time'
		END AS [Overdue Status]

FROM Orderbook AS ob;