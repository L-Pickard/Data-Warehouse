--The below code drops the database if exists and the creates the Warehouse database.
USE [master];

GO

IF EXISTS (
		SELECT *
		
		FROM sys.databases
		
		WHERE name = 'Warehouse'
		)
BEGIN
	ALTER DATABASE [Warehouse]

	SET SINGLE_USER
	
	WITH

	ROLLBACK IMMEDIATE;

	DROP DATABASE [Warehouse];

	PRINT 'Database [Warehouse] dropped.';

END;

GO

CREATE DATABASE [Warehouse] ON (
	NAME = Warehouse_Data
	,FILENAME = 'E:\Warehouse\Warehouse.mdf'
	) LOG ON (
	NAME = Warehouse_Log
	,FILENAME = 'E:\Warehouse\Warehouse.ldf'
	);

PRINT 'Database [Warehouse] created.';

GO

-- The below code creates a reporting user account to execute T-SQL
USE [master];

GO

-- Create Login if it does not exist
IF NOT EXISTS (
		SELECT *
		
		FROM sys.server_principals
		
		WHERE name = N'Warehouse_Reporting'
		)
BEGIN
	CREATE LOGIN Warehouse_Reporting
		WITH PASSWORD = '****************************';

	PRINT 'Login Warehouse_Reporting created.';

END

ELSE
BEGIN
	PRINT 'Login Warehouse_Reporting already exists.';

END

GO

USE [Warehouse];

GO

-- Create User if it does not exist in the Warehouse database
IF NOT EXISTS (
		SELECT *
		
		FROM sys.database_principals
		
		WHERE name = N'Warehouse_Reporting'
		)
BEGIN
	CREATE USER Warehouse_Reporting
	
	FOR LOGIN Warehouse_Reporting;

	PRINT 'User Warehouse_Reporting created in Warehouse database.';

END

ELSE
BEGIN
	PRINT 'User Warehouse_Reporting already exists in Warehouse database.';

END

GO

-- Assign the user to roles
PRINT 'Warehouse_Reporting added to db_datareader and db_datawriter for Warehouse.';

GO

GRANT EXECUTE
	TO Warehouse_Reporting;

PRINT 'EXECUTE permission granted to Warehouse_Reporting for Warehouse.';

GO

-- The below code creates user and adds permissions for ORGANIZATION\lead.user
USE [master];

GO

IF NOT EXISTS (
		SELECT *
		
		FROM sys.server_principals
		
		WHERE name = N'ORGANIZATION\lead.user'
		)
BEGIN
	CREATE LOGIN [ORGANIZATION\lead.user]
	
	FROM WINDOWS;

	PRINT 'Login for ORGANIZATION\lead.user created.';

END

ELSE
BEGIN
	PRINT 'Login for ORGANIZATION\lead.user already exists.';

END

GO

USE [Warehouse];

GO

IF NOT EXISTS (
		SELECT *
		
		FROM sys.database_principals
		
		WHERE name = N'ORGANIZATION\lead.user'
		)
BEGIN
	CREATE USER [ORGANIZATION\lead.user]
	
	FOR LOGIN [ORGANIZATION\lead.user];

	PRINT 'User ORGANIZATION\lead.user created in Warehouse database.';

END

ELSE
BEGIN
	PRINT 'User lead.user already exists in Warehouse database.';

END

GO

ALTER ROLE db_owner ADD MEMBER [ORGANIZATION\lead.user];

PRINT 'lead.user added to db_owner in Warehouse database.';

GO

CREATE TABLE [dBrand] (
	[Brand Code] NVARCHAR(3) NOT NULL PRIMARY KEY
	,[Brand Name] NVARCHAR(50) NOT NULL
	,[Buying Category] NVARCHAR(22) NOT NULL
	,[Status] NVARCHAR(12) NOT NULL
	,[Budget Category] NVARCHAR(30) NOT NULL
	,[Grouping] NVARCHAR(30) NOT NULL
	,[Revenue Group] NVARCHAR(50) NULL
	);

CREATE NONCLUSTERED INDEX IX_dBrand_Brand_Name ON [dBrand] ([Brand Name]);

CREATE NONCLUSTERED INDEX IX_dBrand_Status ON [dBrand] ([Status]);

CREATE NONCLUSTERED INDEX IX_dBrand_Buying_Category ON [dBrand] ([Buying Category]);

CREATE NONCLUSTERED INDEX IX_dBrand_Budget_Category ON [dBrand] ([Budget Category]);

CREATE NONCLUSTERED INDEX IX_dBrand_Grouping ON [dBrand] ([Grouping]);

CREATE NONCLUSTERED INDEX IX_dBrand_Revenue_Group ON [dBrand] ([Revenue Group]);

CREATE TABLE [dCountry] (
	[Country Code] NVARCHAR(5) NOT NULL PRIMARY KEY
	,[Country Name] NVARCHAR(50) NOT NULL
	,[CI Required] BIT NOT NULL
	,[Shp Time Days] INTEGER NOT NULL
	,[D2C Customer] NVARCHAR(12) NULL
	,[Arbor Customer] NVARCHAR(12) NULL
	,[Feiyue Customer] NVARCHAR(12) NULL
	,[Flag URL] NVARCHAR(40) NULL
	);

CREATE NONCLUSTERED INDEX IX_dCountry_Country_Name ON [dCountry] ([Country Name]);

CREATE NONCLUSTERED INDEX IX_dCountry_CI_Required ON [dCountry] ([CI Required]);

CREATE NONCLUSTERED INDEX IX_dCountry_Shp_Time_Days ON [dCountry] ([Shp Time Days]);

CREATE NONCLUSTERED INDEX IX_dCountry_D2C_Customer ON [dCountry] ([D2C Customer]);

CREATE NONCLUSTERED INDEX IX_dCountry_Arbor_Customer ON [dCountry] ([Arbor Customer]);

CREATE NONCLUSTERED INDEX IX_dCountry_Feiyue_Customer ON [dCountry] ([Feiyue Customer]);

-- Note - I have changed the [GBP Revenue] calculation which now means it can no longer be persisted.
CREATE TABLE [fMonth Avg XR] (
	[Start Date] DATE NOT NULL
	,[End Date] DATE NOT NULL
	,[From Currency] NVARCHAR(3) NOT NULL
	,[To Currency] NVARCHAR(3) NOT NULL
	,[Code] NVARCHAR(7) NOT NULL
	,[Value] DECIMAL(25, 15) NOT NULL
	,PRIMARY KEY (
		[End Date]
		,[Code]
		)
	);

CREATE NONCLUSTERED INDEX IX_fMonthAvgXR_CurrencyDateRange ON [fMonth Avg XR] (
	[From Currency]
	,[To Currency]
	,[End Date]
	) INCLUDE (
	[Start Date]
	,[Value]
	);

CREATE NONCLUSTERED INDEX IX_fMonthAvgXR_Code ON [fMonth Avg XR] ([Code]) INCLUDE (
	[From Currency]
	,[To Currency]
	,[Value]
	);

CREATE TABLE [fBrand Forecast] (
	[Date Key] AS CAST(CAST(YEAR([Date]) AS VARCHAR(4)) + RIGHT('0' + CAST(MONTH([Date]) AS VARCHAR(2)), 2) + RIGHT('0' + CAST(DAY([Date]) AS VARCHAR(2)), 2) AS INTEGER) 
	PERSISTED
	,[Entity] NVARCHAR(10) NOT NULL
	,[Brand Code] NVARCHAR(3) NOT NULL
	,[Sales Type] NVARCHAR(3) NOT NULL
	,[Date] DATE NOT NULL
	,[Currency] NVARCHAR(3) NOT NULL
	,[Revenue] DECIMAL(30, 15) NOT NULL
	,[GBP Revenue] DECIMAL(30, 15) NOT NULL
	,[EUR Revenue] DECIMAL(30, 15) NOT NULL
	,[USD Revenue] DECIMAL(30, 15) NOT NULL
	,PRIMARY KEY (
		[Entity]
		,[Brand Code]
		,[Sales Type]
		,[Date]
		)
	,CONSTRAINT FK_fBrand_Forecast_to_dDate FOREIGN KEY ([Date Key]) REFERENCES [dDate]([Date Key])
	,CONSTRAINT FK_fBrand_Forecast_to_dBrand FOREIGN KEY ([Brand Code]) REFERENCES [dBrand]([Brand Code])
	);

CREATE NONCLUSTERED INDEX IX_fBrandForecast_DateCurrency ON [fBrand Forecast] (
	[Date]
	,[Currency]
	) INCLUDE (
	[Revenue]
	,[GBP Revenue]
	,[EUR Revenue]
	,[USD Revenue]
	);

CREATE NONCLUSTERED INDEX IX_fBrandForecast_BrandCode ON [fBrand Forecast] ([Brand Code]) INCLUDE (
	[Entity]
	,[Sales Type]
	,[Date]
	,[Revenue]
	);

CREATE NONCLUSTERED INDEX IX_fBrandForecast_DateKey ON [fBrand Forecast] ([Date Key]) INCLUDE (
	[Entity]
	,[Brand Code]
	,[Sales Type]
	,[Revenue]
	);

CREATE TABLE [fTop Forecast] (
	[Date Key] AS CAST(CAST(YEAR([Date]) AS VARCHAR(4)) + RIGHT('0' + CAST(MONTH([Date]) AS VARCHAR(2)), 2) + RIGHT('0' + CAST(DAY([Date]) AS VARCHAR(2)), 2) AS INTEGER) 
	PERSISTED
	,[Category] NVARCHAR(50) NOT NULL
	,[Sub Category] NVARCHAR(50) NOT NULL
	,[Label] NVARCHAR(50) NOT NULL
	,[Entity] NVARCHAR(15) NOT NULL
	,[Currency] NVARCHAR(3) NOT NULL
	,[Date] DATE NOT NULL
	,[Value] DECIMAL(35, 20) NOT NULL
	,[GBP Value] AS CASE 
		WHEN [Currency] = 'GBP'
			THEN [Value]
		WHEN [Currency] = 'EUR'
			THEN [Value] / 1.15598430555556
		WHEN [Currency] = 'USD'
			THEN [Value] / 1.25501957175926
		END PERSISTED
	,PRIMARY KEY (
		[Category]
		,[Sub Category]
		,[Label]
		,[Entity]
		,[Date]
		)
	,CONSTRAINT FK_fTop_Forecast_to_dDate FOREIGN KEY ([Date Key]) REFERENCES [dDate]([Date Key])
	);

CREATE NONCLUSTERED INDEX IX_fTopForecast_DateKey ON [fTop Forecast] ([Date Key]) INCLUDE (
	[Category]
	,[Sub Category]
	,[Label]
	,[Entity]
	,[Currency]
	,[Value]
	,[GBP Value]
	);

CREATE NONCLUSTERED INDEX IX_fTopForecast_DateCurrency ON [fTop Forecast] (
	[Date]
	,[Currency]
	) INCLUDE (
	[Value]
	,[GBP Value]
	,[Category]
	,[Sub Category]
	,[Label]
	);

CREATE NONCLUSTERED INDEX IX_fTopForecast_CategoryBreakdown ON [fTop Forecast] (
	[Category]
	,[Sub Category]
	,[Label]
	) INCLUDE (
	[Entity]
	,[Date]
	,[Currency]
	,[Value]
	,[GBP Value]
	);

CREATE TABLE [fBudget] (
	[Date Key] AS CAST(CAST(YEAR([Date]) AS VARCHAR(4)) + RIGHT('0' + CAST(MONTH([Date]) AS VARCHAR(2)), 2) + RIGHT('0' + CAST(DAY([Date]) AS VARCHAR(2)), 2) AS INTEGER) 
	PERSISTED
	,[Entity] NVARCHAR(15) NOT NULL
	,[Budget Category] NVARCHAR(30) NOT NULL
	,[Sales Type] NVARCHAR(3) NOT NULL
	,[Date] DATE NOT NULL
	,[Currency] NVARCHAR(3) NOT NULL
	,[Revenue] DECIMAL(35, 20) NOT NULL
	,PRIMARY KEY (
		[Date]
		,[Sales Type]
		,[Entity]
		,[Budget Category]
		,[Currency]
		)
	,CONSTRAINT FK_fBudget_to_dDate FOREIGN KEY ([Date Key]) REFERENCES [dDate]([Date Key])
	)

