USE [Warehouse]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE
    OR

ALTER PROCEDURE [dbo].[Update fB2B Events]
AS
BEGIN
    SET XACT_ABORT ON;
    SET NOCOUNT ON;

    DECLARE @Timestamp DATETIME2(3)
        ,@Level NVARCHAR(10)
        ,@File_Name NVARCHAR(270)
        ,@Table NVARCHAR(50)
        ,@Action NVARCHAR(500)
        ,@Start_Date DATE
        ,@End_Date DATE
        ,@Message NVARCHAR(MAX)
        ,@Row_Count INTEGER

    BEGIN TRY
        BEGIN TRANSACTION;

        BULK INSERT [dbo].[fB2B Events]
        FROM '\\WHServer\\Users\leo.pickard\Desktop\Misc Bulk Inserts\Preorder Data\events import.csv' 
            WITH (
                 FIELDTERMINATOR = '~'
                ,ROWTERMINATOR = '\n'
                ,FIRSTROW = 2
                );

        ALTER INDEX ALL ON [dbo].[fB2B Events] REBUILD;

        UPDATE STATISTICS [dbo].[fB2B Events];

        --The below code enters a success record into the update log table
        SELECT @Timestamp = SYSDATETIME()
            ,@Level = 'INFO'
            ,@File_Name = 'Update fB2B Events.sql'
            ,@Table = 'fB2B Events'
            ,@Action = 'Insert New Data into fB2b Events'
            ,@Row_Count = (
                SELECT COUNT(*)
                FROM [Warehouse].[dbo].[fB2b Events]
                )
            ,@Start_Date = NULL
            ,@End_Date = NULL
            ,@Message = 'New data has been written to fB2b Events table from owtanet ftp csv.';

        EXEC [dbo].[Insert Record Into Database Log] @Timestamp = @Timestamp
            ,@Level = @Level
            ,@File_Name = @File_Name
            ,@Table = @Table
            ,@Action = @Action
            ,@Row_Count = @Row_Count
            ,@Start_Date = @Start_Date
            ,@End_Date = @End_Date
            ,@Message = @Message

        COMMIT TRANSACTION;
    END TRY

    BEGIN CATCH

        /*
        XACT_STATE() = 1: There is an active transaction that can still be committed or rolled back.
        XACT_STATE() = -1: The transaction is uncommittable and must be rolled back.
        XACT_STATE() = 0: There is no active transaction.
        */

        IF (XACT_STATE()) = - 1
        BEGIN
            SELECT @Timestamp = SYSDATETIME()
                ,@Level = 'ERROR'
                ,@File_Name = 'Update fB2B Events.sql'
                ,@Table = 'fB2B Events'
                ,@Action = 'Insert New Data into fB2b Events'
                ,@Row_Count = NULL
                ,@Start_Date = NULL
                ,@End_Date = NULL
                ,@Message = CAST((
                        SELECT CONCAT (
                                ERROR_NUMBER()
                                ,' - '
                                ,ERROR_MESSAGE()
                                )
                        ) AS NVARCHAR(MAX))

            EXEC [dbo].[Insert Record Into Database Log] @Timestamp = @Timestamp
                ,@Level = @Level
                ,@File_Name = @File_Name
                ,@Table = @Table
                ,@Action = @Action
                ,@Row_Count = @Row_Count
                ,@Start_Date = @Start_Date
                ,@End_Date = @End_Date
                ,@Message = @Message;

            ROLLBACK TRANSACTION;
        END
        ELSE IF (XACT_STATE() = 1)
        BEGIN
            ROLLBACK TRANSACTION;
        END
    END CATCH
END
GO