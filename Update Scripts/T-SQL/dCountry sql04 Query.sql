SELECT [Code] AS [Country Code]
      ,[Name] AS [Country Name]
	  ,0 AS [CI Required]
	  ,NULL AS [Shp Time Days]
	  ,'' AS [D2C Customer]
	  ,'' AS [Arbor Customer]
	  ,'' AS [Feiyue Customer]
  FROM [US Region Country]
  WHERE [Code] <> '';