CREATE NONCLUSTERED INDEX IX_fBudget_DateKey ON [fBudget] ([Date Key]) INCLUDE (
	[Entity]
	,[Budget Category]
	,[Sales Type]
	,[Currency]
	,[Revenue]
	);

CREATE NONCLUSTERED INDEX IX_fBudget_Date_BudgetCategory ON [fBudget] (
	[Date]
	,[Budget Category]
	) INCLUDE (
	[Entity]
	,[Sales Type]
	,[Currency]
	,[Revenue]
	);

CREATE NONCLUSTERED INDEX IX_fBudget_Entity_BudgetCategory ON [fBudget] (
	[Entity]
	,[Budget Category]
	) INCLUDE (
	[Date]
	,[Sales Type]
	,[Currency]
	,[Revenue]
	);

CREATE TABLE [dVendor] (
	[Vendor No] NVARCHAR(30) NOT NULL PRIMARY KEY
	,[Name] NVARCHAR(100) NULL
	,[Address] NVARCHAR(100) NULL
	,[Address 2] NVARCHAR(100) NULL
	,[City] NVARCHAR(50) NULL
	,[County] NVARCHAR(50) NULL
	,[Post Code] NVARCHAR(30) NULL
	,[Country Code] NVARCHAR(5) NULL
	,[Contact] NVARCHAR(50) NULL
	,[Phone No] NVARCHAR(50) NULL
	,[Currency Code] NVARCHAR(3) NOT NULL
	,[Payment Terms Code] NVARCHAR(30) NULL
	,[Purchaser Code] NVARCHAR(30) NULL
	,[Pay to Vendor No] NVARCHAR(30) NULL
	,[VAT Registration No] NVARCHAR(50) NULL
	,[E-Mail] NVARCHAR(100) NULL
	,[Home Page] NVARCHAR(100) NULL
	,[Contact No] NVARCHAR(50) NULL
	,CONSTRAINT FK_dVendor_to_dCountry FOREIGN KEY ([Country Code]) REFERENCES [dCountry]([Country Code])
	)

CREATE NONCLUSTERED INDEX IX_dVendor_Name ON [dVendor] ([Name]) INCLUDE (
	[Vendor No]
	,[City]
	,[Country Code]
	,[Currency Code]
	,[Purchaser Code]
	);

CREATE NONCLUSTERED INDEX IX_dVendor_CountryCurrency ON [dVendor] (
	[Country Code]
	,[Currency Code]
	) INCLUDE (
	[Vendor No]
	,[Name]
	,[City]
	,[Purchaser Code]
	);

CREATE NONCLUSTERED INDEX IX_dVendor_VAT ON [dVendor] ([VAT Registration No]) INCLUDE (
	[Vendor No]
	,[Name]
	,[Country Code]
	,[Currency Code]
	);

CREATE TABLE [dSalesperson] (
	[Salesperson Code] NVARCHAR(50) PRIMARY KEY NOT NULL
	,[Name] NVARCHAR(100) NULL
	,[E-Mail] NVARCHAR(100) NULL
	)

CREATE NONCLUSTERED INDEX IX_dSalesperson_Name ON [dSalesperson] ([Name]) INCLUDE (
	[Salesperson Code]
	,[E-Mail]
	);

CREATE NONCLUSTERED INDEX IX_dSalesperson_Email ON [dSalesperson] ([E-Mail]) INCLUDE (
	[Salesperson Code]
	,[Name]
	);

CREATE TABLE [dCustomer] (
	[Customer No] NVARCHAR(12) NOT NULL PRIMARY KEY
	,[Name] NVARCHAR(200) NULL
	,[Address] NVARCHAR(200) NULL
	,[Address 2] NVARCHAR(200) NULL
	,[City] NVARCHAR(50) NULL
	,[County] NVARCHAR(50) NULL
	,[Country Code] NVARCHAR(5) NULL
	,[Post Code] NVARCHAR(30) NULL
	,[Territory Code] NVARCHAR(30) NULL
	,[Contact] NVARCHAR(100) NULL
	,[Phone No] NVARCHAR(50) NULL
	,[Email] NVARCHAR(100) NULL
	,[Home Page] NVARCHAR(100) NULL
	,[Contact No] NVARCHAR(100) NULL
	,[Currency Code] NVARCHAR(3) NOT NULL
	,[Type of Supply] NVARCHAR(100) NULL
	,[Salesperson Code] NVARCHAR(50) NULL
	,[VAT Reg No] NVARCHAR(100) NULL
	,CONSTRAINT FK_dCustomer_to_dSalesperson FOREIGN KEY ([Salesperson Code]) REFERENCES [dSalesperson]([Salesperson Code])
	,CONSTRAINT FK_dCustomer_to_dCountry FOREIGN KEY ([Country Code]) REFERENCES [dCountry]([Country Code])
	);

CREATE NONCLUSTERED INDEX IX_dCustomer_CountryCurrency ON [dCustomer] (
	[Country Code]
	,[Currency Code]
	) INCLUDE (
	[Customer No]
	,[Name]
	,[Salesperson Code]
	);

CREATE NONCLUSTERED INDEX IX_dCustomer_Salesperson ON [dCustomer] ([Salesperson Code]) INCLUDE (
	[Customer No]
	,[Name]
	,[Currency Code]
	,[Country Code]
	);

CREATE NONCLUSTERED INDEX IX_dCustomer_SupplyType ON [dCustomer] ([Type of Supply]) INCLUDE (
	[Customer No]
	,[Name]
	,[Currency Code]
	);

CREATE TABLE [fAdjustments] (
	[Category] NVARCHAR(100) NOT NULL
	,[Financial Year Full] NVARCHAR(8) NOT NULL
	,[Period] NVARCHAR(8) NOT NULL
	,[Month No] INTEGER NOT NULL
	,[Start Date] DATE NOT NULL
	,[End Date] DATE NOT NULL
	,[Entity] NVARCHAR(10) NOT NULL
	,[Currency] NVARCHAR(5) NOT NULL
	,[Value] DECIMAL(20, 8) NOT NULL
	,PRIMARY KEY (
		[Category]
		,[Financial Year Full]
		,[Period]
		,[Month No]
		,[Entity]
		,[Currency]
		)
	);

CREATE NONCLUSTERED INDEX IX_fAdjustments_FY_Period ON [fAdjustments] (
	[Financial Year Full]
	,[Period]
	) INCLUDE (
	[Category]
	,[Month No]
	,[Entity]
	,[Currency]
	,[Value]
	);

CREATE NONCLUSTERED INDEX IX_fAdjustments_DateRange ON [fAdjustments] (
	[Start Date]
	,[End Date]
	) INCLUDE (
	[Category]
	,[Financial Year Full]
	,[Period]
	,[Entity]
	,[Currency]
	,[Value]
	);

CREATE NONCLUSTERED INDEX IX_fAdjustments_EntityCurrency ON [fAdjustments] (
	[Entity]
	,[Currency]
	) INCLUDE (
	[Category]
	,[Financial Year Full]
	,[Period]
	,[Value]
	);

CREATE TABLE [dItem] (
	 [Item No] NVARCHAR(30) NOT NULL PRIMARY KEY
	,[Vendor Reference] NVARCHAR(30) NULL
	,[Brand Code] NVARCHAR(3) NULL
	,[Description] NVARCHAR(100) NULL
	,[Description 2] NVARCHAR(100) NULL
	,[Colours] NVARCHAR(100) NULL
	,[Size 1] NVARCHAR(15) NULL
	,[Size 1 Unit] NVARCHAR(20) NULL
	,[EU Size] NVARCHAR(15) NULL
	,[EU Size Unit] NVARCHAR(20) NULL
	,[US Size] NVARCHAR(15) NULL
	,[US Size Unit] NVARCHAR(20) NULL
	,[Season] NVARCHAR(4) NULL
	,[Item Info] NVARCHAR(100) NULL
	,[Category] NVARCHAR(30) NULL
	,[Category Code] NVARCHAR(10) NULL
	,[Group] NVARCHAR(30) NULL
	,[Group Code] NVARCHAR(15) NULL
	,[EAN Barcode] NVARCHAR(30)
	,[Tariff No] NVARCHAR(20) NULL
	,[HTS No] NVARCHAR(20) NULL
	,[Style Ref] NVARCHAR(300) NULL
	,[GBP Trade] DECIMAL(20, 8) NULL
	,[GBP SRP] DECIMAL(20, 8) NULL
	,[EUR Trade] DECIMAL(20, 8) NULL
	,[EUR SRP] DECIMAL(20, 8) NULL
	,[USD Trade] DECIMAL(20, 8) NULL
	,[USD SRP] DECIMAL(20, 8) NULL
	,[Nav Vendor No] NVARCHAR(30) NULL
	,[BC Vendor No] NVARCHAR(30) NULL
	,[Vendor Name] NVARCHAR(50) NULL
	,[Ltd Blocked] BIT NULL
	,[B.V Blocked] BIT NULL
	,[LLC Blocked] BIT NULL
	,[On Sale] BIT NULL
	,[COO] NVARCHAR(5) NULL
	,[UOM] NVARCHAR(30) NULL
	,[Hot Product] BIT NULL
	,[Lead Time] NVARCHAR(30) NULL
	,[Bread & Butter] BIT NULL
	,[Ltd Buffer Stock] INTEGER NULL
	,[B.V Buffer Stock] INTEGER NULL
	,[LLC Buffer Stock] INTEGER NULL
	,[Ltd GBP Unit Cost] DECIMAL(20, 8) NULL
	,[B.V EUR Unit Cost] DECIMAL(20, 8) NULL
	,[LLC USD Unit Cost] DECIMAL(20, 8) NULL
	,[Common Item No] NVARCHAR(16) NULL
	,[D2C Master SKU] NVARCHAR(30) NULL
	,[D2C Web Item] BIT NULL
	,[Owtanet Export] BIT NULL
	,[Web Item] BIT NULL
	,[Record ID] VARBINARY(224) NULL
	);

CREATE NONCLUSTERED INDEX IX_dItem_BrandCategory ON [dItem] (
	[Brand Code]
	,[Category]
	,[Group]
	) INCLUDE (
	[Item No]
	,[Description]
	,[Vendor Name]
	);

CREATE NONCLUSTERED INDEX IX_dItem_RecordID ON [dItem] ([Record ID]) INCLUDE (
	[Item No]
	,[Brand Code]
	,[Category]
	);

CREATE NONCLUSTERED INDEX IX_dItem_BlockedFlags ON [dItem] (
	[Ltd Blocked]
	,[B.V Blocked]
	,[LLC Blocked]
	) INCLUDE (
	[Item No]
	,[Vendor Name]
	);

CREATE NONCLUSTERED INDEX IX_dItem_OnSale ON [dItem] ([On Sale]) INCLUDE (
	[Item No]
	,[Description]
	,[Brand Code]
	);

CREATE NONCLUSTERED INDEX IX_dItem_EANBarcode ON [dItem] ([EAN Barcode]) INCLUDE (
	[Item No]
	,[Brand Code]
	,[Description]
	);

CREATE NONCLUSTERED INDEX IX_dItem_CommonItemNo ON [dItem] ([Common Item No]) INCLUDE (
	[Item No]
	,[Brand Code]
	);

CREATE NONCLUSTERED INDEX IX_dItem_VendorReference ON [dItem] ([Vendor Reference]) INCLUDE (
	[Item No]
	,[Brand Code]
	);

