USE [Warehouse]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE
    OR

ALTER PROCEDURE [dbo].[Insert New Rows Into fGL Entry]
AS
BEGIN
    SET XACT_ABORT ON;
    SET NOCOUNT ON;

    DECLARE @Row_Count INTEGER
        ,@Start_Date DATE
        ,@End_Date DATE

    SET @Row_Count = (
            SELECT COUNT(*)
            FROM [fGL Entry Staging]
            )
    SET @Start_Date = (
            SELECT MIN([Posting Date])
            FROM [fGL Entry Staging]
            )
    SET @End_Date = (
            SELECT MAX([Posting Date])
            FROM [fGL Entry Staging]
            )

    BEGIN TRY
        BEGIN TRANSACTION;

        INSERT INTO [Warehouse].[dbo].[fGL Entry] (
             [Date Key]
            ,[Posting Date]
            ,[Entity]
            ,[Entry No]
            ,[GL Account No]
            ,[Document Type]
            ,[Document No]
            ,[Description]
            ,[User ID]
            ,[Source Code]
            ,[Source Type]
            ,[Source No]
            ,[Balance Account No]
            ,[GBP Amount]
            ,[GBP VAT Amount]
            ,[GBP Debit Amount]
            ,[GBP Credit Amount]
            ,[GBP XR Date]
            ,[GBP XR]
            ,[EUR Amount]
            ,[EUR VAT Amount]
            ,[EUR Debit Amount]
            ,[EUR Credit Amount]
            ,[EUR XR Date]
            ,[EUR XR]
            ,[USD Amount]
            ,[USD VAT Amount]
            ,[USD Debit Amount]
            ,[USD Credit Amount]
            ,[USD XR Date]
            ,[USD XR]
            )
        SELECT st.*
        FROM (
            SELECT [Date Key]
                ,[Posting Date]
                ,[Entity]
                ,[Entry No]
                ,[GL Account No]
                ,[Document Type]
                ,[Document No]
                ,[Description]
                ,[User ID]
                ,[Source Code]
                ,[Source Type]
                ,[Source No]
                ,[Balance Account No]
                ,[GBP Amount]
                ,[GBP VAT Amount]
                ,[GBP Debit Amount]
                ,[GBP Credit Amount]
                ,[GBP XR Date]
                ,[GBP XR]
                ,[EUR Amount]
                ,[EUR VAT Amount]
                ,[EUR Debit Amount]
                ,[EUR Credit Amount]
                ,[EUR XR Date]
                ,[EUR XR]
                ,[USD Amount]
                ,[USD VAT Amount]
                ,[USD Debit Amount]
                ,[USD Credit Amount]
                ,[USD XR Date]
                ,[USD XR]
            FROM [fGL Entry Staging]
            ) AS st
        LEFT JOIN [fGL Entry] AS gl
            ON st.[Entity] = gl.[Entity]
                AND st.[Entry No] = gl.[Entry No]
        WHERE gl.[Entity] IS NULL
            AND gl.[Entry No] IS NULL;

        UPDATE [Increment Date]
        SET [Collect Date fGL Entry] = (
                CASE 
                    WHEN (
                            SELECT COUNT(*)
                            FROM [fGL Entry Staging]
                            WHERE [Entity] = 'Shiner Ltd'
                            ) > 0
                        THEN (
                                SELECT MAX([Posting Date])
                                FROM [fGL Entry Staging]
                                WHERE [Entity] = 'Shiner Ltd'
                                )
                    ELSE [Collect Date fGL Entry]
                    END
                )
        WHERE [Entity] = 'Shiner Ltd';

        UPDATE [Increment Date]
        SET [Collect Date fGL Entry] = (
                CASE 
                    WHEN (
                            SELECT COUNT(*)
                            FROM [fGL Entry Staging]
                            WHERE [Entity] = 'Shiner B.V'
                            ) > 0
                        THEN (
                                SELECT MAX([Posting Date])
                                FROM [fGL Entry Staging]
                                WHERE [Entity] = 'Shiner B.V'
                                )
                    ELSE [Collect Date fGL Entry]
                    END
                )
        WHERE [Entity] = 'Shiner B.V';

        UPDATE [Increment Date]
        SET [Collect Date fGL Entry] = (
                CASE 
                    WHEN (
                            SELECT COUNT(*)
                            FROM [fGL Entry Staging]
                            WHERE [Entity] = 'Shiner LLC'
                            ) > 0
                        THEN (
                                SELECT MAX([Posting Date])
                                FROM [fGL Entry Staging]
                                WHERE [Entity] = 'Shiner LLC'
                                )
                    ELSE [Collect Date fGL Entry]
                    END
                )
        WHERE [Entity] = 'Shiner LLC';

        COMMIT TRANSACTION;
    END TRY

    BEGIN CATCH
        DECLARE @Timestamp DATETIME2(3)
            ,@Level NVARCHAR(10)
            ,@File_Name NVARCHAR(270)
            ,@Table NVARCHAR(50)
            ,@Action NVARCHAR(500)
            ,@Message NVARCHAR(MAX);

        /*
        XACT_STATE() = 1: There is an active transaction that can still be committed or rolled back.
        XACT_STATE() = -1: The transaction is uncommittable and must be rolled back.
        XACT_STATE() = 0: There is no active transaction.
        */
		
        IF (XACT_STATE()) = - 1
        BEGIN
            SELECT @Timestamp = SYSDATETIME()
                ,@Level = 'ERROR'
                ,@File_Name = 'Insert New Rows Into fGL Entry.sql'
                ,@Table = 'fGL Entry'
                ,@Action = 'Insert new data into fGL Entry from staging.'
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