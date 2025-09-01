from SQL_Functions import (
    execute_sql_procedure,
    get_sql_dataframe,
    write_df_to_sql_db
)
from db_logger import write_to_log
from sqlalchemy.types import NVARCHAR, INTEGER, VARBINARY, DATETIME
import os

def main():
    
    script_name = os.path.basename(__file__)
    
    try:
        
        with open(
            "//WHServer/Users/leo.pickard/Desktop/Data-Warehouse/Update Scripts/T-SQL/dRecord Link squkeu Query.sql",
            "r",
        ) as file:
            sqlukeu_content = file.read()

        df_Record_Link = get_sql_dataframe(
            server = "UKEUServer",
            db = "LIVE",
            table = "dRecord Link",
            sql = sqlukeu_content,
            action = "Executed sqlukeu dRecord Link query.",
            script = script_name,
        )

        num_rows = len(df_Record_Link)

        dtype_mapping = {
	     "[Link ID]": INTEGER()
	    ,"[Record ID]": VARBINARY(224)
	    ,"[URL]": NVARCHAR(250)
	    ,"[Description]": NVARCHAR(250)
	    ,"[Created Timestamp]": DATETIME()
	    ,"[User ID]": NVARCHAR(50)
	    ,"[Entity]": NVARCHAR(10)
        }
        
        execute_sql_procedure(
            server = "WHServer",
            db = "Warehouse",
            table = "dRecord Link",
            sql = "EXEC [Clear dRecord Link Table]",
            action = "Execute truncate dCountry table.",
            script = script_name
        )
        
        write_df_to_sql_db(
            server = "WHServer",
            db = "Warehouse",
            table = "dRecord Link",
            df = df_Record_Link,
            dtype = dtype_mapping,
            action = "Write dataframe to dRecord Link table.",
            script = script_name,
            rows = num_rows
        )

        print(f"{script_name} finished. Number of rows written: {num_rows}")
        
    except Exception as e:
        
        write_to_log(
        script_txt = script_name,
        table_txt ="dRecord Link",
        action_txt = "Execute script to update dRecord Link table. An error has occurred.",
        message_txt = f"An unexpected error occurred: {str(e)}",
        log_level = "CRITICAL",   
        )
        
        print(f"{script_name} has ran into a critical error during execution. See log file.")

if __name__ == "__main__":
    main()