from SQL_Functions import (
    execute_sql_procedure,
    get_sql_dataframe,
    write_df_to_sql_db
)
from db_logger import write_to_log
from sqlalchemy.types import NVARCHAR, DECIMAL, DATE, BOOLEAN, INTEGER
from pandas import concat
import os

def main():
    
    script_name = os.path.basename(__file__)
    
    try:

        with open(
                "//WHServer/Users/leo.pickard/Desktop/Data-Warehouse/Update Scripts/T-SQL/fOrderbook sqlukeu Query.sql",
                "r",
            ) as file:
                sqlukeu_content = file.read()

        df_sqlukeu = get_sql_dataframe(
            server = "UKEUServer",
            db = "LIVE",
            table = "fOrderbook",
            sql = sqlukeu_content,
            action = "Executed sqlukeu fOrderbook Query",
            script = script_name,
        )

        with open(
                "//WHServer/Users/leo.pickard/Desktop/Data-Warehouse/Update Scripts/T-SQL/fOrderbook sqlus Query.sql",
                "r",
            ) as file:
                sqlus_content = file.read()

        df_sqlus = get_sql_dataframe(
            server = "USServer",
            db = "LIVE_USA",
            table = "fOrderbook",
            sql = sqlus_content,
            action = "Executed sqlus fOrderbook query.",
            script = script_name,
        )

        df_Orderbook = concat([df_sqlukeu, df_sqlus], ignore_index=True)

        df_Orderbook[['Item No', 'Customer No']] = df_Orderbook[['Item No', 'Customer No']].fillna({'Item No': '', 'Customer No': ''})

        num_rows = len(df_Orderbook)

        execute_sql_procedure(
            server = "WHServer",
            db = "Warehouse",
            table = "fOrderbook",
            sql = "EXEC [Clear fOrderbook Table];",
            action = "Execute truncate fOrderbook table.",
            script = script_name
        )

        dtype_mapping = {
            "[Entity]": NVARCHAR(10),
            "[Document No]": NVARCHAR(18),
            "[Order Date]": DATE(),
            "[Shipment Date]": DATE(),
            "[Reporting Date]": DATE(),
            "[Location Code]": NVARCHAR(30),
            "[Customer No]": NVARCHAR(12),
            "[Customer Name]": NVARCHAR(100),
            "[Salesperson Code]": NVARCHAR(50),
            "[Shiner Ref]": NVARCHAR(150),
            "[Your Reference]": NVARCHAR(150),
            "[Country Code]": NVARCHAR(5),
            "[Item No]": NVARCHAR(16),
            "[Currency]": NVARCHAR(5),
            "[Quantity]": INTEGER(),
            "[Line Total]": DECIMAL(20, 8),
            "[Outstanding Qty]": INTEGER,
            "[Outstanding Value]": DECIMAL(20, 8),
            "[Item Ledger Qty]": INTEGER(),
            "[PO Qty]": INTEGER(),
            "[SKU Status]": NVARCHAR(30),
            "[Pre Order]": BOOLEAN(),
            "[Order Status]": NVARCHAR(15),
            "[Release Status]": NVARCHAR(20),
            "[Sys Status]": NVARCHAR(20),
            "[Overdue Status]": NVARCHAR(15),
        }

        write_df_to_sql_db(
            server = "WHServer",
            db = "Warehouse",
            table = "fOrderbook",
            df = df_Orderbook,
            dtype = dtype_mapping,
            action = "Write dataframe to fOrderbook table.",
            script = script_name,
            rows = num_rows
        )

        print(f"{script_name} finished. Number of rows written: {num_rows}")
        
    except Exception as e:
        
        write_to_log(
        script_txt = script_name,
        table_txt = "fOrderbook",
        action_txt = "Execute script to update fOrderbook table. An error has occurred.",
        message_txt = f"An unexpected error occurred: {str(e)}",
        log_level = "CRITICAL",   
        )
        
        print(f"{script_name} has ran into a critical error during execution. See log file.")

if __name__ == "__main__":
    main()