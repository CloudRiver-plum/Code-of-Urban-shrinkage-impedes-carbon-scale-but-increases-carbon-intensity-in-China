# 安装和加载所需的包
required_packages <- c("readxl", "broom", "ggplot2", "plm", "dplyr")

# 检查并安装缺少的包
missing_packages <- required_packages[!(required_packages %in% installed.packages()[, "Package"])]
if(length(missing_packages)) install.packages(missing_packages)

# 加载所有包
lapply(required_packages, library, character.only = TRUE)

# 读取数据
file_path <- "D:/00博士/小论文/paper1/数据处理/01计算数据/数据处理初步1/stata/数据重新处理/data.xlsx"
if (file.exists(file_path)) {
  data1 <- read_excel(file_path, sheet = 1, na = c("NA", "#DIV/0!"))
} else {
  stop("文件不存在，请检查路径。")
}

# 确保数据中没有负值或零，并且排除缺失值
if(any(data1$TC <= 0, na.rm = TRUE)) stop("TC contains zero or negative values, log transformation cannot be applied.")
if(any(data1$GC <= 0, na.rm = TRUE)) stop("GC contains zero or negative values, log transformation cannot be applied.")

# 进行必要的变量变换
HC <- data1$HC * 10
OE <- data1$OE * 1000
data1$ln_TC <- log(data1$TC)
data1$ln_GC <- log(data1$GC * 10)  # Assuming multiplication by 10 is intentional

# 检查是否有 'city' 和 'year' 列
if(!all(c("city", "year") %in% colnames(data1))) {
  stop("数据中缺少 'city' 或 'year' 列。")
}

# 将数据转换为面板数据格式
panel_data <- pdata.frame(data1, index = c("city", "year"))

# 线性回归模型，双固定效应（city + year）
# 使用 plm 中的 'within' 方法进行双固定效应模型
model_TC <- plm(ln_TC ~ SR + NL + GI + NE + PI + OE + HC + UR + BG + ED,
                data = panel_data, model = "within")
model_GC <- plm(ln_GC ~ SR + NL + GI + NE + PI + OE + HC + UR + BG + ED,
                data = panel_data, model = "within")

# 使用 broom 包将回归结果整理成 tidy 格式
tidy_TC <- tidy(model_TC, conf.int = TRUE) %>%
  mutate(model = "ln_TC", color = "red")  # 为结果添加模型标识和颜色

tidy_GC <- tidy(model_GC, conf.int = TRUE) %>%
  mutate(model = "ln_GC", color = "green")  # 为结果添加模型标识和颜色

# 合并两个回归结果
tidy_models <- bind_rows(tidy_TC, tidy_GC)

# 根据需要重新排列或修改数据
tidy_models <- tidy_models %>%
  mutate(significance = case_when(
    p.value < 0.001 ~ "***",
    p.value < 0.01 ~ "**",
    p.value < 0.05 ~ "*",
    TRUE ~ ""
  ))

# 创建系数图
p <- ggplot(tidy_models, aes(x = estimate, y = term, xmin = conf.low, xmax = conf.high, color = color)) +
  geom_point(aes(shape = model), size = 3) +  # 点样式区分模型
  geom_errorbarh(aes(xmin = conf.low, xmax = conf.high), height = 0.2) +  # 水平误差条
  geom_vline(xintercept = 0, linetype = "dashed", color = "gray") +  # 添加零线
  scale_color_manual(values = c("red", "green")) +  # 自定义颜色
  scale_shape_manual(values = c(16, 17)) +  # 自定义点形状
  geom_text(data = subset(tidy_models, model == "ln_TC"), aes(label = paste0(round(estimate, 3), significance)),
            position = position_nudge(x = -1, y = 0.3), size = 5, color = "red", hjust = 1) +  # 添加ln_TC系数
  geom_text(data = subset(tidy_models, model == "ln_GC"), aes(label = paste0(round(estimate, 3), significance)),
            position = position_nudge(x = 1, y = 0.3), size = 5, color = "green", hjust = 0) +  # 添加ln_GC系数
  theme_minimal() +
  theme(
    axis.title.y = element_blank(),
    axis.text.y = element_text(size = 12),
    axis.text.x = element_text(size = 12),
    plot.title = element_text(hjust = 0.5, size = 14),
    legend.title = element_blank(),
    panel.grid = element_blank(),  # 去除网格线
    axis.ticks = element_line(color = "black"),  # 设置坐标轴刻度
    axis.line = element_line(color = "black"),  # 设置坐标轴线
    panel.border = element_rect(color = "black", fill = NA, size = 1),  # 添加封闭的黑框
    legend.position = "bottom",  # 图例位置
    legend.box = "horizontal",  # 图例盒子为横向
    legend.key = element_rect(color = "black", fill = "white", size = 1),  # 设置图例键的边框
    legend.background = element_rect(color = "black", fill = "white", size = 1)  # 图例背景为白色，边框为黑色
  ) +
  labs(
    title = "Carbon scale and intensity (N=1152)",
    x = "Coefficient",
    y = "变量"
  )

# 绘制并保存图像
ggsave("regression_coefficients.png", plot = p, width = 6, height = 6, dpi = 450, units = "in")

dev.new(width = 7, height = 5)  # 打开一个新图形窗口
print(p)
