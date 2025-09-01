USE [Warehouse]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER
    
 PROCEDURE [dbo].[Update fShipped Qty]
AS
/*===============================================================================================================================================
Project: Potential Sell Through
Language: T-SQL
Author: Leo Pickard
Version: 1.0
Date: 16/08/2024
=================================================================================================================================================
This stored procedure deletes all rows of data and then inserts new rows of data in the [dbo].[fShipped Qty] table. This file is included in
warehouse db repository and if changes are made they need to be made in both places. I have included a copy of this file so we have all the files
affecting the pst in one place.
=================================================================================================================================================*/
DECLARE @today DATE

SET @today = CAST(GETDATE() AS DATE);

DELETE
	FROM [Warehouse].[dbo].[fShipped Qty];

PRINT('Deleted all rows from [Warehouse].[dbo].[fShipped Qty]');

INSERT INTO [fShipped Qty] (
     [Entity]
    ,[Item No]
    ,[Shipped in Last 360 Days]
    ,[Shipped in Last 180 Days]
    ,[Shipped 331 to 360 Days Ago]
    ,[Shipped 301 to 330 Days Ago]
    ,[Shipped 271 to 300 Days Ago]
    ,[Shipped 241 to 270 Days Ago]
    ,[Shipped 211 to 240 Days Ago]
    ,[Shipped 181 to 210 Days Ago]
    ,[Shipped 151 to 180 Days Ago]
    ,[Shipped 121 to 150 Days Ago]
    ,[Shipped 91 to 120 Days Ago]
    ,[Shipped 61 to 90 Days Ago]
    ,[Shipped 31 to 60 Days Ago]
    ,[Shipped 1 to 30 Days Ago]
    ,[Shipped 30 Day Avg]
    ,[Shipped 30 Day Avg 6M]
    )

-- Below are the selects for Shiner Ltd which exclude sales orders to Shiner LLC

