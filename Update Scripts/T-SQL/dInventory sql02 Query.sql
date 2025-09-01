WITH CTE_WHQTY
AS (
    SELECT [Item No_]
        ,SUM([Quantity]) AS [Inventory]
    FROM [Entry Warehouse]
    GROUP BY [Item No_]
    )
SELECT 'Org Ltd' AS 'Entity'
    ,itm.[No_] AS [Item No]
    ,CAST((
            (
                -- ILE
                isnull((
                        SELECT sum([Quantity])
                        FROM dbo.[Entry Item Ledger]
                        WHERE [Item No_] = itm.[No_]
                            AND [Location Code] = 'BRISTOL'
                        ), 0)
                ) - (
                -- Buffer Stock
                (
                    SELECT itm2.[Buffer Stock]
                    FROM dbo.[Item] itm2
                    WHERE itm2.[No_] = itm.[No_]
                    ) +
                -- Reservations                       
                isnull((
                        SELECT sum([Quantity])
                        FROM dbo.[Entry Reservation]
                        WHERE [Item No_] = itm.[No_]
                            AND [Source Type] = 32
                            AND -- ILE
                            [Source Subtype] = 0
                            AND [Reservation Status] = 0
                            AND -- Reservation
                            [Location Code] = 'BRISTOL'
                        ), 0) +
                -- Faulty Bin                         
                isnull((
                        SELECT sum([Quantity])
                        FROM dbo.[Entry Warehouse]
                        WHERE [Item No_] = itm.[No_]
                            AND [Bin Code] = 'FAULTY'
                            AND [Location Code] = 'BRISTOL'
                        ), 0) +
                ---- Rework Bin                         
                isnull((
                        SELECT sum([Quantity])
                        FROM dbo.[Entry Warehouse]
                        WHERE [Item No_] = itm.[No_]
                            AND [Bin Code] = 'REWORK'
                            AND [Location Code] = 'BRISTOL'
                        ), 0) +
                -- Receipt Bin                         
                isnull((
                        SELECT sum([Quantity])
                        FROM dbo.[Entry Warehouse]
                        WHERE [Item No_] = itm.[No_]
                            AND [Bin Code] = 'RECEIPT'
                            AND [Location Code] = 'BRISTOL'
                        ), 0) +
                -- QC                        
                isnull((
                        SELECT sum([Quantity])
                        FROM dbo.[Entry Warehouse]
                        WHERE [Item No_] = itm.[No_]
                            AND [Bin Code] = 'QC'
                            AND [Location Code] = 'BRISTOL'
                        ), 0) +
                -- Sample Room Bin                         
                isnull((
                        SELECT sum([Quantity])
                        FROM dbo.[Entry Warehouse]
                        WHERE [Item No_] = itm.[No_]
                            AND [Bin Code] = 'SAMPLE ROOM'
                            AND [Location Code] = 'BRISTOL'
                        ), 0)
                )
            ) AS INTEGER) AS 'Free Stock'
    ,CAST(ISNULL(wq.[Inventory], 0) AS INTEGER) AS 'Inventory'
FROM [dbo].[Item] AS itm
LEFT JOIN CTE_WHQTY AS wq
    ON itm.[No_] = wq.[Item No_]
GROUP BY itm.[No_]
    ,ISNULL(wq.[Inventory], 0)
HAVING ISNULL(wq.[Inventory], 0) > 0

UNION ALL

SELECT 'Org B.V' AS [Entity]
    ,il.[Item No_] AS [Item No]
    ,CAST(SUM(il.[Quantity]) - ISNULL((
                SELECT SUM([Quantity])
                FROM [EU Entry Reservation]
                WHERE [Item No_] = il.[Item No_]
                    AND [Source Type] = 32
                    AND -- ILE
                    [Source Subtype] = 0
                    AND [Reservation Status] = 0
                    AND -- Reservation
                    [Location Code] = '3PL'
                ), 0) AS INTEGER) AS [Free Stock]
    ,CAST(SUM(il.[Quantity]) AS INTEGER) AS [Inventory]
FROM [EU Entry Item Ledger] AS il
WHERE il.[Location Code] = '3PL'
GROUP BY il.[Item No_]
HAVING SUM([Quantity]) > 0;