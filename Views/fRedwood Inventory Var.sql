USE [Finance]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER VIEW [fRedwood Inventory Var] AS

SELECT iv.[Item No]
    ,it.[Description]
    ,it.[Description 2]
    ,it.[Colours]
    ,it.[Size 1]
    ,it.[Size 1 Unit]
    ,it.[UOM]
    ,iv.[Inventory] AS [Shiner Inv]
    ,ISNULL(rw.[Qty Total in Warehouse], 0) AS [Redwood Inv]
    ,ISNULL(rw.[Qty Total in Warehouse], 0) - iv.[Inventory] AS [Redwood Var]
FROM [dInventory] AS iv
LEFT JOIN [dItem] AS it
    ON iv.[Item No] = it.[Item No]
LEFT JOIN [fRedwood] AS rw
    ON iv.[Item No] = rw.[Item No]
WHERE iv.[Entity] = 'Shiner B.V'
    AND ISNULL(rw.[Qty Total in Warehouse], 0) - iv.[Inventory] <> 0;