SELECT 'Shiner Ltd' AS [Entity]
    ,lc.[Item No]
    ,CAST(ISNULL((
                SELECT SUM([Quantity])
                FROM [fSales]
                WHERE [Posting Date] BETWEEN DATEADD(dd, - 360, @today)
                        AND DATEADD(dd, - 1, @today)
                    AND [Customer No] NOT IN (
                          'CU110036' -- Shiner LLC (Management Recharge)
                        , 'CU110077' -- Shiner LLC
                        )
                    AND [Entity] = 'Shiner Ltd'
                    AND [Item No] = lc.[Item No]
                ), 0) AS INTEGER) AS [Shipped in Last 360 Days]
    ,CAST(ISNULL((
                SELECT SUM([Quantity])
                FROM [fSales]
                WHERE [Posting Date] BETWEEN DATEADD(dd, - 180, @today)
                        AND DATEADD(dd, - 1, @today)
                    AND [Customer No] NOT IN (
                          'CU110036' -- Shiner LLC (Management Recharge)
                        , 'CU110077' -- Shiner LLC
                        )
                    AND [Entity] = 'Shiner Ltd'
                    AND [Item No] = lc.[Item No]
                ), 0) AS INTEGER) AS [Shipped in Last 180 Days]
    ,CAST(ISNULL((
                SELECT SUM([Quantity])
                FROM [fSales]
                WHERE [Posting Date] BETWEEN DATEADD(dd, - 360, @today)
                        AND DATEADD(dd, - 331, @today)
                    AND [Customer No] NOT IN (
                          'CU110036' -- Shiner LLC (Management Recharge)
                        , 'CU110077' -- Shiner LLC
                        )
                    AND [Entity] = 'Shiner Ltd'
                    AND [Item No] = lc.[Item No]
                ), 0) AS INTEGER) AS [Shipped 331 to 360 Days Ago]
    ,CAST(ISNULL((
                SELECT SUM([Quantity])
                FROM [fSales]
                WHERE [Posting Date] BETWEEN DATEADD(dd, - 330, @today)
                        AND DATEADD(dd, - 301, @today)
                    AND [Customer No] NOT IN (
                          'CU110036' -- Shiner LLC (Management Recharge)
                        , 'CU110077' -- Shiner LLC
                        )
                    AND [Entity] = 'Shiner Ltd'
                    AND [Item No] = lc.[Item No]
                ), 0) AS INTEGER) AS [Shipped 301 to 330 Days Ago]
    ,CAST(ISNULL((
                SELECT SUM([Quantity])
                FROM [fSales]
                WHERE [Posting Date] BETWEEN DATEADD(dd, - 300, @today)
                        AND DATEADD(dd, - 271, @today)
                    AND [Customer No] NOT IN (
                          'CU110036' -- Shiner LLC (Management Recharge)
                        , 'CU110077' -- Shiner LLC
                        )
                    AND [Entity] = 'Shiner Ltd'
                    AND [Item No] = lc.[Item No]
                ), 0) AS INTEGER) AS [Shipped 271 to 300 Days Ago]
    ,CAST(ISNULL((
                SELECT SUM([Quantity])
                FROM [fSales]
                WHERE [Posting Date] BETWEEN DATEADD(dd, - 270, @today)
                        AND DATEADD(dd, - 241, @today)
                    AND [Customer No] NOT IN (
                          'CU110036' -- Shiner LLC (Management Recharge)
                        , 'CU110077' -- Shiner LLC
                        )
                    AND [Entity] = 'Shiner Ltd'
                    AND [Item No] = lc.[Item No]
                ), 0) AS INTEGER) AS [Shipped 241 to 270 Days Ago]
    ,CAST(ISNULL((
                SELECT SUM([Quantity])
                FROM [fSales]
                WHERE [Posting Date] BETWEEN DATEADD(dd, - 240, @today)
                        AND DATEADD(dd, - 211, @today)
                    AND [Customer No] NOT IN (
                          'CU110036' -- Shiner LLC (Management Recharge)
                        , 'CU110077' -- Shiner LLC
                        )
                    AND [Entity] = 'Shiner Ltd'
                    AND [Item No] = lc.[Item No]
                ), 0) AS INTEGER) AS [Shipped 211 to 240 Days Ago]
    ,CAST(ISNULL((
                SELECT SUM([Quantity])
                FROM [fSales]
                WHERE [Posting Date] BETWEEN DATEADD(dd, - 210, @today)
                        AND DATEADD(dd, - 181, @today)
                    AND [Customer No] NOT IN (
                          'CU110036' -- Shiner LLC (Management Recharge)
                        , 'CU110077' -- Shiner LLC
                        )
                    AND [Entity] = 'Shiner Ltd'
                    AND [Item No] = lc.[Item No]
                ), 0) AS INTEGER) AS [Shipped 181 to 210 Days Ago]
    ,CAST(ISNULL((
                SELECT SUM([Quantity])
                FROM [fSales]
                WHERE [Posting Date] BETWEEN DATEADD(dd, - 180, @today)
                        AND DATEADD(dd, - 151, @today)
                    AND [Customer No] NOT IN (
                          'CU110036' -- Shiner LLC (Management Recharge)
                        , 'CU110077' -- Shiner LLC
                        )
                    AND [Entity] = 'Shiner Ltd'
                    AND [Item No] = lc.[Item No]
                ), 0) AS INTEGER) AS [Shipped 151 to 180 Days Ago]
    ,CAST(ISNULL((
                SELECT SUM([Quantity])
                FROM [fSales]
                WHERE [Posting Date] BETWEEN DATEADD(dd, - 150, @today)
                        AND DATEADD(dd, - 121, @today)
                    AND [Customer No] NOT IN (
                          'CU110036' -- Shiner LLC (Management Recharge)
                        , 'CU110077' -- Shiner LLC
                        )
                    AND [Entity] = 'Shiner Ltd'
                    AND [Item No] = lc.[Item No]
                ), 0) AS INTEGER) AS [Shipped 121 to 150 Days Ago]
    ,CAST(ISNULL((
                SELECT SUM([Quantity])
                FROM [fSales]
                WHERE [Posting Date] BETWEEN DATEADD(dd, - 120, @today)
                        AND DATEADD(dd, - 91, @today)
                    AND [Customer No] NOT IN (
                          'CU110036' -- Shiner LLC (Management Recharge)
                        , 'CU110077' -- Shiner LLC
                        )
                    AND [Entity] = 'Shiner Ltd'
                    AND [Item No] = lc.[Item No]
                ), 0) AS INTEGER) AS [Shipped 91 to 120 Days Ago]
    ,CAST(ISNULL((
                SELECT SUM([Quantity])
                FROM [fSales]
                WHERE [Posting Date] BETWEEN DATEADD(dd, - 90, @today)
                        AND DATEADD(dd, - 61, @today)
                    AND [Customer No] NOT IN (
                          'CU110036' -- Shiner LLC (Management Recharge)
                        , 'CU110077' -- Shiner LLC
                        )
                    AND [Entity] = 'Shiner Ltd'
                    AND [Item No] = lc.[Item No]
                ), 0) AS INTEGER) AS [Shipped 61 to 90 Days Ago]
    ,CAST(ISNULL((
                SELECT SUM([Quantity])
                FROM [fSales]
                WHERE [Posting Date] BETWEEN DATEADD(dd, - 60, @today)
                        AND DATEADD(dd, - 31, @today)
                    AND [Customer No] NOT IN (
                          'CU110036' -- Shiner LLC (Management Recharge)
                        , 'CU110077' -- Shiner LLC
                        )
                    AND [Entity] = 'Shiner Ltd'
                    AND [Item No] = lc.[Item No]
                ), 0) AS INTEGER) AS [Shipped 31 to 60 Days Ago]
    ,CAST(ISNULL((
                SELECT SUM([Quantity])
                FROM [fSales]
                WHERE [Posting Date] BETWEEN DATEADD(dd, - 30, @today)
                        AND DATEADD(dd, - 1, @today)
                    AND [Customer No] NOT IN (
                          'CU110036' -- Shiner LLC (Management Recharge)
                        , 'CU110077' -- Shiner LLC
                        )
                    AND [Entity] = 'Shiner Ltd'
                    AND [Item No] = lc.[Item No]
                ), 0) AS INTEGER) AS [Shipped 1 to 30 Days Ago]
    ,CAST(ISNULL((
                SELECT SUM([Quantity])
                FROM [fSales]
                WHERE [Posting Date] BETWEEN DATEADD(dd, - 360, @today)
                        AND DATEADD(dd, - 1, @today)
                    AND [Customer No] NOT IN (
                          'CU110036' -- Shiner LLC (Management Recharge)
                        , 'CU110077' -- Shiner LLC
                        )
                    AND [Entity] = 'Shiner Ltd'
                    AND [Item No] = lc.[Item No]
                ), 0) / 12 AS DECIMAL(20, 8)) AS [Shipped 30 Day Avg]
    ,CAST(ISNULL((
                SELECT SUM([Quantity])
                FROM [fSales]
                WHERE [Posting Date] BETWEEN DATEADD(dd, - 180, @today)
                        AND DATEADD(dd, - 1, @today)
                    AND [Customer No] NOT IN (
                          'CU110036' -- Shiner LLC (Management Recharge)
                        , 'CU110077' -- Shiner LLC
                        )
                    AND [Entity] = 'Shiner Ltd'
                    AND [Item No] = lc.[Item No]
                ), 0) / 6 AS DECIMAL(20, 8)) AS [Shipped 30 Day Avg 6M]
