from SQL_Functions import execute_sql_procedure, get_sql_dataframe, write_df_to_sql_db
from db_logger import write_to_log
from sqlalchemy.types import NVARCHAR
from pandas import concat
import os


def main():

    script_name = os.path.basename(__file__)

    try:

        with open(
            "//WHServer/Users/leo.pickard/Desktop/Data-Warehouse/Update Scripts/T-SQL/dCustomer sqlukeu Query.sql",
            "r",
        ) as file:
            sqlukeu_content = file.read()

        df_sqlukeu = get_sql_dataframe(
            server="UKEUServer",
            db="LIVE",
            table="dCustomer",
            sql=sqlukeu_content,
            action="Executed sqlukeu dCustomer query.",
            script=script_name,
        )

        with open(
            "//WHServer/Users/leo.pickard/Desktop/Data-Warehouse/Update Scripts/T-SQL/dCustomer sqlus Query.sql",
            "r",
        ) as file:
            sqlus_content = file.read()

        df_sqlus = get_sql_dataframe(
            server="USServer",
            db="LIVE_USA",
            table="dCustomer",
            sql=sqlus_content,
            action="Executed sqlus dCustomer query.",
            script=script_name,
        )

        df_dCustomer = concat([df_sqlukeu, df_sqlus], ignore_index=True)

        num_rows = len(df_dCustomer)

        dtype_mapping = {
            "[Customer No]": NVARCHAR(12),
            "[Name]": NVARCHAR(200),
            "[Address]": NVARCHAR(200),
            "[Address 2]": NVARCHAR(200),
            "[City]": NVARCHAR(50),
            "[County]": NVARCHAR(50),
            "[Country Code]": NVARCHAR(5),
            "[Post Code]": NVARCHAR(30),
            "[Territory Code]": NVARCHAR(30),
            "[Contact]": NVARCHAR(100),
            "[Phone No]": NVARCHAR(50),
            "[Email]": NVARCHAR(100),
            "[Home Page]": NVARCHAR(100),
            "[Contact No]": NVARCHAR(100),
            "[Currency Code]": NVARCHAR(3),
            "[Type of Supply]": NVARCHAR(100),
            "[Salesperson Code]": NVARCHAR(50),
            "[VAT Reg No]": NVARCHAR(100),
        }

        execute_sql_procedure(
            server="WHServer",
            db="Warehouse",
            table="dCustomer",
            sql="EXEC [Clear dCustomer Table];",
            action="Execute truncate dCustomer table.",
            script=script_name,
        )

        write_df_to_sql_db(
            server="WHServer",
            db="Warehouse",
            table="dCustomer",
            df=df_dCustomer,
            dtype=dtype_mapping,
            action="Write dataframe to dCustomer table.",
            script=script_name,
            rows=num_rows,
        )

        print(f"{script_name} finished. Number of rows written: {num_rows}")

    except Exception as e:

        write_to_log(
            script_txt=script_name,
            table_txt="dCustomer",
            action_txt="Execute script to update dCustomer table. An error has occurred.",
            message_txt=f"An unexpected error occurred: {str(e)}",
            log_level="CRITICAL",
        )

        print(f"{script_name} has ran into a critical error during execution. See log file.")


if __name__ == "__main__":
    main()
