from SQL_Functions import (
    get_sql_dataframe,
    execute_sql_procedure,
    write_df_to_sql_db,
)
from db_logger import write_to_log
from shutil import copyfile
import os
from selenium import webdriver
from selenium.webdriver.chrome.service import Service
from selenium.webdriver.chrome.options import Options
from webdriver_manager.chrome import ChromeDriverManager
from selenium.webdriver.common.by import By
import msal
from time import sleep
import json
from re import search, sub
import requests
from pandas import to_datetime, DataFrame, to_numeric, merge
from sqlalchemy.types import INTEGER, NVARCHAR, DATETIME, BIGINT

name_script = os.path.basename(__file__)


def upload_file(
    file_path: str, file_name: str, drive_id: str, access_token_id: str
) -> None:

    script_name = name_script

    url = f"https://graph.microsoft.com/v1.0/drives/{drive_id}/root:/{file_name}:/content"

    headers = {
        "Authorization": f"Bearer {access_token_id}",
        "Content-Type": "application/octet-stream",
    }

    try:
        with open(file_path, "rb") as file_data:
            response = requests.put(url, headers=headers, data=file_data)

        if response.status_code == 200:  # HTTP 200 == Edited

            write_to_log(
                script_txt=script_name,
                table_txt="dImage",
                action_txt=f"Upload {file_name} to SharePoint document library.",
                message_txt=f"This file has not been newly created as it already exists in the document library. Instead it has been updated/edited.",
                log_level="WARNING",
            )

        elif response.status_code == 201:  # HTTP 201 == Created

            write_to_log(
                script_txt=script_name,
                table_txt="dImage",
                action_txt=f"Upload {file_name} to SharePoint document library.",
                message_txt=f"This file has been sucessfully uploaded to the document library.",
                log_level="INFO",
            )

        else:

            write_to_log(
                script_txt=script_name,
                table_txt="dImage",
                action_txt=f"Upload {file_name} to SharePoint document library.",
                message_txt=f"An error has occurred while uploading this file to the document library. The status code from the response is: {response.status_code}. Response text: {response.text}",
                log_level="ERROR",
            )

    except Exception as e:

        write_to_log(
            script_txt=script_name,
            table_txt="dImage",
            action_txt=f"Upload {file_name} to SharePoint document library.",
            message_txt=f"An exception has occurred while uploading this file to the document library. See the error text: {str(e)}",
            log_level="ERROR",
        )


def upload_all_files_in_folder(
    local_folder: str, drive_id: str, access_token_id: str
) -> None:

    files = os.listdir(local_folder)
    for file_name in files:
        file_path = os.path.join(local_folder, file_name)
        if os.path.isfile(file_path):
            try:
                upload_file(file_path, file_name, drive_id, access_token_id)
            except Exception:
                continue


def fetch_all_files(drive_id: str, access_token_id: str) -> json:

    script_name = name_script

    url = f"https://graph.microsoft.com/v1.0/drives/{drive_id}/root/children"
    headers = {"Authorization": "Bearer " + access_token_id}
    all_files = []

    try:
        # Log the start of the fetching process
        write_to_log(
            script_txt=script_name,
            table_txt="dImage",
            action_txt="Fetch all files from SharePoint document library.",
            message_txt=f"Starting to fetch files from drive {drive_id}.",
            log_level="INFO",
        )

        while url:
            response = requests.get(url, headers=headers)

            if response.status_code == 200:
                try:
                    data = response.json()
                    all_files.extend(data.get("value", []))
                    url = data.get("@odata.nextLink")  # Get the next link
                except ValueError as e:
                    # Log JSON decoding errors
                    write_to_log(
                        script_txt=script_name,
                        table_txt="dImage",
                        action_txt="Fetch all files from SharePoint document library.",
                        message_txt=f"Failed to decode JSON response. Error: {str(e)}. Response text: {response.text}",
                        log_level="ERROR",
                    )
                    break
            else:
                # Log any HTTP error responses
                write_to_log(
                    script_txt=script_name,
                    table_txt="dImage",
                    action_txt="Fetch all files from SharePoint document library.",
                    message_txt=f"HTTP error while fetching files. Status code: {response.status_code}. Response text: {response.text}",
                    log_level="ERROR",
                )
                break

        # Log completion of fetching
        write_to_log(
            script_txt=script_name,
            table_txt="dImage",
            action_txt="Fetch all files from SharePoint document library.",
            message_txt=f"Completed fetching files. Total files fetched: {len(all_files)}.",
            log_level="INFO",
        )

    except Exception as e:
        # Log any unexpected exceptions
        write_to_log(
            script_txt=script_name,
            table_txt="dImage",
            action_txt="Fetch all files from SharePoint document library.",
            message_txt=f"An unexpected error occurred: {str(e)}.",
            log_level="ERROR",
        )

    return all_files


