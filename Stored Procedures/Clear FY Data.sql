USE [Warehouse]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE
    OR

ALTER PROCEDURE [dbo].[Clear FY Data]
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
        ,@Row_Count INTEGER;

    SET @File_Name = 'Clear FY Data.sql'
    SET @Action = 'Clear FY Data for full update.'
    SET @Table = 'fSales'
    SET @Row_Count = (
            SELECT COUNT(*)
            FROM [fSales]
            WHERE [Posting Date] >= '2023-05-01'
            )
    SET @Start_Date = (
            SELECT MIN([Posting Date])
            FROM [fSales]
            WHERE [Posting Date] >= '2023-05-01'
            )
    SET @End_Date = (
            SELECT MAX([Posting Date])
            FROM [fSales]
            WHERE [Posting Date] >= '2023-05-01'
            )

    BEGIN TRY
        BEGIN TRANSACTION;

        DELETE
        FROM [fSales]
        WHERE [Posting Date] >= '2023-05-01';

        UPDATE [Increment Date]
        SET [Collect Date fSales] = '2023-04-30';

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
                ,@Message = CAST((
                        SELECT CONCAT (
                                ERROR_NUMBER()
                                ,' - '
                                ,ERROR_MESSAGE()
                                )
                        ) AS NVARCHAR(MAX))

            EXEC [dbo].[Insert Record Into Database Log]
				 @Timestamp = @Timestamp
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

    -- fGL Entry Actions
    SET @Table = 'fGL Entry'
    SET @Row_Count = (
            SELECT COUNT(*)
            FROM [fGL Entry]
            WHERE [Posting Date] >= '2023-05-01'
            )
    SET @Start_Date = (
            SELECT MIN([Posting Date])
            FROM [fGL Entry]
            WHERE [Posting Date] >= '2023-05-01'
            )
    SET @End_Date = (
            SELECT MAX([Posting Date])
            FROM [fGL Entry]
            WHERE [Posting Date] >= '2023-05-01'
            )

    BEGIN TRY
        BEGIN TRANSACTION;

        DELETE
        FROM [fGL Entry]
        WHERE [Posting Date] >= '2023-05-01';

        UPDATE [Increment Date]
        SET [Collect Date fGL Entry] = '2023-04-30';

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
                ,@Message = CAST((
                        SELECT CONCAT (
                                ERROR_NUMBER()
                                ,' - '
                                ,ERROR_MESSAGE()
                                )
                        ) AS NVARCHAR(MAX))

            EXEC [dbo].[Insert Record Into Database Log] 
				 @Timestamp = @Timestamp
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