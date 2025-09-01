USE [Warehouse]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER PROCEDURE [dbo].[Insert Record Into Update Log] @Timestamp DATETIME2(0) = NULL
	,@Table NVARCHAR(50) = NULL
	,@Action NVARCHAR(200) = NULL
	,@Rows INTEGER = NULL
	,@Status NVARCHAR(10)
	,@Start_Date DATE = NULL
	,@End_Date DATE = NULL
	,@Error_Message NVARCHAR(2000) = NULL
AS
BEGIN
	SET XACT_ABORT ON;
	SET NOCOUNT ON;

	BEGIN TRY
		BEGIN TRANSACTION;

		INSERT INTO [Update Log] (
			 [Timestamp]
			,[Table]
			,[Action]
			,[Rows]
			,[Status]
			,[Start Date]
			,[End Date]
			,[Error Message]
			)
		VALUES (
			 @Timestamp
			,@Table
			,@Action
			,@Rows
			,@Status
			,@Start_Date
			,@End_Date
			,@Error_Message
			)

		COMMIT TRANSACTION;
	END TRY

	BEGIN CATCH
		DECLARE @ErrMsg NVARCHAR(2000)

		SELECT @ErrMsg = ERROR_MESSAGE()

		IF (XACT_STATE()) = - 1
		BEGIN
			ROLLBACK TRANSACTION;
		END

		BEGIN TRY
			BEGIN TRANSACTION;

			INSERT INTO [Update Log] (
				[Timestamp]
				,[Table]
				,[Action]
				,[Rows]
				,[Status]
				,[Start Date]
				,[End Date]
				,[Error Message]
				)
			VALUES (
				SYSDATETIME()
				,@Table
				,@Action
				,NULL
				,'Failure'
				,NULL
				,NULL
				,@ErrMsg
				)

			COMMIT TRANSACTION;
		END TRY

		BEGIN CATCH
			ROLLBACK TRANSACTION;
		END CATCH
	END CATCH
END
GO
