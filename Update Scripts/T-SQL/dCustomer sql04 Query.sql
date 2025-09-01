SELECT cu.[No_] AS [Customer No]
    ,cu.[Name]
    ,cu.[Address]
    ,cu.[Address 2]
    ,cu.[City]
    ,cu.[County]
    ,cu.[Country_Region Code] AS [Country Code]
    ,cu.[Post Code]
    ,cu.[Territory Code]
    ,cu.[Contact]
    ,cu.[Phone No_] AS [Phone No]
    ,cu.[E-Mail] AS [Email]
    ,cu.[Home Page]
    ,cu.[Primary Contact No_] AS [Contact No]
    ,CASE 
        WHEN cu.[Currency Code] = ''
            THEN 'USD'
        ELSE cu.[Currency Code]
        END AS 'Currency Code'
    ,'Not Assigned' AS [Type of Supply]
    ,cu.[Salesperson Code]
    ,cu.[VAT Registration No_] AS [VAT Reg No]
FROM [US Customer] AS cu;