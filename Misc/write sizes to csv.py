import csv
from numpy import arange

# Define the size lists
f0_sizes_in = [f"{x:.0f}" for x in arange(1.0, 1001.0, 1.0)]
f1_sizes_in = [f"{x:.1f}" for x in arange(1.0, 100.1, 0.1)]
f2_sizes_in = [f"{x:.2f}" for x in arange(1.0, 100.01, 0.01)]
f3_sizes_in = [f"{x:.3f}" for x in arange(1.0, 100.001, 0.001)]

f0_sizes_mm = [f"{x:.0f}" for x in arange(1.0, 2001.0, 1.0)]
f1_sizes_mm = [f"{x:.1f}" for x in arange(1.0, 2000.1, 0.1)]
f2_sizes_mm = [f"{x:.2f}" for x in arange(1.0, 2000.01, 0.01)]
f3_sizes_mm = [f"{x:.3f}" for x in arange(1.0, 2000.001, 0.001)]

fractions_mm = [
    "1/8", "1/4", "1/2", "5/8", "3/4", "7/8",
    "1 1/8", "1 1/4", "1 3/8", "1 1/2"
]

# Combine and sort the sizes
in_sizes = sorted(f0_sizes_in + f1_sizes_in + f2_sizes_in + f3_sizes_in, key=lambda x: float(x))
mm_sizes = sorted(f0_sizes_mm + f1_sizes_mm + f2_sizes_mm + f3_sizes_mm, key=lambda x: float(x))
mm_sizes = fractions_mm + mm_sizes

# Combine in_sizes and mm_sizes into one column
all_sizes = in_sizes + mm_sizes

# Write to a CSV file
output_file = "sizes.csv"
with open(output_file, mode="w", newline="") as csvfile:
    writer = csv.writer(csvfile)
    writer.writerow(["Index", "Sizes"])
    for index, size in enumerate(all_sizes, start=1):
        writer.writerow([index, size])

print(f"Sizes with index written to {output_file}.")