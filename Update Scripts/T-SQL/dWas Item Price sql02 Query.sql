WITH [Item Codes]
AS (
    SELECT DISTINCT [No_]
    FROM (
        SELECT il.[No_]
        FROM [Line Invoice Sales] AS il
        LEFT JOIN [Header Invoice Sales] AS ih
            ON il.[Document No_] = ih.[No_]
        WHERE il.[Sell-to Customer No_] NOT IN (
                  'CU110025' -- Org BV - NPD Samples EUR
                , 'CU110036' -- Org LLC (Management Recharge)
                , 'CU110040' -- Org BV (Management Recharge)
                , 'CU110083' -- Org BV - NPD Samples USD
                , 'CU103500' -- Org Limited
                , 'CU109221' -- Org EU B.V.Replen
                , 'CU109441' -- Org EU BV BTB
                , 'CU109444' -- Org EU BV Replen DONT USE
                , 'CU109525' -- Org EU Riga B2B
                , 'CU110077' -- Org LLC
                , 'CU110744' -- Org EU B.V. ..  Redwood Replen
                )
            AND il.[Sell-to Customer No_] NOT IN (
                SELECT [No_]
                FROM [Shiner$Customer]
                WHERE [Name] LIKE '%D2C%'
                
                UNION
                
                SELECT [No_]
                FROM [Shiner BV$Customer]
                WHERE [Name] LIKE '%D2C%'
                )
            AND ih.[Posting Date] >= '2022-05-01'
            AND il.Type = 2
        
        UNION ALL
        
        SELECT il.[No_]
        FROM [EU Line Invoice Sales] AS il
        LEFT JOIN [EU Header Invoice Sales] AS ih
            ON il.[Document No_] = ih.[No_]
        WHERE il.[Sell-to Customer No_] NOT IN (
                  'CU110025' -- Org BV - NPD Samples EUR
                , 'CU109506' -- NPD Samples EU
                , 'CU103500' -- Org Limited
                , 'CU109221' -- Org EU B.V.Replen
                , 'CU109441' -- Org EU BV BTB
                , 'CU109444' -- Org EU BV Replen DONT USE
                , 'CU109525' -- Org EU Riga B2B
                , 'CU110077' -- Org LLC
                )
            AND il.[Sell-to Customer No_] NOT IN (
                SELECT [No_]
                FROM [Customer]
                WHERE [Name] LIKE '%D2C%'
                
                UNION
                
                SELECT [No_]
                FROM [EU Customer]
                WHERE [Name] LIKE '%D2C%'
                )
            AND ih.[Posting Date] >= '2022-05-01'
            AND il.Type = 2
        ) AS [SKU Data]
    )
    ,[Items List]
