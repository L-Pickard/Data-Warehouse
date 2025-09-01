SELECT MAX([Collect Date fGL Entry]) AS 'Collect Date fGL Entry'
FROM [Increment Date]
WHERE [Entity] = 'Org Ltd';

SELECT MAX([Collect Date fGL Entry]) AS 'Collect Date fGL Entry'
FROM [Increment Date]
WHERE [Entity] = 'Org B.V';

SELECT MAX([Collect Date fGL Entry]) AS 'Collect Date fGL Entry'
FROM [Increment Date]
WHERE [Entity] = 'Org LLC';