FROM (
    SELECT DISTINCT [Item No]
    FROM [fSales]
    WHERE [Posting Date] BETWEEN DATEADD(dd, - 360, @today)
            AND DATEADD(dd, - 1, @today)
        AND [Customer No] NOT IN (
              'CU110036' -- Shiner LLC (Management Recharge)
            , 'CU110077' -- Shiner LLC
            )
        AND [Entity] = 'Shiner Ltd'
    ) AS lc

UNION ALL

-- Below are the selects for Shiner B.V which exclude orders shipped from Shiner Ltd and intercompany sales orders to Shiner LLC or Shiner B.V

SELECT 'Shiner B.V' AS [Entity]
    ,bc.[Item No]
    ,CAST(ISNULL((
                SELECT SUM([Quantity])
                FROM [fSales]
                WHERE [Posting Date] BETWEEN DATEADD(dd, - 360, @today)
                        AND DATEADD(dd, - 1, @today)
                    AND [Customer No] NOT IN (
                          'CU110036' -- Shiner LLC (Management Recharge)
                        , 'CU110077' -- Shiner LLC
                        , 'CU103500' -- Shiner Limited
                        )
                    AND [Order No] NOT IN (
                        SELECT [Order No]
                        FROM [fSales]
                        WHERE [Entity] = 'Shiner Ltd'
                            AND [Order No] IS NOT NULL
                        )
                    AND [Entity] = 'Shiner B.V'
                    AND [Item No] = bc.[Item No]
                ), 0) AS INTEGER) AS [Shipped in Last 360 Days]
    ,CAST(ISNULL((
                SELECT SUM([Quantity])
                FROM [fSales]
                WHERE [Posting Date] BETWEEN DATEADD(dd, - 180, @today)
                        AND DATEADD(dd, - 1, @today)
                    AND [Customer No] NOT IN (
                          'CU110036' -- Shiner LLC (Management Recharge)
                        , 'CU110077' -- Shiner LLC
                        , 'CU103500' -- Shiner Limited
                        )
                    AND [Order No] NOT IN (
                        SELECT [Order No]
                        FROM [fSales]
                        WHERE [Entity] = 'Shiner Ltd'
                            AND [Order No] IS NOT NULL
                        )
                    AND [Entity] = 'Shiner B.V'
                    AND [Item No] = bc.[Item No]
                ), 0) AS INTEGER) AS [Shipped in Last 180 Days]
    ,CAST(ISNULL((
                SELECT SUM([Quantity])
                FROM [fSales]
                WHERE [Posting Date] BETWEEN DATEADD(dd, - 360, @today)
                        AND DATEADD(dd, - 331, @today)
                    AND [Customer No] NOT IN (
                          'CU110036' -- Shiner LLC (Management Recharge)
                        , 'CU110077' -- Shiner LLC
                        , 'CU103500' -- Shiner Limited
                        )
                    AND [Order No] NOT IN (
                        SELECT [Order No]
                        FROM [fSales]
                        WHERE [Entity] = 'Shiner Ltd'
                            AND [Order No] IS NOT NULL
                        )
                    AND [Entity] = 'Shiner B.V'
                    AND [Item No] = bc.[Item No]
                ), 0) AS INTEGER) AS [Shipped 331 to 360 Days Ago]
    ,CAST(ISNULL((
                SELECT SUM([Quantity])
                FROM [fSales]
                WHERE [Posting Date] BETWEEN DATEADD(dd, - 330, @today)
                        AND DATEADD(dd, - 301, @today)
                    AND [Customer No] NOT IN (
                          'CU110036' -- Shiner LLC (Management Recharge)
                        , 'CU110077' -- Shiner LLC
                        , 'CU103500' -- Shiner Limited
                        )
                    AND [Order No] NOT IN (
                        SELECT [Order No]
                        FROM [fSales]
                        WHERE [Entity] = 'Shiner Ltd'
                            AND [Order No] IS NOT NULL
                        )
                    AND [Entity] = 'Shiner B.V'
                    AND [Item No] = bc.[Item No]
                ), 0) AS INTEGER) AS [Shipped 301 to 330 Days Ago]
    ,CAST(ISNULL((
                SELECT SUM([Quantity])
                FROM [fSales]
                WHERE [Posting Date] BETWEEN DATEADD(dd, - 300, @today)
                        AND DATEADD(dd, - 271, @today)
                    AND [Customer No] NOT IN (
                          'CU110036' -- Shiner LLC (Management Recharge)
                        , 'CU110077' -- Shiner LLC
                        , 'CU103500' -- Shiner Limited
                        )
                    AND [Order No] NOT IN (
                        SELECT [Order No]
                        FROM [fSales]
                        WHERE [Entity] = 'Shiner Ltd'
                            AND [Order No] IS NOT NULL
                        )
                    AND [Entity] = 'Shiner B.V'
                    AND [Item No] = bc.[Item No]
                ), 0) AS INTEGER) AS [Shipped 271 to 300 Days Ago]
    ,CAST(ISNULL((
                SELECT SUM([Quantity])
                FROM [fSales]
                WHERE [Posting Date] BETWEEN DATEADD(dd, - 270, @today)
                        AND DATEADD(dd, - 241, @today)
                    AND [Customer No] NOT IN (
                          'CU110036' -- Shiner LLC (Management Recharge)
                        , 'CU110077' -- Shiner LLC
                        , 'CU103500' -- Shiner Limited
                        )
                    AND [Order No] NOT IN (
                        SELECT [Order No]
                        FROM [fSales]
                        WHERE [Entity] = 'Shiner Ltd'
                            AND [Order No] IS NOT NULL
                        )
                    AND [Entity] = 'Shiner B.V'
                    AND [Item No] = bc.[Item No]
                ), 0) AS INTEGER) AS [Shipped 241 to 270 Days Ago]
    ,CAST(ISNULL((
                SELECT SUM([Quantity])
                FROM [fSales]
                WHERE [Posting Date] BETWEEN DATEADD(dd, - 240, @today)
                        AND DATEADD(dd, - 211, @today)
                    AND [Customer No] NOT IN (
                          'CU110036' -- Shiner LLC (Management Recharge)
                        , 'CU110077' -- Shiner LLC
                        , 'CU103500' -- Shiner Limited
                        )
                    AND [Order No] NOT IN (
                        SELECT [Order No]
                        FROM [fSales]
                        WHERE [Entity] = 'Shiner Ltd'
                            AND [Order No] IS NOT NULL
                        )
                    AND [Entity] = 'Shiner B.V'
                    AND [Item No] = bc.[Item No]
                ), 0) AS INTEGER) AS [Shipped 211 to 240 Days Ago]
    ,CAST(ISNULL((
                SELECT SUM([Quantity])
                FROM [fSales]
                WHERE [Posting Date] BETWEEN DATEADD(dd, - 210, @today)
                        AND DATEADD(dd, - 181, @today)
                    AND [Customer No] NOT IN (
                          'CU110036' -- Shiner LLC (Management Recharge)
                        , 'CU110077' -- Shiner LLC
                        , 'CU103500' -- Shiner Limited
                        )
                    AND [Order No] NOT IN (
                        SELECT [Order No]
                        FROM [fSales]
                        WHERE [Entity] = 'Shiner Ltd'
                            AND [Order No] IS NOT NULL
                        )
                    AND [Entity] = 'Shiner B.V'
                    AND [Item No] = bc.[Item No]
                ), 0) AS INTEGER) AS [Shipped 181 to 210 Days Ago]
    ,CAST(ISNULL((
                SELECT SUM([Quantity])
                FROM [fSales]
                WHERE [Posting Date] BETWEEN DATEADD(dd, - 180, @today)
                        AND DATEADD(dd, - 151, @today)
                    AND [Customer No] NOT IN (
                          'CU110036' -- Shiner LLC (Management Recharge)
                        , 'CU110077' -- Shiner LLC
                        , 'CU103500' -- Shiner Limited
                        )
                    AND [Order No] NOT IN (
                        SELECT [Order No]
                        FROM [fSales]
                        WHERE [Entity] = 'Shiner Ltd'
                            AND [Order No] IS NOT NULL
                        )
                    AND [Entity] = 'Shiner B.V'
                    AND [Item No] = bc.[Item No]
                ), 0) AS INTEGER) AS [Shipped 151 to 180 Days Ago]
    ,CAST(ISNULL((
                SELECT SUM([Quantity])
                FROM [fSales]
                WHERE [Posting Date] BETWEEN DATEADD(dd, - 150, @today)
                        AND DATEADD(dd, - 121, @today)
                    AND [Customer No] NOT IN (
                          'CU110036' -- Shiner LLC (Management Recharge)
                        , 'CU110077' -- Shiner LLC
                        , 'CU103500' -- Shiner Limited
                        )
                    AND [Order No] NOT IN (
                        SELECT [Order No]
                        FROM [fSales]
                        WHERE [Entity] = 'Shiner Ltd'
                            AND [Order No] IS NOT NULL
                        )
                    AND [Entity] = 'Shiner B.V'
                    AND [Item No] = bc.[Item No]
                ), 0) AS INTEGER) AS [Shipped 121 to 150 Days Ago]
    ,CAST(ISNULL((
                SELECT SUM([Quantity])
                FROM [fSales]
                WHERE [Posting Date] BETWEEN DATEADD(dd, - 120, @today)
                        AND DATEADD(dd, - 91, @today)
                    AND [Customer No] NOT IN (
                          'CU110036' -- Shiner LLC (Management Recharge)
                        , 'CU110077' -- Shiner LLC
                        , 'CU103500' -- Shiner Limited
                        )
                    AND [Order No] NOT IN (
                        SELECT [Order No]
                        FROM [fSales]
                        WHERE [Entity] = 'Shiner Ltd'
                            AND [Order No] IS NOT NULL
                        )
                    AND [Entity] = 'Shiner B.V'
                    AND [Item No] = bc.[Item No]
                ), 0) AS INTEGER) AS [Shipped 91 to 120 Days Ago]
    ,CAST(ISNULL((
                SELECT SUM([Quantity])
                FROM [fSales]
                WHERE [Posting Date] BETWEEN DATEADD(dd, - 90, @today)
                        AND DATEADD(dd, - 61, @today)
                    AND [Customer No] NOT IN (
                          'CU110036' -- Shiner LLC (Management Recharge)
                        , 'CU110077' -- Shiner LLC
                        , 'CU103500' -- Shiner Limited
                        )
                    AND [Order No] NOT IN (
                        SELECT [Order No]
                        FROM [fSales]
                        WHERE [Entity] = 'Shiner Ltd'
                            AND [Order No] IS NOT NULL
                        )
                    AND [Entity] = 'Shiner B.V'
                    AND [Item No] = bc.[Item No]
                ), 0) AS INTEGER) AS [Shipped 61 to 90 Days Ago]
    ,CAST(ISNULL((
                SELECT SUM([Quantity])
                FROM [fSales]
                WHERE [Posting Date] BETWEEN DATEADD(dd, - 60, @today)
                        AND DATEADD(dd, - 31, @today)
                    AND [Customer No] NOT IN (
                          'CU110036' -- Shiner LLC (Management Recharge)
                        , 'CU110077' -- Shiner LLC
                        , 'CU103500' -- Shiner Limited
                        )
                    AND [Order No] NOT IN (
                        SELECT [Order No]
                        FROM [fSales]
                        WHERE [Entity] = 'Shiner Ltd'
                            AND [Order No] IS NOT NULL
                        )
                    AND [Entity] = 'Shiner B.V'
                    AND [Item No] = bc.[Item No]
                ), 0) AS INTEGER) AS [Shipped 31 to 60 Days Ago]
    ,CAST(ISNULL((
                SELECT SUM([Quantity])
                FROM [fSales]
                WHERE [Posting Date] BETWEEN DATEADD(dd, - 30, @today)
                        AND DATEADD(dd, - 1, @today)
                    AND [Customer No] NOT IN (
                          'CU110036' -- Shiner LLC (Management Recharge)
                        , 'CU110077' -- Shiner LLC
                        , 'CU103500' -- Shiner Limited
                        )
                    AND [Order No] NOT IN (
                        SELECT [Order No]
                        FROM [fSales]
                        WHERE [Entity] = 'Shiner Ltd'
                            AND [Order No] IS NOT NULL
                        )
                    AND [Entity] = 'Shiner B.V'
                    AND [Item No] = bc.[Item No]
                ), 0) AS INTEGER) AS [Shipped 1 to 30 Days Ago]
    ,CAST(ISNULL((
                SELECT SUM([Quantity])
                FROM [fSales]
                WHERE [Posting Date] BETWEEN DATEADD(dd, - 360, @today)
                        AND DATEADD(dd, - 1, @today)
                    AND [Customer No] NOT IN (
                          'CU110036' -- Shiner LLC (Management Recharge)
                        , 'CU110077' -- Shiner LLC
                        , 'CU103500' -- Shiner Limited
                        )
                    AND [Order No] NOT IN (
                        SELECT [Order No]
                        FROM [fSales]
                        WHERE [Entity] = 'Shiner Ltd'
                            AND [Order No] IS NOT NULL
                        )
                    AND [Entity] = 'Shiner B.V'
                    AND [Item No] = bc.[Item No]
                ), 0) / 12 AS DECIMAL(20, 8)) AS [Shipped 30 Day Avg]
    ,CAST(ISNULL((
                SELECT SUM([Quantity])
                FROM [fSales]
                WHERE [Posting Date] BETWEEN DATEADD(dd, - 180, @today)
                        AND DATEADD(dd, - 1, @today)
                    AND [Customer No] NOT IN (
                          'CU110036' -- Shiner LLC (Management Recharge)
                        , 'CU110077' -- Shiner LLC
                        , 'CU103500' -- Shiner Limited
                        )
                    AND [Order No] NOT IN (
                        SELECT [Order No]
                        FROM [fSales]
                        WHERE [Entity] = 'Shiner Ltd'
                            AND [Order No] IS NOT NULL
                        )
                    AND [Entity] = 'Shiner B.V'
                    AND [Item No] = bc.[Item No]
                ), 0) / 6 AS DECIMAL(20, 8)) [Shipped 30 Day Avg 6M]
