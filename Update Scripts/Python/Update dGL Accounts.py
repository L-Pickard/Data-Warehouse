from SQL_Functions import execute_sql_procedure, get_sql_dataframe, write_df_to_sql_db
from db_logger import write_to_log
from sqlalchemy.types import Integer, NVARCHAR, Boolean
from pandas import concat, read_excel, merge
import os


def main():

    script_name = os.path.basename(__file__)

    try:

        with open("//WHServer/Users/leo.pickard/Desktop/Data-Warehouse/Update Scripts/T-SQL/dGL Accounts sqlukeu Query.sql", "r") as file:
            sqlukeu_content = file.read()

        df_sqlukeu = get_sql_dataframe(
            server="UKEUServer",
            db="LIVE",
            table="dGL Accounts",
            sql=sqlukeu_content,
            action="Executed sqlukeu dGL Accounts query.",
            script=script_name,
        )

        with open("//WHServer/Users/leo.pickard/Desktop/Data-Warehouse/Update Scripts/T-SQL/dGL Accounts sqlus Query.sql", "r") as file:
            sqlus_content = file.read()

        df_sqlus = get_sql_dataframe(
            server="USServer",
            db="LIVE_USA",
            table="dGL Accounts",
            sql=sqlus_content,
            action="Executed sqlus dGL Accounts query.",
            script=script_name,
        )

        df_dGL_Accounts = concat([df_sqlukeu, df_sqlus], ignore_index=True)

        df_Classification = read_excel(
            "//WHServer/Users/leo.pickard/Desktop/Data-Warehouse/Update Scripts/Documents/dGL Classification.xlsx",
            sheet_name="Classification",
            engine="openpyxl",
            dtype={"GL Account No": str},
        )

        df_dGL_Accounts = merge(
            df_dGL_Accounts,
            df_Classification[["Entity", "GL Account No", "Classification", "Group", "Financial Statement"]],
            on=["Entity", "GL Account No"],
            how="left",
        )

        num_rows = len(df_dGL_Accounts)

        execute_sql_procedure(
            server="WHServer",
            db="Warehouse",
            table="dGL Accounts",
            sql="EXEC [Clear dGL Accounts Table];",
            action="Truncate dGL Accounts table.",
            script=script_name,
        )

        dtype_mapping = {
            "[Entity]": NVARCHAR(10),
            "[GL Account No]": Integer(),
            "[GL Account Name]": NVARCHAR(60),
            "[Account Type]": NVARCHAR(15),
            "[Blocked]": Boolean,
            "[Direct Posting]": Boolean,
            "[Start GL No]": Integer(),
            "[End GL No]": Integer(),
            "[Classification]": NVARCHAR(50),
            "[Group]": NVARCHAR(40),
            "[Financial Statement]": NVARCHAR(5),
        }

        write_df_to_sql_db(
            server="WHServer",
            db="Warehouse",
            table="dGL Accounts",
            df=df_dGL_Accounts,
            dtype=dtype_mapping,
            action="Write dataframe to dGL Accounts table.",
            script=script_name,
            rows=num_rows,
        )

        print(f"{script_name} finished. Number of rows written: {num_rows}")

    except Exception as e:

        write_to_log(
            script_txt=script_name,
            table_txt="dGL Accounts",
            action_txt="Execute script to update dGL Accounts table. An error has occurred.",
            message_txt=f"An unexpected error occurred: {str(e)}",
            log_level="CRITICAL",
        )

        print(f"{script_name} has ran into a critical error during execution. See log file.")


if __name__ == "__main__":
    main()
