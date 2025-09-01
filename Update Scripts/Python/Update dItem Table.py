from SQL_Functions import execute_sql_procedure, get_sql_dataframe, write_df_to_sql_db
from db_logger import write_to_log
from sqlalchemy.types import INTEGER, NVARCHAR, DECIMAL, BOOLEAN, VARBINARY
from pandas import merge, concat, NA
import os


def main():

    script_name = os.path.basename(__file__)

    try:

        with open(
            "//WHServer/Users/leo.pickard/Desktop/Data-Warehouse/Update Scripts/T-SQL/dItem sqlukeu Query.sql",
            "r",
        ) as file:
            sqlukeu_content = file.read()

        df_sqlukeu = get_sql_dataframe(
            server="UKEUServer",
            db="LIVE",
            table="dItem",
            sql=sqlukeu_content,
            action="Executed sqlukeu dItem query.",
            script=script_name,
        )

        with open(
            "//WHServer/Users/leo.pickard/Desktop/Data-Warehouse/Update Scripts/T-SQL/dItem sqlus Query.sql",
            "r",
        ) as file:
            sqlus_content = file.read()

        df_sqlus = get_sql_dataframe(
            server="USServer",
            db="LIVE_USA",
            table="dItem",
            sql=sqlus_content,
            action="Executed sqlus dItem query.",
            script=script_name,
        )

        df_sqlus_join = df_sqlus[
            [
                "Item No",
                "HTS No",
                "BC Vendor No",
                "LLC Blocked",
                "LLC Buffer Stock",
                "LLC USD Unit Cost",
            ]
        ]

        df_dItem = merge(df_sqlukeu, df_sqlus_join, on="Item No", how="left")

        column_order = [
            "Item No",
            "Vendor Reference",
            "Brand Code",
            "Description",
            "Description 2",
            "Colours",
            "Size 1",
            "Size 1 Unit",
            "EU Size",
            "EU Size Unit",
            "US Size",
            "US Size Unit",
            "Season",
            "Item Info",
            "Category",
            "Category Code",
            "Group",
            "Group Code",
            "EAN Barcode",
            "Tariff No",
            "HTS No",
            "Style Ref",
            "GBP Trade",
            "GBP SRP",
            "EUR Trade",
            "EUR SRP",
            "USD Trade",
            "USD SRP",
            "Nav Vendor No",
            "BC Vendor No",
            "Vendor Name",
            "Ltd Blocked",
            "B.V Blocked",
            "LLC Blocked",
            "On Sale",
            "COO",
            "UOM",
            "Hot Product",
            "Lead Time",
            "Bread & Butter",
            "Ltd Buffer Stock",
            "B.V Buffer Stock",
            "LLC Buffer Stock",
            "Ltd GBP Unit Cost",
            "B.V EUR Unit Cost",
            "LLC USD Unit Cost",
            "Common Item No",
            "D2C Master SKU",
            "D2C Web Item",
            "Owtanet Export",
            "Web Item",
            "Record ID",
        ]

        df_dItem = df_dItem[column_order]

        df_llc_only = df_sqlus[~df_sqlus["Item No"].isin(df_dItem["Item No"])]

        df_dItem = concat([df_dItem, df_llc_only], ignore_index=True)

        df_dItem[["LLC Blocked", "LLC Buffer Stock", "LLC USD Unit Cost"]] = df_dItem[
            ["LLC Blocked", "LLC Buffer Stock", "LLC USD Unit Cost"]
        ].fillna(0)

        num_rows = len(df_dItem)

        dtype_mapping = {
            "[Item No]": NVARCHAR(16),
            "[Vendor Reference]": NVARCHAR(30),
            "[Brand Code]": NVARCHAR(3),
            "[Description]": NVARCHAR(100),
            "[Description 2]": NVARCHAR(100),
            "[Colours]": NVARCHAR(100),
            "[Size 1]": NVARCHAR(15),
            "[Size 1 Unit]": NVARCHAR(20),
            "[EU Size]": NVARCHAR(15),
            "[EU Size Unit]": NVARCHAR(20),
            "[US Size]": NVARCHAR(15),
            "[US Size Unit]": NVARCHAR(20),
            "[Season]": NVARCHAR(4),
            "[Item Info]": NVARCHAR(30),
            "[Category]": NVARCHAR(30),
            "[Category Code]": NVARCHAR(10),
            "[Group]": NVARCHAR(30),
            "[Group Code]": NVARCHAR(15),
            "[EAN Barcode]": NVARCHAR(30),
            "[Tariff No]": NVARCHAR(20),
            "[HTS No]": NVARCHAR(20),
            "[Style Ref]": NVARCHAR(300),
            "[GBP Trade]": DECIMAL(20, 8),
            "[GBP SRP]": DECIMAL(20, 8),
            "[EUR Trade]": DECIMAL(20, 8),
            "[EUR SRP]": DECIMAL(20, 8),
            "[USD Trade]": DECIMAL(20, 8),
            "[USD SRP]": DECIMAL(20, 8),
            "[Nav Vendor No]": NVARCHAR(30),
            "[BC Vendor No]": NVARCHAR(30),
            "[Vendor Name]": NVARCHAR(50),
            "[Ltd Blocked]": BOOLEAN,
            "[B.V Blocked]": BOOLEAN,
            "[LLC Blocked]": BOOLEAN,
            "[On Sale]": BOOLEAN,
            "[COO]": NVARCHAR(5),
            "[UOM]": NVARCHAR(30),
            "[Hot Product]": BOOLEAN,
            "[Lead Time]": NVARCHAR(30),
            "[Bread & Butter]": BOOLEAN,
            "[Ltd Buffer Stock]": INTEGER,
            "[B.V Buffer Stock]": INTEGER,
            "[LLC Buffer Stock]": INTEGER,
            "[Ltd GBP Unit Cost]": DECIMAL(20, 8),
            "[B.V EUR Unit Cost]": DECIMAL(20, 8),
            "[LLC USD Unit Cost]": DECIMAL(20, 8),
            "[Common Item No]": NVARCHAR(16),
            "[D2C Master SKU]": NVARCHAR(30),
            "[D2C Web Item]": BOOLEAN,
            "[Owtanet Export]": BOOLEAN,
            "[Web Item]": BOOLEAN,
            "[Record ID]": VARBINARY(224),
        }

        execute_sql_procedure(
            server="WHServer",
            db="Warehouse",
            table="dItem",
            sql="EXEC [Clear dItem Table];",
            action="Execute truncate dItem table.",
            script=script_name,
        )

        write_df_to_sql_db(
            server="WHServer",
            db="Warehouse",
            table="dItem",
            df=df_dItem,
            dtype=dtype_mapping,
            action="Write dataframe to dItem.",
            script=script_name,
            rows=num_rows,
        )

        print(f"{script_name} finished. Number of rows written: {num_rows}")

    except Exception as e:

        write_to_log(
            script_txt=script_name,
            table_txt="dItem",
            action_txt="Execute script to update dItem table. An error has occurred.",
            message_txt=f"An unexpected error occurred: {str(e)}",
            log_level="CRITICAL",
        )

        print(f"{script_name} has ran into a critical error during execution. See log file.")


if __name__ == "__main__":
    main()
