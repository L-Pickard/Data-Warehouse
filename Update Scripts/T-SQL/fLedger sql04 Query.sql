DECLARE @Start_Date AS DATE

SET @Start_Date = '2022-05-01';

SELECT @Start_Date AS [Posting Date]
    ,'Org LLC' AS [Entity]
    ,'Starting Inventory' AS [Entry Type]
	,LEFT(ve.[Item No_], 3) AS [Brand Code]
    ,ve.[Item No_] AS [Item No]
    ,ve.[Location Code]
    ,CAST(SUM(ve.[Invoiced Quantity]) AS INTEGER) AS [Quantity]
    ,'USD' AS [Currency]
    ,CAST(SUM(ve.[Cost Amount (Actual)]) AS DECIMAL(20, 8)) AS [Cost Value]
FROM [US Entry Value] AS ve
WHERE ve.[Posting Date] <= @Start_Date
GROUP BY LEFT(ve.[Item No_], 3)
	,ve.[Item No_]
    ,ve.[Location Code]
HAVING SUM(ve.[Invoiced Quantity]) > 0

UNION ALL

SELECT CAST(ve.[Posting Date] AS DATE) AS [Posting Date]
    ,'Org LLC' AS [Entity]
    ,CASE 
        WHEN ve.[Item Ledger Entry Type] = 0
            THEN 'Purchase'
        WHEN ve.[Item Ledger Entry Type] = 1
            THEN 'Sale'
        WHEN ve.[Item Ledger Entry Type] = 2
            THEN 'Positive Adjustment'
        WHEN ve.[Item Ledger Entry Type] = 3
            THEN 'Negative Adjustment'
        WHEN ve.[Item Ledger Entry Type] = 4
            THEN 'Transfer'
        WHEN ve.[Item Ledger Entry Type] = 5
            THEN 'Consumption'
        WHEN ve.[Item Ledger Entry Type] = 6
            THEN 'Output'
        ELSE 'Unknown'
        END AS [Entry Type]
	,LEFT(ve.[Item No_], 3) AS [Brand Code]
    ,ve.[Item No_] AS [Item No]
    ,ve.[Location Code]
    ,CAST(SUM(ve.[Invoiced Quantity]) AS INTEGER) AS [Quantity]
    ,'USD' AS [Currency]
    ,CAST(SUM(ve.[Cost Amount (Actual)]) AS DECIMAL(20, 8)) AS [Cost Value]
FROM [US Entry Value] AS ve
WHERE [Posting Date] > @Start_Date
GROUP BY ve.[Posting Date]
    ,ve.[Item Ledger Entry Type]
	,LEFT(ve.[Item No_], 3)
    ,ve.[Item No_]
    ,ve.[Location Code];