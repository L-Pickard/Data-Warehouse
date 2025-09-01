import os
import pyexiv2
import json


def main():

    directory = "//orgnas01/OrgData/MARKETING/001 Image Processing/012 Master Thumbnail Imagery/002 Batch Processed - 450px 1-1 SFW"

    count = 0

    for file_name in os.listdir(directory):
        file_path = os.path.join(directory, file_name)

        try:

            if os.path.isfile(file_path):

                with pyexiv2.Image(file_path) as img:
                    file_dict = json.loads(img.read_comment())

                item_no = file_dict["Item No"]
                common_item_no = file_dict["Common Item No"]
                vendor_ref = file_dict["Vendor Reference"]
                brand_code = file_dict["Brand Code"]
                description = file_dict["Description"]
                description_2 = file_dict["Description 2"]
                colours = file_dict["Colours"]
                size_1 = file_dict["Size 1"]
                size_1_unit = file_dict["Size 1 Unit"]
                uom = file_dict["Unit of Measure"]
                season = file_dict["Season"]
                category = file_dict["Category"]
                group = file_dict["Group"]
                ean = file_dict["EAN"]
                tariff = file_dict["Tariff No"]
                coo = file_dict["COO"]

                print(
                    f"""
                      -------------------------------------------------------------------------------------------------------------
                      File:               {file_name}
                      Item No:            {item_no}
                      Common Item No:     {common_item_no}
                      Vendor Reference:   {vendor_ref}
                      Brand Code:         {brand_code}
                      Description:        {description}
                      Description 2:      {description_2}
                      Colours:            {colours}
                      Size 1:             {size_1}
                      Size 1 Unit:        {size_1_unit}
                      Unit of Measure:    {uom}
                      Season:             {season}
                      Category:           {category}
                      Group:              {group}
                      EAN Barcode:        {ean}
                      Tariff No:          {tariff}
                      COO:                {coo}
                      -------------------------------------------------------------------------------------------------------------
                      """
                )

            count += 1

            if count >= 100:
                break

        except Exception as e:

            print(
                f"""
                      -------------------------------------------------------------------------------------------------------------
                      File:               {file_name}

                      THERE WAS AN ERROR READING THE DATA FROM THIS FILE!

                      MOVING ON TO THE NEXT FILE!
                      -------------------------------------------------------------------------------------------------------------
                      """
            )
        continue


if __name__ == "__main__":
    main()
