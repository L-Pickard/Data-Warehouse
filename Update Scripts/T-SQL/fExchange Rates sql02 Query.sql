SELECT 'Org Ltd' AS 'Entity'
    ,[Currency Code]
    ,CASE 
        WHEN [Relational Currency Code] = ''
            THEN 'GBP'
        ELSE [Relational Currency Code]
        END AS 'Relational Currency Code'
    ,CAST([Starting Date] AS DATE) AS [Starting Date]
    ,[Exchange Rate Amount]
FROM [Rate Currency Exchange]
WHERE [Starting Date] >= '2020-05-01'

UNION ALL

SELECT 'Org B.V' AS 'Entity'
    ,[Currency Code]
    ,CASE 
        WHEN [Relational Currency Code] = ''
            THEN 'EUR'
        ELSE [Relational Currency Code]
        END AS 'Relational Currency Code'
    ,CAST([Starting Date] AS DATE) AS [Starting Date]
    ,[Exchange Rate Amount]
FROM [EU Rate Currency Exchange]
WHERE [Starting Date] >= '2020-05-01';