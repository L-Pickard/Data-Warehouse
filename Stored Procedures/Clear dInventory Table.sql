USE [Warehouse]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE
    OR

ALTER PROCEDURE [dbo].[Clear dInventory Table]
AS
BEGIN
    SET XACT_ABORT ON;
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        DECLARE @Row_Count INTEGER

        SET @Row_Count = (
                SELECT COUNT(*)
                FROM [Warehouse].[dbo].[dInventory]
                );

        DELETE
        FROM [Warehouse].[dbo].[dInventory];

        COMMIT TRANSACTION;
    END TRY

    BEGIN CATCH
        DECLARE @Timestamp DATETIME2(3)
            ,@Level NVARCHAR(10)
            ,@File_Name NVARCHAR(270)
            ,@Table NVARCHAR(50)
            ,@Action NVARCHAR(500)
            ,@Start_Date DATE
            ,@End_Date DATE
            ,@Message NVARCHAR(MAX);

        /*
        XACT_STATE() = 1: There is an active transaction that can still be committed or rolled back.
        XACT_STATE() = -1: The transaction is uncommittable and must be rolled back.
        XACT_STATE() = 0: There is no active transaction.
        */
        
        IF (XACT_STATE()) = - 1
        BEGIN
            SELECT @Timestamp = GETDATE()
                ,@Level = 'ERROR'
                ,@File_Name = 'Clear dInventory Table.sql'
                ,@Table = 'dCountry'
                ,@Action = 'delete all data from dInventory table.'
                ,@Row_Count = @Row_Count
                ,@Start_Date = NULL
                ,@End_Date = NULL
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