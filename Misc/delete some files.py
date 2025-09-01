import pandas as pd
from pathlib import Path

csv_file = "//WHServer/Users/leo.pickard/Desktop/Thumbnails to delete.csv"

df = pd.read_csv(csv_file)

for file_path in df.iloc[:, 0]:
    file = Path(file_path)
    if file.exists():
        file.unlink()
        print(f"Deleted: {file}")
    else:
        print(f"File not found: {file}")

print("File deletion process completed.")
