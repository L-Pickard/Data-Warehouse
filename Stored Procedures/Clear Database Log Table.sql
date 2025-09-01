USE [Warehouse]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE
    OR

ALTER PROCEDURE [dbo].[Clear Database Log Table]
AS
BEGIN
    SET XACT_ABORT ON;
    SET NOCOUNT ON;

    DECLARE @Timestamp DATETIME2(3)
        ,@Level NVARCHAR(10)
        ,@File_Name NVARCHAR(270)
        ,@Table NVARCHAR(50)
        ,@Action NVARCHAR(500)
        ,@Row_Count INTEGER
        ,@Start_Date DATE
        ,@End_Date DATE
        ,@Message NVARCHAR(MAX);

    SET @Row_Count = (
            SELECT COUNT(*)
            FROM [Warehouse].[dbo].[Database Log]
            WHERE [Timestamp] < DATEADD(DAY, - 21, GETDATE())
            );
    SET @Start_Date = (
            SELECT CAST(MIN([Timestamp]) AS DATE)
            FROM [Warehouse].[dbo].[Database Log]
            WHERE [Timestamp] < DATEADD(DAY, - 21, GETDATE())
            );
    SET @End_Date = (
            SELECT CAST(MAX([Timestamp]) AS DATE)
            FROM [Warehouse].[dbo].[Database Log]
            WHERE [Timestamp] < DATEADD(DAY, - 21, GETDATE())
            );

    SET @File_Name = 'Clear Database Log Table.sql';
    SET @Table = 'Database Log';
    SET @Action = 'Delete all records older than 21 days.';

    BEGIN TRY
        BEGIN TRANSACTION;

        DELETE
        FROM [Warehouse].[dbo].[Database Log]
        WHERE [Timestamp] < DATEADD(DAY, - 21, GETDATE());

        SET @Timestamp = SYSDATETIME();
        SET @Level = 'INFO';
        SET @Message = 'Old records have been successfully deleted from the database log table.';

        EXEC [dbo].[Insert Record Into Database Log] @Timestamp = @Timestamp
            ,@Level = @Level
            ,@File_Name = @File_Name
            ,@Table = @Table
            ,@Action = @Action
            ,@Row_Count = @Row_Count
            ,@Start_Date = @Start_Date
            ,@End_Date = @End_Date
            ,@Message = @Message;

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
            SET @Timestamp = SYSDATETIME();
            SET @Level = 'ERROR';
            SET @Message = CAST((
                        SELECT CONCAT (
                                ERROR_NUMBER()
                                ,' - '
                                ,ERROR_MESSAGE()
                                )
                        ) AS NVARCHAR(MAX));

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