/*================================================================================================================
Project: Data Warehouse - Org UK/EU fSales
Author: Leo Pickard
Date: April 2024
Version: 1.00

This SQL select statement gets the data needed for the fSales table in the warehouse database. This
query will run on UK/EU server each night, triggered from a python script.
================================================================================================================*/
DECLARE @DTStart_Ltd AS DATE
	,@DTStart_BV AS DATE
	,@DTEnd AS DATE

SET @DTStart_Ltd = DATEADD(DAY, 1, '{COLDATE_LTD}')

SET @DTStart_BV = DATEADD(DAY, 1, '{COLDATE_BV}')

SET @DTEnd = DATEADD(DAY, - 1, GETDATE());

WITH CTE_Ltd_BV
AS (
	SELECT ve.[Posting Date]
		,ve.[Source No_] AS 'Customer No'
		,ve.[Document No_] AS 'Document No'
		,CASE 
			WHEN LEFT(ve.[Document No_], 4) = 'SCM+'
				THEN cmh.[Return Order No_] + '-Ltd'
			ELSE RIGHT(sih.[Posting Description], 9)
			END AS 'Order No'
		,ve.[Salespers__Purch_ Code] AS 'Salesperson Code'
		,CASE 
			WHEN sih.[Ship-to Country_Region Code] <> NULL
				OR sih.[Ship-to Country_Region Code] <> ''
				THEN sih.[Ship-to Country_Region Code]
			WHEN cmh.[Ship-to Country_Region Code] <> NULL
				OR cmh.[Ship-to Country_Region Code] <> ''
				THEN cmh.[Ship-to Country_Region Code]
			ELSE cus.[Country_Region Code]
			END AS 'Country Code'
		,'Org Ltd' AS 'Entity'
		-- Below are the Shiner royalty values, not specific to Org Ltd.
		,CASE 
			WHEN it.[Royalty %] = 0
				AND LEFT(ve.[Item No_], 3) IN ('ABR', 'BIR', 'TSS', 'INA', 'SCA')
				THEN 0.08
			WHEN it.[Royalty %] = 0
				AND LEFT(ve.[Item No_], 3) = 'BUL'
				AND SUBSTRING(ve.[Item No_], 5, 3) = 'PCO'
				THEN 0.06
			WHEN it.[Royalty %] = 0
				AND LEFT(ve.[Item No_], 3) = 'BUL'
				AND SUBSTRING(ve.[Item No_], 5, 3) <> 'PCO'
				THEN 0.05
			ELSE it.[Royalty %] / 100
			END AS 'Royalty %'
		-- Below are the Org Ltd specific customer rebate percentage values.
		,CASE 
			WHEN ve.[Source No_] = 'CU105862' -- Amazon
				AND LEFT(ve.[Item No_], 3) = 'HLY'
				THEN 0.15
			WHEN ve.[Source No_] = 'CU105862' -- Amazon
				AND LEFT(ve.[Item No_], 3) <> 'HLY'
				THEN 0.13
			WHEN ve.[Source No_] = 'CU100037' -- ASOS
				THEN 0.05
			WHEN ve.[Source No_] = 'CU105598' -- Smyths
				THEN 0.025
			WHEN ve.[Source No_] = 'CU105389' -- Sports Direct
				THEN 0.025
			ELSE 0
			END AS 'Customer Rebate %'
		-- Below is a case statement which checks to see if the sales type is D2C or B2B. It checks by seeing if
		-- the customer code is in a list of codes returned by the select statement.
		,CASE 
			WHEN ve.[Source No_] IN (
					SELECT [No_]
					
					FROM [Customer]
					
					WHERE [Name] LIKE '%D2C%'
					
					
					UNION
					
					SELECT [No_]
					
					FROM [EU Customer]
					
					WHERE [Name] LIKE '%D2C%'
					)
				THEN 'D2C'
			ELSE 'B2B'
			END AS 'Sales Type'
		-- Below is a list of conditions where royalty should not be applied, this is not specific to Org Ltd.
		,CASE 
			WHEN ve.[Source No_] IN (
					'CU105240' -- Prizes - Scoot lt £50
					, 'CU105483' -- Team - D Street
					, 'CU105237' -- Prizes - Rookie lt £50
					, 'CU105239' -- Prizes - Heelys gt £50
					, 'CU105650' -- Tony Hawk Incorporated
					, 'CU105489' -- Photo Studio Account
					, 'CU105474' -- Team - Sk8 One NO NOT USE
					, 'CU105231' -- Prizes - NHS - £50
					, 'CU105238' -- Seeding Marketing
					, 'CU105248' -- Prizes Marketing
					, 'CU105249' -- Prizes - Sports goods - cost gt £50
					, 'CU105330' -- Samples - Distributed
					, 'CU105487' -- Sales Team Samples - sales samples sets
					, 'CU105485' -- Marketing Promotional Items DO NOT USE
					, 'CU105478' -- Team - Heelys
					, 'CU105482' -- Team - Scoot
					, 'CU105472' -- Team - Core (Marketing)
					, 'CU105490' -- Team - Action Sports (Marketing)
					, 'CU107785' -- Eagle B.V
					, 'CU108171' -- FSX Media Ltd - Daily Orders
					, 'CU105331' -- Samples - Own Brand
					, 'CU105484' -- Team - Protection
					, 'CU105473' -- Team - core USA
					, 'CU105329' -- Staff Clothing Allowance
					, 'CU105486' -- NPD Samples
					, 'CU105332' -- Samples - NHS Apparel
					)
				THEN 0
			WHEN SUBSTRING(ve.[Item No_], 5, 3) = 'DLR'
				THEN 0
			ELSE 1
			END AS 'Royalty Include'
		,ve.[Item No_] AS 'Item No'
		,(ve.[Invoiced Quantity] * - 1) AS 'Quantity'
		,CAST(ve.[Sales Amount (Actual)] AS DECIMAL(20, 8)) AS 'GBP Sales'
		,CAST((ve.[Cost Amount (Actual)] * - 1) AS DECIMAL(20, 8)) AS 'GBP Cost'
		,ve.[Posting Date] AS 'GBP XR Date'
		,1.00 AS 'GBP XR'
		,CAST(ve.[Sales Amount (Actual)] * (
				SELECT TOP 1 [Exchange Rate Amount]
				
				FROM [Rate Currency Exchange]
				
				WHERE [Relational Currency Code] = ''
					AND [Currency Code] = 'EUR'
					AND [Starting Date] <= ve.[Posting Date]
				
				ORDER BY [Starting Date] DESC
				) AS DECIMAL(20, 8)) AS 'EUR Sales'
		,CAST((ve.[Cost Amount (Actual)] * - 1) * (
				SELECT TOP 1 [Exchange Rate Amount]
				
				FROM [Rate Currency Exchange]
				
				WHERE [Relational Currency Code] = ''
					AND [Currency Code] = 'EUR'
					AND [Starting Date] <= ve.[Posting Date]
				
				ORDER BY [Starting Date] DESC
				) AS DECIMAL(20, 8)) AS 'EUR Cost'
		,(
			SELECT TOP 1 [Starting Date]
			
			FROM [Rate Currency Exchange]
			
			WHERE [Relational Currency Code] = ''
				AND [Currency Code] = 'EUR'
				AND [Starting Date] <= ve.[Posting Date]
			
			ORDER BY [Starting Date] DESC
			) AS 'EUR XR Date'
		,(
			SELECT TOP 1 [Exchange Rate Amount]
			
			FROM [Rate Currency Exchange]
			
			WHERE [Relational Currency Code] = ''
				AND [Currency Code] = 'EUR'
				AND [Starting Date] <= ve.[Posting Date]
			
			ORDER BY [Starting Date] DESC
			) AS 'EUR XR'
		,CAST(ve.[Sales Amount (Actual)] * (
				SELECT TOP 1 [Exchange Rate Amount]
				
				FROM [Rate Currency Exchange]
				
				WHERE [Relational Currency Code] = ''
					AND [Currency Code] = 'USD'
					AND [Starting Date] <= ve.[Posting Date]
				
				ORDER BY [Starting Date] DESC
				) AS DECIMAL(20, 8)) AS 'USD Sales'
		,CAST((ve.[Cost Amount (Actual)] * - 1) * (
				SELECT TOP 1 [Exchange Rate Amount]
				
				FROM [Rate Currency Exchange]
				
				WHERE [Relational Currency Code] = ''
					AND [Currency Code] = 'USD'
					AND [Starting Date] <= ve.[Posting Date]
				
				ORDER BY [Starting Date] DESC
				) AS DECIMAL(20, 8)) AS 'USD Cost'
		,(
			SELECT TOP 1 [Starting Date]
			
			FROM [Rate Currency Exchange]
			
			WHERE [Relational Currency Code] = ''
				AND [Currency Code] = 'USD'
				AND [Starting Date] <= ve.[Posting Date]
			
			ORDER BY [Starting Date] DESC
			) AS 'USD XR Date'
		,(
			SELECT TOP 1 [Exchange Rate Amount]
			
			FROM [Rate Currency Exchange]
			
			WHERE [Relational Currency Code] = ''
				AND [Currency Code] = 'USD'
				AND [Starting Date] <= ve.[Posting Date]
			
			ORDER BY [Starting Date] DESC
			) AS 'USD XR'
	
	FROM [Entry Value] AS ve
	
	LEFT JOIN [Header CR Memo] AS cmh
		ON ve.[Document No_] = cmh.No_
	
	LEFT JOIN [Header Invoice Sales] AS sih
		ON ve.[Document No_] = sih.No_
	
	LEFT JOIN [Customer] AS cus
		ON ve.[Source No_] = cus.[No_]
	
	LEFT JOIN [Item] AS it
		ON ve.[Item No_] = it.No_
	
	WHERE ve.[Posting Date] BETWEEN @DTStart_Ltd
			AND @DTEnd
		AND ve.[Source Type] = 1
	
	
	UNION ALL
	
	SELECT ve.[Posting Date]
		,ve.[Source No_] AS 'Customer No'
		,ve.[Document No_] AS 'Document No'
		,CASE 
			WHEN LEFT(ve.[Document No_], 4) = 'SCM+'
				THEN cmh.[Return Order No_] + '-B.V'
			ELSE RIGHT(sih.[Posting Description], 9)
			END AS 'Order No'
		,ve.[Salespers__Purch_ Code] AS 'Salesperson Code'
		,CASE 
			WHEN sih.[Ship-to Country_Region Code] <> NULL
				OR sih.[Ship-to Country_Region Code] <> ''
				THEN sih.[Ship-to Country_Region Code]
			WHEN cmh.[Ship-to Country_Region Code] <> NULL
				OR cmh.[Ship-to Country_Region Code] <> ''
				THEN cmh.[Ship-to Country_Region Code]
			ELSE cus.[Country_Region Code]
			END AS 'Country Code'
		,'Org B.V' AS 'Entity'
		-- Below are the Shiner royalty values, not specific to Shiner Ltd.
		,CASE 
			WHEN it.[Royalty %] = 0
				AND LEFT(ve.[Item No_], 3) IN ('ABR', 'BIR', 'TSS', 'INA', 'SCA')
				THEN 0.08
			WHEN it.[Royalty %] = 0
				AND LEFT(ve.[Item No_], 3) = 'BUL'
				AND SUBSTRING(ve.[Item No_], 5, 3) = 'PCO'
				THEN 0.06
			WHEN it.[Royalty %] = 0
				AND LEFT(ve.[Item No_], 3) = 'BUL'
				AND SUBSTRING(ve.[Item No_], 5, 3) <> 'PCO'
				THEN 0.05
			ELSE it.[Royalty %] / 100
			END AS 'Royalty %'
		-- Below are the Org B.V specific customer rebate percentage values.
		,CASE 
			WHEN ve.[Source No_] = 'CU109640' -- ASOS
				THEN 0.05
			WHEN ve.[Source No_] = 'CU103027' -- Intersport France SA
				THEN 0.045
			WHEN ve.[Source No_] IN (
					'CU109334' -- About You SE & Co. KG
					, 'CU101067' -- Sport 2000
					)
				THEN 0.04
			WHEN ve.[Source No_] IN (
					'CU100487' -- Blue Tomato GmbH
					, 'CU103346' -- Spartoo
					)
				THEN 0.03
			WHEN ve.[Source No_] = 'CU105597' -- Smyths
				THEN 0.025
			WHEN ve.[Source No_] IN (
					'CU110281' -- Maple Leaf
					, 'CU101352' -- Skatedeluxe
					, 'CU103309' -- Sport 2002
					, 'CU104900' -- Zmart Skating
					)
				THEN 0.02
			ELSE 0
			END AS 'Customer Rebate %'
		,CASE 
			WHEN ve.[Source No_] IN (
					SELECT [No_]
					
					FROM [Customer]
					
					WHERE [Name] LIKE '%D2C%'
					
					
					UNION
					
					SELECT [No_]
					
					FROM [EU Customer]
					
					WHERE [Name] LIKE '%D2C%'
					)
				THEN 'D2C'
			ELSE 'B2B'
			END AS 'Sales Type'
		-- Below is a list of conditions where royalty should not be applied, this is not specific to Org B.V.
		,CASE 
			WHEN ve.[Source No_] IN (
					'CU105240' -- Prizes - Scoot lt £50
					, 'CU105483' -- Team - D Street
					, 'CU105237' -- Prizes - Rookie lt £50
					, 'CU105239' -- Prizes - Heelys gt £50
					, 'CU105650' -- Tony Hawk Incorporated
					, 'CU105489' -- Photo Studio Account
					, 'CU105474' -- Team - Sk8 One NO NOT USE
					, 'CU105231' -- Prizes - NHS - £50
					, 'CU105238' -- Seeding Marketing
					, 'CU105248' -- Prizes Marketing
					, 'CU105249' -- Prizes - Sports goods - cost gt £50
					, 'CU105330' -- Samples - Distributed
					, 'CU105487' -- Sales Team Samples - sales samples sets
					, 'CU105485' -- Marketing Promotional Items DO NOT USE
					, 'CU105478' -- Team - Heelys
					, 'CU105482' -- Team - Scoot
					, 'CU105472' -- Team - Core (Marketing)
					, 'CU105490' -- Team - Action Sports (Marketing)
					, 'CU107785' -- Eagle B.V
					, 'CU108171' -- FSX Media Ltd - Daily Orders
					, 'CU105331' -- Samples - Own Brand
					, 'CU105484' -- Team - Protection
					, 'CU105473' -- Team - core USA
					, 'CU105329' -- Staff Clothing Allowance
					, 'CU105486' -- NPD Samples
					, 'CU105332' -- Samples - NHS Apparel
					)
				THEN 0
			WHEN SUBSTRING(ve.[Item No_], 5, 3) = 'DLR'
				THEN 0
			ELSE 1
			END AS 'Royalty Include'
		,ve.[Item No_] AS 'Item No'
		,(ve.[Invoiced Quantity] * - 1) AS 'Quantity'
		,CAST(ve.[Sales Amount (Actual)] * (
				SELECT TOP 1 [Exchange Rate Amount]
				
				FROM [EU Rate Currency Exchange]
				
				WHERE [Relational Currency Code] = ''
					AND [Currency Code] = 'GBP'
					AND [Starting Date] <= ve.[Posting Date]
				
				ORDER BY [Starting Date] DESC
				) AS DECIMAL(20, 8)) AS 'GBP Sales'
		,CAST((ve.[Cost Amount (Actual)] * - 1) * (
				SELECT TOP 1 [Exchange Rate Amount]
				
				FROM [EU Rate Currency Exchange]
				
				WHERE [Relational Currency Code] = ''
					AND [Currency Code] = 'GBP'
					AND [Starting Date] <= ve.[Posting Date]
				
				ORDER BY [Starting Date] DESC
				) AS DECIMAL(20, 8)) AS 'GBP Cost'
		,(
			SELECT TOP 1 [Starting Date]
			
			FROM [EU Rate Currency Exchange]
			
			WHERE [Relational Currency Code] = ''
				AND [Currency Code] = 'GBP'
				AND [Starting Date] <= ve.[Posting Date]
			
			ORDER BY [Starting Date] DESC
			) AS 'GBP XR Date'
		,(
			SELECT TOP 1 [Exchange Rate Amount]
			
			FROM [EU Rate Currency Exchange]
			
			WHERE [Relational Currency Code] = ''
				AND [Currency Code] = 'GBP'
				AND [Starting Date] <= ve.[Posting Date]
			
			ORDER BY [Starting Date] DESC
			) AS 'GBP XR'
		,CAST(ve.[Sales Amount (Actual)] AS DECIMAL(20, 8)) AS 'EUR Sales'
		,CAST((ve.[Cost Amount (Actual)] * - 1) AS DECIMAL(20, 8)) AS 'EUR Cost'
		,ve.[Posting Date] AS 'EUR XR Date'
		,1.00 AS 'EUR XR'
		,CAST(ve.[Sales Amount (Actual)] * (
				SELECT TOP 1 [Exchange Rate Amount]
				
				FROM [EU Rate Currency Exchange]
				
				WHERE [Relational Currency Code] = ''
					AND [Currency Code] = 'USD'
					AND [Starting Date] <= ve.[Posting Date]
				
				ORDER BY [Starting Date] DESC
				) AS DECIMAL(20, 8)) AS 'USD Sales'
		,CAST((ve.[Cost Amount (Actual)] * - 1) * (
				SELECT TOP 1 [Exchange Rate Amount]
				
				FROM [EU Rate Currency Exchange]
				
				WHERE [Relational Currency Code] = ''
					AND [Currency Code] = 'USD'
					AND [Starting Date] <= ve.[Posting Date]
				
				ORDER BY [Starting Date] DESC
				) AS DECIMAL(20, 8)) AS 'USD Cost'
		,(
			SELECT TOP 1 [Starting Date]
			
			FROM [EU Rate Currency Exchange]
			
			WHERE [Relational Currency Code] = ''
				AND [Currency Code] = 'USD'
				AND [Starting Date] <= ve.[Posting Date]
			
			ORDER BY [Starting Date] DESC
			) AS 'USD XR Date'
		,(
			SELECT TOP 1 [Exchange Rate Amount]
			
			FROM [EU Rate Currency Exchange]
			
			WHERE [Relational Currency Code] = ''
				AND [Currency Code] = 'USD'
				AND [Starting Date] <= ve.[Posting Date]
			
			ORDER BY [Starting Date] DESC
			) AS 'USD XR'
	
	FROM [EU Entry Value] AS ve
	
	LEFT JOIN [EU Header CR Memo] AS cmh
		ON ve.[Document No_] = cmh.No_
	
	LEFT JOIN [EU Header Invoice Sales] AS sih
		ON ve.[Document No_] = sih.No_
	
	LEFT JOIN [EU Customer] AS cus
		ON ve.[Source No_] = cus.[No_]
	
	LEFT JOIN [EU Item] AS it
		ON ve.[Item No_] = it.No_
	
	WHERE ve.[Posting Date] BETWEEN @DTStart_BV
			AND @DTEnd
		AND ve.[Source Type] = 1
	)
	,LTD_BTB_Detail
