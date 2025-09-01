USE [Warehouse]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER
    

 PROCEDURE [dbo].[Rebuild db Indexes] @FragmentationThreshold FLOAT = 30.0 

AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @DatabaseName NVARCHAR(128) = 'Finance'
    DECLARE @TableName NVARCHAR(128)
    DECLARE @IndexName NVARCHAR(128)
    DECLARE @SchemaName NVARCHAR(128)
    DECLARE @SQL NVARCHAR(MAX)

    CREATE TABLE #FragmentedIndexes (
        SchemaName NVARCHAR(128)
        ,TableName NVARCHAR(128)
        ,IndexName NVARCHAR(128)
        ,AvgFragmentationInPercent FLOAT
        )

    INSERT INTO #FragmentedIndexes
    SELECT s.name AS SchemaName
        ,o.name AS TableName
        ,i.name AS IndexName
        ,ps.avg_fragmentation_in_percent
    FROM sys.dm_db_index_physical_stats(DB_ID(@DatabaseName), NULL, NULL, NULL, 'LIMITED') ps
    JOIN sys.indexes i
        ON ps.object_id = i.object_id
            AND ps.index_id = i.index_id
    JOIN sys.objects o
        ON ps.object_id = o.object_id
    JOIN sys.schemas s
        ON o.schema_id = s.schema_id
    WHERE ps.avg_fragmentation_in_percent >= @FragmentationThreshold
        AND ps.index_id > 0 -- Ignore heap tables (index_id = 0)

    DECLARE IndexCursor CURSOR
    FOR
    SELECT SchemaName
        ,TableName
        ,IndexName
    FROM #FragmentedIndexes

    OPEN IndexCursor

    FETCH NEXT
    FROM IndexCursor
    INTO @SchemaName
        ,@TableName
        ,@IndexName

    WHILE @@FETCH_STATUS = 0
    BEGIN
        SET @SQL = N'ALTER INDEX ' + QUOTENAME(@IndexName) + ' ON ' + QUOTENAME(@SchemaName) + '.' + 
            QUOTENAME(@TableName) + ' REBUILD;'

        EXEC sp_executesql @SQL

        PRINT 'Rebuilding index: ' + @SchemaName + '.' + @TableName + '.' + @IndexName

        FETCH NEXT
        FROM IndexCursor
        INTO @SchemaName
            ,@TableName
            ,@IndexName
    END

    CLOSE IndexCursor

    DEALLOCATE IndexCursor

    DROP TABLE #FragmentedIndexes

    SET NOCOUNT OFF;
END
GO
