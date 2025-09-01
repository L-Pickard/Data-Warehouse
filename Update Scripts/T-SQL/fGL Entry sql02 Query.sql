/*================================================================================================================
Project: Data Warehouse - Org Ltd & B.V GL Entry Table
Author: Leo Pickard
Date: April 2024
Version: 1.00

This SQL select statement gets the data needed for the GL entry table in the warehouse database. This
query will run on UK/EU server each night, triggered from a python script.
================================================================================================================*/
DECLARE @DTStart_Ltd AS DATE
    ,@DTStart_BV AS DATE
    ,@DTEnd AS DATE

SET @DTStart_Ltd = DATEADD(DAY, 1, '{COLDATE_LTD}')
SET @DTStart_BV = DATEADD(DAY, 1, '{COLDATE_BV}')

SET @DTEnd = CAST(DATEADD(DAY, - 1, GETDATE()) AS DATE);

-- SET @DTStart_Ltd = DATEADD(DAY, 1, '2024-01-01')
-- SET @DTStart_BV = DATEADD(DAY, 1, '2024-01-01')

-- SET @DTEnd = '2023-04-30';

SELECT CAST(CAST(YEAR(gl.[Posting Date]) AS VARCHAR(4)) + RIGHT('0' + CAST(MONTH(gl.
                [Posting Date]) AS VARCHAR(2)), 2) + RIGHT('0' + CAST(DAY(gl.
                [Posting Date]) AS VARCHAR(2)), 2) AS INTEGER) AS 'Date Key'
    ,CAST(gl.[Posting Date] AS DATE) AS 'Posting Date'
    ,'Org Ltd' AS 'Entity'
    ,gl.[Entry No_] AS 'Entry No'
    ,gl.[G_L Account No_] AS 'GL Account No'
    ,CASE 
        WHEN gl.[Document Type] = 0
            THEN 'Journal'
        WHEN gl.[Document Type] = 1
            THEN 'Payment'
        WHEN gl.[Document Type] = 2
            THEN 'Invoice'
        WHEN gl.[Document Type] = 3
            THEN 'Credit Memo'
        WHEN gl.[Document Type] = 4
            THEN 'Finance Charge Memo'
        WHEN gl.[Document Type] = 5
            THEN 'Reminder'
        WHEN gl.[Document Type] = 6
            THEN 'Refund'
        END AS 'Document Type'
    ,gl.[Document No_] AS 'Document No'
    ,gl.[Description]
    ,gl.[User ID]
    ,gl.[Source Code]
    ,gl.[Source Type]
    ,gl.[Source No_] AS 'Source No'
    ,gl.[Bal_ Account No_] AS 'Balance Account No'
    ,CAST(gl.[Amount] AS DECIMAL(20, 8)) AS 'GBP Amount'
    ,CAST(gl.[VAT Amount] AS DECIMAL(20, 8)) AS 'GBP VAT Amount'
    ,CAST(gl.[Debit Amount] AS DECIMAL(20, 8)) AS 'GBP Debit Amount'
    ,CAST(gl.[Credit Amount] AS DECIMAL(20, 8)) AS 'GBP Credit Amount'
    ,CAST(gl.[Posting Date] AS DATE) AS 'GBP XR Date'
    ,CAST(1.00 AS DECIMAL(12, 8)) AS 'GBP XR'
    ,CAST(gl.[Amount] * (
            SELECT TOP 1 [Exchange Rate Amount]
            FROM [Rate Currency Exchange]
            WHERE [Relational Currency Code] = ''
                AND [Currency Code] = 'EUR'
                AND [Starting Date] <= gl.[Posting Date]
            ORDER BY [Starting Date] DESC
            ) AS DECIMAL(20, 8)) AS 'EUR Amount'
    ,CAST(gl.[VAT Amount] * (
            SELECT TOP 1 [Exchange Rate Amount]
            FROM [Rate Currency Exchange]
            WHERE [Relational Currency Code] = ''
                AND [Currency Code] = 'EUR'
                AND [Starting Date] <= gl.[Posting Date]
            ORDER BY [Starting Date] DESC
            ) AS DECIMAL(20, 8)) AS 'EUR VAT Amount'
    ,CAST(gl.[Debit Amount] * (
            SELECT TOP 1 [Exchange Rate Amount]
            FROM [Rate Currency Exchange]
            WHERE [Relational Currency Code] = ''
                AND [Currency Code] = 'EUR'
                AND [Starting Date] <= gl.[Posting Date]
            ORDER BY [Starting Date] DESC
            ) AS DECIMAL(20, 8)) AS 'EUR Debit Amount'
    ,CAST(gl.[Credit Amount] * (
            SELECT TOP 1 [Exchange Rate Amount]
            FROM [Rate Currency Exchange]
            WHERE [Relational Currency Code] = ''
                AND [Currency Code] = 'EUR'
                AND [Starting Date] <= gl.[Posting Date]
            ORDER BY [Starting Date] DESC
            ) AS DECIMAL(20, 8)) AS 'EUR Credit Amount'
    ,CAST((
            SELECT TOP 1 [Starting Date]
            FROM [Rate Currency Exchange]
            WHERE [Relational Currency Code] = ''
                AND [Currency Code] = 'EUR'
                AND [Starting Date] <= gl.[Posting Date]
            ORDER BY [Starting Date] DESC
            ) AS DATE) AS 'EUR XR Date'
    ,CAST((
            SELECT TOP 1 [Exchange Rate Amount]
            FROM [Rate Currency Exchange]
            WHERE [Relational Currency Code] = ''
                AND [Currency Code] = 'EUR'
                AND [Starting Date] <= gl.[Posting Date]
            ORDER BY [Starting Date] DESC
            ) AS DECIMAL(12, 8)) AS 'EUR XR'
    ,CAST(gl.[Amount] * (
            SELECT TOP 1 [Exchange Rate Amount]
            FROM [Rate Currency Exchange]
            WHERE [Relational Currency Code] = ''
                AND [Currency Code] = 'USD'
                AND [Starting Date] <= gl.[Posting Date]
            ORDER BY [Starting Date] DESC
            ) AS DECIMAL(20, 8)) AS 'USD Amount'
    ,CAST(gl.[VAT Amount] * (
            SELECT TOP 1 [Exchange Rate Amount]
            FROM [Rate Currency Exchange]
            WHERE [Relational Currency Code] = ''
                AND [Currency Code] = 'USD'
                AND [Starting Date] <= gl.[Posting Date]
            ORDER BY [Starting Date] DESC
            ) AS DECIMAL(20, 8)) AS 'USD VAT Amount'
    ,CAST(gl.[Debit Amount] * (
            SELECT TOP 1 [Exchange Rate Amount]
            FROM [Rate Currency Exchange]
            WHERE [Relational Currency Code] = ''
                AND [Currency Code] = 'USD'
                AND [Starting Date] <= gl.[Posting Date]
            ORDER BY [Starting Date] DESC
            ) AS DECIMAL(20, 8)) AS 'USD Debit Amount'
    ,CAST(gl.[Credit Amount] * (
            SELECT TOP 1 [Exchange Rate Amount]
            FROM [Rate Currency Exchange]
            WHERE [Relational Currency Code] = ''
                AND [Currency Code] = 'USD'
                AND [Starting Date] <= gl.[Posting Date]
            ORDER BY [Starting Date] DESC
            ) AS DECIMAL(20, 8)) AS 'USD Credit Amount'
    ,CAST((
            SELECT TOP 1 [Starting Date]
            FROM [Rate Currency Exchange]
            WHERE [Relational Currency Code] = ''
                AND [Currency Code] = 'USD'
                AND [Starting Date] <= gl.[Posting Date]
            ORDER BY [Starting Date] DESC
            ) AS DATE) AS 'USD XR Date'
    ,CAST((
            SELECT TOP 1 [Exchange Rate Amount]
            FROM [Rate Currency Exchange]
            WHERE [Relational Currency Code] = ''
                AND [Currency Code] = 'USD'
                AND [Starting Date] <= gl.[Posting Date]
            ORDER BY [Starting Date] DESC
            ) AS DECIMAL(12, 8)) AS 'USD XR'