CREATE NONCLUSTERED INDEX IX_dItem_D2CWeb ON [dItem] (
	[D2C Web Item]
	,[Web Item]
	,[Owtanet Export]
	) INCLUDE (
	[Item No]
	,[Brand Code]
	);

CREATE TABLE [dRecord Link] (
	[Link ID] INTEGER NOT NULL PRIMARY KEY
	,[Record ID] VARBINARY(224) NOT NULL
	,[URL] NVARCHAR(250) NULL
	,[Description] NVARCHAR(250) NULL
	,[Created Timestamp] DATETIME2 NULL
	,[User ID] NVARCHAR(50) NULL
	,[Entity] NVARCHAR(10)
	);

CREATE NONCLUSTERED INDEX IX_dRecordLink_RecordID ON [dRecord Link] ([Record ID]) INCLUDE (
	[URL]
	,[Description]
	,[Created Timestamp]
	,[User ID]
	,[Entity]
	);

CREATE NONCLUSTERED INDEX IX_dRecordLink_Timestamp ON [dRecord Link] ([Created Timestamp]) INCLUDE (
	[Record ID]
	,[User ID]
	,[Entity]
	);

CREATE NONCLUSTERED INDEX IX_dRecordLink_UserID ON [dRecord Link] ([User ID]) INCLUDE (
	[Record ID]
	,[Created Timestamp]
	,[Entity]
	);

CREATE TABLE [dInventory] (
	[Entity] NVARCHAR(10) NOT NULL
	,[Item No] NVARCHAR(30) NOT NULL
	,[Free Stock] INTEGER NOT NULL
	,[Inventory] INTEGER NOT NULL
	,[Brand Code] AS LEFT([Item No], 3) PERSISTED
	,PRIMARY KEY (
		[Entity]
		,[Item No]
		)
	,CONSTRAINT FK_dInventory_to_dItem FOREIGN KEY ([Item No]) REFERENCES [dItem]([Item No])
	,CONSTRAINT FK_dInventory_to_dBrand FOREIGN KEY ([Brand Code]) REFERENCES [Warehouse].[dbo].[dBrand]([Brand Code])
	);

CREATE NONCLUSTERED INDEX IX_dInventory_BrandCode ON [dInventory] ([Brand Code]) INCLUDE (
	[Entity]
	,[Item No]
	,[Free Stock]
	,[Inventory]
	);

CREATE NONCLUSTERED INDEX IX_dInventory_StockLevels ON [dInventory] (
	[Free Stock]
	,[Inventory]
	) INCLUDE (
	[Entity]
	,[Item No]
	,[Brand Code]
	);

CREATE TABLE [dImage] (
	[Table Id] BIGINT IDENTITY(1, 1) NOT NULL PRIMARY KEY
	,[Item No] NVARCHAR(30) NOT NULL
	,[File ID] NVARCHAR(255) NOT NULL
	,[File Name] NVARCHAR(255) NOT NULL
	,[Last Modified] DATETIME2(3) NOT NULL
	,[File Size] BIGINT NOT NULL
	,[Height] INT NOT NULL
	,[Width] INT NOT NULL
	,[Image URL] NVARCHAR(400) NOT NULL
	,[File Path] NVARCHAR(400) NOT NULL
	,CONSTRAINT FK_dImage_to_dItem FOREIGN KEY ([Item No]) REFERENCES [dItem]([Item No])
	)

CREATE NONCLUSTERED INDEX IX_dImage_ItemNo ON [dImage] ([Item No]) INCLUDE (
	[File ID]
	,[File Name]
	,[Last Modified]
	,[Image URL]
	);

CREATE NONCLUSTERED INDEX IX_dImage_ImageDimensions ON [dImage] (
	[Height]
	,[Width]
	) INCLUDE (
	[Item No]
	,[File Name]
	);

CREATE NONCLUSTERED INDEX IX_dImage_FileMeta ON [dImage] (
	[Last Modified]
	,[File Size]
	) INCLUDE (
	[Item No]
	,[File Name]
	,[File Path]
	);

CREATE TABLE [fExchange Rates] (
	[Date Key] AS CAST(CAST(YEAR([Starting Date]) AS VARCHAR(4)) + RIGHT('0' + CAST(MONTH([Starting Date]) AS VARCHAR(2)), 2) + RIGHT('0' + CAST(DAY([Starting Date]) 
				AS VARCHAR(2)), 2) AS INTEGER) PERSISTED
	,[Entity] NVARCHAR(10) NOT NULL
	,[Currency Code] NVARCHAR(3) NOT NULL
	,[Relational Currency Code] NVARCHAR(3) NOT NULL
	,[Starting Date] DATE NOT NULL
	,[Exchange Rate Amount] DECIMAL(20, 8) NOT NULL
	,PRIMARY KEY (
		[Entity]
		,[Currency Code]
		,[Relational Currency Code]
		,[Starting Date]
		)
	,CONSTRAINT FK_fExchnage_Rate_to_dDate FOREIGN KEY ([Date Key]) REFERENCES [dDate]([Date Key])
	);

CREATE NONCLUSTERED INDEX IX_fExchangeRates_DateKey ON [fExchange Rates] ([Date Key]) INCLUDE (
	[Entity]
	,[Currency Code]
	,[Relational Currency Code]
	,[Exchange Rate Amount]
	);

CREATE NONCLUSTERED INDEX IX_fExchangeRates_CurrencyPair ON [fExchange Rates] (
	[Currency Code]
	,[Relational Currency Code]
	) INCLUDE (
	[Entity]
	,[Starting Date]
	,[Exchange Rate Amount]
	);

CREATE NONCLUSTERED INDEX IX_fExchangeRates_StartingDate ON [fExchange Rates] ([Starting Date]) INCLUDE (
	[Entity]
	,[Currency Code]
	,[Relational Currency Code]
	,[Exchange Rate Amount]
	);

CREATE TABLE [dDate] (
	[Date Key] INTEGER NOT NULL PRIMARY KEY
	,[Date] DATE NOT NULL
	,[Year] INTEGER NOT NULL
	,[Financial Year Full] NVARCHAR(8) NOT NULL
	,[Financial Year Start] DATE NOT NULL
	,[Financial Year End] DATE NOT NULL
	,[Quarter] INTEGER NOT NULL
	,[Quarter Full] NVARCHAR(2) NOT NULL
	,[Financial Quarter] INTEGER NOT NULL
	,[Financial Quarter Full] NVARCHAR(2) NOT NULL
	,[Quarter Start Date] DATE NOT NULL
	,[Quarter End Date] DATE NOT NULL
	,[Quarter & Year] NVARCHAR(8) NOT NULL
	,[Month No] INTEGER NOT NULL
	,[Month Name] NVARCHAR(9) NOT NULL
	,[Month Name Abb] NVARCHAR(3) NOT NULL
	,[Month & Year] NVARCHAR(10) NOT NULL
	,[Financial Month] INTEGER NOT NULL
	,[Week of Month] INTEGER NOT NULL
	,[Month & FY] NVARCHAR(9) NOT NULL
	,[ISO Week No] INTEGER NOT NULL
	,[WK Start Date] DATE NOT NULL
	,[Day of Week] INTEGER NOT NULL
	,[Day] INTEGER NOT NULL
	,[Day Name] NVARCHAR(9) NOT NULL
	,[Day Name Abb] NVARCHAR(3) NOT NULL
	,[Day of Year] INTEGER NOT NULL
	,[Is Working Day] BIT NOT NULL
	,[Month Year] NVARCHAR(10) NOT NULL
	,[LY Date] DATE NOT NULL
	);

CREATE NONCLUSTERED INDEX IX_dDate_Date_ISOWeek ON [dDate] (
	[Date]
	,[ISO Week No]
	) INCLUDE (
	[Date Key]
	,[Financial Year Full]
	,[Month No]
	,[Day of Week]
	,[Is Working Day]
	);

CREATE NONCLUSTERED INDEX IX_dDate_FinancialStructure ON [dDate] (
	[Financial Year Full]
	,[Financial Quarter Full]
	,[Month No]
	) INCLUDE (
	[Date Key]
	,[Month Name]
	,[Month Name Abb]
	,[Quarter]
	,[Quarter & Year]
	);

CREATE NONCLUSTERED INDEX IX_dDate_WeekStart ON [dDate] ([WK Start Date]) INCLUDE (
	[Date Key]
	,[Month Year]
	,[LY Date]
	,[Day Name]
	,[Is Working Day]
	);

CREATE TABLE [fOrderbook] (
	[Date Key] AS CAST(CAST(YEAR([Shipment Date]) AS VARCHAR(4)) + RIGHT('0' + CAST(MONTH([Shipment Date]) AS VARCHAR(2)), 2) + RIGHT('0' + CAST(DAY([Shipment Date]) 
				AS VARCHAR(2)), 2) AS INTEGER) PERSISTED
	,[Exclusion] AS CAST(CASE 
			WHEN [Entity] = 'Org Ltd'
				AND [Customer No] IN (
					'CU110025' -- Org BV - NPD Samples EUR
					, 'CU110036' -- Org LLC (Management Recharge)
					, 'CU110040' -- Org BV (Management Recharge)
					, 'CU110083' -- Org BV - NPD Samples USD
					)
				THEN 1
			WHEN [Entity] = 'Org B.V'
				AND [Customer No] IN (
					'CU110025' -- Org BV - NPD Samples EUR
					, 'CU109506' -- NPD Samples EU
					)
				THEN 1
			WHEN [Entity] = 'Org LLC'
				AND [Customer No] IN (
					'UC000650' -- Management Recharge Org Ltd
					, 'UC000653' -- Management recharge Org EU BV
					, 'UC000340' -- Org Marketing
					)
				THEN 1
			ELSE 0
			END AS BIT) PERSISTED
	,[Intercompany] AS CAST(CASE 
			WHEN [Entity] = 'Org Ltd'
				AND [Customer No] IN (
					'CU103500' -- Org Limited
					, 'CU109221' -- Org EU B.V.Replen
					, 'CU109441' -- Org EU BV BTB
					, 'CU109444' -- Org EU BV Replen DONT USE
					, 'CU109525' -- Org EU Site B2B
					, 'CU110077' -- Org LLC
					, 'CU110744' -- Org EU B.V. ..  Redwood Replen
					)
				THEN 1
			WHEN [Entity] = 'Org B.V'
				AND [Customer No] IN (
					'CU103500' -- Org Limited
					, 'CU109221' -- Org EU B.V.Replen
					, 'CU109441' -- Org EU BV BTB
					, 'CU109444' -- Org EU BV Replen DONT USE
					, 'CU109525' -- Org EU Site B2B
					, 'CU110077' -- Org LLC
					)
				THEN 1
			WHEN [Entity] = 'Org LLC'
				AND [Customer No] IN (
					'UC000458' -- Org Ltd
					)
				THEN 1
			ELSE 0
			END AS BIT) PERSISTED
	,[Entity] NVARCHAR(10) NOT NULL
	,[Document No] NVARCHAR(18) NOT NULL
	,[Order Date] DATE NOT NULL
	,[Shipment Date] DATE NOT NULL
	,[Reporting Date] DATE NOT NULL
	,[Location Code] NVARCHAR(30) NULL
	,[Customer No] NVARCHAR(12) NOT NULL
	,[Customer Name] NVARCHAR(100) NULL
	,[Salesperson Code] NVARCHAR(50) NULL
	,[Org Ref] NVARCHAR(150) NULL
	,[Your Reference] NVARCHAR(150) NULL
	,[Country Code] NVARCHAR(5) NULL
	,[Item No] NVARCHAR(30) NOT NULL
	,[Currency] NVARCHAR(5) NOT NULL
	,[Quantity] INTEGER NOT NULL
	,[Line Total] DECIMAL(20, 8) NOT NULL
	,[Outstanding Qty] INTEGER NOT NULL
	,[Outstanding Value] DECIMAL(20, 8) NOT NULL
	,[Item Ledger Qty] INTEGER NOT NULL
	,[PO Qty] INTEGER NOT NULL
	,[SKU Status] NVARCHAR(30) NOT NULL
	,[Pre Order] BIT NOT NULL
	,[Order Status] NVARCHAR(15) NOT NULL
	,[Release Status] NVARCHAR(20) NOT NULL
	,[Sys Status] NVARCHAR(20) NOT NULL
	,[Overdue Status] NVARCHAR(15) NOT NULL
	,PRIMARY KEY (
		[Entity]
		,[Document No]
		,[Item No]
		)
	,CONSTRAINT FK_fOrderbook_to_dItem FOREIGN KEY ([Item No]) REFERENCES [dItem]([Item No])
	,CONSTRAINT FK_Orderbook_to_dCustomer FOREIGN KEY ([Customer No]) REFERENCES [dCustomer]([Customer No])
	,CONSTRAINT FK_Orderbook_to_dDate FOREIGN KEY ([Date Key]) REFERENCES [dDate]([Date Key])
	,CONSTRAINT FK_Orderbook_to_dCountry FOREIGN KEY ([Country Code]) REFERENCES [dCountry]([Country Code])
	,CONSTRAINT FK_Orderbook_to_dSalesperson FOREIGN KEY ([Salesperson Code]) REFERENCES [dSalesperson]([Salesperson Code])
	)