AS (
	SELECT ve.[Posting Date]
		,(
			SELECT TOP 1 [Exchange Rate Amount]
			
			FROM [Rate Currency Exchange]
			
			WHERE [Relational Currency Code] = ''
				AND [Currency Code] = 'EUR'
				AND [Starting Date] <= ve.[Posting Date]
			
			ORDER BY [Starting Date] DESC
			) AS 'EUR XR'
		,ve.[Source No_] AS 'Customer No'
		,ve.[Document No_] AS 'Document No'
		,CASE 
			WHEN LEFT(ve.[Document No_], 4) = 'SCM+'
				THEN cmh.[Return Order No_] + '-Ltd'
			ELSE RIGHT(sih.[Posting Description], 9)
			END AS 'Order No'
		,ve.[Item No_] AS 'Item No'
		,(ve.[Invoiced Quantity] * - 1) AS 'Quantity'
		,CAST(ve.[Sales Amount (Actual)] AS DECIMAL(20, 8)) AS 'GBP Sales'
		,CAST(ve.[Sales Amount (Actual)] - (ve.[Cost Amount (Actual)] * - 1) AS DECIMAL(20, 8)) AS 'GBP Margin'
		,CAST(ve.[Sales Amount (Actual)] * (
				SELECT TOP 1 [Exchange Rate Amount]
				
				FROM [Rate Currency Exchange]
				
				WHERE [Relational Currency Code] = ''
					AND [Currency Code] = 'EUR'
					AND [Starting Date] <= ve.[Posting Date]
				
				ORDER BY [Starting Date] DESC
				) AS DECIMAL(20, 8)) AS 'EUR Sales'
		,CAST((
				ve.[Sales Amount (Actual)] * (
					SELECT TOP 1 [Exchange Rate Amount]
					
					FROM [Rate Currency Exchange]
					
					WHERE [Relational Currency Code] = ''
						AND [Currency Code] = 'EUR'
						AND [Starting Date] <= ve.[Posting Date]
					
					ORDER BY [Starting Date] DESC
					)
				) - (
				(ve.[Cost Amount (Actual)] * - 1) * (
					SELECT TOP 1 [Exchange Rate Amount]
					
					FROM [Rate Currency Exchange]
					
					WHERE [Relational Currency Code] = ''
						AND [Currency Code] = 'EUR'
						AND [Starting Date] <= ve.[Posting Date]
					
					ORDER BY [Starting Date] DESC
					)
				) AS DECIMAL(20, 8)) AS 'EUR Margin'
		,CAST(ve.[Sales Amount (Actual)] * (
				SELECT TOP 1 [Exchange Rate Amount]
				
				FROM [Rate Currency Exchange]
				
				WHERE [Relational Currency Code] = ''
					AND [Currency Code] = 'USD'
					AND [Starting Date] <= ve.[Posting Date]
				
				ORDER BY [Starting Date] DESC
				) AS DECIMAL(20, 8)) AS 'USD Sales'
		,CAST((
				ve.[Sales Amount (Actual)] * (
					SELECT TOP 1 [Exchange Rate Amount]
					
					FROM [Rate Currency Exchange]
					
					WHERE [Relational Currency Code] = ''
						AND [Currency Code] = 'USD'
						AND [Starting Date] <= ve.[Posting Date]
					
					ORDER BY [Starting Date] DESC
					)
				) - (
				(ve.[Cost Amount (Actual)] * - 1) * (
					SELECT TOP 1 [Exchange Rate Amount]
					
					FROM [Rate Currency Exchange]
					
					WHERE [Relational Currency Code] = ''
						AND [Currency Code] = 'USD'
						AND [Starting Date] <= ve.[Posting Date]
					
					ORDER BY [Starting Date] DESC
					)
				) AS DECIMAL(20, 8)) AS 'USD Margin'
	
	FROM [Entry Value] AS ve
	
	LEFT JOIN [Header Invoice Sales] AS sih
		ON ve.[Document No_] = sih.[No_]
	
	LEFT JOIN [EU Header CR Memo] AS cmh
		ON ve.[Document No_] = cmh.[No_]
	
	WHERE ve.[Posting Date] BETWEEN @DTStart_Ltd
			AND @DTEnd
		AND ve.[Source No_] = 'CU109441'
	)
	,Ltd_BTB_Final
