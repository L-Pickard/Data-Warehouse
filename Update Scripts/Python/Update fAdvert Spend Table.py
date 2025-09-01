import json
import os
from pandas import DataFrame, concat, to_datetime
import itertools
from SQL_Functions import write_df_to_sql_db, execute_sql_procedure
from db_logger import write_to_log
from sqlalchemy.types import DATE, NVARCHAR, DECIMAL, BIGINT
from datetime import datetime, timedelta
from google.analytics.data_v1beta import BetaAnalyticsDataClient
from google.analytics.data_v1beta.types import (
    DateRange,
    Dimension,
    Metric,
    RunReportRequest,
)

script_name = os.path.basename(__file__)

def get_api_data(property_id: int, starting_date: str, ending_date: str) -> json:

    try:

        client = BetaAnalyticsDataClient()

        request_api = RunReportRequest(
            property=f"properties/{str(property_id)}",
            dimensions=[
                Dimension(name="sessionPrimaryChannelGroup"),
                Dimension(name="date"),
            ],
            metrics=[Metric(name="advertiserAdCost")],
            date_ranges=[DateRange(start_date=starting_date, end_date=ending_date)],
        )

        response = client.run_report(request_api)

        return response

    except Exception as e:

        write_to_log(
            script_txt=script_name,
            table_txt="fAdvert Spend",
            action_txt=f"Fetching json api data from google for property id: {str(property_id)}.",
            message_txt=f"An unexpected error occurred: {str(e)}",
            log_level="Error",
        )

        return None


def create_dataframe(
    property_id: int, property_name: str, currency: str, api_response: json
) -> DataFrame:

    try:
        dimension_headers = [header.name for header in api_response.dimension_headers]
        metric_headers = [header.name for header in api_response.metric_headers]
        dimensions = []
        metrics = []
        for i in range(len(dimension_headers)):
            dimensions.append(
                [row.dimension_values[i].value for row in api_response.rows]
            )
        dimensions
        for i in range(len(metric_headers)):
            metrics.append([row.metric_values[i].value for row in api_response.rows])
        headers = dimension_headers, metric_headers
        headers = list(itertools.chain.from_iterable(headers))
        data = dimensions, metrics
        data = list(itertools.chain.from_iterable(data))
        df = DataFrame(data)
        df = df.transpose()
        df.columns = headers

        df["Property Id"] = property_id
        df["Property Name"] = property_name
        df["Currency"] = currency
        df["Ad Vendor"] = "Google"

        return df

    except Exception as e:

        write_to_log(
            script_txt=script_name,
            table_txt="fAdvert Spend",
            action_txt=f"Converting json api response to dataframe for property id: {str(property_id)} property name: {property_name}.",
            message_txt=f"An unexpected error occurred: {str(e)}",
            log_level="Error",
        )

        return None


