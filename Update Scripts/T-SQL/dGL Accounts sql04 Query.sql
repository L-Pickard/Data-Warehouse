SELECT 'Org LLC' AS 'Entity'
    ,[No_] AS 'GL Account No'
    ,[Name] AS 'GL Account Name'
    ,CASE 
        WHEN [Account Type] = 0
            THEN 'Posting'
        WHEN [Account Type] = 1
            THEN 'Heading'
        WHEN [Account Type] = 2
            THEN 'Total'
        WHEN [Account Type] = 3
            THEN 'Begin-Total'
        WHEN [Account Type] = 4
            THEN 'End-Total'
        END AS 'Account Type'
    ,[Blocked]
    ,[Direct Posting]
    ,CASE 
        WHEN [Totaling] <> ''
            THEN CAST(LEFT([Totaling], CHARINDEX('..', [Totaling]) - 1) AS INTEGER)
        ELSE NULL
        END AS 'Start GL No'
    ,CASE 
        WHEN [Totaling] <> ''
            THEN CAST(SUBSTRING([Totaling], CHARINDEX('..', [Totaling]) + 2, LEN(
                            [Totaling]) - CHARINDEX('..', [Totaling])) AS INTEGER)
        ELSE NULL
        END AS 'End GL No'
FROM [US Account GL];