AS (
	SELECT [Posting Date]
		,[EUR XR]
		,[Customer No]
		,[Document No]
		,[Order No]
		,[Item No]
		,SUM([Quantity]) AS 'Quantity'
		,CAST(SUM([GBP Sales]) AS DECIMAL(20, 8)) AS 'GBP Sales'
		,CAST(SUM([GBP Margin]) AS DECIMAL(20, 8)) AS 'GBP Margin'
		,CAST(SUM([EUR Sales]) AS DECIMAL(20, 8)) AS 'EUR Sales'
		,CAST(SUM([EUR Margin]) AS DECIMAL(20, 8)) AS 'EUR Margin'
		,CAST(SUM([USD Sales]) AS DECIMAL(20, 8)) AS 'USD Sales'
		,CAST(SUM([USD Margin]) AS DECIMAL(20, 8)) AS 'USD Margin'
	
	FROM LTD_BTB_Detail
	
	GROUP BY [Posting Date]
		,[EUR XR]
		,[Customer No]
		,[Document No]
		,[Order No]
		,[Item No]
	)
	,EU_BTB_Rows
AS (
	SELECT ve.[Posting Date]
		,ve.[Customer No]
		,ve.[Document No]
		,ve.[Order No]
		,ve.[Salesperson Code]
		,ve.[Country Code]
		,ve.[Entity]
		,ve.[Royalty %]
		,ve.[Customer Rebate %]
		,ve.[Sales Type]
		,ve.[Royalty Include]
		,ve.[Item No]
		,SUM(ve.[Quantity]) AS 'Quantity'
		,CAST(SUM(ve.[GBP Sales]) AS DECIMAL(20, 8)) AS 'GBP Sales'
		,CAST(SUM(ve.[GBP Cost]) AS DECIMAL(20, 8)) AS 'GBP Cost'
		,ve.[GBP XR Date]
		,ve.[GBP XR]
		,CAST(SUM((ve.[GBP Sales] * [Customer Rebate %])) AS DECIMAL(20, 8)) AS 'GBP Customer Rebate'
		,CAST(SUM(ve.[GBP Sales] * ([Royalty Include] * [Royalty %])) AS DECIMAL(20, 8)) AS 'GBP Royalty'
		,CAST(SUM(ve.[GBP Sales] - (
					ve.[GBP Cost] + (ve.[GBP Sales] * ve.[Customer Rebate %]) + (ve.[GBP Sales] * (ve.[Royalty Include] * ve.[Royalty %])
						)
					)) AS DECIMAL(20, 8)) AS 'GBP Margin'
		,CAST(SUM(ve.[EUR Sales]) AS DECIMAL(20, 8)) AS 'EUR Sales'
		,CAST(SUM(ve.[EUR Cost]) AS DECIMAL(20, 8)) AS 'EUR Cost'
		,ve.[EUR XR Date]
		,ve.[EUR XR]
		,CAST(SUM((ve.[EUR Sales] * ve.[Customer Rebate %])) AS DECIMAL(20, 8)) AS 'EUR Customer Rebate'
		,CAST(SUM(ve.[EUR Sales] * (ve.[Royalty Include] * ve.[Royalty %])) AS DECIMAL(20, 8)) AS 'EUR Royalty'
		,CAST(SUM(ve.[EUR Sales] - (
					ve.[EUR Cost] + (ve.[EUR Sales] * ve.[Customer Rebate %]) + (ve.[EUR Sales] * (ve.[Royalty Include] * ve.[Royalty %])
						)
					)) AS DECIMAL(20, 8)) AS 'EUR Margin'
		,CAST(SUM(ve.[USD Sales]) AS DECIMAL(20, 8)) AS 'USD Sales'
		,CAST(SUM(ve.[USD Cost]) AS DECIMAL(20, 8)) AS 'USD Cost'
		,ve.[USD XR Date]
		,ve.[USD XR]
		,CAST(SUM(ve.[USD Sales] * ve.[Customer Rebate %]) AS DECIMAL(20, 8)) AS 'USD Customer Rebate'
		,CAST(SUM(ve.[USD Sales] * (ve.[Royalty Include] * ve.[Royalty %])) AS DECIMAL(20, 8)) AS 'USD Royalty'
		,CAST(SUM(ve.[USD Sales] - (
					ve.[USD Cost] + (ve.[USD Sales] * ve.[Customer Rebate %]) + (ve.[USD Sales] * (ve.[Royalty Include] * ve.[Royalty %])
						)
					)) AS DECIMAL(20, 8)) AS 'USD Margin'
	
	FROM CTE_Ltd_BV AS ve
	
	WHERE ve.[Order No] IN (
			SELECT DISTINCT [Order No]
			
			FROM Ltd_BTB_Detail
			
			WHERE [Order No] IS NOT NULL
			)
		AND ve.[Entity] = 'Shiner B.V'
	
	GROUP BY ve.[Posting Date]
		,ve.[Customer No]
		,ve.[Document No]
		,ve.[Order No]
		,ve.[Salesperson Code]
		,ve.[Country Code]
		,ve.[Entity]
		,ve.[Royalty %]
		,ve.[Customer Rebate %]
		,ve.[Sales Type]
		,ve.[Royalty Include]
		,ve.[Item No]
		,ve.[GBP XR Date]
		,ve.[GBP XR]
		,ve.[EUR XR Date]
		,ve.[EUR XR]
		,ve.[USD XR Date]
		,ve.[USD XR]
	)

