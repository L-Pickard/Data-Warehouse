from SQL_Functions import (
    execute_sql_procedure,
    get_sql_dataframe,
    write_df_to_sql_db
)
from db_logger import write_to_log
from sqlalchemy.types import INTEGER, NVARCHAR,  BOOLEAN
from pandas import concat, read_csv, merge
import os

def main():
    
    script_name = os.path.basename(__file__)
    
    try:

        with open(
            "//WHServer/Users/leo.pickard/Desktop/Data-Warehouse/Update Scripts/T-SQL/dCountry sqlukeu Query.sql",
            "r",
        ) as file:
            sqlukeu_content = file.read()

        df_sqlukeu = get_sql_dataframe(
            server = "UKEUServer",
            db = "LIVE",
            table = "dCountry",
            sql = sqlukeu_content,
            action = "Executed sqlukeu dCountry Query",
            script = script_name,
        )

        with open(
            "//WHServer/Users/leo.pickard/Desktop/Data-Warehouse/Update Scripts/T-SQL/dCountry sqlus Query.sql",
            "r",
        ) as file:
            sqlus_content = file.read()

        df_sqlus = get_sql_dataframe(
            server = "USServer",
            db = "LIVE_USA",
            table = "dCountry",
            sql = sqlus_content,
            action = "Executed sqlus dCountry Query",
            script = script_name,
        )

        df_llc_only = df_sqlus[~df_sqlus["Country Code"].isin(df_sqlukeu["Country Code"])]

        df_dCountry = concat([df_sqlukeu, df_llc_only], ignore_index=True)
        
        df_flags = read_csv("//WHServer/Users/leo.pickard/Desktop/Data-Warehouse/Documents/dCountry Images.csv")
        
        df_dCountry = merge(df_dCountry, df_flags, on="Country Code", how="left")
        
        num_rows = len(df_dCountry)

        dtype_mapping = {
            "[Country Code]": NVARCHAR(5),
            "[Country Name]": NVARCHAR(50),
            "[CI Required]": BOOLEAN(),
            "[Shp Time Days]": INTEGER(),
            "[D2C Customer]": NVARCHAR(12),
            "[Arbor Customer]": NVARCHAR(12),
            "[Feiyue Customer]": NVARCHAR(12),
            "[Flag URL]": NVARCHAR(40),
        }

        execute_sql_procedure(
            server = "WHServer",
            db = "Warehouse",
            table = "dCountry",
            sql = "EXEC [Clear dCountry Table];",
            action = "Exec Truncate dCountry Table",
            script = script_name
        )

        write_df_to_sql_db(
            server = "WHServer",
            db = "Warehouse",
            table = "dCountry",
            df = df_dCountry,
            dtype = dtype_mapping,
            action = "Write dataframe to dCountry",
            script = script_name,
            rows = num_rows
        )

        print(f"{script_name} finished. Number of rows written to dCountry: {num_rows}")
        
    except Exception as e:
        
        write_to_log(
        script_txt = script_name,
        table_txt ="dCustomer",
        action_txt = "Execute script to update dCustomer table. An error has occurred.",
        message_txt = f"An unexpected error occurred: {str(e)}",
        log_level = "CRITICAL",   
        )
        
        print(f"{script_name} has ran into a critical error during execution. See log file.")

if __name__ == "__main__":
    main()