def main():

    os.environ[
        "GOOGLE_APPLICATION_CREDENTIALS"
    ] = "D:/Shinersql18/Finance-db/Update Scripts/Python/reporting-438915-d4be8675229e.json"

    properties = {
        295311195: {"name": "*D2C | 187 Killer Pads (187)", "currency": "GBP"},
        393859217: {"name": "*D2C | Feiyue (EU) | FEI", "currency": "GBP"},
        287349826: {"name": "*D2C | Feiyue UK (FEI)", "currency": "GBP"},
        250189731: {"name": "*D2C | Heelys (HLY)", "currency": "GBP"},
        377498192: {"name": "*D2C | Independent Trucks (IND+INA)", "currency": "GBP"},
        377507581: {"name": "*D2C | Pro-Tec (PRT)", "currency": "GBP"},
        377507476: {"name": "*D2C | Santa Cruz (SCA+SCR)", "currency": "GBP"},
        386355931: {"name": "B2B - Shiner Distribution - GA4", "currency": "GBP"},
        386636503: {"name": "Blog - PixelsTV - GA4", "currency": "GBP"},
        390742125: {"name": "Brand - Bullet Protection - GA4", "currency": "USD"},
        386571134: {"name": "Brand - D-Street - GA4", "currency": "GBP"},
        386461405: {"name": "Brand - www.sushiskateboards.com - GA4", "currency": "GBP"},
        386393358: {"name": "D2C - Feiyue - GA4", "currency": "GBP"},
        402783027: {"name": "D2C - Heelys (UA) - GA4 (DO NOT USE)", "currency": "GBP"},
        377463677: {"name": "D2C - Rookie Skates - GA4", "currency": "GBP"},
        259735815: {"name": "D2C - SuperDeker EU", "currency": "EUR"},
        259732222: {"name": "D2C - SuperDeker UK", "currency": "GBP"},
        377461265: {"name": "D2C | Addict Scootering (ADD)", "currency": "GBP"},
        377502930: {"name": "D2C | BlazerPro (BLZ)", "currency": "GBP"},
        268281493: {"name": "mcstaging Heelys - GA4", "currency": "GBP"},
        386647694: {"name": "Rocketskateboards - GA4", "currency": "USD"},
        463700828: {"name": "Roll Up Property- Test", "currency": "GBP"},
        259769679: {"name": "SuperDeker (EU) - GA4", "currency": "EUR"},
        259733045: {"name": "SuperDeker (UK) - GA4", "currency": "GBP"},
        414938907: {"name": "Tony Hawk Signature Series", "currency": "GBP"},
    }

    start = "2024-05-01"
    yesterday = (datetime.now() - timedelta(days=1)).strftime("%Y-%m-%d")

    df_google = DataFrame()

    try:

        for property_id in properties:

            name_property = properties.get(property_id, {}).get("name")
            currency = properties.get(property_id, {}).get("currency")

            response_api = get_api_data(
                property_id=property_id, starting_date=start, ending_date=yesterday
            )

            df_temp = create_dataframe(
                property_id=property_id,
                property_name=name_property,
                currency=currency,
                api_response=response_api,
            )

            df_google = concat([df_google, df_temp], ignore_index=True)

        df_google = df_google.rename(
            columns={
                "sessionPrimaryChannelGroup": "Session Primary Channel Group",
                "date": "Date",
                "advertiserAdCost": "Ads Cost",
            }
        )

        df_google = df_google[
            [
                "Date",
                "Ad Vendor",
                "Property Id",
                "Property Name",
                "Session Primary Channel Group",
                "Currency",
                "Ads Cost",
            ]
        ]

        df_google["Date"] = to_datetime(df_google["Date"], format="%Y%m%d").dt.strftime(
            "%Y-%m-%d"
        )

    except Exception as e:

        write_to_log(
            script_txt=script_name,
            table_txt="fAdvert Spend",
            action_txt=f"Combining property dataframes and applying dataframe formats.",
            message_txt=f"An unexpected error occurred: {str(e)}",
            log_level="Error",
        )

        return None

    try:

        num_rows = len(df_google)

        dtype_mapping = {
            "[Date]": DATE,
            "[Ad Vendor]": NVARCHAR(30),
            "[Property Id]": BIGINT,
            "[Property Name]": NVARCHAR(200),
            "[Session Primary Channel Group]": NVARCHAR(100),
            "[Currency]": NVARCHAR(3),
            "[Ads Cost]": DECIMAL(30, 15),
        }

        execute_sql_procedure(
            server="WHServer",
            db="Warehouse",
            table="fAdvert Spend",
            sql="EXEC [Clear fAdvert Spend Table];",
            action="Execute truncate fAdvert Spend table.",
            script=script_name,
        )

        write_df_to_sql_db(
            server="WHServer",
            db="Warehouse",
            table="fAdvert Spend",
            df=df_google,
            dtype=dtype_mapping,
            action="Write dataframe to fAdvert Spend table.",
            script=script_name,
            rows=num_rows,
        )

        print(f"{script_name} finished. Number of rows written: {num_rows}")

    except Exception as e:

        write_to_log(
            script_txt=script_name,
            table_txt="fAdvert Spend",
            action_txt="Clear old data then write data to update fAdvert Spend table. An error has occurred.",
            message_txt=f"An unexpected error occurred: {str(e)}",
            log_level="CRITICAL",
        )

        print(
            f"{script_name} has ran into a critical error during execution. See log file."
        )

if __name__ == "__main__":
    main()
