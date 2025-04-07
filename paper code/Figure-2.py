import matplotlib.pyplot as plt
import pandas as pd
import numpy as np
import seaborn as sns
import matplotlib.lines as mlines  # import Line2D

# Reading CSV Data
file_path = r'C:\Users\paper\base data2005.csv' # Please add 2010, 2015 and 2020
data = pd.read_csv(file_path)

# Extract the required columns from the data
cities = data['city']
CEI = data['G_Carbon']
PCEs = data['P_Carbon']
CEs = data['TP_CARBON']
SCss = data[data['ST'] == 1]['city']  # Pick out shrinking cities

# The average value of all cities and the average value of shrinking and non-shrinking cities
# (these values are calculated by the author in the Excel table according to specific years)
All_cities = 2.35
SCs = 3.13
USCs = 2.2

# Create a graph
plt.figure(figsize=(12, 8))

# Color changes according to GDP
norm = plt.Normalize(min(PCEs), max(PCEs))
cmap = plt.cm.YlGnBu  # 选择颜色映射

# Adjust the spacing of the bars (increase the space between the bars to avoid overlapping)
spacing = 1

x_coor = 0
total_width = 0  # The total width used to calculate the maximum value of the horizontal axis
for i, city in enumerate(cities):
    color = cmap(norm(PCEs[i]))  # Choose a color for each bar
    plt.bar(x_coor + CEs[i]/2.0, CEI[i], width=CEs[i], color=color)  # Set the height and color
    x_coor += CEs[i]
    total_width += CEs[i]

# Add a reference line to the y-axis (here we move the reference line of the y-axis)
line_all_cities = plt.axhline(y=All_cities, color='blue', linestyle='--', label=f'All_cities average ({All_cities})')
line_SCs = plt.axhline(y=SCs, color='red', linestyle='--', label=f'SCs average ({SCs})')
line_USCs = plt.axhline(y=USCs, color='green', linestyle='--', label=f'USCs average ({USCs})')

# Mark the shrinking cities with small red triangles
x_coor = 0
triangle_markers = []
for i, city in enumerate(cities):
    if city in SCss.values:
        plt.plot(x_coor + CEs[i] / 2.0, CEI[i], 'r^', markersize=8)
    x_coor += CEs[i]

# Create a red triangle legend entry
triangle = mlines.Line2D([], [], color='r', marker='^', markersize=8, label='SCs')

# Add a color bar for GDP per capita
sm = plt.cm.ScalarMappable(cmap=cmap, norm=norm)
sm.set_array([])
cbar = plt.colorbar(sm, ax=plt.gca())
cbar.set_label('PC (ton/person)', fontsize=24)

# Set title and tags
plt.title('(c) 2015', fontsize=28)
plt.xlabel('Cumulative Share of CEs (%)', fontsize=24)
plt.ylabel('CEI (ton/10000yuan)', fontsize=24)

# Set the 0 position of the coordinate axis to be consistent
plt.xlim(0, total_width)
plt.ylim(0, max(CEI) * 1.1)

# Adjust the legend position to avoid overlapping with the graph
# Add legend items with red triangles and reference lines
plt.legend(handles=[triangle, line_all_cities, line_SCs, line_USCs], loc='best', fontsize=20)

# Beautify the layout
plt.tight_layout()

# Save the chart as a 300 DPI JPEG file
save_path = r'C:\Users\paper\output_image2005.jpg'
plt.savefig(save_path, dpi=300, format='jpeg')

# Show Chart
plt.show()