CREATE NONCLUSTERED INDEX IX_fOrderbook_DateFilters ON [fOrderbook] (
	[Date Key]
	,[Shipment Date]
	,[Order Date]
	,[Reporting Date]
	) INCLUDE (
	[Quantity]
	,[Line Total]
	,[Outstanding Qty]
	,[Outstanding Value]
	,[Item Ledger Qty]
	,[PO Qty]
	);

CREATE NONCLUSTERED INDEX IX_fOrderbook_CustomerSales ON [fOrderbook] (
	[Customer No]
	,[Salesperson Code]
	) INCLUDE (
	[Entity]
	,[Item No]
	,[Currency]
	,[Line Total]
	,[Outstanding Qty]
	,[Outstanding Value]
	);

CREATE NONCLUSTERED INDEX IX_fOrderbook_ItemStatus ON [fOrderbook] (
	[Item No]
	,[Currency]
	,[SKU Status]
	,[Location Code]
	) INCLUDE (
	[Entity]
	,[Quantity]
	,[Outstanding Qty]
	,[Outstanding Value]
	,[Pre Order]
	);

CREATE NONCLUSTERED INDEX IX_fOrderbook_StatusFlags ON [fOrderbook] (
	[Exclusion]
	,[Order Status]
	,[Release Status]
	,[Sys Status]
	,[Overdue Status]
	,[Pre Order]
	) INCLUDE (
	[Entity]
	,[Item No]
	,[Quantity]
	,[Outstanding Value]
	,[PO Qty]
	);

CREATE TABLE [fSales] (
	[Date Key] INTEGER NOT NULL
	,[Posting Date] DATE NOT NULL
	,[Customer No] NVARCHAR(12) NULL
	,[Document No] NVARCHAR(14) NOT NULL
	,[Order No] NVARCHAR(18) NULL
	,[Salesperson Code] NVARCHAR(50) NOT NULL
	,[Country Code] NVARCHAR(5) NOT NULL
	,[Entity] NVARCHAR(10) NOT NULL
	,[Royalty %] DECIMAL(20, 15) NOT NULL
	,[Customer Rebate %] DECIMAL(20, 15) NOT NULL
	,[Adjusted Margin] NVARCHAR(3) NOT NULL
	,[Sales Type] NVARCHAR(3) NOT NULL
	,[Royalty Include] BIT NOT NULL
	,[Exclusion] AS CAST(CASE 
			WHEN [Entity] = 'Org Ltd'
				AND [Customer No] IN (
					'CU110025' -- Org BV - NPD Samples EUR
					, 'CU110036' -- Org LLC (Management Recharge)
					, 'CU110040' -- Org BV (Management Recharge)
					, 'CU110083' -- Org BV - NPD Samples USD
					)
				THEN 1
			WHEN [Entity] = 'Org B.V'
				AND [Customer No] IN (
					'CU110025' -- Org BV - NPD Samples EUR
					, 'CU109506' -- NPD Samples EU
					)
				THEN 1
			WHEN [Entity] = 'Org LLC'
				AND [Customer No] IN (
					'UC000650' -- Management Recharge Org Ltd
					, 'UC000653' -- Management recharge Org EU BV
					, 'UC000340' -- Org Marketing
					)
				THEN 1
			ELSE 0
			END AS BIT) PERSISTED
	,[Intercompany] AS CAST(CASE 
			WHEN [Entity] = 'Org Ltd'
				AND [Customer No] IN (
					'CU103500' -- Org Limited
					, 'CU109221' -- Org EU B.V.Replen
					, 'CU109441' -- Org EU BV BTB
					, 'CU109444' -- Org EU BV Replen DONT USE
					, 'CU109525' -- Org EU Site B2B
					, 'CU110077' -- Org LLC
					, 'CU110744' -- Org EU B.V. ..  Redwood Replen
					)
				THEN 1
			WHEN [Entity] = 'Org B.V'
				AND [Customer No] IN (
					'CU103500' -- Org Limited
					, 'CU109221' -- Org EU B.V.Replen
					, 'CU109441' -- Org EU BV BTB
					, 'CU109444' -- Org EU BV Replen DONT USE
					, 'CU109525' -- Org EU Site B2B
					, 'CU110077' -- Org LLC
					)
				THEN 1
			WHEN [Entity] = 'Org LLC'
				AND [Customer No] IN (
					'UC000458' -- Org Ltd
					)
				THEN 1
			ELSE 0
			END AS BIT) PERSISTED
	,[Brand Code] NVARCHAR(3) NOT NULL
	,[Item No] NVARCHAR(30) NOT NULL
	,[Quantity] DECIMAL(16, 4) NOT NULL
	,[GBP Sales] DECIMAL(20, 8) NOT NULL
	,[GBP Cost] DECIMAL(20, 8) NOT NULL
	,[GBP Customer Rebate] DECIMAL(20, 8) NOT NULL
	,[GBP Royalty] DECIMAL(20, 8) NOT NULL
	,[GBP Margin] DECIMAL(20, 8) NOT NULL
	,[GBP Adjusted Margin] DECIMAL(20, 8) NOT NULL
	,[GBP XR Date] DATE NOT NULL
	,[GBP XR] DECIMAL(12, 8) NOT NULL
	,[EUR Sales] DECIMAL(20, 8) NOT NULL
	,[EUR Cost] DECIMAL(20, 8) NOT NULL
	,[EUR Customer Rebate] DECIMAL(20, 8) NOT NULL
	,[EUR Royalty] DECIMAL(20, 8) NOT NULL
	,[EUR Margin] DECIMAL(20, 8) NOT NULL
	,[EUR Adjusted Margin] DECIMAL(20, 8) NOT NULL
	,[EUR XR Date] DATE NOT NULL
	,[EUR XR] DECIMAL(12, 8) NOT NULL
	,[USD Sales] DECIMAL(20, 8) NOT NULL
	,[USD Cost] DECIMAL(20, 8) NOT NULL
	,[USD Customer Rebate] DECIMAL(20, 8) NOT NULL
	,[USD Royalty] DECIMAL(20, 8) NOT NULL
	,[USD Margin] DECIMAL(20, 8) NOT NULL
	,[USD Adjusted Margin] DECIMAL(20, 8) NOT NULL
	,[USD XR Date] DATE NOT NULL
	,[USD XR] DECIMAL(12, 8) NOT NULL
	,PRIMARY KEY (
		[Posting Date]
		,[Entity]
		,[Document No]
		,[Salesperson Code]
		,[Item No]
		)
	,CONSTRAINT FK_fSales_to_dBrand FOREIGN KEY ([Brand Code]) REFERENCES [dBrand]([Brand Code])
	,CONSTRAINT FK_fSales_to_dItem FOREIGN KEY ([Item No]) REFERENCES [dItem]([Item No])
	,CONSTRAINT FK_fSales_to_dCustomer FOREIGN KEY ([Customer No]) REFERENCES [dCustomer]([Customer No])
	,CONSTRAINT FK_fSales_to_dDate FOREIGN KEY ([Date Key]) REFERENCES [dDate]([Date Key])
	,CONSTRAINT FK_Sales_to_dCountry FOREIGN KEY ([Country Code]) REFERENCES [dCountry]([Country Code])
	,CONSTRAINT FK_Orderbook_to_dSalesperson FOREIGN KEY ([Salesperson Code]) REFERENCES [dSalesperson]([Salesperson Code])
	);

CREATE NONCLUSTERED INDEX IX_fSales_Date ON [fSales] (
	[Posting Date]
	,[Date Key]
	) INCLUDE (
	[Quantity]
	,[GBP Sales]
	,[GBP Margin]
	,[GBP Adjusted Margin]
	,[EUR Sales]
	,[EUR Margin]
	,[EUR Adjusted Margin]
	,[USD Sales]
	,[USD Margin]
	,[USD Adjusted Margin]
	);

CREATE NONCLUSTERED INDEX IX_fSales_CustomerSales ON [fSales] (
	[Customer No]
	,[Salesperson Code]
	,[Country Code]
	) INCLUDE (
	[Entity]
	,[Document No]
	,[Brand Code]
	,[Item No]
	,[Quantity]
	,[GBP Sales]
	,[GBP Margin]
	,[EUR Sales]
	,[USD Sales]
	);

CREATE NONCLUSTERED INDEX IX_fSales_ItemGrouping ON [fSales] (
	[Item No]
	,[Brand Code]
	,[Sales Type]
	) INCLUDE (
	[Quantity]
	,[GBP Sales]
	,[GBP Margin]
	,[GBP Adjusted Margin]
	,[EUR Sales]
	,[EUR Margin]
	,[EUR Adjusted Margin]
	,[USD Sales]
	,[USD Margin]
	,[USD Adjusted Margin]
	);

CREATE NONCLUSTERED INDEX IX_fSales_Flags ON [fSales] (
	[Exclusion]
	,[Intercompany]
	) INCLUDE (
	[Entity]
	,[Document No]
	,[Item No]
	,[Quantity]
	,[GBP Sales]
	,[GBP Margin]
	,[GBP Adjusted Margin]
	,[EUR Sales]
	,[EUR Margin]
	,[EUR Adjusted Margin]
	,[USD Sales]
	,[USD Margin]
	,[USD Adjusted Margin]
	);

