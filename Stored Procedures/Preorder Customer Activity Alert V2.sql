USE [Warehouse]

GO

SET ANSI_NULLS ON

GO

SET QUOTED_IDENTIFIER ON

GO

CREATE
	OR

ALTER PROCEDURE [dbo].[Preorder Customer Activity Alert V2]
AS
/*===============================================================================================================================================
Project: B2B Preorder New Customer Activity Alert
Language: T-SQL
Author: Leo Pickard
Version: 1.0
Date: 18/07/2024
=================================================================================================================================================
This stored procedure will get called after every update to the preorder table on warehouse db. The preorder data comes from the owtanet ftp
server. Once called, the procedure will send an email to each salesperson where they have customers who have entered new orders, ammended orders
or deleted orders on any b2b preorder. This email will conatin details of those entries per salesperson.
================================================================================================================================================*/
BEGIN
	SET NOCOUNT ON;

	-- The below code creates a temp table for new preorder table totals data.
	DROP INDEX

	IF EXISTS IDX_Preorder_Code
		ON #New_Preorder_Totals;
		DROP INDEX

	IF EXISTS IDX_Customer_No
		ON #New_Preorder_Totals;
		DROP INDEX

	IF EXISTS IDX_Currency
		ON #New_Preorder_Totals;
		DROP INDEX

	IF EXISTS IDX_Preorder_Customer_Currency
		ON #New_Preorder_Totals;
		DROP TABLE

	IF EXISTS #New_Preorder_Totals;
		CREATE TABLE #New_Preorder_Totals (
			[Deadline] DATETIME NOT NULL
			,[ETA] DATE NOT NULL
			,[Timestamp] DATETIME NOT NULL
			,[Preorder Code] NVARCHAR(100) NOT NULL
			,[Customer No] NVARCHAR(12) NOT NULL
			,[Customer Name] NVARCHAR(150) NULL
			,[Salesperson Code] NVARCHAR(30) NULL
			,[E-Mail] NVARCHAR(100)
			,[Entries] INTEGER NOT NULL
			,[Quantity] INTEGER NOT NULL
			,[Currency] NVARCHAR(3) NOT NULL
			,[Value] DECIMAL(16, 2) NOT NULL
			,PRIMARY KEY (
				 [Preorder Code]
				,[Customer No]
				,[Currency]
				)
			)

	-- The below code creates some indexes to improve read performance.
	CREATE NONCLUSTERED INDEX IX_NewPreorder_PreorderCustomerCurrency ON #New_Preorder_Totals (
		[Preorder Code]
		,[Customer No]
		,[Currency]
		) INCLUDE (
		[Deadline]
		,[ETA]
		,[Timestamp]
		,[Customer Name]
		,[Salesperson Code]
		,[E-Mail]
		,[Entries]
		,[Quantity]
		,[Value]
		);

	CREATE NONCLUSTERED INDEX IX_NewPreorder_Email_NonBlank ON #New_Preorder_Totals (
		 [E-Mail]
		,[Salesperson Code]
		)
	
	WHERE [E-Mail] <> '';

	-- The below code inserts the new preorder data into the new totals temp table.
	INSERT INTO #New_Preorder_Totals
	
	SELECT CAST(MIN(pr.[End Timestamp]) AS DATETIME) AS [Deadline]
		,CAST(MAX(pr.[ETA Timestamp]) AS DATE) AS [ETA]
		,CAST(MAX(pr.[Order Timestamp]) AS DATETIME) AS [Timestamp]
		,pr.[Preorder Code]
		,pr.[Customer No]
		,cu.[Name]
		,cu.[Salesperson Code]
		,sp.[E-Mail]
		,COUNT(DISTINCT pr.[Order Timestamp]) AS [Entries]
		,SUM(pr.[Quantity]) AS [Quantity]
		,pr.[Currency]
		,ROUND(SUM(pr.[Value]), 2) AS [Value]
	
	FROM [Warehouse].[dbo].[fPreorder] AS pr
	
	LEFT JOIN [Warehouse].[dbo].[dCustomer] AS cu
		ON pr.[Customer No] = cu.[Customer No]
	
	LEFT JOIN [Warehouse].[dbo].[dSalesperson] AS sp
		ON cu.[Salesperson Code] = sp.[Salesperson Code]
	
	GROUP BY pr.[Preorder Code]
		,pr.[Customer No]
		,cu.[Name]
		,cu.[Salesperson Code]
		,sp.[E-Mail]
		,pr.[Currency]

	-- Below is the code to create another temp table for the data we need to send out as emails. This temp table is global instead of local.
	DROP TABLE

	IF EXISTS ##Send_Email_Totals;
		CREATE TABLE ##Send_Email_Totals (
			[Deadline] DATETIME NOT NULL
			,[ETA] DATE NOT NULL
			,[Timestamp] DATETIME NOT NULL
			,[Preorder Code] NVARCHAR(100) NOT NULL
			,[Customer No] NVARCHAR(12) NOT NULL
			,[Customer Name] NVARCHAR(150) NULL
			,[Salesperson Code] NVARCHAR(30) NULL
			,[E-Mail] NVARCHAR(100) NULL
			,[Category] NVARCHAR(100) NOT NULL
			,[Entries] INTEGER NOT NULL
			,[Quantity] INTEGER NOT NULL
			,[Currency] NVARCHAR(3) NOT NULL
			,[Value] DECIMAL(16, 2) NOT NULL
			,PRIMARY KEY (
				[Preorder Code]
				,[Customer No]
				,[Currency]
				)
			)

	CREATE NONCLUSTERED INDEX IX_Send_BySalesperson_Preorder_Timestamp ON ##Send_Email_Totals (
		[Salesperson Code]
		,[Preorder Code]
		,[Timestamp]
		) INCLUDE (
		[Customer No]
		,[Customer Name]
		,[Category]
		,[Entries]
		,[Quantity]
		,[Currency]
		,[Value]
		,[E-Mail]
		,[Deadline]
		,[ETA]
		);

	CREATE NONCLUSTERED INDEX IX_Send_Email_NonBlank ON ##Send_Email_Totals (
		[E-Mail]
		,[Salesperson Code]
		)
	
	WHERE [E-Mail] <> '';

	-- The below code inserts data into the send email temp table. the rows inserted are only where there is a difference from the last time the script ran.
	-- The select is set up in 3 parts using a union which helps classify wether the order is new, adjusted, or deleted.
	INSERT INTO ##Send_Email_Totals
	
	SELECT nt.[Deadline]
		,nt.[ETA]
		,nt.[Timestamp]
		,nt.[Preorder Code]
		,nt.[Customer No]
		,nt.[Customer Name]
		,nt.[Salesperson Code]
		,nt.[E-Mail]
		,'New Order' AS [Category]
		,nt.[Entries]
		,nt.[Quantity]
		,nt.[Currency]
		,nt.[Value]
	
	FROM #New_Preorder_Totals AS nt
	
	LEFT JOIN [fPreorder Totals] AS pr
		ON nt.[Preorder Code] = pr.[Preorder Code]
			AND nt.[Customer No] = pr.[Customer No]
			AND nt.[Currency] = pr.[Currency]
	
	WHERE pr.[Preorder Code] IS NULL
	
	
	UNION ALL
	
	SELECT nt.[Deadline]
		,nt.[ETA]
		,nt.[Timestamp]
		,nt.[Preorder Code]
		,nt.[Customer No]
		,nt.[Customer Name]
		,nt.[Salesperson Code]
		,nt.[E-Mail]
		,'Ammended Order' AS [Category]
		,nt.[Entries]
		,nt.[Quantity]
		,nt.[Currency]
		,nt.[Value]
	
	FROM #New_Preorder_Totals AS nt
	
	LEFT JOIN [fPreorder Totals] AS pr
		ON nt.[Preorder Code] = pr.[Preorder Code]
			AND nt.[Customer No] = pr.[Customer No]
			AND nt.[Currency] = pr.[Currency]
	
	WHERE nt.[Value] <> pr.[Value]

	--UNION ALL
	--SELECT nt.[Deadline]
	--    ,nt.[ETA]
	--    ,nt.[Timestamp]
	--    ,pr.[Preorder Code]
	--    ,pr.[Customer No]
	--    ,pr.[Customer Name]
	--    ,pr.[Salesperson Code]
	--    ,pr.[E-Mail]
	--    ,'Deleted Order' AS [Category]
	--    ,pr.[Entries]
	--    ,pr.[Quantity]
	--    ,pr.[Currency]
	--    ,pr.[Value]
	--FROM [fPreorder Totals] AS pr
	--LEFT JOIN #New_Preorder_Totals AS nt
	--    ON pr.[Preorder Code] = nt.[Preorder Code]
	--        AND pr.[Customer No] = nt.[Customer No]
	--        AND pr.[Currency] = nt.[Currency]
	--WHERE nt.[Preorder Code] IS NULL;
	-- The below code declares variables needed in the cursor loop and also to execute the send db mail stored procedure.
	DECLARE @SalespersonCode NVARCHAR(30)
		,@Email NVARCHAR(100)
		,@Recipients VARCHAR(102)
		,@XML NVARCHAR(MAX)
		,@Body NVARCHAR(MAX)
		,@ColumnName VARCHAR(255)
		,@Query NVARCHAR(MAX)
		,@EmailDatetime AS NVARCHAR(19)
		,@Filename AS NVARCHAR(250)
		,@FormatDatetime AS NVARCHAR(19)
		,@Subject AS NVARCHAR(78)

	-- The below code sets the value of variables which do not need to chnage on every cursor row loop.
	SET @ColumnName = '[sep=,' + CHAR(13) + CHAR(10) + 'Deadline]'

	SET @EmailDatetime = FORMAT(GETDATE(), 'dd-MM-yyyy HH.mm')

	SET @FormatDatetime = FORMAT(GETDATE(), 'dd/MM/yyyy HH:mm:ss')

	-- The below code sets the cursor data and starts the loop
	DECLARE Email_Cursor CURSOR
	FOR
	SELECT DISTINCT [Salesperson Code]
		,[E-Mail]
	
	FROM ##Send_Email_Totals
	
	WHERE [E-Mail] <> '';

	OPEN Email_Cursor;

	FETCH NEXT
	
	FROM Email_Cursor
	
	INTO @SalespersonCode
		,@Email;

	WHILE @@FETCH_STATUS = 0
	BEGIN
		-- First we need to set some row dependent variables including the html for the email.
		SET @Recipients = (
				SELECT CAST(CONCAT (
							'<'
							,@Email
							,'>'
							) AS VARCHAR(102))
				)

		SET @XML = CAST((
					SELECT [Preorder Code] AS 'td'
						,''
						,[Customer No] AS 'td'
						,''
						,[Customer Name] AS 'td'
						,''
						,[Category] AS 'td'
						,''
						,FORMAT([Timestamp], 'dd/MM/yyyy HH:mm:ss') AS 'td'
						,''
						,[Entries] AS 'td'
						,''
						,[Quantity] AS 'td'
						,''
						,CONCAT (
							CASE [Currency]
								WHEN 'USD'
									THEN '$'
								WHEN 'EUR'
									THEN '€'
								WHEN 'GBP'
									THEN '£'
								ELSE ''
								END
							,' '
							,FORMAT([Value], 'N2')
							) AS 'td'
					
					FROM ##Send_Email_Totals
					
					WHERE [Salesperson Code] = @SalespersonCode
					
					ORDER BY [Preorder Code] ASC
						,[Timestamp] ASC
					
					FOR XML PATH('tr')
						,ELEMENTS
					) AS NVARCHAR(MAX))

		--SET @Query = 
		--'
		-- SELECT FORMAT([Deadline], ''dd/MM/yyyy HH:mm:ss'')  AS  ' + 
		--         @ColumnName + 
		--         '
		--     ,FORMAT([ETA], ''dd/MM/yyyy'') AS [ETA] 
		--     ,FORMAT([Timestamp],''dd/MM/yyyy HH:mm:ss'') AS [Timestamp]
		--     ,[Preorder Code]
		--     ,[Customer No]
		--     ,[Customer Name]
		--     ,[Salesperson Code]
		--     ,[E-Mail]
		--     ,[Category]
		--     ,[Entries]
		--     ,[Quantity]
		--     ,[Currency]
		--     ,[Value]
		-- FROM ##Send_Email_Totals
		-- WHERE [Salesperson Code] = ''' 
		--         + @SalespersonCode + '''';
		SET @body = 
			'<!DOCTYPE html>