AS (
    SELECT ic.[No_] AS [Item No]
        ,dt.[First Sold Date]
    FROM [Item Codes] AS ic
    LEFT JOIN (
        (
            SELECT [No_]
                ,MAX([Posting Date]) AS [First Sold Date]
            FROM (
                SELECT il.[No_]
                    ,MIN(ih.[Posting Date]) AS [Posting Date]
                FROM [Line Invoice Sales] AS il
                LEFT JOIN [Header Invoice Sales] AS ih
                    ON il.[Document No_] = ih.[No_]
                WHERE il.[Sell-to Customer No_] NOT IN (
                          'CU110025' -- Org BV - NPD Samples EUR
                        , 'CU110036' -- Org LLC (Management Recharge)
                        , 'CU110040' -- Org BV (Management Recharge)
                        , 'CU110083' -- Org BV - NPD Samples USD
                        , 'CU103500' -- Org Limited
                        , 'CU109221' -- Org EU B.V.Replen
                        , 'CU109441' -- Org EU BV BTB
                        , 'CU109444' -- Org EU BV Replen DONT USE
                        , 'CU109525' -- Org EU Riga B2B
                        , 'CU110077' -- Org LLC
                        , 'CU110744' -- Org EU B.V. ..  Redwood Replen
                        )
                    AND il.[Sell-to Customer No_] NOT IN (
                        SELECT [No_]
                        FROM [Customer]
                        WHERE [Name] LIKE '%D2C%'
                        
                        UNION
                        
                        SELECT [No_]
                        FROM [EU Customer]
                        WHERE [Name] LIKE '%D2C%'
                        )
                    AND il.[Type] = 2
                GROUP BY il.[No_]
                
                UNION ALL
                
                SELECT il.[No_]
                    ,MIN(ih.[Posting Date]) AS [Posting Date]
                FROM [EU Line Invoice Sales] AS il
                LEFT JOIN [EU Header Invoice Sales] AS ih
                    ON il.[Document No_] = ih.[No_]
                WHERE il.[Sell-to Customer No_] NOT IN (
                          'CU110025' -- Org BV - NPD Samples EUR
                        , 'CU109506' -- NPD Samples EU
                        , 'CU103500' -- Org Limited
                        , 'CU109221' -- Org EU B.V.Replen
                        , 'CU109441' -- Org EU BV BTB
                        , 'CU109444' -- Org EU BV Replen DONT USE
                        , 'CU109525' -- Org EU Riga B2B
                        , 'CU110077' -- Org LLC
                        )
                    AND il.[Sell-to Customer No_] NOT IN (
                        SELECT [No_]
                        FROM [Customer]
                        WHERE [Name] LIKE '%D2C%'
                        
                        UNION
                        
                        SELECT [No_]
                        FROM [EU Customer]
                        WHERE [Name] LIKE '%D2C%'
                        )
                    AND il.[Type] = 2
                GROUP BY il.[No_]
                ) AS [Dates]
            GROUP BY [No_]
            )
        ) AS dt
        ON ic.[No_] = dt.[No_]
    )
SELECT ip.[Item No]
    ,CAST(ip.[First Sold Date] AS DATE) AS [First Sold Date]
    ,CAST(DATEADD(DAY, 30, ip.[First Sold Date]) AS DATE) AS [Period End Date]
    ,'GBP' AS [Currency]
    ,(
        SELECT TOP 1 [Unit Price]
        FROM (
            SELECT il.[Unit Price]
            FROM [Line Invoice Sales] AS il
            LEFT JOIN [Header Invoice Sales] AS ih
                ON il.[Document No_] = ih.[No_]
            WHERE il.[Sell-to Customer No_] NOT IN (
                     'CU110025' -- Org BV - NPD Samples EUR
                    , 'CU110036' -- Org LLC (Management Recharge)
                    , 'CU110040' -- Org BV (Management Recharge)
                    , 'CU110083' -- Org BV - NPD Samples USD
                    , 'CU103500' -- Org Limited
                    , 'CU109221' -- Org EU B.V.Replen
                    , 'CU109441' -- Org EU BV BTB
                    , 'CU109444' -- Org EU BV Replen DONT USE
                    , 'CU109525' -- Org EU Riga B2B
                    , 'CU110077' -- Org LLC
                    , 'CU110744' -- Org EU B.V. ..  Redwood Replen
                    )
                AND il.[Sell-to Customer No_] NOT IN (
                    SELECT [No_]
                    FROM [Customer]
                    WHERE [Name] LIKE '%D2C%'
                    
                    UNION
                    
                    SELECT [No_]
                    FROM [EU Customer]
                    WHERE [Name] LIKE '%D2C%'
                    )
                AND ih.[Currency Code] = ''
                AND il.[No_] = ip.[Item No]
                AND ih.[Posting Date] BETWEEN ip.[First Sold Date]
                    AND DATEADD(DAY, 30, ip.[First Sold Date])
            
            UNION ALL
            
            SELECT il.[Unit Price]
            FROM [EU Line Invoice Sales] AS il
            LEFT JOIN [EU Header Invoice Sales] AS ih
                ON il.[Document No_] = ih.[No_]
            WHERE il.[Sell-to Customer No_] NOT IN (
                      'CU110025' -- Org BV - NPD Samples EUR
                    , 'CU109506' -- NPD Samples EU
                    , 'CU103500' -- Org Limited
                    , 'CU109221' -- Org EU B.V.Replen
                    , 'CU109441' -- Org EU BV BTB
                    , 'CU109444' -- Org EU BV Replen DONT USE
                    , 'CU109525' -- Org EU Riga B2B
                    , 'CU110077' -- Org LLC
                    )
                AND il.[Sell-to Customer No_] NOT IN (
                    SELECT [No_]
                    FROM [Customer]
                    WHERE [Name] LIKE '%D2C%'
                    
                    UNION
                    
                    SELECT [No_]
                    FROM [EU Customer]
                    WHERE [Name] LIKE '%D2C%'
                    )
                AND ih.[Currency Code] = 'GBP'
                AND il.[No_] = ip.[Item No]
                AND ih.[Posting Date] BETWEEN ip.[First Sold Date]
                    AND DATEADD(DAY, 30, ip.[First Sold Date])
            ) AS [Prices]
        GROUP BY [Unit Price]
        ORDER BY COUNT([Unit Price]) DESC
        ) AS [Was Trade Price]
