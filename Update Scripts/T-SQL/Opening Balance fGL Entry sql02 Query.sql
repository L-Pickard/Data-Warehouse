DECLARE @End AS DATE

SET @End = '2022-04-30'

SELECT CAST(CAST(YEAR(MAX(gl.[Posting Date])) AS VARCHAR(4)) + RIGHT('0' + CAST(MONTH(MAX(gl.[Posting Date])) AS VARCHAR(2)), 2) + RIGHT('0' + CAST(DAY(MAX(gl.
						[Posting Date])) AS VARCHAR(2)), 2) AS INTEGER) AS 'Date Key'
	,MAX(CAST(gl.[Posting Date] AS DATE)) AS 'Posting Date'
	,'Org Ltd' AS 'Entity'
	,ROW_NUMBER() OVER (
		ORDER BY gl.[G_L Account No_]
		) AS 'Entry No'
	,gl.[G_L Account No_] AS 'GL Account No'
	,'Journal' AS 'Document Type'
	,'Opening Balance' AS 'Document No'
	,'Sum of all up to 2022-04-30' AS 'Description'
	,'LEOP' AS 'User ID'
	,NULL AS 'Source Code'
	,100 AS 'Source Type'
	,gl.[Source No_] AS 'Source No'
	,NULL AS 'Balance Account No'
	,SUM(gl.[Amount]) AS 'GBP Amount'
	,SUM(gl.[VAT Amount]) AS 'GBP VAT Amount'
	,SUM(gl.[Debit Amount]) AS 'GBP Debit Amount'
	,SUM(gl.[Credit Amount]) AS 'GBP Credit Amount'
	,CAST(@End AS DATE) AS 'GBP XR Date'
	,CAST(1.00 AS DECIMAL(12, 8)) AS 'GBP XR'
	,CAST(SUM(gl.[Amount]) * (
			SELECT TOP 1 [Exchange Rate Amount]
			
			FROM [Rate Currency Exchange]
			
			WHERE [Relational Currency Code] = ''
				AND [Currency Code] = 'EUR'
				AND [Starting Date] <= @End
			
			ORDER BY [Starting Date] DESC
			) AS DECIMAL(20, 8)) AS 'EUR Amount'
	,CAST(SUM(gl.[VAT Amount]) * (
			SELECT TOP 1 [Exchange Rate Amount]
			
			FROM [Rate Currency Exchange]
			
			WHERE [Relational Currency Code] = ''
				AND [Currency Code] = 'EUR'
				AND [Starting Date] <= @End
			
			ORDER BY [Starting Date] DESC
			) AS DECIMAL(20, 8)) AS 'EUR VAT Amount'
	,CAST(SUM(gl.[Debit Amount]) * (
			SELECT TOP 1 [Exchange Rate Amount]
			
			FROM [Rate Currency Exchange]
			
			WHERE [Relational Currency Code] = ''
				AND [Currency Code] = 'EUR'
				AND [Starting Date] <= @End
			
			ORDER BY [Starting Date] DESC
			) AS DECIMAL(20, 8)) AS 'EUR Debit Amount'
	,CAST(SUM(gl.[Credit Amount]) * (
			SELECT TOP 1 [Exchange Rate Amount]
			
			FROM [Rate Currency Exchange]
			
			WHERE [Relational Currency Code] = ''
				AND [Currency Code] = 'EUR'
				AND [Starting Date] <= @End
			
			ORDER BY [Starting Date] DESC
			) AS DECIMAL(20, 8)) AS 'EUR Credit Amount'
	,CAST((
			SELECT TOP 1 [Starting Date]
			
			FROM [Rate Currency Exchange]
			
			WHERE [Relational Currency Code] = ''
				AND [Currency Code] = 'EUR'
				AND [Starting Date] <= @End
			
			ORDER BY [Starting Date] DESC
			) AS DATE) AS 'EUR XR Date'
	,CAST((
			SELECT TOP 1 [Exchange Rate Amount]
			
			FROM [Rate Currency Exchange]
			
			WHERE [Relational Currency Code] = ''
				AND [Currency Code] = 'EUR'
				AND [Starting Date] <= @End
			
			ORDER BY [Starting Date] DESC
			) AS DECIMAL(12, 8)) AS 'EUR XR'
	,CAST(SUM(gl.[Amount]) * (
			SELECT TOP 1 [Exchange Rate Amount]
			
			FROM [Rate Currency Exchange]
			
			WHERE [Relational Currency Code] = ''
				AND [Currency Code] = 'USD'
				AND [Starting Date] <= @End
			
			ORDER BY [Starting Date] DESC
			) AS DECIMAL(20, 8)) AS 'USD Amount'
	,CAST(SUM(gl.[VAT Amount]) * (
			SELECT TOP 1 [Exchange Rate Amount]
			
			FROM [Rate Currency Exchange]
			
			WHERE [Relational Currency Code] = ''
				AND [Currency Code] = 'USD'
				AND [Starting Date] <= @End
			
			ORDER BY [Starting Date] DESC
			) AS DECIMAL(20, 8)) AS 'USD VAT Amount'
	,CAST(SUM(gl.[Debit Amount]) * (
			SELECT TOP 1 [Exchange Rate Amount]
			
			FROM [Rate Currency Exchange]
			
			WHERE [Relational Currency Code] = ''
				AND [Currency Code] = 'USD'
				AND [Starting Date] <= @End
			
			ORDER BY [Starting Date] DESC
			) AS DECIMAL(20, 8)) AS 'USD Debit Amount'
	,CAST(SUM(gl.[Credit Amount]) * (
			SELECT TOP 1 [Exchange Rate Amount]
			
			FROM [Rate Currency Exchange]
			
			WHERE [Relational Currency Code] = ''
				AND [Currency Code] = 'USD'
				AND [Starting Date] <= @End
			
			ORDER BY [Starting Date] DESC
			) AS DECIMAL(20, 8)) AS 'USD Credit Amount'
	,CAST((
			SELECT TOP 1 [Starting Date]
			
			FROM [Rate Currency Exchange]
			
			WHERE [Relational Currency Code] = ''
				AND [Currency Code] = 'USD'
				AND [Starting Date] <= @End
			
			ORDER BY [Starting Date] DESC
			) AS DATE) AS 'USD XR Date'
	,CAST((
			SELECT TOP 1 [Exchange Rate Amount]
			
			FROM [Rate Currency Exchange]
			
			WHERE [Relational Currency Code] = ''
				AND [Currency Code] = 'USD'
				AND [Starting Date] <= @End
			
			ORDER BY [Starting Date] DESC
			) AS DECIMAL(12, 8)) AS 'USD XR'