SELECT CAST(CAST(YEAR(ve.[Posting Date]) AS VARCHAR(4)) + RIGHT('0' + CAST(MONTH(ve.[Posting Date]) AS VARCHAR(2)), 2) + RIGHT('0' + CAST(DAY(ve.[Posting Date]) AS 
				VARCHAR(2)), 2) AS INTEGER) AS 'Date Key'
	,CAST(ve.[Posting Date] AS DATE) AS 'Posting Date'
	,CAST(ve.[Customer No] AS NVARCHAR(12)) AS 'Customer No'
	,CAST(ve.[Document No] AS NVARCHAR(14)) AS 'Document No'
	,CAST(ve.[Order No] AS NVARCHAR(18)) AS 'Order No'
	,CAST(ISNULL(ve.[Salesperson Code], 'Not Assigned') AS NVARCHAR(20)) AS 'Salesperson Code'
	,CAST(ve.[Country Code] AS NVARCHAR(2)) AS 'Country Code'
	,CAST(ve.[Entity] AS NVARCHAR(10)) AS 'Entity'
	,CAST(ve.[Royalty %] AS DECIMAL(20, 15)) AS 'Royalty %'
	,CAST(ve.[Customer Rebate %] AS DECIMAL(20, 15)) AS 'Customer Rebate %'
	,CAST('No' AS NVARCHAR(3)) AS 'Adjusted Margin'
	,CAST(ve.[Sales Type] AS NVARCHAR(3)) AS 'Sales Type'
	,CAST(ve.[Royalty Include] AS BIT) AS 'Royalty Include'
	,CAST(LEFT(ve.[Item No], 3) AS NVARCHAR(3)) AS 'Brand Code'
	,CAST(ve.[Item No] AS NVARCHAR(16)) AS 'Item No'
	,CAST(SUM(ve.[Quantity]) AS DECIMAL(16, 4)) AS 'Quantity'
	,CAST(SUM(ve.[GBP Sales]) AS DECIMAL(20, 8)) AS 'GBP Sales'
	,CAST(SUM(ve.[GBP Cost]) AS DECIMAL(20, 8)) AS 'GBP Cost'
	,CAST(SUM((ve.[GBP Sales] * [Customer Rebate %])) AS DECIMAL(20, 8)) AS 'GBP Customer Rebate'
	,CAST(SUM(ve.[GBP Sales] * ([Royalty Include] * [Royalty %])) AS DECIMAL(20, 8)) AS 'GBP Royalty'
	,CAST(SUM(ve.[GBP Sales] - (
				ve.[GBP Cost] + (ve.[GBP Sales] * ve.[Customer Rebate %]) + (ve.[GBP Sales] * (ve.[Royalty Include] * ve.[Royalty %])
					)
				)) AS DECIMAL(20, 8)) AS 'GBP Margin'
	,CAST(SUM(ve.[GBP Sales] - (
				ve.[GBP Cost] + (ve.[GBP Sales] * ve.[Customer Rebate %]) + (ve.[GBP Sales] * (ve.[Royalty Include] * ve.[Royalty %])
					)
				)) AS DECIMAL(20, 8)) AS 'GBP Adjusted Margin'
	,CAST(ve.[GBP XR Date] AS DATE) AS 'GBP XR Date'
	,CAST(ve.[GBP XR] AS DECIMAL(12, 8)) AS 'GBP XR'
	,CAST(SUM(ve.[EUR Sales]) AS DECIMAL(20, 8)) AS 'EUR Sales'
	,CAST(SUM(ve.[EUR Cost]) AS DECIMAL(20, 8)) AS 'EUR Cost'
	,CAST(SUM((ve.[EUR Sales] * ve.[Customer Rebate %])) AS DECIMAL(20, 8)) AS 'EUR Customer Rebate'
	,CAST(SUM(ve.[EUR Sales] * (ve.[Royalty Include] * ve.[Royalty %])) AS DECIMAL(20, 8)) AS 'EUR Royalty'
	,CAST(SUM(ve.[EUR Sales] - (
				ve.[EUR Cost] + (ve.[EUR Sales] * ve.[Customer Rebate %]) + (ve.[EUR Sales] * (ve.[Royalty Include] * ve.[Royalty %])
					)
				)) AS DECIMAL(20, 8)) AS 'EUR Margin'
	,CAST(SUM(ve.[EUR Sales] - (
				ve.[EUR Cost] + (ve.[EUR Sales] * ve.[Customer Rebate %]) + (ve.[EUR Sales] * (ve.[Royalty Include] * ve.[Royalty %])
					)
				)) AS DECIMAL(20, 8)) AS 'EUR Adjusted Margin'
	,CAST(ve.[EUR XR Date] AS DATE) AS 'EUR XR Date'
	,CAST(ve.[EUR XR] AS DECIMAL(12, 8)) AS 'EUR XR'
	,CAST(SUM(ve.[USD Sales]) AS DECIMAL(20, 8)) AS 'USD Sales'
	,CAST(SUM(ve.[USD Cost]) AS DECIMAL(20, 8)) AS 'USD Cost'
	,CAST(SUM(ve.[USD Sales] * ve.[Customer Rebate %]) AS DECIMAL(20, 8)) AS 'USD Customer Rebate'
	,CAST(SUM(ve.[USD Sales] * (ve.[Royalty Include] * ve.[Royalty %])) AS DECIMAL(20, 8)) AS 'USD Royalty'
	,CAST(SUM(ve.[USD Sales] - (
				ve.[USD Cost] + (ve.[USD Sales] * ve.[Customer Rebate %]) + (ve.[USD Sales] * (ve.[Royalty Include] * ve.[Royalty %])
					)
				)) AS DECIMAL(20, 8)) AS 'USD Margin'
	,CAST(SUM(ve.[USD Sales] - (
				ve.[USD Cost] + (ve.[USD Sales] * ve.[Customer Rebate %]) + (ve.[USD Sales] * (ve.[Royalty Include] * ve.[Royalty %])
					)
				)) AS DECIMAL(20, 8)) AS 'USD Adjusted Margin'
	,CAST(ve.[USD XR Date] AS DATE) AS 'USD XR Date'
	,CAST(ve.[USD XR] AS DECIMAL(12, 8)) AS 'USD XR'