<html>
<head>
<style>
h1 {
  font-family: Arial, Helvetica, Times, serif;
  font-size: 16px;
}

p {
  font-family: Arial, Helvetica, Times, serif;
  font-size: 14px;
}

#customers {
  font-family: Arial, Helvetica, sans-serif;
  border-collapse: collapse;
  width: 100%;
}

#customers td, #customers th {
  border: 0.5px solid #000000;
  padding: 5px;
  font-size: 9px;
  text-align: center;
}

#customers tr:nth-child(even) {
  background-color: #f2f2f2;
}

#customers tr:hover {
  background-color: #C6EFCE;
  color: #006100;
}

#customers th {
  padding-top: 5px;
  padding-bottom: 5px;
  text-align: center;
  background-color: #808080;
  color: white;
  font-size: 10px;
  border: 0.5px solid #000000;
}
</style>
</head>
<body>

<h1>Open Preorders Customer Activity Update</h1><br>

<p>The below table shows the new customer preorder activity for the salesperson ' 
			+ @SalespersonCode + ' @ ' + @FormatDatetime + 
			'</p><br>

<table id="customers">
  <tr>
    <th>Preorder Code</th>
    <th>Customer No</th>
    <th>Customer Name</th>
    <th>Status</th>
    <th>Timestamp</th>
    <th>Entries</th>
    <th>Quantity</th>
    <th>Value</th>
  </tr>'

		SET @Body = @Body + @XML + '</table></body></html>'

		SET @Filename = CONCAT (
				@SalespersonCode
				,' Customer Preorder Activity '
				,@EmailDatetime
				,'.csv'
				)

		SET @Subject = CONCAT (
				@SalespersonCode
				,' - Customer Preorder Activity Update - '
				,@FormatDatetime
				)

		-- The below code is for sending emails to each salesperson. If the code fails it will proceed to the next row.
		BEGIN TRY
			EXEC msdb.dbo.sp_send_dbmail @profile_name = 'Reports'
				,@recipients = @Recipients
				,@blind_copy_recipients = '<*******************>'
				,@body = @Body
				,@subject = @Subject
				,@from_address = '<reports@org.co.uk>'
				,@reply_to = '<reports@org.co.uk>'
				-- ,@query = @Query
				-- ,@attach_query_result_as_file = 1
				-- ,@query_attachment_filename = @Filename
				-- ,@query_result_separator = ',' --enforce csv
				-- ,@query_result_no_padding = 1 --trim
				-- ,@query_result_width = 32767 --stop wordwrap
				,@body_format = 'HTML';
		
		END TRY

		BEGIN CATCH
		
		END CATCH;

		FETCH NEXT
		
		FROM Email_Cursor
		
		INTO @SalespersonCode
			,@Email;
	
	END;

	-- The below code cleans up the cursor
	CLOSE Email_Cursor;

	DEALLOCATE Email_Cursor;

	-- The below code drops the [fPreorder Totals] table and recreates it brand new.
	DROP INDEX

	IF EXISTS IDX_Preorder_Code
		ON [fPreorder Totals];
		DROP INDEX

	IF EXISTS IDX_Customer_No
		ON [fPreorder Totals];
		DROP INDEX

	IF EXISTS IDX_Currency
		ON [fPreorder Totals];
		DROP INDEX

	IF EXISTS IDX_Preorder_Customer_Currency
		ON [fPreorder Totals];
		DROP TABLE

	IF EXISTS [fPreorder Totals];
		CREATE TABLE [fPreorder Totals] (
			[Deadline] DATETIME NOT NULL
			,[ETA] DATE NOT NULL
			,[Timestamp] DATETIME NOT NULL
			,[Preorder Code] NVARCHAR(100) NOT NULL
			,[Customer No] NVARCHAR(12) NOT NULL
			,[Customer Name] NVARCHAR(150) NULL
			,[Salesperson Code] NVARCHAR(30) NULL
			,[E-Mail] NVARCHAR(100)
			,[Entries] INTEGER NOT NULL
			,[Quantity] INTEGER NOT NULL
			,[Currency] NVARCHAR(3) NOT NULL
			,[Value] DECIMAL(16, 2) NOT NULL
			,PRIMARY KEY (
				[Preorder Code]
				,[Customer No]
				,[Currency]
				)
			)

	CREATE NONCLUSTERED INDEX IX_fPreorder_BySalesperson_Preorder_Timestamp ON [fPreorder Totals] (
		[Salesperson Code]
		,[Preorder Code]
		,[Timestamp]
		) INCLUDE (
		[Customer No]
		,[Customer Name]
		,[Entries]
		,[Quantity]
		,[Currency]
		,[Value]
		,[E-Mail]
		,[Deadline]
		,[ETA]
		);

	CREATE NONCLUSTERED INDEX IX_fPreorder_Email_NonBlank ON [fPreorder Totals] (
		[E-Mail]
		,[Salesperson Code]
		)
	
	WHERE [E-Mail] <> '';

	-- Finally we insert the new preorder totals data into the [fPreorder Totals] table so everything is ready for the next execution of the procedure.
	INSERT INTO [fPreorder Totals]
	
	SELECT [Deadline]
		,[ETA]
		,[Timestamp]
		,[Preorder Code]
		,[Customer No]
		,[Customer Name]
		,[Salesperson Code]
		,[E-Mail]
		,[Entries]
		,[Quantity]
		,[Currency]
		,[Value]
	
	FROM #New_Preorder_Totals

END

GO