CREATE TABLE [fSales Staging] (
	[Date Key] INTEGER NOT NULL
	,[Posting Date] DATE NOT NULL
	,[Customer No] NVARCHAR(12) NOT NULL
	,[Document No] NVARCHAR(14) NOT NULL
	,[Order No] NVARCHAR(18) NULL
	,[Salesperson Code] NVARCHAR(50) NOT NULL
	,[Country Code] NVARCHAR(2) NULL
	,[Entity] NVARCHAR(10) NOT NULL
	,[Royalty %] DECIMAL(20, 15) NOT NULL
	,[Customer Rebate %] DECIMAL(20, 15) NOT NULL
	,[Adjusted Margin] NVARCHAR(3) NOT NULL
	,[Sales Type] NVARCHAR(3) NOT NULL
	,[Royalty Include] BIT NOT NULL
	,[Brand Code] NVARCHAR(3) NOT NULL
	,[Item No] NVARCHAR(30) NOT NULL
	,[Quantity] DECIMAL(16, 4) NOT NULL
	,[GBP Sales] DECIMAL(20, 8) NOT NULL
	,[GBP Cost] DECIMAL(20, 8) NOT NULL
	,[GBP Customer Rebate] DECIMAL(20, 8) NOT NULL
	,[GBP Royalty] DECIMAL(20, 8) NOT NULL
	,[GBP Margin] DECIMAL(20, 8) NOT NULL
	,[GBP Adjusted Margin] DECIMAL(20, 8) NOT NULL
	,[GBP XR Date] DATE NOT NULL
	,[GBP XR] DECIMAL(12, 8) NOT NULL
	,[EUR Sales] DECIMAL(20, 8) NOT NULL
	,[EUR Cost] DECIMAL(20, 8) NOT NULL
	,[EUR Customer Rebate] DECIMAL(20, 8) NOT NULL
	,[EUR Royalty] DECIMAL(20, 8) NOT NULL
	,[EUR Margin] DECIMAL(20, 8) NOT NULL
	,[EUR Adjusted Margin] DECIMAL(20, 8) NOT NULL
	,[EUR XR Date] DATE NOT NULL
	,[EUR XR] DECIMAL(12, 8) NOT NULL
	,[USD Sales] DECIMAL(20, 8) NOT NULL
	,[USD Cost] DECIMAL(20, 8) NOT NULL
	,[USD Customer Rebate] DECIMAL(20, 8) NOT NULL
	,[USD Royalty] DECIMAL(20, 8) NOT NULL
	,[USD Margin] DECIMAL(20, 8) NOT NULL
	,[USD Adjusted Margin] DECIMAL(20, 8) NOT NULL
	,[USD XR Date] DATE NOT NULL
	,[USD XR] DECIMAL(12, 8) NOT NULL
	,PRIMARY KEY (
		[Date Key]
		,[Customer No]
		,[Document No]
		,[Salesperson Code]
		,[Item No]
		)
	);

CREATE TABLE [dGL Accounts] (
	[Entity] NVARCHAR(10) NOT NULL
	,[GL Account No] INTEGER NOT NULL
	,[GL Account Name] NVARCHAR(60) NOT NULL
	,[Account Type] NVARCHAR(15) NOT NULL
	,[Blocked] BIT NOT NULL
	,[Direct Posting] BIT NOT NULL
	,[Start GL No] INTEGER NULL
	,[End GL No] INTEGER NULL
	,[Classification] NVARCHAR(50) NULL
	,[Group] NVARCHAR(40) NULL
	,[Financial Statement] NVARCHAR(5) NULL
	,[P&L Label] AS (
		CASE 
			WHEN [GL Account No] IN (20003, 20010, 20020, 20021, 20025, 20040)
				THEN 'Turnover'
			WHEN [GL Account No] IN (31000, 31005, 31010, 31050, 31060, 31080, 31085, 31090, 31099, 31501, 31502)
				THEN 'Cost of Sales'
			WHEN [GL Account No] IN (
					40220, 40401, 40403, 40410, 40411, 40421, 40423, 40441, 40620, 40801, 40805, 40851, 41201, 41801, 41802, 41803, 41804, 41805, 41806, 41808, 41809, 
					41810, 42103, 42104, 42106, 42107, 42110, 42302, 42303, 42305, 42851, 43801, 43810, 43902, 44003, 44101, 44102, 44301, 44302, 44303, 44305, 44306, 
					44311, 44312, 44313, 44315, 44316, 44323, 44325, 44333, 44335, 44342, 44343, 44345, 44355, 44393, 44395, 44361, 44403, 44405, 44415, 44532, 44535, 
					44537, 44556, 44561, 44562, 44563, 44565, 44566, 44575, 44585, 44587, 44596, 44645, 44646, 44686, 44702, 44746, 44781, 44782, 44786, 44811, 44816, 
					45081, 45085
					)
				THEN 'Distribution Costs'
			WHEN [GL Account No] IN (
					40303, 40305, 40306, 40307, 40308, 40310, 40402, 40404, 40412, 40422, 40424, 40431, 40442, 40471, 40504, 40541, 40601, 40701, 40852, 40901, 40902, 
					40904, 40905, 40906, 40907, 41001, 41002, 41003, 41004, 41101, 41102, 41301, 41302, 41401, 41501, 41502, 41551, 41601, 41701, 41901, 41902, 42001, 
					42201, 42401, 42501, 42601, 42603, 42701, 42703, 42901, 42902, 42903, 42904, 42905, 42906, 42907, 43101, 43102, 43103, 43108, 43109, 43110, 43201, 
					43202, 43301, 43304, 43401, 43402, 43501, 43502, 43503, 43601, 43701, 43702, 43704, 43705
					)
				THEN 'Administration Expenditure'
			WHEN [GL Account No] IN (10113, 10121, 10127, 10176)
				THEN 'Other Operating Income'
			WHEN [GL Account No] IN (43049, 43190)
				THEN 'Exceptional Write Off'
			END
		) PERSISTED
	,PRIMARY KEY (
		[Entity]
		,[GL Account No]
		)
	);

CREATE NONCLUSTERED INDEX IX_dGLAccounts_AccountType ON [dGL Accounts] (
	[Account Type]
	,[P&L Label]
	) INCLUDE (
	[GL Account No]
	,[Entity]
	,[GL Account Name]
	,[Classification]
	,[Group]
	,[Financial Statement]
	);

CREATE NONCLUSTERED INDEX IX_dGLAccounts_ClassBlock ON [dGL Accounts] (
	[Classification]
	,[Blocked]
	,[Direct Posting]
	) INCLUDE (
	[GL Account No]
	,[Entity]
	,[GL Account Name]
	,[Account Type]
	,[Group]
	,[Financial Statement]
	,[P&L Label]
	);

CREATE NONCLUSTERED INDEX IX_dGLAccounts_GLRange ON [dGL Accounts] (
	[Start GL No]
	,[End GL No]
	) INCLUDE (
	[GL Account No]
	,[Entity]
	,[GL Account Name]
	,[Classification]
	,[P&L Label]
	);

CREATE TABLE [fGL Balance at Date] (
	[Date Key] AS CAST(CAST(YEAR([Date]) AS VARCHAR(4)) + RIGHT('0' + CAST(MONTH([Date]) AS VARCHAR(2)), 2) + RIGHT('0' + CAST(DAY([Date]) AS VARCHAR(2)), 2) AS INTEGER) 
	PERSISTED
	,[GL Account No] INTEGER NOT NULL
	,[Entity] NVARCHAR(10) NOT NULL
	,[Date] DATE NOT NULL
	,[Currency] NVARCHAR(3) NOT NULL
	,[Debit Amount] DECIMAL(20, 8) NOT NULL
	,[Credit Amount] DECIMAL(20, 8) NOT NULL
	,[Amount] DECIMAL(20, 8) NOT NULL
	,PRIMARY KEY (
		[GL Account No]
		,[Entity]
		,[Date]
		)
	,CONSTRAINT FK_fGL_Balance_at_Date_to_dDate FOREIGN KEY ([Date Key]) REFERENCES [dDate]([Date Key])
	,CONSTRAINT FK_fGL_Balance_at_Date_to_GL_Accounts FOREIGN KEY (
		[Entity]
		,[GL Account No]
		) REFERENCES [dGL Accounts]([Entity], [GL Account No])
	);

CREATE NONCLUSTERED INDEX IX_fGLBalance_DateKey ON [fGL Balance at Date] ([Date Key]) INCLUDE (
	[GL Account No]
	,[Entity]
	,[Date]
	,[Currency]
	,[Amount]
	);

CREATE NONCLUSTERED INDEX IX_fGLBalance_AccountEntity ON [fGL Balance at Date] (
	[GL Account No]
	,[Entity]
	) INCLUDE (
	[Date]
	,[Currency]
	,[Amount]
	);

CREATE NONCLUSTERED INDEX IX_fGLBalance_Currency ON [fGL Balance at Date] ([Currency]) INCLUDE (
	[GL Account No]
	,[Entity]
	,[Date]
	,[Amount]
	);

CREATE TABLE [fGL Entry] (
	[Date Key] INTEGER NOT NULL
	,[Posting Date] DATE NOT NULL
	,[Entity] NVARCHAR(10) NOT NULL
	,[Entry No] INTEGER NOT NULL
	,[GL Account No] INTEGER NOT NULL
	,[Document Type] NVARCHAR(20) NOT NULL
	,[Document No] NVARCHAR(30) NOT NULL
	,[Description] NVARCHAR(100) NULL
	,[User ID] NVARCHAR(20) NOT NULL
	,[Source Code] NVARCHAR(10) NULL
	,[Source Type] INTEGER NOT NULL
	,[Source No] NVARCHAR(20) NULL
	,[Balance Account No] NVARCHAR(20) NULL
	,[Exclusion] AS CAST(CASE 
			WHEN [Entity] = 'Org Ltd'
				AND [Customer No] IN (
					'CU110025' -- Org BV - NPD Samples EUR
					, 'CU110036' -- Org LLC (Management Recharge)
					, 'CU110040' -- Org BV (Management Recharge)
					, 'CU110083' -- Org BV - NPD Samples USD
					)
				THEN 1
			WHEN [Entity] = 'Org B.V'
				AND [Customer No] IN (
					'CU110025' -- Org BV - NPD Samples EUR
					, 'CU109506' -- NPD Samples EU
					)
				THEN 1
			WHEN [Entity] = 'Org LLC'
				AND [Customer No] IN (
					'UC000650' -- Management Recharge Org Ltd
					, 'UC000653' -- Management recharge Org EU BV
					, 'UC000340' -- Org Marketing
					)
				THEN 1
			ELSE 0
			END AS BIT) PERSISTED
	,[Intercompany] AS CAST(CASE 
			WHEN [Entity] = 'Org Ltd'
				AND [Customer No] IN (
					'CU103500' -- Org Limited
					, 'CU109221' -- Org EU B.V.Replen
					, 'CU109441' -- Org EU BV BTB
					, 'CU109444' -- Org EU BV Replen DONT USE
					, 'CU109525' -- Org EU Site B2B
					, 'CU110077' -- Org LLC
					, 'CU110744' -- Org EU B.V. ..  Redwood Replen
					)
				THEN 1
			WHEN [Entity] = 'Org B.V'
				AND [Customer No] IN (
					'CU103500' -- Org Limited
					, 'CU109221' -- Org EU B.V.Replen
					, 'CU109441' -- Org EU BV BTB
					, 'CU109444' -- Org EU BV Replen DONT USE
					, 'CU109525' -- Org EU Site B2B
					, 'CU110077' -- Org LLC
					)
				THEN 1
			WHEN [Entity] = 'Org LLC'
				AND [Customer No] IN (
					'UC000458' -- Org Ltd
					)
				THEN 1
			ELSE 0
			END AS BIT) PERSISTED
	,[GBP Amount] DECIMAL(20, 8) NOT NULL
	,[GBP VAT Amount] DECIMAL(20, 8) NOT NULL
	,[GBP Debit Amount] DECIMAL(20, 8) NOT NULL
	,[GBP Credit Amount] DECIMAL(20, 8) NOT NULL
	,[GBP XR Date] DATE NOT NULL
	,[GBP XR] DECIMAL(12, 8) NOT NULL
	,[EUR Amount] DECIMAL(20, 8) NOT NULL
	,[EUR VAT Amount] DECIMAL(20, 8) NOT NULL
	,[EUR Debit Amount] DECIMAL(20, 8) NOT NULL
	,[EUR Credit Amount] DECIMAL(20, 8) NOT NULL
	,[EUR XR Date] DATE NOT NULL
	,[EUR XR] DECIMAL(12, 8) NOT NULL
	,[USD Amount] DECIMAL(20, 8) NOT NULL
	,[USD VAT Amount] DECIMAL(20, 8) NOT NULL
	,[USD Debit Amount] DECIMAL(20, 8) NOT NULL
	,[USD Credit Amount] DECIMAL(20, 8) NOT NULL
	,[USD XR Date] DATE NOT NULL
	,[USD XR] DECIMAL(12, 8) NOT NULL
	,PRIMARY KEY (
		[Entity]
		,[Entry No]
		)
	,CONSTRAINT FK_GL_Entry_to_GL_Accounts FOREIGN KEY (
		[Entity]
		,[GL Account No]
		) REFERENCES [dGL Accounts]([Entity], [GL Account No])
	);