FROM CTE_Ltd_BV AS ve

WHERE NOT EXISTS (
		SELECT 1
		
		FROM EU_BTB_Rows AS er
		
		WHERE er.[Order No] = ve.[Order No]
			AND ve.[Entity] = 'Shiner B.V'
		)

GROUP BY CAST(CAST(YEAR(ve.[Posting Date]) AS VARCHAR(4)) + RIGHT('0' + CAST(MONTH(ve.[Posting Date]) AS VARCHAR(2)), 2) + RIGHT('0' + CAST(DAY(ve.[Posting Date]) AS 
				VARCHAR(2)), 2) AS INTEGER)
	,CAST(ve.[Posting Date] AS DATE)
	,CAST(ve.[Customer No] AS NVARCHAR(12))
	,CAST(ve.[Document No] AS NVARCHAR(14))
	,CAST(ve.[Order No] AS NVARCHAR(18))
	,CAST(ISNULL(ve.[Salesperson Code], 'Not Assigned') AS NVARCHAR(20))
	,CAST(ve.[Country Code] AS NVARCHAR(2))
	,CAST(ve.[Entity] AS NVARCHAR(10))
	,CAST(ve.[Royalty %] AS DECIMAL(20, 15))
	,CAST(ve.[Customer Rebate %] AS DECIMAL(20, 15))
	,CAST(ve.[Sales Type] AS NVARCHAR(3))
	,CAST(ve.[Royalty Include] AS BIT)
	,CAST(LEFT(ve.[Item No], 3) AS NVARCHAR(3))
	,CAST(ve.[Item No] AS NVARCHAR(16))
	,CAST(ve.[GBP XR Date] AS DATE)
	,CAST(ve.[GBP XR] AS DECIMAL(12, 8))
	,CAST(ve.[EUR XR Date] AS DATE)
	,CAST(ve.[EUR XR] AS DECIMAL(12, 8))
	,CAST(ve.[USD XR Date] AS DATE)
	,CAST(ve.[USD XR] AS DECIMAL(12, 8))


