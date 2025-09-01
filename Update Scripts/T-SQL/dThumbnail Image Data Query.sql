WITH [Item Docs Paths]
AS (
    SELECT it.[Item No]
        ,rl.[URL] AS [Img URL]
        ,CASE 
            WHEN ISNUMERIC(SUBSTRING(rl.[URL], CHARINDEX('.', rl.[URL]) - 2, 1)) = 1
                AND ISNUMERIC(SUBSTRING(rl.[URL], CHARINDEX('.', rl.[URL]) - 1, 1)) = 1
                THEN 0
            WHEN ISNUMERIC(SUBSTRING(rl.[URL], CHARINDEX('.', rl.[URL]) - 2, 1)) = 0
                AND ISNUMERIC(SUBSTRING(rl.[URL], CHARINDEX('.', rl.[URL]) - 1, 1)) = 1
                THEN TRY_CONVERT(INTEGER, SUBSTRING(rl.[URL], CHARINDEX('.', rl.[URL]) - 1, 1))
            ELSE 100
            END AS [Index]
    FROM [dRecord Link] AS rl
    LEFT JOIN [dItem] AS it
        ON rl.[Record ID] = it.[Record ID]
    WHERE (
            it.[Ltd Blocked] = 0
            OR it.[B.V Blocked] = 0
            OR it.[B.V Blocked] = 0
            )
        AND rl.[Entity] = 'Org Ltd'
        AND rl.[Record ID] <> 0x00000000
        AND LEN(rl.[URL]) > 5
    )
    ,[Required Images]
AS (
    SELECT DISTINCT it.[Item No]
        ,(
            SELECT TOP 1 [Img URL]
            FROM [Item Docs Paths]
            WHERE [Item No] = it.[Item No]
            ORDER BY [Index] ASC
            ) AS [Image Path]
    FROM [Item Docs Paths] AS it
    )
SELECT ri.[Item No]
    ,it.[Common Item No]
    ,it.[Vendor Reference]
    ,it.[Brand Code]
    ,it.[Description]
    ,it.[Description 2]
    ,it.[Colours]
    ,it.[Size 1]
    ,it.[Size 1 Unit]
    ,it.[UOM]
    ,it.[Season]
    ,it.[Category Code]
    ,it.[Group Code]
    ,it.[EAN Barcode]
    ,it.[Tariff No]
    ,it.[COO]
    ,ri.[Image Path]
FROM [Required Images] AS ri
LEFT JOIN [dItem] AS it
    ON ri.[Item No] = it.[Item No]
WHERE [Brand Code] NOT IN ('DEL');