FROM [Items List] AS ip

UNION ALL

SELECT ip.[Item No]
    ,CAST(ip.[First Sold Date] AS DATE) AS [First Sold Date]
    ,CAST(DATEADD(DAY, 30, ip.[First Sold Date]) AS DATE) AS [Period End Date]
    ,'EUR' AS [Currency]
    ,(
        SELECT TOP 1 [Unit Price]
        FROM (
            SELECT il.[Unit Price]
            FROM [Line Invoice Sales] AS il
            LEFT JOIN [Header Invoice Sales] AS ih
                ON il.[Document No_] = ih.[No_]
            WHERE il.[Sell-to Customer No_] NOT IN (
                      'CU110025' -- Org BV - NPD Samples EUR
                    , 'CU110036' -- Org LLC (Management Recharge)
                    , 'CU110040' -- Org BV (Management Recharge)
                    , 'CU110083' -- Org BV - NPD Samples USD
                    , 'CU103500' -- Org Limited
                    , 'CU109221' -- Org EU B.V.Replen
                    , 'CU109441' -- Org EU BV BTB
                    , 'CU109444' -- Org EU BV Replen DONT USE
                    , 'CU109525' -- Org EU Riga B2B
                    , 'CU110077' -- Org LLC
                    , 'CU110744' -- Org EU B.V. ..  Redwood Replen
                    )
                AND il.[Sell-to Customer No_] NOT IN (
                    SELECT [No_]
                    FROM [Customer]
                    WHERE [Name] LIKE '%D2C%'
                    
                    UNION
                    
                    SELECT [No_]
                    FROM [EU Customer]
                    WHERE [Name] LIKE '%D2C%'
                    )
                AND ih.[Currency Code] = 'EUR'
                AND il.[No_] = ip.[Item No]
                AND ih.[Posting Date] BETWEEN ip.[First Sold Date]
                    AND DATEADD(DAY, 30, ip.[First Sold Date])
            
            UNION ALL
            
            SELECT il.[Unit Price]
            FROM [EU Line Invoice Sales] AS il
            LEFT JOIN [EU Header Invoice Sales] AS ih
                ON il.[Document No_] = ih.[No_]
            WHERE il.[Sell-to Customer No_] NOT IN (
                      'CU110025' -- Org BV - NPD Samples EUR
                    , 'CU109506' -- NPD Samples EU
                    , 'CU103500' -- Org Limited
                    , 'CU109221' -- Org EU B.V.Replen
                    , 'CU109441' -- Org EU BV BTB
                    , 'CU109444' -- Org EU BV Replen DONT USE
                    , 'CU109525' -- Org EU Riga B2B
                    , 'CU110077' -- Org LLC
                    )
                AND il.[Sell-to Customer No_] NOT IN (
                    SELECT [No_]
                    FROM [Customer]
                    WHERE [Name] LIKE '%D2C%'
                    
                    UNION
                    
                    SELECT [No_]
                    FROM [EU Customer]
                    WHERE [Name] LIKE '%D2C%'
                    )
                AND ih.[Currency Code] = ''
                AND il.[No_] = ip.[Item No]
                AND ih.[Posting Date] BETWEEN ip.[First Sold Date]
                    AND DATEADD(DAY, 30, ip.[First Sold Date])
            ) AS [Prices]
        GROUP BY [Unit Price]
        ORDER BY COUNT([Unit Price]) DESC
        ) AS [Was Trade Price]
FROM [Items List] AS ip;