FROM [Entry GL] AS gl
WHERE [Posting Date] BETWEEN @DTStart_Ltd
        AND @DTEnd

UNION ALL

SELECT CAST(CAST(YEAR(gl.[Posting Date]) AS VARCHAR(4)) + RIGHT('0' + CAST(MONTH(gl.
                [Posting Date]) AS VARCHAR(2)), 2) + RIGHT('0' + CAST(DAY(gl.
                [Posting Date]) AS VARCHAR(2)), 2) AS INTEGER) AS 'Date Key'
    ,CAST(gl.[Posting Date] AS DATE) AS 'Posting Date'
    ,'Org B.V' AS 'Entity'
    ,gl.[Entry No_] AS 'Entry No'
    ,gl.[G_L Account No_] AS 'GL Account No'
    ,CASE 
        WHEN gl.[Document Type] = 0
            THEN 'Journal'
        WHEN gl.[Document Type] = 1
            THEN 'Payment'
        WHEN gl.[Document Type] = 2
            THEN 'Invoice'
        WHEN gl.[Document Type] = 3
            THEN 'Credit Memo'
        WHEN gl.[Document Type] = 4
            THEN 'Finance Charge Memo'
        WHEN gl.[Document Type] = 5
            THEN 'Reminder'
        WHEN gl.[Document Type] = 6
            THEN 'Refund'
        END AS 'Document Type'
    ,gl.[Document No_] AS 'Document No'
    ,gl.[Description]
    ,gl.[User ID]
    ,gl.[Source Code]
    ,gl.[Source Type]
    ,gl.[Source No_] AS 'Source No'
    ,gl.[Bal_ Account No_] AS 'Balance Account No'
    ,CAST(gl.[Amount] * (
            SELECT TOP 1 [Exchange Rate Amount]
            FROM [EU Rate Currency Exchange]
            WHERE [Relational Currency Code] = ''
                AND [Currency Code] = 'GBP'
                AND [Starting Date] <= gl.[Posting Date]
            ORDER BY [Starting Date] DESC
            ) AS DECIMAL(20, 8)) AS 'GBP Amount'
    ,CAST(gl.[VAT Amount] * (
            SELECT TOP 1 [Exchange Rate Amount]
            FROM [EU Rate Currency Exchange]
            WHERE [Relational Currency Code] = ''
                AND [Currency Code] = 'GBP'
                AND [Starting Date] <= gl.[Posting Date]
            ORDER BY [Starting Date] DESC
            ) AS DECIMAL(20, 8)) AS 'GBP VAT Amount'
    ,CAST(gl.[Debit Amount] * (
            SELECT TOP 1 [Exchange Rate Amount]
            FROM [EU Rate Currency Exchange]
            WHERE [Relational Currency Code] = ''
                AND [Currency Code] = 'GBP'
                AND [Starting Date] <= gl.[Posting Date]
            ORDER BY [Starting Date] DESC
            ) AS DECIMAL(20, 8)) AS 'GBP Debit Amount'
    ,CAST(gl.[Credit Amount] * (
            SELECT TOP 1 [Exchange Rate Amount]
            FROM [EU Rate Currency Exchange]
            WHERE [Relational Currency Code] = ''
                AND [Currency Code] = 'GBP'
                AND [Starting Date] <= gl.[Posting Date]
            ORDER BY [Starting Date] DESC
            ) AS DECIMAL(20, 8)) AS 'GBP Credit Amount'
    ,CAST((
            SELECT TOP 1 [Starting Date]
            FROM [EU Rate Currency Exchange]
            WHERE [Relational Currency Code] = ''
                AND [Currency Code] = 'GBP'
                AND [Starting Date] <= gl.[Posting Date]
            ORDER BY [Starting Date] DESC
            ) AS DATE) AS 'GBP XR Date'
    ,CAST((
            SELECT TOP 1 [Exchange Rate Amount]
            FROM [EU Rate Currency Exchange]
            WHERE [Relational Currency Code] = ''
                AND [Currency Code] = 'GBP'
                AND [Starting Date] <= gl.[Posting Date]
            ORDER BY [Starting Date] DESC
            ) AS DECIMAL(12, 8)) AS 'GBP XR'
    ,CAST(gl.[Amount] AS DECIMAL(20, 8)) AS 'EUR Amount'
    ,CAST(gl.[VAT Amount] AS DECIMAL(20, 8)) AS 'EUR VAT Amount'
    ,CAST(gl.[Debit Amount] AS DECIMAL(20, 8)) AS 'EUR Debit Amount'
    ,CAST(gl.[Credit Amount] AS DECIMAL(20, 8)) AS 'EUR Credit Amount'
    ,CAST(gl.[Posting Date] AS DATE) AS 'EUR XR Date'
    ,CAST(1.00 AS DECIMAL(12, 8)) AS 'EUR XR'
    ,CAST(gl.[Amount] * (
            SELECT TOP 1 [Exchange Rate Amount]
            FROM [EU Rate Currency Exchange]
            WHERE [Relational Currency Code] = ''
                AND [Currency Code] = 'USD'
                AND [Starting Date] <= gl.[Posting Date]
            ORDER BY [Starting Date] DESC
            ) AS DECIMAL(20, 8)) AS 'USD Amount'
    ,CAST(gl.[VAT Amount] * (
            SELECT TOP 1 [Exchange Rate Amount]
            FROM [EU Rate Currency Exchange]
            WHERE [Relational Currency Code] = ''
                AND [Currency Code] = 'USD'
                AND [Starting Date] <= gl.[Posting Date]
            ORDER BY [Starting Date] DESC
            ) AS DECIMAL(20, 8)) AS 'USD VAT Amount'
    ,CAST(gl.[Debit Amount] * (
            SELECT TOP 1 [Exchange Rate Amount]
            FROM [EU Rate Currency Exchange]
            WHERE [Relational Currency Code] = ''
                AND [Currency Code] = 'USD'
                AND [Starting Date] <= gl.[Posting Date]
            ORDER BY [Starting Date] DESC
            ) AS DECIMAL(20, 8)) AS 'USD Debit Amount'
    ,CAST(gl.[Credit Amount] * (
            SELECT TOP 1 [Exchange Rate Amount]
            FROM [EU Rate Currency Exchange]
            WHERE [Relational Currency Code] = ''
                AND [Currency Code] = 'USD'
                AND [Starting Date] <= gl.[Posting Date]
            ORDER BY [Starting Date] DESC
            ) AS DECIMAL(20, 8)) AS 'USD Credit Amount'
    ,CAST((
            SELECT TOP 1 [Starting Date]
            FROM [EU Rate Currency Exchange]
            WHERE [Relational Currency Code] = ''
                AND [Currency Code] = 'USD'
                AND [Starting Date] <= gl.[Posting Date]
            ORDER BY [Starting Date] DESC
            ) AS DATE) AS 'USD XR Date'
    ,CAST((
            SELECT TOP 1 [Exchange Rate Amount]
            FROM [EU Rate Currency Exchange]
            WHERE [Relational Currency Code] = ''
                AND [Currency Code] = 'USD'
                AND [Starting Date] <= gl.[Posting Date]
            ORDER BY [Starting Date] DESC
            ) AS DECIMAL(12, 8)) AS 'USD XR'
FROM [EU Entry GL] AS gl
WHERE [Posting Date] BETWEEN @DTStart_BV
        AND @DTEnd