FROM [Entry GL] AS gl

WHERE [Posting Date] <= @End

GROUP BY gl.[G_L Account No_]
	,gl.[Source No_]
	,gl.[G_L Account No_]
	,gl.[Source No_]


UNION ALL

SELECT CAST(CAST(YEAR(MAX(gl.[Posting Date])) AS VARCHAR(4)) + RIGHT('0' + CAST(MONTH(MAX(gl.[Posting Date])) AS VARCHAR(2)), 2) + RIGHT('0' + CAST(DAY(MAX(gl.
						[Posting Date])) AS VARCHAR(2)), 2) AS INTEGER) AS 'Date Key'
	,MAX(CAST(gl.[Posting Date] AS DATE)) AS 'Posting Date'
	,'Org B.V' AS 'Entity'
	,ROW_NUMBER() OVER (
		ORDER BY gl.[G_L Account No_]
		) AS 'Entry No'
	,gl.[G_L Account No_] AS 'GL Account No'
	,'Journal' AS 'Document Type'
	,'Opening Balance' AS 'Document No'
	,'Sum of all up to 2022-04-30' AS 'Description'
	,'LEOP' AS 'User ID'
	,NULL AS 'Source Code'
	,100 AS 'Source Type'
	,gl.[Source No_] AS 'Source No'
	,NULL AS 'Balance Account No'
	,CAST(SUM(gl.[Amount]) * (
			SELECT TOP 1 [Exchange Rate Amount]
			
			FROM [EU Rate Currency Exchange]
			
			WHERE [Relational Currency Code] = ''
				AND [Currency Code] = 'GBP'
				AND [Starting Date] <= @End
			
			ORDER BY [Starting Date] DESC
			) AS DECIMAL(20, 8)) AS 'GBP Amount'
	,CAST(SUM(gl.[VAT Amount]) * (
			SELECT TOP 1 [Exchange Rate Amount]
			
			FROM [EU Rate Currency Exchange]
			
			WHERE [Relational Currency Code] = ''
				AND [Currency Code] = 'GBP'
				AND [Starting Date] <= @End
			
			ORDER BY [Starting Date] DESC
			) AS DECIMAL(20, 8)) AS 'GBP VAT Amount'
	,CAST(SUM(gl.[Debit Amount]) * (
			SELECT TOP 1 [Exchange Rate Amount]
			
			FROM [EU Rate Currency Exchange]
			
			WHERE [Relational Currency Code] = ''
				AND [Currency Code] = 'GBP'
				AND [Starting Date] <= @End
			
			ORDER BY [Starting Date] DESC
			) AS DECIMAL(20, 8)) AS 'GBP Debit Amount'
	,CAST(SUM(gl.[Credit Amount]) * (
			SELECT TOP 1 [Exchange Rate Amount]
			
			FROM [EU Rate Currency Exchange]
			
			WHERE [Relational Currency Code] = ''
				AND [Currency Code] = 'GBP'
				AND [Starting Date] <= @End
			
			ORDER BY [Starting Date] DESC
			) AS DECIMAL(20, 8)) AS 'GBP Credit Amount'
	,CAST((
			SELECT TOP 1 [Starting Date]
			
			FROM [EU Rate Currency Exchange]
			
			WHERE [Relational Currency Code] = ''
				AND [Currency Code] = 'GBP'
				AND [Starting Date] <= @End
			
			ORDER BY [Starting Date] DESC
			) AS DATE) AS 'GBP XR Date'
	,CAST((
			SELECT TOP 1 [Exchange Rate Amount]
			
			FROM [EU Rate Currency Exchange]
			
			WHERE [Relational Currency Code] = ''
				AND [Currency Code] = 'GBP'
				AND [Starting Date] <= @End
			
			ORDER BY [Starting Date] DESC
			) AS DECIMAL(12, 8)) AS 'GBP XR'
	,CAST(SUM(gl.[Amount]) AS DECIMAL(20, 8)) AS 'EUR Amount'
	,CAST(SUM(gl.[VAT Amount]) AS DECIMAL(20, 8)) AS 'EUR VAT Amount'
	,CAST(SUM(gl.[Debit Amount]) AS DECIMAL(20, 8)) AS 'EUR Debit Amount'
	,CAST(SUM(gl.[Credit Amount]) AS DECIMAL(20, 8)) AS 'EUR Credit Amount'
	,CAST(@End AS DATE) AS 'EUR XR Date'
	,CAST(1.00 AS DECIMAL(12, 8)) AS 'EUR XR'
	,CAST(SUM(gl.[Amount]) * (
			SELECT TOP 1 [Exchange Rate Amount]
			
			FROM [EU Rate Currency Exchange]
			
			WHERE [Relational Currency Code] = ''
				AND [Currency Code] = 'USD'
				AND [Starting Date] <= @End
			
			ORDER BY [Starting Date] DESC
			) AS DECIMAL(20, 8)) AS 'USD Amount'
	,CAST(SUM(gl.[VAT Amount]) * (
			SELECT TOP 1 [Exchange Rate Amount]
			
			FROM [EU Rate Currency Exchange]
			
			WHERE [Relational Currency Code] = ''
				AND [Currency Code] = 'USD'
				AND [Starting Date] <= @End
			
			ORDER BY [Starting Date] DESC
			) AS DECIMAL(20, 8)) AS 'USD VAT Amount'
	,CAST(SUM(gl.[Debit Amount]) * (
			SELECT TOP 1 [Exchange Rate Amount]
			
			FROM [EU Rate Currency Exchange]
			
			WHERE [Relational Currency Code] = ''
				AND [Currency Code] = 'USD'
				AND [Starting Date] <= @End
			
			ORDER BY [Starting Date] DESC
			) AS DECIMAL(20, 8)) AS 'USD Debit Amount'
	,CAST(SUM(gl.[Credit Amount]) * (
			SELECT TOP 1 [Exchange Rate Amount]
			
			FROM [EU Rate Currency Exchange]
			
			WHERE [Relational Currency Code] = ''
				AND [Currency Code] = 'USD'
				AND [Starting Date] <= @End
			
			ORDER BY [Starting Date] DESC
			) AS DECIMAL(20, 8)) AS 'USD Credit Amount'
	,CAST((
			SELECT TOP 1 [Starting Date]
			
			FROM [EU Rate Currency Exchange]
			
			WHERE [Relational Currency Code] = ''
				AND [Currency Code] = 'USD'
				AND [Starting Date] <= @End
			
			ORDER BY [Starting Date] DESC
			) AS DATE) AS 'USD XR Date'
	,CAST((
			SELECT TOP 1 [Exchange Rate Amount]
			
			FROM [EU Rate Currency Exchange]
			
			WHERE [Relational Currency Code] = ''
				AND [Currency Code] = 'USD'
				AND [Starting Date] <= @End
			
			ORDER BY [Starting Date] DESC
			) AS DECIMAL(12, 8)) AS 'USD XR'

FROM [EU Entry GL] AS gl

WHERE [Posting Date] <= @End

GROUP BY gl.[G_L Account No_]
	,gl.[Source No_]
	,gl.[G_L Account No_]
	,gl.[Source No_];