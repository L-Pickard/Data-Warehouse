USE [Finance]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE
    OR

ALTER VIEW [All Error Database Log Updates Today]
AS

SELECT [Id]
      ,CAST([Timestamp] AS DATE) AS [Date]
	  ,CAST([Timestamp] AS TIME) AS [Time]
      ,[Level]
      ,[File Name]
      ,[Table]
      ,[Action]
	  ,[Message]
      ,[Row Count]
      ,[Start Date]
      ,[End Date]
  FROM [Finance].[dbo].[Database Log]
  WHERE CAST([Timestamp] AS DATE) = CAST(GETDATE() AS DATE)
  AND [Level] <> 'INFO'