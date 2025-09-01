WITH [Item Codes]
AS (
    SELECT DISTINCT il.[No_]
    FROM [US Line Invoice Sales] AS il
    LEFT JOIN 
        [US Header Invoice Sales] AS ih
        ON il.[Document No_] = ih.[No_]
    WHERE il.[Sell-to Customer No_] NOT IN (
              'UC000650' -- Management Recharge Shiner Ltd
            , 'UC000653' -- Management recharge Shiner EU BV
            , 'UC000340' -- Shiner Marketing
            , 'UC000458' -- Shiner Ltd
            )
        AND il.[Sell-to Customer No_] NOT IN (
            SELECT [No_]
            FROM [US Customer]
            WHERE [Name] LIKE '%D2C%'
            )
        AND ih.[Posting Date] >= '2022-05-01'
        AND il.[Type] = 2
    )
    ,[Items List]
AS (
    SELECT ic.[No_] AS [Item No]
        ,dt.[First Sold Date]
    FROM [Item Codes] AS ic
    LEFT JOIN (
        SELECT il.[No_]
            ,MIN(ih.[Posting Date]) AS [First Sold Date]
        FROM [US Line Invoice Sales] AS 
            il
        LEFT JOIN 
            [US Header Invoice Sales] 
            AS ih
            ON il.[Document No_] = ih.[No_]
        WHERE il.[Sell-to Customer No_] NOT IN (
                  'CU110025' -- Shiner BV - NPD Samples EUR
                , 'CU110036' -- Shiner LLC (Management Recharge)
                , 'CU110040' -- Shiner BV (Management Recharge)
                , 'CU110083' -- Shiner BV - NPD Samples USD
                , 'CU103500' -- Shiner Limited
                , 'CU109221' -- Shiner EU B.V.Replen
                , 'CU109441' -- Shiner EU BV BTB
                , 'CU109444' -- Shiner EU BV Replen DONT USE
                , 'CU109525' -- Shiner EU Riga B2B
                , 'CU110077' -- Shiner LLC
                , 'CU110744' -- Shiner EU B.V. ..  Redwood Replen
                )
            AND il.[Sell-to Customer No_] NOT IN (
                SELECT [No_]
                FROM [US Customer]
                WHERE [Name] LIKE '%D2C%'
                )
            AND il.[Type] = 2
        GROUP BY il.[No_]
        ) AS dt
        ON ic.[No_] = dt.[No_]
    )
SELECT ip.[Item No]
    ,CAST(ip.[First Sold Date] AS DATE) AS [First Sold Date]
    ,CAST(DATEADD(DAY, 30, ip.[First Sold Date]) AS DATE) AS [Period End Date]
    ,'USD' AS [Currency]
    ,(
        SELECT TOP 1 il.[Unit Price]
        FROM [US Line Invoice Sales] AS 
            il
        LEFT JOIN 
            [US Header Invoice Sales] 
            AS ih
            ON il.[Document No_] = ih.[No_]
        WHERE il.[Sell-to Customer No_] NOT IN (
                  'UC000650' -- Management Recharge Shiner Ltd
                , 'UC000653' -- Management recharge Shiner EU BV
                , 'UC000340' -- Shiner Marketing
                , 'UC000458' -- Shiner Ltd
                )
            AND il.[Sell-to Customer No_] NOT IN (
                SELECT [No_]
                FROM [US Customer]
                WHERE [Name] LIKE '%D2C%'
                )
            AND ih.[Currency Code] = ''
            AND il.[No_] = ip.[Item No]
            AND ih.[Posting Date] BETWEEN ip.[First Sold Date]
                AND DATEADD(DAY, 30, ip.[First Sold Date])
        GROUP BY il.[Unit Price]
        ORDER BY COUNT(il.[Unit Price]) DESC
        ) AS [Was Trade Price]
FROM [Items List] AS ip;