FROM (
    SELECT DISTINCT [Item No]
    FROM [fSales]
    WHERE [Posting Date] BETWEEN DATEADD(dd, - 360, @today)
            AND DATEADD(dd, - 1, @today)
        AND [Customer No] NOT IN (
              'CU110036' -- Shiner LLC (Management Recharge)
            , 'CU110077' -- Shiner LLC
            , 'CU103500' -- Shiner Limited
            )
        AND [Order No] NOT IN (
            SELECT [Order No]
            FROM [fSales]
            WHERE [Entity] = 'Shiner Ltd'
                AND [Order No] IS NOT NULL
            )
        AND [Entity] = 'Shiner B.V'
    ) AS bc


UNION ALL

-- Below are the selects for Shiner LLC which excludes no orders

SELECT 'Shiner LLC' AS [Entity]
    ,lc.[Item No]
    ,CAST(ISNULL((
                SELECT SUM([Quantity])
                FROM [fSales]
                WHERE [Posting Date] BETWEEN DATEADD(dd, - 360, @today)
                        AND DATEADD(dd, - 1, @today)
                    AND [Intercompany] = 0
                    AND [Exclusion] = 0
                    AND [Entity] = 'Shiner LLC'
                    AND [Item No] = lc.[Item No]
                ), 0) AS INTEGER) AS [Shipped in Last 360 Days]
    ,CAST(ISNULL((
                SELECT SUM([Quantity])
                FROM [fSales]
                WHERE [Posting Date] BETWEEN DATEADD(dd, - 180, @today)
                        AND DATEADD(dd, - 1, @today)
                    AND [Intercompany] = 0
                    AND [Exclusion] = 0
                    AND [Entity] = 'Shiner LLC'
                    AND [Item No] = lc.[Item No]
                ), 0) AS INTEGER) AS [Shipped in Last 180 Days]
    ,CAST(ISNULL((
                SELECT SUM([Quantity])
                FROM [fSales]
                WHERE [Posting Date] BETWEEN DATEADD(dd, - 360, @today)
                        AND DATEADD(dd, - 331, @today)
                    AND [Intercompany] = 0
                    AND [Exclusion] = 0
                    AND [Entity] = 'Shiner LLC'
                    AND [Item No] = lc.[Item No]
                ), 0) AS INTEGER) AS [Shipped 331 to 360 Days Ago]
    ,CAST(ISNULL((
                SELECT SUM([Quantity])
                FROM [fSales]
                WHERE [Posting Date] BETWEEN DATEADD(dd, - 330, @today)
                        AND DATEADD(dd, - 301, @today)
                    AND [Intercompany] = 0
                    AND [Exclusion] = 0
                    AND [Entity] = 'Shiner LLC'
                    AND [Item No] = lc.[Item No]
                ), 0) AS INTEGER) AS [Shipped 301 to 330 Days Ago]
    ,CAST(ISNULL((
                SELECT SUM([Quantity])
                FROM [fSales]
                WHERE [Posting Date] BETWEEN DATEADD(dd, - 300, @today)
                        AND DATEADD(dd, - 271, @today)
                    AND [Intercompany] = 0
                    AND [Exclusion] = 0
                    AND [Entity] = 'Shiner LLC'
                    AND [Item No] = lc.[Item No]
                ), 0) AS INTEGER) AS [Shipped 271 to 300 Days Ago]
    ,CAST(ISNULL((
                SELECT SUM([Quantity])
                FROM [fSales]
                WHERE [Posting Date] BETWEEN DATEADD(dd, - 270, @today)
                        AND DATEADD(dd, - 241, @today)
                    AND [Intercompany] = 0
                    AND [Exclusion] = 0
                    AND [Entity] = 'Shiner LLC'
                    AND [Item No] = lc.[Item No]
                ), 0) AS INTEGER) AS [Shipped 241 to 270 Days Ago]
    ,CAST(ISNULL((
                SELECT SUM([Quantity])
                FROM [fSales]
                WHERE [Posting Date] BETWEEN DATEADD(dd, - 240, @today)
                        AND DATEADD(dd, - 211, @today)
                    AND [Intercompany] = 0
                    AND [Exclusion] = 0
                    AND [Entity] = 'Shiner LLC'
                    AND [Item No] = lc.[Item No]
                ), 0) AS INTEGER) AS [Shipped 211 to 240 Days Ago]
    ,CAST(ISNULL((
                SELECT SUM([Quantity])
                FROM [fSales]
                WHERE [Posting Date] BETWEEN DATEADD(dd, - 210, @today)
                        AND DATEADD(dd, - 181, @today)
                    AND [Intercompany] = 0
                    AND [Exclusion] = 0
                    AND [Entity] = 'Shiner LLC'
                    AND [Item No] = lc.[Item No]
                ), 0) AS INTEGER) AS [Shipped 181 to 210 Days Ago]
    ,CAST(ISNULL((
                SELECT SUM([Quantity])
                FROM [fSales]
                WHERE [Posting Date] BETWEEN DATEADD(dd, - 180, @today)
                        AND DATEADD(dd, - 151, @today)
                    AND [Intercompany] = 0
                    AND [Exclusion] = 0
                    AND [Entity] = 'Shiner LLC'
                    AND [Item No] = lc.[Item No]
                ), 0) AS INTEGER) AS [Shipped 151 to 180 Days Ago]
    ,CAST(ISNULL((
                SELECT SUM([Quantity])
                FROM [fSales]
                WHERE [Posting Date] BETWEEN DATEADD(dd, - 150, @today)
                        AND DATEADD(dd, - 121, @today)
                    AND [Intercompany] = 0
                    AND [Exclusion] = 0
                    AND [Entity] = 'Shiner LLC'
                    AND [Item No] = lc.[Item No]
                ), 0) AS INTEGER) AS [Shipped 121 to 150 Days Ago]
    ,CAST(ISNULL((
                SELECT SUM([Quantity])
                FROM [fSales]
                WHERE [Posting Date] BETWEEN DATEADD(dd, - 120, @today)
                        AND DATEADD(dd, - 91, @today)
                    AND [Intercompany] = 0
                    AND [Exclusion] = 0
                    AND [Entity] = 'Shiner LLC'
                    AND [Item No] = lc.[Item No]
                ), 0) AS INTEGER) AS [Shipped 91 to 120 Days Ago]
    ,CAST(ISNULL((
                SELECT SUM([Quantity])
                FROM [fSales]
                WHERE [Posting Date] BETWEEN DATEADD(dd, - 90, @today)
                        AND DATEADD(dd, - 61, @today)
                    AND [Intercompany] = 0
                    AND [Exclusion] = 0
                    AND [Entity] = 'Shiner LLC'
                    AND [Item No] = lc.[Item No]
                ), 0) AS INTEGER) AS [Shipped 61 to 90 Days Ago]
    ,CAST(ISNULL((
                SELECT SUM([Quantity])
                FROM [fSales]
                WHERE [Posting Date] BETWEEN DATEADD(dd, - 60, @today)
                        AND DATEADD(dd, - 31, @today)
                    AND [Intercompany] = 0
                    AND [Exclusion] = 0
                    AND [Entity] = 'Shiner LLC'
                    AND [Item No] = lc.[Item No]
                ), 0) AS INTEGER) AS [Shipped 31 to 60 Days Ago]
    ,CAST(ISNULL((
                SELECT SUM([Quantity])
                FROM [fSales]
                WHERE [Posting Date] BETWEEN DATEADD(dd, - 30, @today)
                        AND DATEADD(dd, - 1, @today)
                    AND [Intercompany] = 0
                    AND [Exclusion] = 0
                    AND [Entity] = 'Shiner LLC'
                    AND [Item No] = lc.[Item No]
                ), 0) AS INTEGER) AS [Shipped 1 to 30 Days Ago]
    ,CAST(ISNULL((
                SELECT SUM([Quantity])
                FROM [fSales]
                WHERE [Posting Date] BETWEEN DATEADD(dd, - 360, @today)
                        AND DATEADD(dd, - 1, @today)
                    AND [Intercompany] = 0
                    AND [Exclusion] = 0
                    AND [Entity] = 'Shiner LLC'
                    AND [Item No] = lc.[Item No]
                ), 0) / 12 AS DECIMAL(20, 8)) AS [Shipped 30 Day Avg]
    ,CAST(ISNULL((
                SELECT SUM([Quantity])
                FROM [fSales]
                WHERE [Posting Date] BETWEEN DATEADD(dd, - 180, @today)
                        AND DATEADD(dd, - 1, @today)
                    AND [Intercompany] = 0
                    AND [Exclusion] = 0
                    AND [Entity] = 'Shiner LLC'
                    AND [Item No] = lc.[Item No]
                ), 0) / 6 AS DECIMAL(20, 8)) [Shipped 30 Day Avg 6M]
FROM (
    SELECT DISTINCT [Item No]
    FROM [fSales]
    WHERE [Posting Date] BETWEEN DATEADD(dd, - 360, @today)
            AND DATEADD(dd, - 1, @today)
        AND [Intercompany] = 0
        AND [Exclusion] = 0
        AND [Entity] = 'Shiner LLC'
    ) AS lc
GO