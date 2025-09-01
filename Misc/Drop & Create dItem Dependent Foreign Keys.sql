USE [Finance]
GO

-- Drop Foreign Keys

ALTER TABLE [dbo].[fLedger] DROP CONSTRAINT [FK_fLedger_to_dItem]
GO

ALTER TABLE [dbo].[fShipped Qty] DROP CONSTRAINT [FK_fShipped_Qty_to_dItem]
GO

ALTER TABLE [dbo].[dImage] DROP CONSTRAINT [FK_dImage_to_dItem]
GO

ALTER TABLE [dbo].[fSales] DROP CONSTRAINT [FK_fSales_to_dItem]
GO


ALTER TABLE [dbo].[dInventory] DROP CONSTRAINT [FK_dInventory_to_dItem]
GO

ALTER TABLE [dbo].[fPurchases] DROP CONSTRAINT [FK_fPurchases_to_dItem]
GO


ALTER TABLE [dbo].[fOrderbook] DROP CONSTRAINT [FK_fOrderbook_to_dItem]
GO

--Drop Table

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dItem]') AND type in (N'U'))
DROP TABLE [dbo].[dItem]
GO

--Create Keys

ALTER TABLE [dbo].[fLedger]  WITH NOCHECK ADD  CONSTRAINT [FK_fLedger_to_dItem] FOREIGN KEY([Item No])
REFERENCES [dbo].[dItem] ([Item No])
GO

ALTER TABLE [dbo].[fLedger] CHECK CONSTRAINT [FK_fLedger_to_dItem]
GO

ALTER TABLE [dbo].[fShipped Qty]  WITH NOCHECK ADD  CONSTRAINT [FK_fShipped_Qty_to_dItem] FOREIGN KEY([Item No])
REFERENCES [dbo].[dItem] ([Item No])
GO

ALTER TABLE [dbo].[fShipped Qty] CHECK CONSTRAINT [FK_fShipped_Qty_to_dItem]
GO

ALTER TABLE [dbo].[dImage]  WITH NOCHECK ADD  CONSTRAINT [FK_dImage_to_dItem] FOREIGN KEY([Item No])
REFERENCES [dbo].[dItem] ([Item No])
GO

ALTER TABLE [dbo].[dImage] CHECK CONSTRAINT [FK_dImage_to_dItem]
GO

ALTER TABLE [dbo].[fSales]  WITH NOCHECK ADD  CONSTRAINT [FK_fSales_to_dItem] FOREIGN KEY([Item No])
REFERENCES [dbo].[dItem] ([Item No])
GO

ALTER TABLE [dbo].[fSales] CHECK CONSTRAINT [FK_fSales_to_dItem]
GO

ALTER TABLE [dbo].[dInventory]  WITH NOCHECK ADD  CONSTRAINT [FK_dInventory_to_dItem] FOREIGN KEY([Item No])
REFERENCES [dbo].[dItem] ([Item No])
GO

ALTER TABLE [dbo].[dInventory] CHECK CONSTRAINT [FK_dInventory_to_dItem]
GO

ALTER TABLE [dbo].[fPurchases]  WITH NOCHECK ADD  CONSTRAINT [FK_fPurchases_to_dItem] FOREIGN KEY([Item No])
REFERENCES [dbo].[dItem] ([Item No])
GO

ALTER TABLE [dbo].[fPurchases] CHECK CONSTRAINT [FK_fPurchases_to_dItem]
GO

ALTER TABLE [dbo].[fOrderbook]  WITH NOCHECK ADD  CONSTRAINT [FK_fOrderbook_to_dItem] FOREIGN KEY([Item No])
REFERENCES [dbo].[dItem] ([Item No])
GO

ALTER TABLE [dbo].[fOrderbook] CHECK CONSTRAINT [FK_fOrderbook_to_dItem]
GO