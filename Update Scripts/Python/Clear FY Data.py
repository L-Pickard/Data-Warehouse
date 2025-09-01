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
            sql = "EXEC [Clear FY Data];",
            action = "Execute stored procedure to clear FY data from fSales & GL Entry.",
            script = script_name
        )
        
        print(f"{script_name} finished. FY Data has been deleted from update log.")
        
    except Exception as e:
        
        write_to_log(
        script_txt = script_name,
        table_txt ="N/A",
        action_txt = "Execute script to delete FY data. An error has occurred.",
        message_txt = f"An unexpected error occurred: {str(e)}",
        log_level = "CRITICAL",   
        )
        
        print(f"{script_name} has ran into a critical error during execution. See log file.")
        
if __name__ == "__main__":
    main()