CREATE NONCLUSTERED INDEX IX_fGLEntry_Date ON [fGL Entry] (
	[Date Key]
	,[Posting Date]
	) INCLUDE (
	[GL Account No]
	,[Entity]
	,[Document No]
	,[GBP Amount]
	,[GBP Debit Amount]
	,[GBP Credit Amount]
	,[EUR Amount]
	,[EUR Debit Amount]
	,[EUR Credit Amount]
	,[USD Amount]
	,[USD Debit Amount]
	,[USD Credit Amount]
	);

CREATE NONCLUSTERED INDEX IX_fGLEntry_GLAccount ON [fGL Entry] (
	[GL Account No]
	,[Entity]
	) INCLUDE (
	[Date Key]
	,[Posting Date]
	,[Document No]
	,[GBP Amount]
	,[EUR Amount]
	,[USD Amount]
	);

CREATE NONCLUSTERED INDEX IX_fGLEntry_DocumentsAndSource ON [fGL Entry] (
	[Document No]
	,[User ID]
	,[Source No]
	) INCLUDE (
	[Date Key]
	,[GL Account No]
	,[Entity]
	,[GBP Amount]
	,[EUR Amount]
	,[USD Amount]
	);

CREATE NONCLUSTERED INDEX IX_fGLEntry_Flags ON [fGL Entry] (
	[Exclusion]
	,[Intercompany]
	) INCLUDE (
	[Date Key]
	,[GL Account No]
	,[Entity]
	,[GBP Amount]
	,[EUR Amount]
	,[USD Amount]
	);

CREATE TABLE [fGL Entry Staging] (
	[Date Key] INTEGER NOT NULL
	,[Posting Date] DATE NOT NULL
	,[Entity] NVARCHAR(10) NOT NULL
	,[Entry No] INTEGER NOT NULL
	,[GL Account No] NVARCHAR(8) NOT NULL
	,[Document Type] NVARCHAR(20) NOT NULL
	,[Document No] NVARCHAR(30) NOT NULL
	,[Description] NVARCHAR(100) NULL
	,[User ID] NVARCHAR(20) NOT NULL
	,[Source Code] NVARCHAR(10) NULL
	,[Source Type] INTEGER NOT NULL
	,[Source No] NVARCHAR(20) NULL
	,[Balance Account No] NVARCHAR(20) NULL
	,[GBP Amount] DECIMAL(20, 8) NOT NULL
	,[GBP VAT Amount] DECIMAL(20, 8) NOT NULL
	,[GBP Debit Amount] DECIMAL(20, 8) NOT NULL
	,[GBP Credit Amount] DECIMAL(20, 8) NOT NULL
	,[GBP XR Date] DATE NOT NULL
	,[GBP XR] DECIMAL(12, 8) NOT NULL
	,[EUR Amount] DECIMAL(20, 8) NOT NULL
	,[EUR VAT Amount] DECIMAL(20, 8) NOT NULL
	,[EUR Debit Amount] DECIMAL(20, 8) NOT NULL
	,[EUR Credit Amount] DECIMAL(20, 8) NOT NULL
	,[EUR XR Date] DATE NOT NULL
	,[EUR XR] DECIMAL(12, 8) NOT NULL
	,[USD Amount] DECIMAL(20, 8) NOT NULL
	,[USD VAT Amount] DECIMAL(20, 8) NOT NULL
	,[USD Debit Amount] DECIMAL(20, 8) NOT NULL
	,[USD Credit Amount] DECIMAL(20, 8) NOT NULL
	,[USD XR Date] DATE NOT NULL
	,[USD XR] DECIMAL(12, 8) NOT NULL
	,PRIMARY KEY (
		[Entity]
		,[Entry No]
		)
	);

CREATE TABLE [fPurchases] (
	[Date Key] AS CAST(CAST(YEAR([ETA Date]) AS VARCHAR(4)) + RIGHT('0' + CAST(MONTH([ETA Date]) AS VARCHAR(2)), 2) + RIGHT('0' + CAST(DAY([ETA Date]) AS VARCHAR(2)), 2
		) AS INTEGER) PERSISTED
	,[Exclusion] AS CAST(CASE 
			WHEN [Vendor No] IN (
					'UV000199' -- Management Recharge Org Ltd
					, 'UV000200' -- Managemment Recharge Org EU BV
					, 'VE100194' -- Org Properties Limited
					, 'VE100890' -- Org LLC (Management Recharge)
					)
				THEN 1
			ELSE 0
			END AS BIT) PERSISTED
	,[Intercompany] AS CAST(CASE 
			WHEN [Vendor No] IN (
					'UV000081' -- Org Ltd
					, 'UV000195' -- Org EU BV
					, 'VE100520' -- Org Ltd - Replen
					, 'VE100927' -- Org Ltd
					, 'VE100934' -- Org LLC
					, 'VE100952' -- Org EU B.V.
					)
				THEN 1
			ELSE 0
			END AS BIT) PERSISTED
	,[Entity] NVARCHAR(10) NOT NULL
	,[ETA Date] DATE NULL
	,[Document No] NVARCHAR(30) NOT NULL
	,[Vendor No] NVARCHAR(30) NULL
	,[Location Code] NVARCHAR(50) NULL
	,[Your Reference] NVARCHAR(100) NULL
	,[Invoice No] NVARCHAR(100) NULL
	,[Item No] NVARCHAR(30) NOT NULL
	,[Currency] NVARCHAR(30) NOT NULL
	,[Quantity] INTEGER NOT NULL
	,[Line Total] DECIMAL(20, 8) NOT NULL
	,[Qty Received] INTEGER NOT NULL
	,[Outstanding Qty] INTEGER NOT NULL
	,[Outstanding Value] DECIMAL(20, 8)
	,[Reserved Qty] INTEGER NOT NULL
	,[PO Freestock] INTEGER NOT NULL
	,PRIMARY KEY (
		[Entity]
		,[Document No]
		,[Item No]
		)
	,CONSTRAINT FK_fPurchases_to_dDate FOREIGN KEY ([Date Key]) REFERENCES [dDate]([Date Key])
	,CONSTRAINT FK_fPurchases_to_dVendor FOREIGN KEY ([Vendor No]) REFERENCES [dVendor]([Vendor No])
	,CONSTRAINT FK_fPurchases_to_dItem FOREIGN KEY ([Item No]) REFERENCES [dItem]([Item No])
	);

CREATE NONCLUSTERED INDEX IX_fPurchases_DateFilters ON [fPurchases] (
	[Date Key]
	,[ETA Date]
	) INCLUDE (
	[Entity]
	,[Item No]
	,[Vendor No]
	,[Document No]
	,[Currency]
	,[Quantity]
	,[Line Total]
	,[Outstanding Qty]
	,[Outstanding Value]
	);

CREATE NONCLUSTERED INDEX IX_fPurchases_VendorItemDocument ON [fPurchases] (
	[Vendor No]
	,[Item No]
	,[Document No]
	) INCLUDE (
	[Entity]
	,[Date Key]
	,[Currency]
	,[Quantity]
	,[Line Total]
	,[Qty Received]
	,[Outstanding Qty]
	,[Reserved Qty]
	);

CREATE NONCLUSTERED INDEX IX_fPurchases_Flags ON [fPurchases] (
	[Exclusion]
	,[Intercompany]
	) INCLUDE (
	[Entity]
	,[Date Key]
	,[ETA Date]
	,[Item No]
	,[Currency]
	,[Quantity]
	,[Line Total]
	,[Outstanding Qty]
	,[PO Freestock]
	);

CREATE NONCLUSTERED INDEX IX_fPurchases_ReferenceFilters ON [fPurchases] (
	[Location Code]
	,[Invoice No]
	,[Your Reference]
	) INCLUDE (
	[Entity]
	,[Date Key]
	,[Item No]
	,[Document No]
	,[Quantity]
	,[Line Total]
	,[Outstanding Value]
	);

CREATE TABLE [fLedger] (
	[Date Key] AS CAST(CAST(YEAR([Posting Date]) AS VARCHAR(4)) + RIGHT('0' + CAST(MONTH([Posting Date]) AS VARCHAR(2)), 2) + RIGHT('0' + CAST(DAY([Posting Date]) AS 
				VARCHAR(2)), 2) AS INTEGER) PERSISTED
	,[Posting Date] DATE NOT NULL
	,[Entity] NVARCHAR(10) NOT NULL
	,[Entry Type] NVARCHAR(30) NOT NULL
	,[Brand Code] NVARCHAR(3) NOT NULL
	,[Item No] NVARCHAR(30) NOT NULL
	,[Location Code] NVARCHAR(50) NOT NULL
	,[Quantity] INTEGER NOT NULL
	,[Currency] NVARCHAR(3) NOT NULL
	,[Cost Value] DECIMAL(20, 8) NOT NULL
	,PRIMARY KEY (
		[Posting Date]
		,[Entity]
		,[Entry Type]
		,[Item No]
		,[Location Code]
		)
	,CONSTRAINT FK_fLedger_to_dDate FOREIGN KEY ([Date Key]) REFERENCES [dDate]([Date Key])
	,CONSTRAINT FK_fLedger_to_dBrand FOREIGN KEY ([Brand Code]) REFERENCES [dBrand]([Brand Code])
	,CONSTRAINT FK_fLedger_to_dItem FOREIGN KEY ([Item No]) REFERENCES [dItem]([Item No])
	)

CREATE NONCLUSTERED INDEX IX_fLedger_Date ON [fLedger] (
	[Date Key]
	,[Posting Date]
	) INCLUDE (
	[Entity]
	,[Entry Type]
	,[Item No]
	,[Location Code]
	,[Brand Code]
	,[Currency]
	,[Quantity]
	,[Cost Value]
	);

CREATE NONCLUSTERED INDEX IX_fLedger_EntityItemLocation ON [fLedger] (
	[Entity]
	,[Item No]
	,[Location Code]
	) INCLUDE (
	[Date Key]
	,[Posting Date]
	,[Entry Type]
	,[Brand Code]
	,[Currency]
	,[Quantity]
	,[Cost Value]
	);

CREATE NONCLUSTERED INDEX IX_fLedger_EntryAndBrand ON [fLedger] (
	[Entry Type]
	,[Brand Code]
	) INCLUDE (
	[Date Key]
	,[Posting Date]
	,[Entity]
	,[Item No]
	,[Location Code]
	,[Currency]
	,[Quantity]
	,[Cost Value]
	);

CREATE TABLE [fShipped Qty] (
	[Entity] NVARCHAR(10) NOT NULL
	,[Item No] NVARCHAR(30) NOT NULL
	,[Shipped in Last 360 Days] INTEGER NOT NULL
	,[Shipped in Last 180 Days] INTEGER NOT NULL
	,[Shipped 331 to 360 Days Ago] INTEGER NOT NULL
	,[Shipped 301 to 330 Days Ago] INTEGER NOT NULL
	,[Shipped 271 to 300 Days Ago] INTEGER NOT NULL
	,[Shipped 241 to 270 Days Ago] INTEGER NOT NULL
	,[Shipped 211 to 240 Days Ago] INTEGER NOT NULL
	,[Shipped 181 to 210 Days Ago] INTEGER NOT NULL
	,[Shipped 151 to 180 Days Ago] INTEGER NOT NULL
	,[Shipped 121 to 150 Days Ago] INTEGER NOT NULL
	,[Shipped 91 to 120 Days Ago] INTEGER NOT NULL
	,[Shipped 61 to 90 Days Ago] INTEGER NOT NULL
	,[Shipped 31 to 60 Days Ago] INTEGER NOT NULL
	,[Shipped 1 to 30 Days Ago] INTEGER NOT NULL
	,[Shipped 30 Day Avg] DECIMAL(20, 8) NOT NULL
	,[Shipped 30 Day Avg 6M] DECIMAL(20, 8) NOT NULL
	,PRIMARY KEY (
		[Entity]
		,[Item No]
		)
	,CONSTRAINT FK_fShipped_Qty_to_dItem FOREIGN KEY ([Item No]) REFERENCES [dItem]([Item No])
	);