UNION ALL

SELECT CAST(CAST(YEAR(ve.[Posting Date]) AS VARCHAR(4)) + RIGHT('0' + CAST(MONTH(ve.[Posting Date]) AS VARCHAR(2)), 2) + RIGHT('0' + CAST(DAY(ve.[Posting Date]) AS 
				VARCHAR(2)), 2) AS INTEGER) AS 'Date Key'
	,CAST(ve.[Posting Date] AS DATE) AS 'Posting Date'
	,CAST(ve.[Customer No] AS NVARCHAR(12)) AS 'Customer No'
	,CAST(ve.[Document No] AS NVARCHAR(14)) AS 'Document No'
	,CAST(ve.[Order No] AS NVARCHAR(18)) AS 'Order No'
	,CAST(ISNULL(ve.[Salesperson Code], 'Not Assigned') AS NVARCHAR(20)) AS 'Salesperson Code'
	,CAST(ve.[Country Code] AS NVARCHAR(2)) AS 'Country Code'
	,CAST(ve.[Entity] AS NVARCHAR(10)) AS 'Entity'
	,CAST(ve.[Royalty %] AS DECIMAL(20, 15)) AS 'Royalty %'
	,CAST(ve.[Customer Rebate %] AS DECIMAL(20, 15)) AS 'Customer Rebate %'
	,CAST('Yes' AS NVARCHAR(3)) AS 'Adjusted Margin'
	,CAST(ve.[Sales Type] AS NVARCHAR(3)) AS 'Sales Type'
	,CAST(ve.[Royalty Include] AS BIT) AS 'Royalty Include'
	,CAST(LEFT(ve.[Item No], 3) AS NVARCHAR(3)) AS 'Brand Code'
	,CAST(ve.[Item No] AS NVARCHAR(16)) AS 'Item No'
	,CAST(ve.[Quantity] AS DECIMAL(16, 4)) AS 'Quantity'
	,CAST(ve.[GBP Sales] AS DECIMAL(20, 8)) AS 'GBP Sales'
	,CAST(ve.[GBP Cost] AS DECIMAL(20, 8)) AS 'GBP Cost'
	,CAST(ve.[GBP Customer Rebate] AS DECIMAL(20, 8)) AS 'GBP Customer Rebate'
	,CAST(ve.[GBP Royalty] AS DECIMAL(20, 8)) AS 'GBP Royalty'
	,CAST(ve.[GBP Margin] AS DECIMAL(20, 8)) AS 'GBP Margin'
	,CAST(ISNULL(ve.[GBP Margin] + bt.[GBP Margin], ve.[GBP Margin]) AS DECIMAL(20, 8)) AS 'GBP Adjusted Margin'
	,CAST(ve.[GBP XR Date] AS DATE) AS 'GBP XR Date'
	,CAST(ve.[GBP XR] AS DECIMAL(12, 8)) AS 'GBP XR'
	,CAST(ve.[EUR Sales] AS DECIMAL(20, 8)) AS 'EUR Sales'
	,CAST(ve.[EUR Cost] AS DECIMAL(20, 8)) AS 'EUR Cost'
	,CAST(ve.[EUR Customer Rebate] AS DECIMAL(20, 8)) AS 'EUR Customer Rebate'
	,CAST(ve.[EUR Royalty] AS DECIMAL(20, 8)) AS 'EUR Royalty'
	,CAST(ve.[EUR Margin] AS DECIMAL(20, 8)) AS 'EUR Margin'
	,CAST(ISNULL(ve.[EUR Margin] + bt.[EUR Margin], ve.[EUR Margin]) AS DECIMAL(20, 8)) AS 'EUR Adjusted Margin'
	,CAST(ve.[EUR XR Date] AS DATE) AS 'EUR XR Date'
	,CAST(ve.[EUR XR] AS DECIMAL(12, 8)) AS 'EUR XR'
	,CAST(ve.[USD Sales] AS DECIMAL(20, 8)) AS 'USD Sales'
	,CAST(ve.[USD Cost] AS DECIMAL(20, 8)) AS 'USD Cost'
	,CAST(ve.[USD Customer Rebate] AS DECIMAL(20, 8)) AS 'USD Customer Rebate'
	,CAST(ve.[USD Royalty] AS DECIMAL(20, 8)) AS 'USD Royalty'
	,CAST(ve.[USD Margin] AS DECIMAL(20, 8)) AS 'USD Margin'
	,CAST(ISNULL(ve.[USD Margin] + bt.[USD Margin], ve.[USD Margin]) AS DECIMAL(20, 8)) AS 'USD Adjusted Margin'
	,CAST(ve.[USD XR Date] AS DATE) AS 'USD XR Date'
	,CAST(ve.[USD XR] AS DECIMAL(12, 8)) AS 'USD XR'

FROM EU_BTB_Rows AS ve

LEFT JOIN Ltd_BTB_Final AS bt
	ON ve.[Order No] = bt.[Order No]
		AND ve.[Item No] = bt.[Item No]
		AND ve.[Quantity] = bt.[Quantity];