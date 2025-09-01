/*
Code Type
0    Purchase
1	 Sale
2	 Positive Adjmt.
3	 Negative Adjmt.
4	 Transfer
*/
DECLARE @Start_Date AS DATE

SET @Start_Date = '2022-05-01';

-- Org starting inventory
SELECT @Start_Date AS [Posting Date]
    ,'Org Ltd' AS [Entity]
    ,'Starting Inventory' AS [Entry Type]
    ,LEFT(ve.[Item No_], 3) AS [Brand Code]
    ,ve.[Item No_] AS [Item No]
    ,ve.[Location Code]
    ,CAST(SUM([Invoiced Quantity]) AS INTEGER) AS [Quantity]
    ,'GBP' AS [Currency]
    ,CAST(SUM(ve.[Cost Amount (Actual)]) AS DECIMAL(20, 8)) AS [Cost Value]
FROM [Entry Value] AS ve
WHERE [Posting Date] <= @Start_Date
GROUP BY LEFT(ve.[Item No_], 3)
    ,[Item No_]
    ,[Location Code]
HAVING SUM([Invoiced Quantity]) > 0

UNION ALL

SELECT @Start_Date AS [Posting Date]
    ,'Org B.V' AS [Entity]
    ,'Starting Inventory' AS [Entry Type]
    ,LEFT(ve.[Item No_], 3) AS [Brand Code]
    ,ve.[Item No_] AS [Item No]
    ,ve.[Location Code]
    ,CAST(SUM([Invoiced Quantity]) AS INTEGER) AS [Quantity]
    ,'EUR' AS [Currency]
    ,CAST(SUM(ve.[Cost Amount (Actual)]) AS DECIMAL(20, 8)) AS [Cost Value]
FROM [EU Entry Value] AS ve
WHERE [Posting Date] <= @Start_Date
GROUP BY LEFT(ve.[Item No_], 3)
    ,[Item No_]
    ,[Location Code]
HAVING SUM([Invoiced Quantity]) > 0

UNION ALL

SELECT CAST(ve.[Posting Date] AS DATE) AS [Posting Date]
    ,'Org Ltd' AS [Entity]
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
    ,CAST(SUM([Invoiced Quantity]) AS INTEGER) AS [Quantity]
    ,'GBP' AS [Currency]
    ,CAST(SUM(ve.[Cost Amount (Actual)]) AS DECIMAL(20, 8)) AS [Cost Value]
FROM [Entry Value] AS ve
WHERE [Posting Date] > @Start_Date
GROUP BY ve.[Posting Date]
    ,ve.[Item Ledger Entry Type]
    ,LEFT(ve.[Item No_], 3)
    ,ve.[Item No_]
    ,ve.[Location Code]

UNION ALL

SELECT CAST(ve.[Posting Date] AS DATE)
    ,'Org B.V' AS [Entity]
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
    ,LEFT(ve.[Item No_], 3)
    ,ve.[Item No_] AS [Item No]
    ,ve.[Location Code]
    ,CAST(SUM([Invoiced Quantity]) AS INTEGER) AS [Quantity]
    ,'EUR' AS [Currency]
    ,CAST(SUM(ve.[Cost Amount (Actual)]) AS DECIMAL(20, 8)) AS [Cost Value]
FROM [EU Entry Value] AS ve
WHERE [Posting Date] > @Start_Date
GROUP BY ve.[Posting Date]
    ,ve.[Item Ledger Entry Type]
    ,LEFT(ve.[Item No_], 3)
    ,ve.[Item No_]
    ,ve.[Location Code];