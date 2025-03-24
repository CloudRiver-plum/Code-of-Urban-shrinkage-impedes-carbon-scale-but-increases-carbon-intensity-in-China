import matplotlib.pyplot as plt
import pandas as pd
import numpy as np
import seaborn as sns
import matplotlib.lines as mlines  # 导入Line2D

# 读取CSV数据
file_path = r'D:\00博士\小论文\paper1\绘图最新\base data2015.csv'
data = pd.read_csv(file_path)

# 从数据中提取所需的列
cities = data['city']  # 替换为city列
CEI = data['G_Carbon']  # 替换为G_Carbon列
PCEs = data['P_Carbon']  # 替换为P_Carbon列
CEs = data['TP_CARBON']  # 替换为T_Carbon列
SCss = data[data['ST'] == 1]['city']  # ST列值为1的城市

# 全球平均值和各区域的平均值（这些值需要根据实际数据进行修改）
All_cities = 2.35
SCs = 3.13
USCs = 2.2

# 创建图形
plt.figure(figsize=(12, 8))

# 按照“Cumulative Share of Geographic Barriers”均匀分布条形图，颜色根据GDP变化
norm = plt.Normalize(min(PCEs), max(PCEs))  # 根据GDP数值归一化
cmap = plt.cm.YlGnBu  # 选择颜色映射

# 调整条形的间距（增加条形之间的间距以避免重叠）
spacing = 1  # 调整为适当的间距

x_coor = 0
total_width = 0  # 用于计算横坐标最大值的总宽度
for i, city in enumerate(cities):
    color = cmap(norm(PCEs[i]))  # 为每个条形选择颜色
    plt.bar(x_coor + CEs[i]/2.0, CEI[i], width=CEs[i], color=color)  # 设置高度和颜色
    x_coor += CEs[i]
    total_width += CEs[i]  # 累加总宽度

# 添加参考线到y轴（这里我们将y轴的参考线移动）
line_all_cities = plt.axhline(y=All_cities, color='blue', linestyle='--', label=f'All_cities average ({All_cities})')
line_SCs = plt.axhline(y=SCs, color='red', linestyle='--', label=f'SCs average ({SCs})')
line_USCs = plt.axhline(y=USCs, color='green', linestyle='--', label=f'USCs average ({USCs})')

# 在ST == 1的城市上标记红色小三角形
x_coor = 0
triangle_markers = []  # 存储红色三角形的标记，用于图例
for i, city in enumerate(cities):
    if city in SCss.values:
        plt.plot(x_coor + CEs[i] / 2.0, CEI[i], 'r^', markersize=8)  # 红色小三角形
    x_coor += CEs[i]

# 创建红色三角形的图例项
triangle = mlines.Line2D([], [], color='r', marker='^', markersize=8, label='SCs')

# 添加GDP per capita的颜色条
sm = plt.cm.ScalarMappable(cmap=cmap, norm=norm)
sm.set_array([])  # 设置空数组
cbar = plt.colorbar(sm, ax=plt.gca())  # 显示颜色条并明确指定ax参数
cbar.set_label('PC (ton/person)', fontsize=24)  # 字号增大一倍

# 设置标题和标签
plt.title('(c) 2015', fontsize=28)  # 字号增大一倍
plt.xlabel('Cumulative Share of CEs (%)', fontsize=24)  # 字号增大一倍
plt.ylabel('CEI (ton/10000yuan)', fontsize=24)  # 字号增大一倍

# 设置坐标轴的0位置一致
plt.xlim(0, total_width)  # 横坐标的范围从0到条形的总宽度
plt.ylim(0, max(CEI) * 1.1)  # 纵坐标的范围从0到最大CEI值，稍微加大范围

# 调整图例位置，避免与图形重叠，添加红色三角形和参考线的图例项
plt.legend(handles=[triangle, line_all_cities, line_SCs, line_USCs], loc='best', fontsize=20)  # 字号增大一倍

# 美化布局
plt.tight_layout()

# 保存图表为 300 DPI 的 JPEG 文件
save_path = r'D:\00博士\小论文\paper1\绘图最新\output_image2015.jpg'  # 设置保存路径
plt.savefig(save_path, dpi=300, format='jpeg')

# 显示图表
plt.show()
