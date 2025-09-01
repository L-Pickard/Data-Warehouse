SELECT ISNULL(it.No_, bt.No_) AS [Item No]
    ,ISNULL(LEFT(it.No_, 3), LEFT(bt.No_, 3)) AS [Brand Code]
    ,ISNULL(it.[Vendor Reference], bt.[Vendor Reference]) AS [Vendor Reference]
    ,ISNULL(it.[Description], bt.[Description]) AS [Description]
    ,ISNULL(it.[Description 2], bt.[Description 2]) AS [Description 2]
    ,ISNULL(it.[Colours], bt.[Colours]) AS [Colours]
    ,ISNULL(it.[Size 1], bt.[Size 1]) AS [Size 1]
    ,ISNULL(it.[Size 1 Unit], bt.[Size 1 Unit]) AS [Size 1 Unit]
    ,ISNULL(it.[EU Size], bt.[EU Size]) AS [EU Size]
    ,ISNULL(it.[EU Size Unit], bt.[EU Size Unit]) AS [EU Size Unit]
    ,ISNULL(it.[US Size], bt.[US Size]) AS [US Size]
    ,ISNULL(it.[US Size Unit], bt.[US Size Unit]) AS [US Size Unit]
    ,ISNULL(it.[Base Unit of Measure], bt.[Base Unit of Measure]) AS [UOM]
    ,ISNULL(CASE it.[Season Code]
            WHEN 0
                THEN ''
            WHEN 1
                THEN 'SP'
            WHEN 2
                THEN 'SU'
            WHEN 3
                THEN 'FA'
            WHEN 4
                THEN 'HO'
            ELSE CAST(it.[Season Code] AS VARCHAR(2))
            END + CASE it.[Season Year]
            WHEN 0
                THEN ''
            WHEN 1
                THEN '23'
            WHEN 2
                THEN '24'
            WHEN 3
                THEN '25'
            WHEN 4
                THEN '26'
            ELSE CAST(it.[Season Year] AS VARCHAR(2))
            END, CASE bt.[Season Code]
            WHEN 0
                THEN ''
            WHEN 1
                THEN 'SP'
            WHEN 2
                THEN 'SU'
            WHEN 3
                THEN 'FA'
            WHEN 4
                THEN 'HO'
            ELSE CAST(bt.[Season Code] AS VARCHAR(2))
            END + CASE bt.[Season Year]
            WHEN 0
                THEN ''
            WHEN 1
                THEN '23'
            WHEN 2
                THEN '24'
            WHEN 3
                THEN '25'
            WHEN 4
                THEN '26'
            ELSE CAST(it.[Season Year] AS VARCHAR(2))
            END) AS [Season]
    ,ISNULL(it.[Item Info], 'EU Item Only') AS [Item Info]
    ,CASE 
        WHEN ct.[Description] LIKE 'B2B IT Function%'
            THEN 'B2B IT'
        ELSE ct.[Description]
        END AS [Category]
    ,it.[Item Category Code] AS [Category Code]
    ,CASE 
        WHEN pg.[Description] = 'Girls 2 Wheel Sidewalks'
            THEN 'Girls 2 Wheel'
        WHEN pg.[Description] = 'Boys 2 Wheel Sidewalks'
            THEN 'Boys 2 Wheel'
        WHEN pg.[Description] = 'Girls 1 Wheel Sidewalks'
            THEN 'Girls 1 Wheel'
        WHEN pg.[Description] = 'Boys 1 Wheel Sidewalks'
            THEN 'Boys 1 Wheel'
        WHEN pg.[Description] = 'Old Nil Cost Stock'
            THEN 'Old Nil Cost'
        ELSE pg.[Description]
        END AS [Group]
    ,it.[Product Group Code] AS [Group Code]
    ,it.[EAN Barcode] AS [EAN Barcode]
    ,it.[Tariff No_] AS [Tariff No]
    ,ISNULL(it.[Description], '-') + '-' + ISNULL(it.[Description 2], '-') + '-' + ISNULL(
        it.[Colours], '-') + '-' + ISNULL(it.[Item Category Code], '-') + '-' + ISNULL(it.
        [Product Group Code], '-') AS [Style Ref]
    ,ISNULL(it.[Unit Price], 0) AS [GBP Trade]
    ,ISNULL(it.[SRP], 0) AS [GBP SRP]
    ,ISNULL((
            SELECT TOP 1 [Unit Price]
            FROM [Shiner$Sales Price]
            WHERE [Sales Type] = 2
                AND [Currency Code] = 'EUR'
                AND [Minimum Quantity] = 1
                AND [Item No_] = it.[No_]
            ), 0) AS [EUR Trade]
    ,ISNULL(it.[Euro SRP], bt.[Euro SRP]) AS [EUR SRP]
    ,ISNULL((
            SELECT TOP 1 [Unit Price]
            FROM [Shiner$Sales Price]
            WHERE [Sales Type] = 2
                AND [Currency Code] = 'USD'
                AND [Minimum Quantity] = 1
                AND [Item No_] = it.[No_]
            ), 0) AS [USD Trade]
    ,ISNULL(it.[USD SRP], bt.[USD SRP]) AS [USD SRP]
    ,ISNULL(it.[Vendor No_], bt.[Vendor No_]) AS [Nav Vendor No]
    ,vn.[Name] AS [Vendor Name]
    ,it.[Blocked] AS [Ltd Blocked]
    ,bt.[Blocked] AS [B.V Blocked]
    ,ISNULL(it.[Preferential Sale], bt.[Preferential Sale]) AS [On Sale]
    ,ISNULL(it.[Hot Product], bt.[Hot Product]) AS [Hot Product]
    ,ISNULL(it.[Lead Time Text], bt.[Lead Time Text]) AS [Lead Time]
    ,ISNULL(it.[Country_Region of Origin Code], bt.
        [Country_Region of Origin Code]) AS [COO]
    ,ISNULL(it.[Bread & Butter], bt.[Bread & Butter]) AS [Bread & Butter]
    ,CAST(ISNULL(it.[Buffer Stock], 0) AS INTEGER) AS [Ltd Buffer Stock]
    ,CAST(ISNULL(bt.[Buffer Stock], 0) AS INTEGER) AS [B.V Buffer Stock]
    ,ISNULL(it.[Common Item No_], bt.[Common Item No_]) AS [Common Item No]
    ,ISNULL(it.[Unit Cost], 0) AS [Ltd GBP Unit Cost]
    ,ISNULL(bt.[Unit Cost], 0) AS [B.V EUR Unit Cost]
    ,ISNULL(it.[D2C Master SKU], bt.[D2C Master SKU]) AS [D2C Master SKU]
    ,ISNULL(it.[D2C Web Item], bt.[D2C Web Item]) AS [D2C Web Item]
    ,ISNULL(it.[Owtanet Export], bt.[Owtanet Export]) AS [Owtanet Export]
    ,ISNULL(it.[Web Item], bt.[Web Item]) AS [Web Item]
    ,ISNULL(it.[Record ID], it.[Record ID]) AS [Record ID]
FROM [Item] AS it
FULL OUTER JOIN [EU Item] AS bt
    ON it.No_ = bt.No_
LEFT JOIN [Vendor] AS vn
    ON ISNULL(it.[Vendor No_], bt.[Vendor No_]) = vn.No_
LEFT JOIN [Category Item] AS ct
    ON it.[Item Category Code] = ct.[Code]
LEFT JOIN [Group Product] AS pg
    ON it.[Item Category Code] = pg.[Item Category Code]
        AND it.[Product Group Code] = pg.[Code]
WHERE LEN(ISNULL(it.No_, bt.No_)) <= 30;