USE [Warehouse]

GO

SET ANSI_NULLS ON

GO

SET QUOTED_IDENTIFIER ON

GO

CREATE
	OR

ALTER PROCEDURE [dbo].[Update fRedwood]
AS
BEGIN TRY
	BEGIN TRANSACTION;

	DECLARE @Timestamp DATETIME2(3)
		,@Level NVARCHAR(10)
		,@File_Name NVARCHAR(270)
		,@Table NVARCHAR(50)
		,@Action NVARCHAR(500)
		,@Start_Date DATE
		,@End_Date DATE
		,@Message NVARCHAR(MAX)
		,@Row_Count INTEGER

	SET @File_Name = 'Update fRedwood.sql'

	SET @Table = 'fRedwood'

	SET @Action = 'Update fRedwood table from new csv data file.'

	DROP TABLE

	IF EXISTS [fRedwood]
		CREATE TABLE [fRedwood] (
			[Item No] NVARCHAR(30) NOT NULL
			,[Barcode] NVARCHAR(20) NULL
			,[Description] NVARCHAR(100) NULL
			,[Qty Free] INTEGER NOT NULL
			,[Qty Bonded] INTEGER NOT NULL
			,[Outstanding on S/O] INTEGER NOT NULL
			,[Qty Total Available for Orders] INTEGER NOT NULL
			,[Qty Allocated on S/O] INTEGER NOT NULL
			,[Qty Quarantine] INTEGER NOT NULL
			,[Qty Total in Warehouse] INTEGER NOT NULL
			,[Outstanding on P/O in Progress] INTEGER NOT NULL
			,[Outstanding on P/O in Transit] INTEGER NOT NULL
			,[Total Qty On P/O] INTEGER NOT NULL
			,[Qty Projected] INTEGER NOT NULL
			,[Qty Damaged] INTEGER NOT NULL
			,[Qty to be Investigated] INTEGER NOT NULL
			,[Quantity Quality Control] INTEGER NOT NULL
			,[Quantity Rework] INTEGER NOT NULL
			)

	DROP INDEX

	IF EXISTS IX_fRedwood_ItemNo
		ON [dbo].[fRedwood];
		CREATE NONCLUSTERED INDEX IX_fRedwood_ItemNo ON [dbo].[fRedwood] ([Item No]) INCLUDE (
			[Barcode]
			,[Description]
			,[Qty Free]
			,[Qty Total Available for Orders]
			,[Qty Total in Warehouse]
			,[Outstanding on S/O]
			,[Total Qty On P/O]
			);

	DROP INDEX

	IF EXISTS IX_fRedwood_Barcode
		ON [dbo].[fRedwood];
		CREATE NONCLUSTERED INDEX IX_fRedwood_Barcode ON [dbo].[fRedwood] ([Barcode]) INCLUDE (
			[Item No]
			,[Description]
			,[Qty Free]
			,[Qty Total Available for Orders]
			,[Qty Total in Warehouse]
			,[Outstanding on S/O]
			,[Total Qty On P/O]
			);

	DROP INDEX

	IF EXISTS IX_fRedwood_Description
		ON [dbo].[fRedwood];
		CREATE NONCLUSTERED INDEX IX_fRedwood_Description ON [dbo].[fRedwood] ([Description]) INCLUDE (
			[Item No]
			,[Barcode]
			,[Qty Free]
			,[Qty Total Available for Orders]
			);

	DROP INDEX

	IF EXISTS IX_fRedwood_Available_GT0
		ON [dbo].[fRedwood];
		CREATE NONCLUSTERED INDEX IX_fRedwood_Available_GT0 ON [dbo].[fRedwood] ([Qty Total Available for Orders]) INCLUDE (
			[Item No]
			,[Barcode]
			,[Description]
			,[Qty Free]
			,[Qty Total in Warehouse]
			)
		
		WHERE [Qty Total Available for Orders] > 0;

	DROP INDEX

	IF EXISTS IX_fRedwood_InWarehouse_GT0
		ON [dbo].[fRedwood];
		CREATE NONCLUSTERED INDEX IX_fRedwood_InWarehouse_GT0 ON [dbo].[fRedwood] ([Qty Total in Warehouse]) INCLUDE (
			[Item No]
			,[Barcode]
			,[Description]
			)
		
		WHERE [Qty Total in Warehouse] > 0;

	DROP INDEX

	IF EXISTS IX_fRedwood_SO_Outstanding_GT0
		ON [dbo].[fRedwood];
		CREATE NONCLUSTERED INDEX IX_fRedwood_SO_Outstanding_GT0 ON [dbo].[fRedwood] ([Outstanding on S/O]) INCLUDE (
			 [Item No]
			,[Barcode]
			,[Description]
			,[Qty Allocated on S/O]
			)
		
		WHERE [Outstanding on S/O] > 0;

	DROP INDEX

	IF EXISTS IX_fRedwood_PO_Total_GT0
		ON [dbo].[fRedwood];
		CREATE NONCLUSTERED INDEX IX_fRedwood_PO_Total_GT0 ON [dbo].[fRedwood] ([Total Qty On P/O]) INCLUDE (
			[Item No]
			,[Barcode]
			,[Description]
			,[Outstanding on P/O in Progress]
			,[Outstanding on P/O in Transit]
			)
		
		WHERE [Total Qty On P/O] > 0;

	BULK INSERT [fRedwood]
	
	FROM '\\WHServer\Users\leo.pickard\Desktop\Finance db\Redwood\Redwood Inventory Export.csv' WITH (
			FIELDTERMINATOR = ';'
			,FIRSTROW = 2
			);

	SELECT @Timestamp = SYSDATETIME()
		,@Level = 'INFO'
		,@Row_Count = (
			SELECT COUNT(*)
			
			FROM [Warehouse].[dbo].[fRedwood]
			)
		,@Message = 'New data has been written to fRedwood table.';

	EXEC [dbo].[Insert Record Into Database Log] @Timestamp = @Timestamp
		,@Level = @Level
		,@File_Name = @File_Name
		,@Table = @Table
		,@Action = @Action
		,@Row_Count = @Row_Count
		,@Start_Date = NULL
		,@End_Date = NULL
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

GO