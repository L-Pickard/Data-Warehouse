/*================================================================================================================
Project: Finance Database - Org LLC fSales
Author: Leo Pickard
Date: October 2023
Version: 1.00

This SQL select statement gets the data needed for the fSales table in the warehouse database. This
query will run on US server each night, triggered from a python script.
================================================================================================================*/
DECLARE @DTStart AS DATE
	,@DTEnd AS DATE

SET @DTStart = DATEADD(DAY, 1, '{COLDATE_LLC}')

SET @DTEnd = DATEADD(DAY, - 1, GETDATE());

WITH CTE_LLC
AS (
	SELECT ve.[Posting Date]
		,ve.[Source No_] AS 'Customer No'
		,ve.[Document No_] AS 'Document No'
		,RIGHT(sih.[Posting Description], 9) AS 'Order No'
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
		,'Org LLC' AS 'Entity'
		-- Below are the Org LLC royalty values, These are specific to Shiner LLLC.
		,CAST(CASE 
				WHEN LEFT(ve.[Item No_], 3) = 'ABR'
					THEN 0.065
				ELSE 0
				END AS DECIMAL(20, 15)) AS 'Royalty %'
		-- Below are the Org LLC specific customer rebate percentage values, Currently none to apply.
		,CAST(0.0000 AS DECIMAL(20, 15)) AS 'Customer Rebate %'
		,'No' AS 'Adjusted Margin'
		-- Below is a case statement which checks to see if the sales type is D2C or B2B. It checks by seeing if
		-- the customer code is in a list of codes returned by the select statement.
		,CASE 
			WHEN ve.[Source No_] IN (
					SELECT [No_]
					
					FROM [US Customer]
					
					WHERE [Name] LIKE '%D2C%'
					)
				THEN 'D2C'
			ELSE 'B2B'
			END AS 'Sales Type'
		-- Below is a case statement which excludes royalty if the Item is DLR.
		,CASE 
			WHEN SUBSTRING(ve.[Item No_], 5, 3) = 'DLR'
				THEN 0
			ELSE 1
			END AS 'Royalty Include'
		,ve.[Item No_] AS 'Item No'
		,(ve.[Invoiced Quantity] * - 1) AS 'Quantity'
		,CAST(ve.[Sales Amount (Actual)] * (
				SELECT TOP 1 [Exchange Rate Amount]
				
				FROM [US Rate Currency Exchange]
				
				WHERE [Relational Currency Code] = ''
					AND [Currency Code] = 'GBP'
					AND [Starting Date] <= ve.[Posting Date]
				
				ORDER BY [Starting Date] DESC
				) AS DECIMAL(20, 8)) AS 'GBP Sales'
		,CAST((ve.[Cost Amount (Actual)] * - 1) * (
				SELECT TOP 1 [Exchange Rate Amount]
				
				FROM [US Rate Currency Exchange]
				
				WHERE [Relational Currency Code] = ''
					AND [Currency Code] = 'GBP'
					AND [Starting Date] <= ve.[Posting Date]
				
				ORDER BY [Starting Date] DESC
				) AS DECIMAL(20, 8)) AS 'GBP Cost'
		,(
			SELECT TOP 1 [Starting Date]
			
			FROM [US Rate Currency Exchange]
			
			WHERE [Relational Currency Code] = ''
				AND [Currency Code] = 'GBP'
				AND [Starting Date] <= ve.[Posting Date]
			
			ORDER BY [Starting Date] DESC
			) AS 'GBP XR Date'
		,(
			SELECT TOP 1 [Exchange Rate Amount]
			
			FROM [US Rate Currency Exchange]
			
			WHERE [Relational Currency Code] = ''
				AND [Currency Code] = 'GBP'
				AND [Starting Date] <= ve.[Posting Date]
			
			ORDER BY [Starting Date] DESC
			) AS 'GBP XR'
		,CAST(ve.[Sales Amount (Actual)] * (
				SELECT TOP 1 [Exchange Rate Amount]
				
				FROM [US Rate Currency Exchange]
				
				WHERE [Relational Currency Code] = ''
					AND [Currency Code] = 'EUR'
					AND [Starting Date] <= ve.[Posting Date]
				
				ORDER BY [Starting Date] DESC
				) AS DECIMAL(20, 8)) AS 'EUR Sales'
		,CAST((ve.[Cost Amount (Actual)] * - 1) * (
				SELECT TOP 1 [Exchange Rate Amount]
				
				FROM [US Rate Currency Exchange]
				
				WHERE [Relational Currency Code] = ''
					AND [Currency Code] = 'EUR'
					AND [Starting Date] <= ve.[Posting Date]
				
				ORDER BY [Starting Date] DESC
				) AS DECIMAL(20, 8)) AS 'EUR Cost'
		,(
			SELECT TOP 1 [Starting Date]
			
			FROM [US Rate Currency Exchange]
			
			WHERE [Relational Currency Code] = ''
				AND [Currency Code] = 'EUR'
				AND [Starting Date] <= ve.[Posting Date]
			
			ORDER BY [Starting Date] DESC
			) AS 'EUR XR Date'
		,(
			SELECT TOP 1 [Exchange Rate Amount]
			
			FROM [US Rate Currency Exchange]
			
			WHERE [Relational Currency Code] = ''
				AND [Currency Code] = 'EUR'
				AND [Starting Date] <= ve.[Posting Date]
			
			ORDER BY [Starting Date] DESC
			) AS 'EUR XR'
		,CAST(ve.[Sales Amount (Actual)] AS DECIMAL(20, 8)) AS 'USD Sales'
		,CAST((ve.[Cost Amount (Actual)] * - 1) AS DECIMAL(20, 8)) AS 'USD Cost'
		,ve.[Posting Date] AS 'USD XR Date'
		,1.00 AS 'USD XR'
	
	FROM [US Entry Value] AS ve
	
	LEFT JOIN [US Customer] AS cus
		ON ve.[Source No_] = cus.[No_]
	
	LEFT JOIN [US Header Invoice Sales] AS sih
		ON ve.[Document No_] = sih.No_
	
	LEFT JOIN [US Header CR Memo] AS cmh
		ON ve.[Document No_] = cmh.No_
	
	WHERE ve.[Posting Date] BETWEEN @DTStart
			AND @DTEnd
		AND ve.[Source Type] = 1
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
	,CAST(ve.[Adjusted Margin] AS NVARCHAR(3)) AS 'Adjusted Margin'
	,CAST(ve.[Sales Type] AS NVARCHAR(3)) AS 'Sales Type'
	,CAST(ve.[Royalty Include] AS BIT) AS 'Royalty Include'
	,CAST(LEFT(ve.[Item No], 3) AS NVARCHAR(3)) AS 'Brand Code'
	,CAST(ve.[Item No] AS NVARCHAR(16)) AS 'Item No'
	,CAST(SUM([Quantity]) AS DECIMAL(16, 4)) AS 'Quantity'
	,CAST(SUM([GBP Sales]) AS DECIMAL(20, 8)) AS 'GBP Sales'
	,CAST(SUM([GBP Cost]) AS DECIMAL(20, 8)) AS 'GBP Cost'
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

FROM CTE_LLC AS ve

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
	,CAST(ve.[Adjusted Margin] AS NVARCHAR(3))
	,CAST(ve.[Sales Type] AS NVARCHAR(3))
	,CAST(ve.[Royalty Include] AS BIT)
	,CAST(LEFT(ve.[Item No], 3) AS NVARCHAR(3))
	,CAST(ve.[Item No] AS NVARCHAR(16))
	,CAST(ve.[GBP XR Date] AS DATE)
	,CAST(ve.[GBP XR] AS DECIMAL(12, 8))
	,CAST(ve.[EUR XR Date] AS DATE)
	,CAST(ve.[EUR XR] AS DECIMAL(12, 8))
	,CAST(ve.[USD XR Date] AS DATE)
	,CAST(ve.[USD XR] AS DECIMAL(12, 8));

