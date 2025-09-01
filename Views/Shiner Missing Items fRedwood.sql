USE [Finance]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE
    OR

ALTER VIEW [Shiner Missing Items fRedwood]
AS
SELECT rw.[Item No]
    ,it.[Description]
    ,it.[Description 2]
    ,it.[Colours]
    ,it.[Size 1]
    ,it.[Size 1 Unit]
    ,it.[UOM]
    ,rw.[Qty Total in Warehouse]
FROM [fRedwood] AS rw
LEFT JOIN [dItem] AS it
    ON rw.[Item No] = it.[Item No]
WHERE rw.[Item No] NOT IN (
        SELECT [Item No]
        FROM [dInventory]
        WHERE [Entity] = 'Shiner B.V'
        )
    AND rw.[Qty Total in Warehouse] > 0
