import csv

input_file_1 = "//WHServer/Users/leo.pickard/Desktop/TEST FOLDER/sizes.csv"
input_file_2 = "//WHServer/Users/leo.pickard/Desktop/TEST FOLDER/Non Numeric Sizes.csv"
output_file = "//WHServer/Users/leo.pickard/OneDrive - Shiner UK Ltd/Projects/Item Size Index.csv"


def read_csv(file_path):
    with open(file_path, mode="r", newline="") as csvfile:
        reader = csv.DictReader(csvfile)
        data = [row for row in reader]
    return data


def write_csv(file_path, data):
    with open(file_path, mode="w", newline="") as csvfile:
        writer = csv.DictWriter(csvfile, fieldnames=["Index", "Sizes"])
        writer.writeheader()
        writer.writerows(data)


data1 = read_csv(input_file_1)
data2 = read_csv(input_file_2)

combined_data = data1 + data2

write_csv(output_file, combined_data)

print(f"Combined data written to {output_file}.")