def copy_files_to_folder(
    query_path: str, destination_folder: str, script_name: str
) -> None:

    with open(query_path, "r") as file:
        image_query = file.read()

    df_image_path = get_sql_dataframe(
        server="WHServer",
        db="Warehouse",
        table="dImage",
        sql=image_query,
        action="Executed dImage download query",
        script=script_name,
    )

    for file_path in df_image_path["Img URL"]:

        try:

            file_name = os.path.basename(file_path)
            destination_file_path = os.path.join(destination_folder, file_name)
            copyfile(file_path, destination_file_path)

        except Exception as e:

            write_to_log(
                script_txt=script_name,
                table_txt="dImage",
                action_txt="Copy image file to WHServer.",
                message_txt=f"Failed to copy {file_path} to {destination_folder}. Error: {str(e)}",
                log_level="ERROR",
            )

            continue


def delete_files_in_folder(folder_path: str) -> None:

    if os.path.exists(folder_path):

        script_name = name_script

        for filename in os.listdir(folder_path):
            file_path = os.path.join(folder_path, filename)

            if os.path.isfile(file_path):
                try:
                    os.remove(file_path)

                except Exception as e:
                    write_to_log(
                        script_txt=script_name,
                        table_txt="dImage",
                        action_txt=f"Delete {filename} from: {folder_path}",
                        message_txt=f"Failed to delete {filename}. Error: {str(e)}",
                        log_level="ERROR",
                    )

    else:
        write_to_log(
            script_txt=script_name,
            table_txt="dImage",
            action_txt=f"Delete all files in the folder: {folder_path}",
            message_txt=f"The folder '{folder_path}' does not exist.",
            log_level="ERROR",
        )


