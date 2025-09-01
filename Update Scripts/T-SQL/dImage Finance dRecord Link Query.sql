SELECT it.[Item No]
    ,rl.[Description] AS [File Name]
    ,rl.[URL] AS [File Path]
FROM [dRecord Link] AS rl
LEFT JOIN [dItem] AS it
    ON rl.[Record ID] = it.[Record ID]
WHERE rl.Entity = 'Org Ltd'
    AND rl.[Record ID] <> 0x00000000
    AND it.[Item No] IS NOT NULL;