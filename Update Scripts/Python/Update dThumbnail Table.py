"""
======================================================================================================================
Project: dThumbnail Table
Language: Python
Author: Leo Pickard
Version: 1.0
Date: 06/02/2024
======================================================================================================================
This python script identifies full size images from item docs that are needed as thumbnail images and copies them to a
processing directory for the marketing department, each required item image is added to a processing table on WHServer
db. The processed images are collected and modified by adding json product data to them, these images are then moved
to the master thumbnail document library. This code loops through the master document libary and reads the product
data from the images and writes the data to the dThumbnail table. Finally an email is sent to marketing dept telling
them about the new required images that need processing, it is accompanied by an excel attachment.
======================================================================================================================
"""

from SQL_Functions import get_sql_dataframe, write_df_to_sql_db, execute_sql_procedure
from db_logger import write_to_log
from sqlalchemy.types import NVARCHAR, DECIMAL
from shutil import copyfile
from datetime import datetime
from msal import ConfidentialClientApplication
from jinja2 import Template
from json import load, dumps, loads
from requests import post
from base64 import b64encode
from pathlib import Path
from pyexiv2 import Image
from pandas import DataFrame, concat

script_name = Path(__file__).name


def process_staging_images(
    staging_path: Path,
    library_path: Path,
    query_path: Path,
) -> None:

    name_script = script_name

    with open(
        query_path,
        "r",
    ) as file:
        requested_content = file.read()

    df_requested = get_sql_dataframe(
        server="WHServer",
        db="Warehouse",
        table="dThumbnail Process",
        sql=requested_content,
        action="Executed query to return requested images.",
        script=name_script,
    )

    delete_items = []

    for index, row in df_requested.iterrows():

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

        file_name = row["Old File Name"]

        new_file_name = row["New File Name"]

        file_path = staging_path.joinpath(file_name)

        new_file_path = library_path.joinpath(new_file_name)

        try:

            if file_path.exists() and not new_file_path.exists():

                copyfile(file_path, new_file_path)

                delete_items.append(item_no)

                file_path.unlink()

                with Image(new_file_path) as img:
                    img.modify_comment(dumps(item_data))

            elif file_path.exists() and new_file_path.exists():

                delete_items.append(item_no)

                file_path.unlink()

        except Exception as e:

            write_to_log(
                script_txt=name_script,
                table_txt="dThumbnail",
                action_txt=f"Copy image from staging to thumbnail library.",
                message_txt=f"Failed to copy {file_name}. Error: {str(e)}",
                log_level="ERROR",
            )

    # The below code deletes the records in the [dThumbnail Processing] table which have been copied to the thumbnail library folder.

    if len(delete_items) > 0:

        delete_items_sql = ", ".join(f"'{item}'" for item in delete_items)

        delete_items_log = ", ".join(f"{item}" for item in delete_items)

        execute_sql_procedure(
            server="WHServer",
            db="Warehouse",
            table="dThumbnail Process",
            sql=f"DELETE FROM [dThumbnail Process] WHERE [Item No] IN ({delete_items_sql});",
            action=f"Delete processed image rows from [dThumbnail Process]. Items: ({delete_items_log})",
            script=name_script,
        )


# The below function clears the [dThumbnail] table of data and writes the new data back to the table.


