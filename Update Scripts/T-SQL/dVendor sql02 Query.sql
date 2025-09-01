SELECT [No_] AS [Vendor No]
    ,[Name]
    ,[Address]
    ,[Address 2]
    ,[City]
    ,[County]
    ,[Post Code]
    ,[Country_Region Code] AS [Country Code]
    ,[Contact]
    ,[Phone No_] AS [Phone No]
    ,CASE 
        WHEN [Currency Code] = ''
            THEN 'GBP'
        ELSE [Currency Code]
        END AS [Currency Code]
    ,[Payment Terms Code]
    ,[Purchaser Code]
    ,[Pay-to Vendor No_] AS [Pay to Vendor No]
    ,[VAT Registration No_] AS [VAT Registration No]
    ,[E-Mail]
    ,[Home Page]
    ,[Primary Contact No_] AS [Contact No]
FROM [Vendor]

UNION ALL

SELECT [No_] AS [Vendor No]
    ,[Name]
    ,[Address]
    ,[Address 2]
    ,[City]
    ,[County]
    ,[Post Code]
    ,[Country_Region Code] AS [Country Code]
    ,[Contact]
    ,[Phone No_] AS [Phone No]
    ,CASE 
        WHEN [Currency Code] = ''
            THEN 'EUR'
        ELSE [Currency Code]
        END AS [Currency Code]
    ,[Payment Terms Code]
    ,[Purchaser Code]
    ,[Pay-to Vendor No_] AS [Pay to Vendor No]
    ,[VAT Registration No_] AS [VAT Registration No]
    ,[E-Mail]
    ,[Home Page]
    ,[Primary Contact No_] AS [Contact No]
FROM [EU Vendor]
WHERE [No_] NOT IN (
        SELECT [No_]
        FROM [Vendor]
        )

UNION ALL

SELECT *
FROM (
    VALUES (
        ''
        ,'Blank Vendor'
        ,''
        ,''
        ,''
        ,''
        ,''
        ,''
        ,''
        ,''
        ,''
        ,''
        ,''
        ,''
        ,''
        ,''
        ,''
        ,''
        )
    ) AS v([Vendor No], [Name], [Address], [Address 2], [City], [County], [Post Code], [Country Code], 
        [Contact], [Phone No], [Currency Code], [Payment Terms Code], [Purchaser Code], 
        [Pay to Vendor No], [VAT Registration No], [E-Mail], [Home Page], [Contact No]);