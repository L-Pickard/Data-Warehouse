SELECT 'Org LLC' AS 'Entity'
	,[Currency Code]
	,CASE 
		WHEN [Relational Currency Code] = ''
			THEN 'USD'
		ELSE [Relational Currency Code]
		END AS 'Relational Currency Code'
	,CAST([Starting Date] AS DATE) AS [Starting Date]
	,[Exchange Rate Amount]
FROM [US Rate Currency Exchange]
WHERE [Starting Date] >= '2020-05-01'