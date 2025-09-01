from SQL_Functions import execute_sql_procedure, get_sql_dataframe, write_df_to_sql_db
from db_logger import write_to_log
from sqlalchemy.types import NVARCHAR
from pandas import concat
import os


def main():

    script_name = os.path.basename(__file__)

    try:

        with open(
            "//WHServer/Users/leo.pickard/Desktop/Data-Warehouse/Update Scripts/T-SQL/dVendor sqlukeu Query.sql",
            "r",
        ) as file:
            sqlukeu_content = file.read()

        df_sqlukeu = get_sql_dataframe(
            server="sqlukeu",
            db="LIVE",
            table="dVendor",
            sql=sqlukeu_content,
            action="Executed sqlukeu dVendor Query",
            script=script_name,
        )

        with open(
            "//WHServer/Users/leo.pickard/Desktop/Data-Warehouse/Update Scripts/T-SQL/dVendor sqlus Query.sql",
            "r",
        ) as file:
            sqlus_content = file.read()

        df_sqlus = get_sql_dataframe(
            server="USServer",
            db="LIVE_USA",
            table="dVendor",
            sql=sqlus_content,
            action="Executed sqlus dCountry query.",
            script=script_name,
        )

        df_dVendor = concat([df_sqlukeu, df_sqlus], ignore_index=True)

        num_rows = len(df_dVendor)

        dtype_mapping = {
            "[Vendor No]": NVARCHAR(30),
            "[Name]": NVARCHAR(100),
            "[Address]": NVARCHAR(100),
            "[Address 2]": NVARCHAR(100),
            "[City]": NVARCHAR(50),
            "[County]": NVARCHAR(50),
            "[Post Code]": NVARCHAR(30),
            "[Country Code]": NVARCHAR(5),
            "[Contact]": NVARCHAR(50),
            "[Currency Code]": NVARCHAR(3),
            "[Payment Terms Code]": NVARCHAR(30),
            "[Purchaser Code]": NVARCHAR(30),
            "[Pay to Vendor No]": NVARCHAR(30),
            "[VAT Registration No]": NVARCHAR(50),
            "[E-Mail]": NVARCHAR(100),
            "[Home Page]": NVARCHAR(100),
            "[Contact No]": NVARCHAR(50),
        }

        execute_sql_procedure(
            server="WHServer",
            db="Warehouse",
            table="dVendor",
            sql="EXEC [Clear dVendor Table];",
            action="Execute truncate dVendor table.",
            script=script_name,
        )

        write_df_to_sql_db(
            server="WHServer",
            db="Warehouse",
            table="dVendor",
            df=df_dVendor,
            dtype=dtype_mapping,
            action="Write dataframe to dVendor table.",
            script=script_name,
            rows=num_rows,
        )

        print(f"{script_name} finished. Number of rows written: {num_rows}")

    except Exception as e:

        write_to_log(
            script_txt=script_name,
            table_txt="dVendor",
            action_txt="Execute script to update dVendor table. An error has occurred.",
            message_txt=f"An unexpected error occurred: {str(e)}",
            log_level="CRITICAL",
        )

        print(f"{script_name} has ran into a critical error during execution. See log file.")


if __name__ == "__main__":
    main()
