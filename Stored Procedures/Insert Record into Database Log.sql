USE [Warehouse]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE
    OR

ALTER PROCEDURE [dbo].[Insert Record Into Database Log]
     @Timestamp DATETIME2(3) = NULL
    ,@Level NVARCHAR(10) = NULL
    ,@File_Name NVARCHAR(270) = NULL
    ,@Table NVARCHAR(50) = NULL
    ,@Action NVARCHAR(500) = NULL
    ,@Row_Count INTEGER = NULL
    ,@Start_Date DATE = NULL
    ,@End_Date DATE = NULL
    ,@Message NVARCHAR(MAX) = NULL
AS
BEGIN
    SET XACT_ABORT ON;
    SET NOCOUNT ON;
    
    SET @Timestamp = ISNULL(@Timestamp, SYSDATETIME());
    SET @Level = ISNULL(@Level, 'INFO');
    SET @File_Name = ISNULL(@File_Name, 'N/A');
    SET @Table = ISNULL(@Table, 'N/A');

    INSERT INTO [Database Log] (
         [Timestamp]
        ,[Level]
        ,[File Name]
        ,[Table]
        ,[Action]
        ,[Row Count]
        ,[Start Date]
        ,[End Date]
        ,[Message]
        )
    VALUES (
         @Timestamp
        ,@Level
        ,@File_Name
        ,@Table
        ,@Action
        ,@Row_Count
        ,@Start_Date
        ,@End_Date
        ,@Message
        );
END
GO