def update_thumbnail_table(library_path: str) -> None:

    name_script = script_name

    execute_sql_procedure(
        server="WHServer",
        db="Warehouse",
        table="dThumbnail",
        sql=f"TRUNCATE TABLE [dThumbnail];",
        action="Delete all data from the dThumbnail table so it is ready for new data.",
        script=name_script,
    )

    columns = [
        "File Path",
        "File Name",
        "Size (KB)",
        "Item No",
        "Brand Code",
    ]

    df_dThumbnail = DataFrame(columns=columns)

    rows = []

    for file in library_path.iterdir():

        if file.name == "Thumbs.db":
            continue

        try:

            file_size_kb = round(file.stat().st_size / 1024, 2)

            item_no = str(file.name)

            item_no = item_no[:-10]

            brand_code = item_no[:3]

            row_data = {
                "File Path": str(file),
                "File Name": str(file.name),
                "Size (KB)": file_size_kb,
                "Item No": item_no,
                "Brand Code": brand_code,
            }

            rows.append(row_data)

        except Exception as e:

            write_to_log(
                script_txt=name_script,
                table_txt="dThumbnail",
                action_txt=f"Reading json item data from: {file}",
                message_txt=f"An error occurred reading the json data from: {file} Error: {str(e)}",
                log_level="ERROR",
            )

        continue

    df_dThumbnail = concat([df_dThumbnail, DataFrame(rows)], ignore_index=True)

    df_item_table = get_sql_dataframe(
        server="WHServer",
        db="Warehouse",
        table="dThumbnail Process",
        sql="SELECT [Item No] FROM [dItem];",
        action="Executed query to return item codes.",
        script=name_script,
    )

    df_dThumbnail = df_dThumbnail[df_dThumbnail["Item No"].isin(df_item_table["Item No"])]

    num_rows = len(df_dThumbnail)

    dtype_mapping = {
        "[File Path]": NVARCHAR(200),
        "[File Name]": NVARCHAR(100),
        "[Size (KB)]": DECIMAL(10, 2),
        "[Item No]": NVARCHAR(30),
        "[Brand Code]": NVARCHAR(3),
    }

    write_df_to_sql_db(
        server="WH Server",
        db="Warehouse",
        table="dThumbnail",
        df=df_dThumbnail,
        dtype=dtype_mapping,
        action="Write dataframe to dThumbnail table.",
        script=name_script,
        rows=num_rows,
    )


# The below function identifies images that are required to be processed in to thumbnails and moves them into the process folder.
# The function finally returns a pandas dataframe to be used later on in the script.


def prepare_required_image(query_path: str, process_dir: Path) -> DataFrame:

    name_script = script_name

    with open(
        query_path,
        "r",
    ) as file:
        thumbnail_content = file.read()

    df_required = get_sql_dataframe(
        server="WHServer",
        db="Warehouse",
        table="dThumbnail",
        sql=thumbnail_content,
        action="Executed required thumbnail query.",
        script=name_script,
    )

    df_required["Image Path"] = df_required["Image Path"].str.replace("\\", "/", regex=False)

    failed_indices = []

    for index, row in df_required.iterrows():

        file_path = row["Image Path"]
        file_name = row["Old File Name"]

        destination_path = process_dir.joinpath(file_name)

        if destination_path.exists():

            continue

        try:

            copyfile(file_path, destination_path)

        except Exception as e:

            write_to_log(
                script_txt=name_script,
                table_txt="dThumbnail",
                action_txt=f"Copy image from item docs to: {process_dir}",
                message_txt=f"Failed to copy {file_name}. Error: {str(e)}",
                log_level="ERROR",
            )

            failed_indices.append(index)

        continue

    df_required = df_required.drop(index=failed_indices).reset_index(drop=True)

    df_requested = get_sql_dataframe(
        server="WHServer",
        db="Warehouse",
        table="dThumbnail Process",
        sql="SELECT [Item No] FROM [dThumbnail Process]",
        action="Executed query to return requested images.",
        script=name_script,
    )

    df_new_requests = df_required[["Item No", "Old File Name"]]

    df_new_requests = df_new_requests[~df_new_requests["Item No"].isin(df_requested["Item No"])]

    dtype_mapping = {
        "[Item No]": NVARCHAR(30),
        "[Old File Name]": NVARCHAR(100),
    }

    num_rows = len(df_new_requests)

    write_df_to_sql_db(
        server="WHServer",
        db="Warehouse",
        table="dThumbnail Process",
        df=df_new_requests,
        dtype=dtype_mapping,
        action="Insert new rows to dThumbnail process",
        script=name_script,
        rows=num_rows,
    )

    return df_required


# The below function is used to generate a token to be used with the microsoft graph api.


def acquire_token(tennant_id: str, authority_url: str, application_id: str, client_secret: str) -> dict:

    authority_url = f"https://login.microsoftonline.com/{tennant_id}"
    app = ConfidentialClientApplication(
        authority=authority_url,
        client_id=application_id,
        client_credential=client_secret,
    )
    token = app.acquire_token_for_client(scopes=["https://graph.microsoft.com/.default"])
    return token


# The below function sends a notifcation email with a xlsx attachment via the microsoft graph api.


