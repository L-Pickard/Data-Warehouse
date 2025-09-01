SELECT it.[Item No]
	,REPLACE(REPLACE(REPLACE(rl.[Description], CHAR(13), ''), CHAR(10), ''), ' ', '') AS [File Name]
	,rl.[URL] AS [Img URL]

FROM [dRecord Link] AS rl

LEFT JOIN [dItem] AS it
	ON rl.[Record ID] = it.[Record ID]

WHERE (
		it.[Ltd Blocked] = 0
		OR it.[B.V Blocked] = 0
		OR it.[B.V Blocked] = 0
		)
	AND REPLACE(REPLACE(REPLACE(rl.[Description], CHAR(13), ''), CHAR(10), ''), ' ', '') NOT IN (
		SELECT [File Name]
		
		FROM [dImage]
		)
	AND rl.[Entity] = 'Org Ltd'
	AND rl.[Record ID] <> 0x00000000
	AND LEN(rl.[URL]) > 5
	AND (
		rl.[Description] LIKE '%.jpeg%'
		OR rl.[Description] LIKE '%.jpg%'
		);