CREATE NONCLUSTERED INDEX IX_fShippedQty_Entity_Item ON [fShipped Qty] (
	[Entity]
	,[Item No]
	) INCLUDE (
	[Shipped in Last 360 Days]
	,[Shipped in Last 180 Days]
	,[Shipped 331 to 360 Days Ago]
	,[Shipped 301 to 330 Days Ago]
	,[Shipped 271 to 300 Days Ago]
	,[Shipped 241 to 270 Days Ago]
	,[Shipped 211 to 240 Days Ago]
	,[Shipped 181 to 210 Days Ago]
	,[Shipped 151 to 180 Days Ago]
	,[Shipped 121 to 150 Days Ago]
	,[Shipped 91 to 120 Days Ago]
	,[Shipped 61 to 90 Days Ago]
	,[Shipped 31 to 60 Days Ago]
	,[Shipped 1 to 30 Days Ago]
	,[Shipped 30 Day Avg]
	,[Shipped 30 Day Avg 6M]
	);

CREATE NONCLUSTERED INDEX IX_fShippedQty_Item ON [fShipped Qty] ([Item No]) INCLUDE (
	[Entity]
	,[Shipped in Last 360 Days]
	,[Shipped in Last 180 Days]
	,[Shipped 30 Day Avg]
	,[Shipped 30 Day Avg 6M]
	);

CREATE NONCLUSTERED INDEX IX_fShippedQty_AvgMetrics ON [fShipped Qty] (
	[Shipped 30 Day Avg]
	,[Shipped 30 Day Avg 6M]
	) INCLUDE (
	[Entity]
	,[Item No]
	,[Shipped in Last 360 Days]
	,[Shipped in Last 180 Days]
	);

-- I have had to create a near duplicate table to fix the orginal Org group pst for charlie. not the greatest db design!
CREATE TABLE [fShipped Qty NAV OG] (
	[Entity] NVARCHAR(10) NOT NULL
	,[Item No] NVARCHAR(30) NOT NULL
	,[Shipped in Last 360 Days] INTEGER NOT NULL
	,[Shipped in Last 180 Days] INTEGER NOT NULL
	,[Shipped 331 to 360 Days Ago] INTEGER NOT NULL
	,[Shipped 301 to 330 Days Ago] INTEGER NOT NULL
	,[Shipped 271 to 300 Days Ago] INTEGER NOT NULL
	,[Shipped 241 to 270 Days Ago] INTEGER NOT NULL
	,[Shipped 211 to 240 Days Ago] INTEGER NOT NULL
	,[Shipped 181 to 210 Days Ago] INTEGER NOT NULL
	,[Shipped 151 to 180 Days Ago] INTEGER NOT NULL
	,[Shipped 121 to 150 Days Ago] INTEGER NOT NULL
	,[Shipped 91 to 120 Days Ago] INTEGER NOT NULL
	,[Shipped 61 to 90 Days Ago] INTEGER NOT NULL
	,[Shipped 31 to 60 Days Ago] INTEGER NOT NULL
	,[Shipped 1 to 30 Days Ago] INTEGER NOT NULL
	,[Shipped 30 Day Avg] DECIMAL(20, 8) NOT NULL
	,[Shipped 30 Day Avg 6M] DECIMAL(20, 8) NOT NULL
	,PRIMARY KEY (
		[Entity]
		,[Item No]
		)
	,CONSTRAINT FK_fShipped_Qty_Nav_to_dItem FOREIGN KEY ([Item No]) REFERENCES [dItem]([Item No])
	);

CREATE NONCLUSTERED INDEX IDX_Entity_Item_No ON [fShipped Qty NAV OG] (
	[Entity]
	,[Item No]
	) INCLUDE (
	[Shipped in Last 360 Days]
	,[Shipped in Last 180 Days]
	,[Shipped 331 to 360 Days Ago]
	,[Shipped 301 to 330 Days Ago]
	,[Shipped 271 to 300 Days Ago]
	,[Shipped 241 to 270 Days Ago]
	,[Shipped 211 to 240 Days Ago]
	,[Shipped 181 to 210 Days Ago]
	,[Shipped 151 to 180 Days Ago]
	,[Shipped 121 to 150 Days Ago]
	,[Shipped 91 to 120 Days Ago]
	,[Shipped 61 to 90 Days Ago]
	,[Shipped 31 to 60 Days Ago]
	,[Shipped 1 to 30 Days Ago]
	,[Shipped 30 Day Avg]
	,[Shipped 30 Day Avg 6M]
	);

CREATE NONCLUSTERED INDEX IDX_Entity ON [fShipped Qty NAV OG] ([Entity]) INCLUDE (
	[Item No]
	,[Shipped in Last 360 Days]
	,[Shipped in Last 180 Days]
	,[Shipped 331 to 360 Days Ago]
	,[Shipped 301 to 330 Days Ago]
	,[Shipped 271 to 300 Days Ago]
	,[Shipped 241 to 270 Days Ago]
	,[Shipped 211 to 240 Days Ago]
	,[Shipped 181 to 210 Days Ago]
	,[Shipped 151 to 180 Days Ago]
	,[Shipped 121 to 150 Days Ago]
	,[Shipped 91 to 120 Days Ago]
	,[Shipped 61 to 90 Days Ago]
	,[Shipped 31 to 60 Days Ago]
	,[Shipped 1 to 30 Days Ago]
	,[Shipped 30 Day Avg]
	,[Shipped 30 Day Avg 6M]
	);

CREATE NONCLUSTERED INDEX IDX_Item_No ON [fShipped Qty NAV OG] ([Item No]) INCLUDE (
	[Entity]
	,[Shipped in Last 360 Days]
	,[Shipped in Last 180 Days]
	,[Shipped 331 to 360 Days Ago]
	,[Shipped 301 to 330 Days Ago]
	,[Shipped 271 to 300 Days Ago]
	,[Shipped 241 to 270 Days Ago]
	,[Shipped 211 to 240 Days Ago]
	,[Shipped 181 to 210 Days Ago]
	,[Shipped 151 to 180 Days Ago]
	,[Shipped 121 to 150 Days Ago]
	,[Shipped 91 to 120 Days Ago]
	,[Shipped 61 to 90 Days Ago]
	,[Shipped 31 to 60 Days Ago]
	,[Shipped 1 to 30 Days Ago]
	,[Shipped 30 Day Avg]
	,[Shipped 30 Day Avg 6M]
	);

-- Composite index for core lookups and filters
CREATE NONCLUSTERED INDEX IX_fShippedQtyNAVOG_Entity_Item ON [fShipped Qty NAV OG] (
	[Entity]
	,[Item No]
	) INCLUDE (
	[Shipped in Last 360 Days]
	,[Shipped in Last 180 Days]
	,[Shipped 331 to 360 Days Ago]
	,[Shipped 301 to 330 Days Ago]
	,[Shipped 271 to 300 Days Ago]
	,[Shipped 241 to 270 Days Ago]
	,[Shipped 211 to 240 Days Ago]
	,[Shipped 181 to 210 Days Ago]
	,[Shipped 151 to 180 Days Ago]
	,[Shipped 121 to 150 Days Ago]
	,[Shipped 91 to 120 Days Ago]
	,[Shipped 61 to 90 Days Ago]
	,[Shipped 31 to 60 Days Ago]
	,[Shipped 1 to 30 Days Ago]
	,[Shipped 30 Day Avg]
	,[Shipped 30 Day Avg 6M]
	);

CREATE NONCLUSTERED INDEX IX_fShippedQtyNAVOG_Averages ON [fShipped Qty NAV OG] (
	[Shipped 30 Day Avg]
	,[Shipped 30 Day Avg 6M]
	) INCLUDE (
	[Entity]
	,[Item No]
	,[Shipped in Last 360 Days]
	,[Shipped in Last 180 Days]
	);

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

CREATE NONCLUSTERED INDEX IX_fRedwood_Item ON [fRedwood] ([Item No]) INCLUDE (
	[Barcode]
	,[Description]
	,[Qty Free]
	,[Qty Bonded]
	,[Outstanding on S/O]
	,[Qty Total Available for Orders]
	,[Qty Allocated on S/O]
	,[Qty Quarantine]
	,[Qty Total in Warehouse]
	,[Outstanding on P/O in Progress]
	,[Outstanding on P/O in Transit]
	,[Total Qty On P/O]
	,[Qty Projected]
	,[Qty Damaged]
	,[Qty to be Investigated]
	,[Quantity Quality Control]
	,[Quantity Rework]
	);

CREATE NONCLUSTERED INDEX IX_fRedwood_Barcode ON [fRedwood] ([Barcode]) INCLUDE ([Item No]);

CREATE NONCLUSTERED INDEX IX_fRedwood_Description ON [fRedwood] ([Description]) INCLUDE ([Item No]);

CREATE TABLE [dPreorder Lines] (
	[Row No] INT IDENTITY(1, 1) NOT NULL
	,[Preorder Code] NVARCHAR(70) NULL
	,[Region] NVARCHAR(10) NULL
	,[Brand Code] NVARCHAR(3) NULL
	,[Type] INTEGER NULL
	,[Season] NVARCHAR(20) NULL
	,[Item No] NVARCHAR(30) NULL
	,[Item Description] NVARCHAR(300) NULL
	,[Price String] NVARCHAR(30) NULL
	,[Currency] NVARCHAR(3) NULL
	,[WHS] DECIMAL(20, 8) NULL
	,[SRP] DECIMAL(20, 8) NULL
	);

CREATE NONCLUSTERED INDEX IX_dPreorderLines_Main ON [dPreorder Lines] (
	[Preorder Code]
	,[Region]
	,[Brand Code]
	,[Type]
	,[Season]
	,[Item No]
	) INCLUDE (
	[Row No]
	,[Item Description]
	,[Price String]
	,[Currency]
	,[WHS]
	,[SRP]
	);

CREATE NONCLUSTERED INDEX IX_dPreorderLines_ItemDesc ON [dPreorder Lines] ([Item Description]) INCLUDE ([Item No]);

CREATE NONCLUSTERED INDEX IX_dPreorderLines_Currency ON [dPreorder Lines] ([Currency]) INCLUDE (
	[WHS]
	,[SRP]
	);

CREATE TABLE [fPreorder] (
	[Preorder Code] NVARCHAR(70) NULL
	,[Season] NVARCHAR(20) NULL
	,[Type] INTEGER NULL
	,[Brand Code] NVARCHAR(3) NULL
	,[Category Code] NVARCHAR(50) NULL
	,[Item No] NVARCHAR(30) NULL
	,[Item Description] NVARCHAR(300) NULL
	,[Customer No] NVARCHAR(12) NULL
	,[Country Code] NVARCHAR(5) NULL
	,[Quantity] INTEGER NULL
	,[Value] DECIMAL(20, 8) NULL
	,[Currency] NVARCHAR(3) NULL
	,[Order Timestamp] DATETIME2(3) NULL
	,[Start Timestamp] DATETIME2(3) NULL
	,[End Timestamp] DATETIME2(3) NULL
	,[ETA Timestamp] DATETIME2(3) NULL
	);

CREATE NONCLUSTERED INDEX IX_fPreorder_Main ON [fPreorder] (
	[Preorder Code]
	,[Season]
	,[Type]
	,[Brand Code]
	,[Category Code]
	,[Item No]
	,[Customer No]
	,[Country Code]
	) INCLUDE (
	[Item Description]
	,[Quantity]
	,[Value]
	,[Currency]
	,[Order Timestamp]
	,[Start Timestamp]
	,[End Timestamp]
	,[ETA Timestamp]
	);

