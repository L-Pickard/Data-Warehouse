DECLARE @End_Date AS DATE

SET @End_Date = '2024-10-31'

SELECT @End_Date AS [Inv Date]
    ,fl.[Brand Code]
    ,br.[Brand Name]
    ,fl.[Item No]
    ,it.[Description]
    ,it.[Description 2]
    ,it.[Colours]
    ,it.[Size 1]
    ,it.[Size 1 Unit]
    ,it.[Category Code] AS [Category]
    ,it.[Group Code] AS [Group]
    ,SUM(fl.[Quantity]) AS [Inventory]
FROM [fLedger] AS fl
LEFT JOIN [dItem] AS it
    ON fl.[Item No] = it.[Item No]
LEFT JOIN [dBrand] AS br
    ON fl.[Brand Code] = br.[Brand Code]
WHERE fl.[Posting Date] <= @End_Date
GROUP BY fl.[Brand Code]
    ,br.[Brand Name]
    ,fl.[Item No]
    ,it.[Description]
    ,it.[Description 2]
    ,it.[Colours]
    ,it.[Size 1]
    ,it.[Size 1 Unit]
    ,it.[Category Code]
    ,it.[Group Code]
HAVING SUM(fl.[Quantity]) > 0
ORDER BY [Item No] ASC;