def send_notification_email(
    config_path: Path,
    save_path: Path,
    html_template_path: Path,
    recipients: list,
    df_required: DataFrame,
) -> None:

    name_script = script_name

    now_str = datetime.now().strftime("%d.%m.%Y %H.%M.%S")

    excel_name = f"Thumbnail Process Request {now_str}.xlsx"

    excel_path = save_path.joinpath(excel_name)

    df_required.to_excel(excel_writer=excel_path, sheet_name=now_str, index=False)

    cols = [
        "Item No",
        "Brand Code",
        "Description",
        "Description 2",
        "Colours",
        "Size 1",
        "Size 1 Unit",
        "Season",
        "Image Path",
    ]

    dict = df_required[cols].to_dict(orient="records")

    with open(
        html_template_path,
        "r",
        encoding="utf-8",
    ) as file:
        template_content = file.read()

    current_time = datetime.now().strftime("%d/%m/%Y %H:%M:%S")

    template = Template(template_content)
    email_body = template.render(items=dict, timestamp=current_time)

    email_subject = f"Thumbnail Images Required {current_time}"

    with open(config_path) as config_file:
        config = load(config_file)
        tennant_id = config["tennant_id"]
        authority_url = config["authority_url"]
        application_id = config["application_id"]
        client_secret = config["client_secret"]

    result = acquire_token(
        tennant_id=tennant_id,
        authority_url=authority_url,
        application_id=application_id,
        client_secret=client_secret,
    )

    with open(excel_path, "rb") as attachment_file:
        attachment_content = b64encode(attachment_file.read()).decode("utf-8")

    if "access_token" in result:
        endpoint = f"https://graph.microsoft.com/v1.0/users/reports@shiner.co.uk/sendMail"

        email_msg = {
            "Message": {
                "Subject": email_subject,
                "Body": {"ContentType": "HTML", "Content": email_body},
                "ToRecipients": [{"EmailAddress": {"Address": email}} for email in recipients],
                "Attachments": [
                    {
                        "@odata.type": "#microsoft.graph.fileAttachment",
                        "Name": excel_name,
                        "ContentType": "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
                        "ContentBytes": attachment_content,
                    }
                ],
            },
            "SaveToSentItems": "true",
        }

        r = post(
            endpoint,
            headers={"Authorization": "Bearer " + result["access_token"]},
            json=email_msg,
        )
        if r.ok:

            write_to_log(
                script_txt=name_script,
                table_txt="dThumbnail",
                action_txt="Send email to marketing for images required to be processed.",
                message_txt=f"Email sucessfully sent.",
                log_level="INFO",
            )

        else:

            write_to_log(
                script_txt=name_script,
                table_txt="dThumbnail",
                action_txt="Send email to marketing for images required to be processed.",
                message_txt=f"{str(r.json())}",
                log_level="ERROR",
            )


def main():

    name_script = script_name

    try:

        path_staging = Path("//Orgnas01/OrgData/MARKETING/001 Image Processing/012 Master Thumbnail Imagery/Thumbnail Staging")

        path_library = Path("//Orgnas01/OrgData/MARKETING/001 Master Thumbnail Images")

        process_query = Path("//WHServer/Users/leo.pickard/Desktop/Data-Warehouse/Update Scripts/T-SQL/dThumbnail Requested Images Query.sql")

        process_staging_images(
            staging_path=path_staging,
            library_path=path_library,
            query_path=process_query,
        )

        update_thumbnail_table(library_path=path_library)

        path_process = Path("//Orgnas01/OrgData/MARKETING/001 Image Processing/012 Master Thumbnail Imagery/Images to Process")

        prepare_query = Path("//WHServer/Users/leo.pickard/Desktop/Finance db/dThumbnail Required Images Query.sql")

        df = prepare_required_image(query_path=prepare_query, process_dir=path_process)

        path_config = Path("//WHServer/Users/leo.pickard/Desktop/Data-Warehouse/config.json")

        path_save = Path("//WHServer/Users/leo.pickard/Desktop/Data-Warehouse/DocumentsThumbnail Requests")

        html_template = Path("//WHServer/Users/leo.pickard/Desktop/Data-Warehouse/Update Scripts/T-SQL//HTML/email_template.html")

        email_recipients = ["**************************", "**************************"]

        send_notification_email(
            config_path=path_config,
            save_path=path_save,
            html_template_path=html_template,
            recipients=email_recipients,
            df_required=df,
        )

    except Exception as e:

        write_to_log(
            script_txt=name_script,
            table_txt="dThumbnail",
            action_txt="Execute script to update dThumbnail table. An error has occurred.",
            message_txt=f"An unexpected error occurred: {str(e)}",
            log_level="CRITICAL",
        )

        print(f"{name_script} has ran into a critical error during execution. See log file.")


if __name__ == "__main__":
    main()
