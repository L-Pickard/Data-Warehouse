USE [Warehouse]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE
	OR

ALTER PROCEDURE [dbo].[Update LLC fShipped Qty NAV OG Values]
AS
INSERT INTO [Warehouse].[dbo].[fShipped Qty NAV OG] (
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
SELECT [Entity]
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
FROM [Warehouse].[dbo].[fShipped Qty]
WHERE [Entity] = 'Shiner LLC'
GO