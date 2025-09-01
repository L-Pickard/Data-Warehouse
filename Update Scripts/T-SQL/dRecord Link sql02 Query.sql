SELECT [Link ID]
    ,[Record ID]
    ,[URL1] AS [URL]
    ,[Description]
    ,[Created] AS [Created Timestamp]
    ,[User ID]
    ,CASE 
        WHEN [Company] = 'Org'
            THEN 'Org Ltd'
        WHEN [Company] = 'Org BV'
            THEN 'Org B.V'
        ELSE [Company]
        END AS [Entity]
FROM [Link Record];