from SQL_Functions import execute_sql_procedure
from db_logger import write_to_log
import os

def main():
    
    script_name = os.path.basename(__file__)
    
    try:
        
        execute_sql_procedure(
            server = "WHServer",
            db = "Warehouse",
            table = "N/A",
            sql = "EXEC [dbo].[Rebuild db Indexes] @FragmentationThreshold = 10.0;",
            action =  "Rebuild fragmented db indexes.",
            script = script_name
        )

        execute_sql_procedure(
            server = "WHServer",
            db = "Warehouse",
            table = "N/A",
            sql = "EXEC sp_updatestats;",
            action =  "Update db statistics",
            script = script_name
        )

        print(f"{script_name} finished. Fragmented indexes have been rebuilt and db statistics updated." )
        
    except Exception as e:
        
        write_to_log(
        script_txt = script_name,
        table_txt ="N/A",
        action_txt = "Execute script to rebuild fragmented indexes and db statistics. An error has occurred.",
        message_txt = f"An unexpected error occurred: {str(e)}",
        log_level = "CRITICAL",   
        )
        
        print(f"{script_name} has ran into a critical error during execution. See log file.")
        
if __name__ == "__main__":
    main()