from SQL_Functions import execute_sql_procedure, get_sql_dataframe, write_df_to_sql_db
from db_logger import write_to_log
from sqlalchemy.types import NVARCHAR, INTEGER
from pandas import concat
import os


def main():

    script_name = os.path.basename(__file__)

    try:

        with open(
            "//WHServer/Users/leo.pickard/Desktop/Data-Warehouse/Update Scripts/T-SQL/dInventory sqlukeu Query.sql",
            "r",
        ) as file:
            sqlukeu_content = file.read()

        df_sqlukeu = get_sql_dataframe(
            server="UKEUServer",
            db="LIVE",
            table="dInventory",
            sql=sqlukeu_content,
            action="Executed sqlukeu dInventory query.",
            script=script_name,
        )

        with open(
            "//WHServer/Users/leo.pickard/Desktop/Data-Warehouse/Update Scripts/T-SQL/dInventory sqlus Query.sql",
            "r",
        ) as file:
            sqlus_content = file.read()

        df_sqlus = get_sql_dataframe(
            server="USServer",
            db="LIVE_USA",
            table="dInventory",
            sql=sqlus_content,
            action="Executed sqlus dInventory query.",
            script=script_name,
        )

        df_dInventory = concat([df_sqlukeu, df_sqlus], ignore_index=True)

        num_rows = len(df_dInventory)

        dtype_mapping = {
            "[Entity]": NVARCHAR(10),
            "[Item No]": NVARCHAR(30),
            "[Free Stock]": INTEGER(),
            "[Inventory]": INTEGER(),
        }

        execute_sql_procedure(
            server="WHServer",
            db="Warehouse",
            table="dInventory",
            sql="EXEC [Clear dInventory Table];",
            action="Execute truncate dInventory table.",
            script=script_name,
        )

        write_df_to_sql_db(
            server="WHServer",
            db="Warehouse",
            table="dInventory",
            df=df_dInventory,
            dtype=dtype_mapping,
            action="Write dataframe to dInventory.",
            script=script_name,
            rows=num_rows,
        )

        print(f"{script_name} finished. Number of rows written: {num_rows}")

    except Exception as e:

        write_to_log(
            script_txt=script_name,
            table_txt="dInventory",
            action_txt="Execute script to update dInventory table. An error has occurred.",
            message_txt=f"An unexpected error occurred: {str(e)}",
            log_level="CRITICAL",
        )

        print(f"{script_name} has ran into a critical error during execution. See log file.")


if __name__ == "__main__":
    main()