def main():

    script_name = name_script

    try:

        destination_folder = "//WHServer/Image Transfer/db_Images"

        copy_files_to_folder(
            query_path="//WHServer/Users/leo.pickard/Desktop/Data-Warehouse/Update Scripts/T-SQL/dRecord Link Image Download Query.sql",
            destination_folder=destination_folder,
            script_name=script_name,
        )

        # Below is the code to create a microsoft graph api token

        with open(
            "//WHServer/Users/leo.pickard/Desktop/Data-Warehouse/config.json"
        ) as config_file:
            config = json.load(config_file)
            username = config["user"]
            password = config["password"]
            application_id = config["application_id"]
            client_secret = config["client_secret"]
            authority_url = config["authority_url"]
            drive_id = config["drive_id"]

        SCOPES = ["Files.ReadWrite.All"]

        client_instance = msal.ConfidentialClientApplication(
            client_id=application_id,
            client_credential=client_secret,
            authority=authority_url,
        )

        authorization_request_url = (
            client_instance.get_authorization_request_url(SCOPES)
        )

        options = Options()
        options.add_argument("start-maximized")
        options.add_argument("disable-infobars")
        options.add_argument("--disable-extensions")

        browser = webdriver.Chrome(
            service=Service(ChromeDriverManager().install()), options=options
        )

        browser.get(authorization_request_url)

        sleep(5)

        email_input = browser.find_element(By.ID, "i0116")

        email_input.send_keys(username)

        sleep(5)

        next_button = browser.find_element(By.ID, "idSIButton9")

        next_button.click()

        sleep(5)

        password_input = browser.find_element(By.ID, "passwordInput")

        password_input.send_keys(password)

        sleep(5)

        sign_in_button = browser.find_element(By.ID, "submitButton")
        sign_in_button.click()

        sleep(5)

        yes_button = browser.find_element(By.ID, "idSIButton9")
        yes_button.click()

        sleep(5)

        current_url = browser.current_url
        browser.quit()

        match = search(r"code=([^&]+)", current_url)
        authorization_code = match.group(1)

        access_token = client_instance.acquire_token_by_authorization_code(
            code=authorization_code, scopes=SCOPES
        )

        access_token_id = access_token["access_token"]

        upload_all_files_in_folder(
            local_folder=destination_folder,
            drive_id=drive_id,
            access_token_id=access_token_id,
        )

        # Below is the code to retrieve the data from the sharepoint document library to insert into the dimage table

        all_files = fetch_all_files(
            drive_id=drive_id, access_token_id=access_token_id
        )

        file_data = []

        for file in all_files:
            height = file.get("image", {}).get("height", 0)
            width = file.get("image", {}).get("width", 0)

            file_data.append(
                {
                    "File ID": file["id"],
                    "File Name": file["name"],
                    "Last Modified": file["lastModifiedDateTime"],
                    "File Size": file["size"],
                    "Height": height,
                    "Width": width,
                    "Image URL": file["webUrl"],
                }
            )

        df_image_files = DataFrame(file_data)

        df_image_files["Last Modified"] = to_datetime(
            df_image_files["Last Modified"], format="%Y-%m-%dT%H:%M:%SZ"
        )

        df_image_files["Height"] = (
            to_numeric(df_image_files["Height"], errors="coerce")
            .fillna(0)
            .astype(int)
        )

        df_image_files["Width"] = (
            to_numeric(df_image_files["Width"], errors="coerce")
            .fillna(0)
            .astype(int)
        )

        with open(
            "//WHServer/Users/leo.pickard/Desktop/Data-Warehouse/Update Scripts/T-SQL/dImage Warehouse dRecord Link Query.sql",
            "r",
        ) as file:
            reord_link_content = file.read()

        df_record_link = get_sql_dataframe(
            server="WHServer",
            db="Warehouse",
            table="dImage",
            sql=reord_link_content,
            action="Executed Warehouse record link query",
            script=script_name,
        )

        df_record_link["File Name"] = (
            df_record_link["File Name"]
            .astype(str)
            .apply(lambda x: sub(r"\s+", "", x))
        )

        df_dImage = merge(
            df_record_link,
            df_image_files,
            how="left",
            left_on="File Name",
            right_on="File Name",
        )

        df_dImage = df_dImage[df_dImage["File ID"].notna()].copy()

        df_dImage = df_dImage[
            [
                "Item No",
                "File ID",
                "File Name",
                "Last Modified",
                "File Size",
                "Height",
                "Width",
                "Image URL",
                "File Path",
            ]
        ]

        num_rows = len(df_dImage)

        dtype_mapping = {
            "[Item No]": NVARCHAR(30),
            "[File ID]": NVARCHAR(255),
            "[File Name]": NVARCHAR(255),
            "[Last Modified]": DATETIME(3),
            "[File Size]": BIGINT(),
            "[Height]": INTEGER(),
            "[Width]": INTEGER(),
            "[Image URL]": NVARCHAR(400),
            "[File Path]": NVARCHAR(400),
        }

        execute_sql_procedure(
            server="WHServer",
            db="Warehouse",
            table="dImage",
            sql="EXEC [Clear dImage Table];",
            action="Execute truncate dImage table.",
            script=script_name,
        )

        write_df_to_sql_db(
            server="WHServer",
            db="Warehouse",
            table="dImage",
            df=df_dImage,
            dtype=dtype_mapping,
            action="Write dataframe to dImage",
            script=script_name,
            rows=num_rows,
        )

        delete_files_in_folder(folder_path=destination_folder)

    except Exception as e:

        write_to_log(
            script_txt=script_name,
            table_txt="dImage",
            action_txt="Execute script to download new images for dImage table.",
            message_txt=f"An unexpected error occurred: {str(e)}",
            log_level="CRITICAL",
        )

        print(
            f"{script_name} has ran into a critical error during execution. See log file."
        )


if __name__ == "__main__":
    main()