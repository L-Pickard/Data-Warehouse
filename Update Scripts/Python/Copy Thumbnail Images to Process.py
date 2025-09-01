from SQL_Functions import get_sql_dataframe
from db_logger import write_to_log
import os
from shutil import copyfile
import json
import pyexiv2


def main():

    script_name = os.path.basename(__file__)

    try:

        with open(
            "//WHServer/Users/leo.pickard/Desktop/Data-Warehouse/Update Scripts/T-SQL/dThumbnail Image Data Query.sql",
            "r",
        ) as file:
            thumbnail_content = file.read()

        df_thumbnail = get_sql_dataframe(
            server="WHServer",
            db="Warehouse",
            table="dThumbnail",
            sql=thumbnail_content,
            action="Executed thumbnail image query.",
            script=script_name,
        )

        num_rows = len(df_thumbnail)

        destination_folder = "Z:/MARKETING/001 Image Processing/012 Master Thumbnail Imagery/001 Master Images"

        for index, row in df_thumbnail.iterrows():

            file_path = row["Image Path"]

            item_no = row["Item No"]
            common_item_no = row["Common Item No"]
            vendor_ref = row["Vendor Reference"]
            brand_code = row["Brand Code"]
            description = row["Description"]
            description_2 = row["Description 2"]
            colours = row["Colours"]
            size_1 = row["Size 1"]
            size_1_unit = row["Size 1 Unit"]
            uom = row["UOM"]
            season = row["Season"]
            category = row["Category Code"]
            group = row["Group Code"]
            ean = row["EAN Barcode"]
            tariff = row["Tariff No"]
            coo = row["COO"]

            item_data = {
                "Item No": item_no,
                "Common Item No": common_item_no,
                "Vendor Reference": vendor_ref,
                "Brand Code": brand_code,
                "Description": description,
                "Description 2": description_2,
                "Colours": colours,
                "Size 1": size_1,
                "Size 1 Unit": size_1_unit,
                "Unit of Measure": uom,
                "Season": season,
                "Category": category,
                "Group": group,
                "EAN": ean,
                "Tariff No": tariff,
                "COO": coo,
            }

            try:

                file_name = os.path.basename(file_path)
                destination_file_path = os.path.join(destination_folder, file_name)
                copyfile(file_path, destination_file_path)

                with pyexiv2.Image(destination_file_path) as img:
                    img.modify_comment(json.dumps(item_data))

            except Exception as e:

                write_to_log(
                    script_txt=script_name,
                    table_txt="dThumbnail",
                    action_txt="Copy thumbnail file to Shiner data.",
                    message_txt=f"Failed to copy {file_path} to {destination_folder}. Error: {str(e)}",
                    log_level="ERROR",
                )

                continue

        print(
            f"{script_name} finished. Number of thumbnail images moved and updated: {num_rows}"
        )

    except Exception as e:

        write_to_log(
            script_txt=script_name,
            table_txt="dThumbnail",
            action_txt="Execute script to update / move dThumbnail Images.",
            message_txt=f"An unexpected error occurred: {str(e)}",
            log_level="CRITICAL",
        )

        print(
            f"{script_name} has ran into a critical error during execution. See log file."
        )


if __name__ == "__main__":
    main()