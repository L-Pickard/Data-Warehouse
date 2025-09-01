USE [Warehouse]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE
    OR

ALTER PROCEDURE [dbo].[Insert New Rows Into fSales]
AS
BEGIN
    SET XACT_ABORT ON;
    SET NOCOUNT ON;

    DECLARE @Row_Count INTEGER
        ,@Start_Date DATE
        ,@End_Date DATE

    SET @Row_Count = (
            SELECT COUNT(*)
            FROM [fSales Staging]
            )

    SET @Start_Date = (
            SELECT MIN([Posting Date])
            FROM [fSales Staging]
            )

    SET @End_Date = (
            SELECT MAX([Posting Date])
            FROM [fSales Staging]
            )

    BEGIN TRY
        BEGIN TRANSACTION;

        INSERT INTO [fSales] (
             [Date Key]
            ,[Posting Date]
            ,[Customer No]
            ,[Document No]
            ,[Order No]
            ,[Salesperson Code]
            ,[Country Code]
            ,[Entity]
            ,[Royalty %]
            ,[Customer Rebate %]
            ,[Adjusted Margin]
            ,[Sales Type]
            ,[Royalty Include]
            ,[Brand Code]
            ,[Item No]
            ,[Quantity]
            ,[GBP Sales]
            ,[GBP Cost]
            ,[GBP Customer Rebate]
            ,[GBP Royalty]
            ,[GBP Margin]
            ,[GBP Adjusted Margin]
            ,[GBP XR Date]
            ,[GBP XR]
            ,[EUR Sales]
            ,[EUR Cost]
            ,[EUR Customer Rebate]
            ,[EUR Royalty]
            ,[EUR Margin]
            ,[EUR Adjusted Margin]
            ,[EUR XR Date]
            ,[EUR XR]
            ,[USD Sales]
            ,[USD Cost]
            ,[USD Customer Rebate]
            ,[USD Royalty]
            ,[USD Margin]
            ,[USD Adjusted Margin]
            ,[USD XR Date]
            ,[USD XR]
            )
        SELECT st.*
        FROM (
            SELECT [Date Key]
                ,[Posting Date]
                ,[Customer No]
                ,[Document No]
                ,[Order No]
                ,[Salesperson Code]
                ,[Country Code]
                ,[Entity]
                ,[Royalty %]
                ,[Customer Rebate %]
                ,[Adjusted Margin]
                ,[Sales Type]
                ,[Royalty Include]
                ,[Brand Code]
                ,[Item No]
                ,[Quantity]
                ,[GBP Sales]
                ,[GBP Cost]
                ,[GBP Customer Rebate]
                ,[GBP Royalty]
                ,[GBP Margin]
                ,[GBP Adjusted Margin]
                ,[GBP XR Date]
                ,[GBP XR]
                ,[EUR Sales]
                ,[EUR Cost]
                ,[EUR Customer Rebate]
                ,[EUR Royalty]
                ,[EUR Margin]
                ,[EUR Adjusted Margin]
                ,[EUR XR Date]
                ,[EUR XR]
                ,[USD Sales]
                ,[USD Cost]
                ,[USD Customer Rebate]
                ,[USD Royalty]
                ,[USD Margin]
                ,[USD Adjusted Margin]
                ,[USD XR Date]
                ,[USD XR]
            FROM [fSales Staging]
            ) AS st
        LEFT JOIN [fSales] AS fs
            ON st.[Date Key] = fs.[Date Key]
                AND st.[Customer No] = fs.[Customer No]
                AND st.[Document No] = fs.[Document No]
                AND st.[Salesperson Code] = fs.[Salesperson Code]
                AND st.[Item No] = fs.[Item No]
        WHERE fs.[Date Key] IS NULL
            AND fs.[Customer No] IS NULL
            AND fs.[Document No] IS NULL
            AND fs.[Salesperson Code] IS NULL
            AND fs.[Item No] IS NULL;

        UPDATE [Increment Date]
        SET [Collect Date fSales] = (
                CASE 
                    WHEN (
                            SELECT COUNT(*)
                            FROM [fSales Staging]
                            WHERE [Entity] = 'Shiner Ltd'
                            ) > 0
                        THEN (
                                SELECT MAX([Posting Date])
                                FROM [fSales Staging]
                                WHERE [Entity] = 'Shiner Ltd'
                                )
                    ELSE [Collect Date fSales]
                    END
                )
        WHERE [Entity] = 'Shiner Ltd';

        UPDATE [Increment Date]
        SET [Collect Date fSales] = (
                CASE 
                    WHEN (
                            SELECT COUNT(*)
                            FROM [fSales Staging]
                            WHERE [Entity] = 'Shiner B.V'
                            ) > 0
                        THEN (
                                SELECT MAX([Posting Date])
                                FROM [fSales Staging]
                                WHERE [Entity] = 'Shiner B.V'
                                )
                    ELSE [Collect Date fSales]
                    END
                )
        WHERE [Entity] = 'Shiner B.V';

        UPDATE [Increment Date]
        SET [Collect Date fSales] = (
                CASE 
                    WHEN (
                            SELECT COUNT(*)
                            FROM [fSales Staging]
                            WHERE [Entity] = 'Shiner LLC'
                            ) > 0
                        THEN (
                                SELECT MAX([Posting Date])
                                FROM [fSales Staging]
                                WHERE [Entity] = 'Shiner LLC'
                                )
                    ELSE [Collect Date fSales]
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
                ,@File_Name = 'Insert New Rows Into fSales.sql'
                ,@Table = 'fSales'
                ,@Action = 'Insert new data into fSales from staging.'
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