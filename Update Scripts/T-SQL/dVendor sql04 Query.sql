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
            THEN 'USD'
        ELSE [Currency Code]
        END AS [Currency Code]
    ,[Payment Terms Code]
    ,[Purchaser Code]
    ,[Pay-to Vendor No_] AS [Pay to Vendor No]
    ,[VAT Registration No_] AS [VAT Registration No]
    ,[E-Mail]
    ,[Home Page]
    ,[Primary Contact No_] AS [Contact No]
FROM [US Vendor];
