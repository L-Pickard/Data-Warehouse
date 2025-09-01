SELECT [Code] AS [Salesperson Code]
    ,[Name]
    ,[E-Mail]
FROM [Purchaser Salesperson]

UNION ALL

SELECT [Code] AS [Salesperson Code]
    ,[Name]
    ,[E-Mail]
FROM [EU Purchaser Salesperson]
WHERE [Code] NOT IN (
        SELECT [Code]
        FROM [Purchaser Salesperson]
        )

UNION ALL

SELECT [Salesperson Code]
    ,[Name]
    ,[E-Mail]
FROM (
    VALUES (
        ''
        ,'Blank'
        ,''
        )
        ,(
        'BARTL'
        ,'Bart L'
        ,''
        )
        ,(
        'CORALIEC'
        ,'Coralie C'
        ,''
        )
        ,(
        'FRANCESCAB'
        ,'Francesca B'
        ,''
        )
        ,(
        'JAMESC'
        ,'James C'
        ,''
        )
        ,(
        'N/A'
        ,'Not Available'
        ,''
        )
    ) AS Hardcoded([Salesperson Code], [Name], [E-Mail])
WHERE [Salesperson Code] NOT IN (
        SELECT [Code]
        FROM [Purchaser Salesperson]
        
        UNION ALL
        
        SELECT [Code]
        FROM [EU Purchaser Salesperson]
        );