CREATE NONCLUSTERED INDEX IX_fPreorder_Timestamps ON [fPreorder] ([Order Timestamp]) INCLUDE (
	[Preorder Code]
	,[Season]
	,[Type]
	,[Brand Code]
	,[Category Code]
	,[Item No]
	,[Customer No]
	,[Quantity]
	,[Value]
	,[Currency]
	,[Start Timestamp]
	,[End Timestamp]
	,[ETA Timestamp]
	);

CREATE NONCLUSTERED INDEX IX_fPreorder_Quantity_Value ON [fPreorder] (
	[Quantity]
	,[Value]
	) INCLUDE (
	[Currency]
	,[Customer No]
	);

CREATE NONCLUSTERED INDEX IX_fPreorder_Item_Description ON [fPreorder] ([Item Description]) INCLUDE ([Item No]);

CREATE TABLE [fPreorder History] (
	[Preorder Code] NVARCHAR(70) NULL
	,[Season] NVARCHAR(20) NULL
	,[Type] INTEGER NULL
	,[Brand Code] NVARCHAR(3) NULL
	,[Category Code] NVARCHAR(50) NULL
	,[Item No] NVARCHAR(30) NULL
	,[Item Description] NVARCHAR(300) NULL
	,[Customer No] NVARCHAR(12) NULL
	,[Country Code] NVARCHAR(5) NULL
	,[Quantity] INTEGER NULL
	,[Value] DECIMAL(20, 8) NULL
	,[Currency] NVARCHAR(3) NULL
	,[Order Timestamp] DATETIME2(3) NULL
	,[Start Timestamp] DATETIME2(3) NULL
	,[End Timestamp] DATETIME2(3) NULL
	,[ETA Timestamp] DATETIME2(3) NULL
	);

CREATE NONCLUSTERED INDEX IX_fPreorderHistory_Main ON [fPreorder History] (
	[Preorder Code]
	,[Season]
	,[Type]
	,[Brand Code]
	,[Category Code]
	,[Item No]
	,[Customer No]
	,[Country Code]
	) INCLUDE (
	[Item Description]
	,[Quantity]
	,[Value]
	,[Currency]
	,[Order Timestamp]
	,[Start Timestamp]
	,[End Timestamp]
	,[ETA Timestamp]
	);

CREATE NONCLUSTERED INDEX IX_fPreorderHistory_Timestamps ON [fPreorder History] ([Order Timestamp]) INCLUDE (
	[Preorder Code]
	,[Season]
	,[Type]
	,[Brand Code]
	,[Category Code]
	,[Item No]
	,[Customer No]
	,[Country Code]
	,[Quantity]
	,[Value]
	,[Currency]
	,[Start Timestamp]
	,[End Timestamp]
	,[ETA Timestamp]
	);

CREATE NONCLUSTERED INDEX IX_fPreorderHistory_QtyValue ON [fPreorder History] (
	[Quantity]
	,[Value]
	) INCLUDE (
	[Preorder Code]
	,[Customer No]
	,[Currency]
	);

CREATE NONCLUSTERED INDEX IX_fPreorderHistory_Description ON [fPreorder History] ([Item Description]) INCLUDE ([Item No]);

CREATE TABLE [Increment Date] (
	[Entity] NVARCHAR(10) NOT NULL PRIMARY KEY
	,[Collect Date fSales] DATE NOT NULL
	,[Collect Date fGL Entry] DATE NOT NULL
	);

INSERT INTO [Increment Date] (
	[Entity]
	,[Collect Date fSales]
	,[Collect Date fGL Entry]
	)

VALUES (
	'Org Ltd'
	,'2022-04-30'
	,'2022-04-30'
	)
	,(
	'Org B.V'
	,'2022-04-30'
	,'2022-04-30'
	)
	,(
	'Org LLC'
	,'2022-04-30'
	,'2022-04-30'
	);

CREATE TABLE [fAdvert Spend] (
	[Date Key] AS CAST(CAST(YEAR([Date]) AS VARCHAR(4)) + RIGHT('0' + CAST(MONTH([Date]) AS VARCHAR(2)), 2) + RIGHT('0' + CAST(DAY([Date]) AS VARCHAR(2)), 2) AS INTEGER) 
	PERSISTED
	,[Date] DATE NOT NULL
	,[Ad Vendor] NVARCHAR(30) NOT NULL
	,[Property Id] BIGINT NOT NULL
	,[Property Name] NVARCHAR(200) NOT NULL
	,[Session Primary Channel Group] NVARCHAR(100) NOT NULL
	,[Currency] NVARCHAR(3) NOT NULL
	,[Ads Cost] DECIMAL(30, 15) NOT NULL
	,PRIMARY KEY (
		[Date]
		,[Property Id]
		,[Session Primary Channel Group]
		)
	,CONSTRAINT FK_fAdvert_Spend_to_dDate FOREIGN KEY ([Date Key]) REFERENCES [dDate]([Date Key])
	);

CREATE NONCLUSTERED INDEX IX_fAdvertSpend_Main ON [fAdvert Spend] (
	[Date]
	,[Property Id]
	,[Session Primary Channel Group]
	) INCLUDE (
	[Date Key]
	,[Ad Vendor]
	,[Property Name]
	,[Currency]
	,[Ads Cost]
	);

CREATE NONCLUSTERED INDEX IX_fAdvertSpend_Currency ON [fAdvert Spend] (
	[Currency]
	,[Date]
	) INCLUDE (
	[Property Id]
	,[Session Primary Channel Group]
	,[Ads Cost]
	);

CREATE NONCLUSTERED INDEX IX_fAdvertSpend_AdVendor ON [fAdvert Spend] (
	[Ad Vendor]
	,[Date]
	) INCLUDE (
	[Property Id]
	,[Session Primary Channel Group]
	,[Currency]
	,[Ads Cost]
	);

CREATE NONCLUSTERED INDEX IX_fAdvertSpend_PropertyName ON [fAdvert Spend] ([Property Name]) INCLUDE (
	[Property Id]
	,[Date]
	,[Currency]
	,[Ads Cost]
	);

CREATE TABLE [dWas Item Price] (
	[Item No] NVARCHAR(30) NOT NULL
	,[First Sold Date] DATE NOT NULL
	,[Period End Date] DATE NOT NULL
	,[Currency] NVARCHAR(3) NOT NULL
	,[Was Trade Price] DECIMAL(20, 8) NULL
	,PRIMARY KEY (
		[Item No]
		,[Currency]
		)
	,CONSTRAINT FK_dWas_Item_Price_to_dItem FOREIGN KEY ([Item No]) REFERENCES [dItem]([Item No])
	);

CREATE NONCLUSTERED INDEX IX_dWasItemPrice_DateRange_Currency ON [dWas Item Price] (
	[First Sold Date]
	,[Period End Date]
	,[Currency]
	) INCLUDE ([Was Trade Price]);

CREATE NONCLUSTERED INDEX IX_dWasItemPrice_Currency_Item ON [dWas Item Price] (
	[Currency]
	,[Item No]
	) INCLUDE (
	[First Sold Date]
	,[Period End Date]
	,[Was Trade Price]
	);

CREATE TABLE [fB2B Events] (
	[Customer No] NVARCHAR(30) NOT NULL
	,[Timestamp] DATETIME2(0) NOT NULL
	,[Event] NVARCHAR(50) NOT NULL
	,PRIMARY KEY (
		[Customer No]
		,[Timestamp]
		,[Event]
		)
	);

CREATE NONCLUSTERED INDEX IX_fB2BEvents_Timestamp_Event ON [fB2B Events] (
	[Timestamp]
	,[Event]
	) INCLUDE ([Customer No]);

CREATE NONCLUSTERED INDEX IX_fB2BEvents_Customer_Event ON [fB2B Events] (
	[Customer No]
	,[Event]
	) INCLUDE ([Timestamp]);

CREATE TABLE [dThumbnail] (
	[File Path] NVARCHAR(200) NOT NULL
	,[File Name] NVARCHAR(100) NOT NULL PRIMARY KEY
	,[Size (KB)] DECIMAL(10, 2) NULL
	,[Item No] NVARCHAR(30) NOT NULL
	,[Brand Code] NVARCHAR(3) NOT NULL
	,CONSTRAINT FK_dThumbnail_to_dItem FOREIGN KEY ([Item No]) REFERENCES [dItem]([Item No])
	,CONSTRAINT FK_dThumbnail_to_dBrand FOREIGN KEY ([Brand Code]) REFERENCES [dBrand]([Brand Code])
	);

CREATE NONCLUSTERED INDEX IX_dThumbnail_ItemBrand ON [dThumbnail] (
	[Item No]
	,[Brand Code]
	) INCLUDE (
	[File Name]
	,[File Path]
	,[Size (KB)]
	);

CREATE NONCLUSTERED INDEX IX_dThumbnail_FilePath ON [dThumbnail] ([File Path]) INCLUDE (
	[File Name]
	,[Item No]
	,[Brand Code]
	,[Size (KB)]
	);

CREATE TABLE [dThumbnail Process] (
	[Id] BIGINT IDENTITY(1, 1) NOT NULL PRIMARY KEY
	,[Item No] NVARCHAR(30) NOT NULL
	,[Old File Name] NVARCHAR(100) NULL
	,[New File Name] AS CASE 
		WHEN LEFT([Old File Name], LEN([Item No])) = [Item No]
			THEN CONCAT (
					LEFT([Old File Name], CHARINDEX('.', [Old File Name]) - 1)
					,'_THUMB'
					,RIGHT([Old File Name], (LEN([Old File Name]) - CHARINDEX('.', [Old File Name])) + 1)
					)
		ELSE CONCAT (
				[Item No]
				,'_THUMB'
				,RIGHT([Old File Name], (LEN([Old File Name]) - CHARINDEX('.', [Old File Name])) + 1)
				)
		END PERSISTED
	,CONSTRAINT FK_dThumbnail_Process_to_dItem FOREIGN KEY ([Item No]) REFERENCES [dItem]([Item No])
	)

CREATE NONCLUSTERED INDEX IX_dThumbnailProcess_Item_OldFile ON [dThumbnail Process] (
	[Item No]
	,[Old File Name]
	) INCLUDE ([New File Name]);

CREATE NONCLUSTERED INDEX IX_dThumbnailProcess_NewFileName ON [dThumbnail Process] ([New File Name]);

CREATE TABLE [Database Log] (
	[Id] BIGINT IDENTITY(1, 1) NOT NULL PRIMARY KEY
	,[Timestamp] DATETIME2(3) NOT NULL
	,[Level] NVARCHAR(10) NOT NULL
	,[File Name] NVARCHAR(270) NOT NULL
	,[Table] NVARCHAR(50) NOT NULL
	,[Action] NVARCHAR(500) NOT NULL
	,[Row Count] INTEGER NULL
	,[Start Date] DATE NULL
	,[End Date] DATE NULL
	,[Message] NVARCHAR(MAX) NULL
	);

CREATE NONCLUSTERED INDEX IX_DatabaseLog_Timestamp_Level ON [Database Log] (
	[Timestamp]
	,[Level]
	) INCLUDE (
	[File Name]
	,[Table]
	,[Action]
	,[Row Count]
	,[Start Date]
	,[End Date]
	,[Message]
	);

CREATE NONCLUSTERED INDEX IX_DatabaseLog_File_Table ON [Database Log] (
	[File Name]
	,[Table]
	) INCLUDE (
	[Timestamp]
	,[Level]
	,[Action]
	,[Row Count]
	,[Start Date]
	,[End Date]
	,[Message]
	);

CREATE NONCLUSTERED INDEX IX_DatabaseLog_Table ON [Database Log] ([Table]) INCLUDE (
	[Action]
	,[Timestamp]
	);