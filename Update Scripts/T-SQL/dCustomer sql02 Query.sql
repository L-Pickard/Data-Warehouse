WITH Ltd
AS (
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
                THEN 'GBP'
            ELSE cu.[Currency Code]
            END AS 'Currency Code'
        ,ISNULL(ts.[Description], 'Not Assigned') AS [Type of Supply]
        ,cu.[Salesperson Code]
        ,cu.[VAT Registration No_] AS [VAT Reg No]
    FROM [Customer] AS cu
    LEFT JOIN [Supply Type] AS ts
        ON cu.[Type of Supply Code] = ts.Code
    )
SELECT [Customer No]
    ,[Name]
    ,[Address]
    ,[Address 2]
    ,[City]
    ,[County]
    ,[Country Code]
    ,[Post Code]
    ,[Territory Code]
    ,[Contact]
    ,[Phone No]
    ,[Email]
    ,[Home Page]
    ,[Contact No]
    ,[Currency Code]
    ,[Type of Supply]
    ,[Salesperson Code]
    ,[VAT Reg No]
FROM Ltd

UNION ALL

SELECT cu.[No_]
    ,cu.[Name]
    ,cu.[Address]
    ,cu.[Address 2]
    ,cu.[City]
    ,cu.[County]
    ,cu.[Country_Region Code]
    ,cu.[Post Code]
    ,cu.[Territory Code]
    ,cu.[Contact]
    ,cu.[Phone No_]
    ,cu.[E-Mail]
    ,cu.[Home Page]
    ,cu.[Primary Contact No_]
    ,CASE 
        WHEN cu.[Currency Code] = ''
            THEN 'EUR'
        ELSE cu.[Currency Code]
        END AS 'Currency Code'
    ,ISNULL(ts.[Description], 'Not Assigned')
    ,cu.[Salesperson Code]
    ,cu.[VAT Registration No_]
FROM [EU Customer] AS cu
LEFT JOIN [EU Supply Type] AS ts
    ON cu.[Type of Supply Code] = ts.Code
WHERE cu.[No_] NOT IN (
        SELECT [Customer No]
        FROM Ltd
        )

UNION ALL

SELECT *
FROM (
    VALUES (
        'CU104992'
        ,'Unknown Old Customer'
        ,'N/A'
        ,'N/A'
        ,'N/A'
        ,'N/A'
        ,'GB'
        ,'N/A'
        ,'N/A'
        ,'N/A'
        ,'N/A'
        ,'N/A'
        ,'N/A'
        ,'N/A'
        ,'N/A'
        ,'N/A'
        ,'N/A'
        ,'N/A'
        )
        ,(
        'CU102032'
        ,'Unknown Old Customer'
        ,'N/A'
        ,'N/A'
        ,'N/A'
        ,'N/A'
        ,'GB'
        ,'N/A'
        ,'N/A'
        ,'N/A'
        ,'N/A'
        ,'N/A'
        ,'N/A'
        ,'N/A'
        ,'N/A'
        ,'N/A'
        ,'N/A'
        ,'N/A'
        )
        ,(
        'CU104997'
        ,'Unknown Old Customer'
        ,'N/A'
        ,'N/A'
        ,'N/A'
        ,'N/A'
        ,'GB'
        ,'N/A'
        ,'N/A'
        ,'N/A'
        ,'N/A'
        ,'N/A'
        ,'N/A'
        ,'N/A'
        ,'N/A'
        ,'N/A'
        ,'N/A'
        ,'N/A'
        )
        ,(
        'CU108091'
        ,'Unknown Old Customer'
        ,'N/A'
        ,'N/A'
        ,'N/A'
        ,'N/A'
        ,'GB'
        ,'N/A'
        ,'N/A'
        ,'N/A'
        ,'N/A'
        ,'N/A'
        ,'N/A'
        ,'N/A'
        ,'N/A'
        ,'N/A'
        ,'N/A'
        ,'N/A'
        )
        ,(
        'CU103325'
        ,'Unknown Old Customer'
        ,'N/A'
        ,'N/A'
        ,'N/A'
        ,'N/A'
        ,'GB'
        ,'N/A'
        ,'N/A'
        ,'N/A'
        ,'N/A'
        ,'N/A'
        ,'N/A'
        ,'N/A'
        ,'N/A'
        ,'N/A'
        ,'N/A'
        ,'N/A'
        )
        ,(
        'CU104668'
        ,'Unknown Old Customer'
        ,'N/A'
        ,'N/A'
        ,'N/A'
        ,'N/A'
        ,'GB'
        ,'N/A'
        ,'N/A'
        ,'N/A'
        ,'N/A'
        ,'N/A'
        ,'N/A'
        ,'N/A'
        ,'N/A'
        ,'N/A'
        ,'N/A'
        ,'N/A'
        )
        ,(
        ''
        ,'Blank Row'
        ,'N/A'
        ,'N/A'
        ,'N/A'
        ,'N/A'
        ,'GB'
        ,'N/A'
        ,'N/A'
        ,'N/A'
        ,'N/A'
        ,'N/A'
        ,'N/A'
        ,'N/A'
        ,'N/A'
        ,'N/A'
        ,'N/A'
        ,'N/A'
        )
    ) AS Missing_Customers([Customer No], [Name], [Address], [Address 2], [City], 
        [County], [Country Region], [Post Code], [Territory Code], [Contact], 
        [Phone No_], [E-Mail], [Home Page], [Contact No], [Currency Code], 
        [Supply Type], [Salesperson Code], [VAT Registration No_])
WHERE [Customer No] NOT IN (
        SELECT [No_]
        FROM [Customer]
        
        UNION ALL
        
        SELECT [No_]
        FROM [EU Customer]
        );
