SELECT [Code] AS [Country Code]
    ,[Name] AS [Country Name]
    ,[Commercial Inv Reqd] AS [CI Required]
    ,CASE WHEN LEN([Shipping Time]) = 0
		THEN NULL
		ELSE CAST(LEFT([Shipping Time], LEN([Shipping Time]) - 1) AS INTEGER) END AS [Shp Time Days]
    ,[D2C Customer]
    ,[Arbor Customer]
    ,[Feiyue Customer]
FROM [Region Country]

UNION ALL

SELECT ''
    ,'Blank'
    ,0
    ,0
    ,''
    ,''
    ,'';