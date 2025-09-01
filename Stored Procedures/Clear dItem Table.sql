USE [Warehouse]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER PROCEDURE [dbo].[Clear dItem Table]
AS
BEGIN
	SET XACT_ABORT ON;
	SET NOCOUNT ON;

	BEGIN TRY
		BEGIN TRANSACTION;

        DECLARE @Row_Count INTEGER
        SET @Row_Count = (
                    SELECT COUNT(*)
                    FROM [Warehouse].[dbo].[dItem]
                    );

        ALTER TABLE [Warehouse].[dbo].[fSales] NOCHECK CONSTRAINT ALL;
		ALTER TABLE [Warehouse].[dbo].[fOrderbook] NOCHECK CONSTRAINT ALL;
		ALTER TABLE [Warehouse].[dbo].[dInventory] NOCHECK CONSTRAINT ALL;
		ALTER TABLE [Warehouse].[dbo].[dImage] NOCHECK CONSTRAINT ALL;
		ALTER TABLE [Warehouse].[dbo].[fPurchases] NOCHECK CONSTRAINT ALL;
		ALTER TABLE [Warehouse].[dbo].[fShipped Qty] NOCHECK CONSTRAINT ALL;
        ALTER TABLE [Warehouse].[dbo].[fShipped Qty NAV OG] NOCHECK CONSTRAINT ALL;
		ALTER TABLE [Warehouse].[dbo].[fLedger] NOCHECK CONSTRAINT ALL;
        ALTER TABLE [Warehouse].[dbo].[dWas Item Price] NOCHECK CONSTRAINT ALL;
        ALTER TABLE [Warehouse].[dbo].[dThumbnail] NOCHECK CONSTRAINT ALL;
        ALTER TABLE [Warehouse].[dbo].[dThumbnail Process] NOCHECK CONSTRAINT ALL;

        DELETE
        FROM [Warehouse].[dbo].[dItem];

        ALTER TABLE [Warehouse].[dbo].[fSales] CHECK CONSTRAINT ALL;
		ALTER TABLE [Warehouse].[dbo].[fOrderbook] CHECK CONSTRAINT ALL;
		ALTER TABLE [Warehouse].[dbo].[dInventory] CHECK CONSTRAINT ALL;
		ALTER TABLE [Warehouse].[dbo].[dImage] CHECK CONSTRAINT ALL;
		ALTER TABLE [Warehouse].[dbo].[fPurchases] CHECK CONSTRAINT ALL;
		ALTER TABLE [Warehouse].[dbo].[fShipped Qty] CHECK CONSTRAINT ALL;
        ALTER TABLE [Warehouse].[dbo].[fShipped Qty NAV OG] CHECK CONSTRAINT ALL;
		ALTER TABLE [Warehouse].[dbo].[fLedger] CHECK CONSTRAINT ALL;
        ALTER TABLE [Warehouse].[dbo].[dWas Item Price] CHECK CONSTRAINT ALL;
        ALTER TABLE [Warehouse].[dbo].[dThumbnail] CHECK CONSTRAINT ALL;
        ALTER TABLE [Warehouse].[dbo].[dThumbnail Process] CHECK CONSTRAINT ALL;

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
                ,@File_Name = 'Clear dItem Table.sql'
                ,@Table = 'dCountry'
                ,@Action = 'delete all data from dItem table.'
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