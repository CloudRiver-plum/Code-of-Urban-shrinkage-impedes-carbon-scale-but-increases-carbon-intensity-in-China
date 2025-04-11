# Install and load required packages
required_packages <- c("readxl", "broom", "ggplot2", "plm", "dplyr")

# Check and install missing packages
missing_packages <- required_packages[!(required_packages %in% installed.packages()[, "Package"])]
if(length(missing_packages)) install.packages(missing_packages)

# Load all packages
lapply(required_packages, library, character.only = TRUE)

# Reading Data
file_path <- "C:/paper/data.xlsx"
if (file.exists(file_path)) {
  data1 <- read_excel(file_path, sheet = 1, na = c("NA", "#DIV/0!"))
} else {
  stop("The file does not exist, please check the path.")
}

# Make sure there are no negative values ​​or zeros in the data and exclude missing values
if(any(data1$TC <= 0, na.rm = TRUE)) stop("TC contains zero or negative values, log transformation cannot be applied.")
if(any(data1$GC <= 0, na.rm = TRUE)) stop("GC contains zero or negative values, log transformation cannot be applied.")

# Perform necessary variable transformations
HC <- data1$HC * 10
OE <- data1$OE * 1000
data1$ln_TC <- log(data1$TC)
data1$ln_GC <- log(data1$GC * 10)  # Assuming multiplication by 10 is intentional

# Check if there are 'city' and 'year' columns
if(!all(c("city", "year") %in% colnames(data1))) {
  stop("The 'city' or 'year' columns are missing in the data.")
}

# Convert data to panel data format
panel_data <- pdata.frame(data1, index = c("city", "year"))

# Linear regression model, double fixed effects (city + year)
# Two-fixed-effects model using the 'within' method in plm
model_TC <- plm(ln_TC ~ SR + NL + GI + NE + PI + OE + HC + UR + BG + ED,
                data = panel_data, model = "within")
model_GC <- plm(ln_GC ~ SR + NL + GI + NE + PI + OE + HC + UR + BG + ED,
                data = panel_data, model = "within")

# Use the broom package to organize the regression results into tidy format
tidy_TC <- tidy(model_TC, conf.int = TRUE) %>%
  mutate(model = "ln_TC", color = "red")

tidy_GC <- tidy(model_GC, conf.int = TRUE) %>%
  mutate(model = "ln_GC", color = "green")

# Combining two regression results
tidy_models <- bind_rows(tidy_TC, tidy_GC)

# Rearrange or modify data as needed
tidy_models <- tidy_models %>%
  mutate(significance = case_when(
    p.value < 0.001 ~ "***",
    p.value < 0.01 ~ "**",
    p.value < 0.05 ~ "*",
    TRUE ~ ""
  ))

# Creating a Coefficient Graph
p <- ggplot(tidy_models, aes(x = estimate, y = term, xmin = conf.low, xmax = conf.high, color = color)) +
  geom_point(aes(shape = model), size = 3) +
  geom_errorbarh(aes(xmin = conf.low, xmax = conf.high), height = 0.2) +
  geom_vline(xintercept = 0, linetype = "dashed", color = "gray") +
  scale_color_manual(values = c("red", "green")) +
  scale_shape_manual(values = c(16, 17)) +
  geom_text(data = subset(tidy_models, model == "ln_TC"), aes(label = paste0(round(estimate, 3), significance)),
            position = position_nudge(x = -1, y = 0.3), size = 5, color = "red", hjust = 1) +
  geom_text(data = subset(tidy_models, model == "ln_GC"), aes(label = paste0(round(estimate, 3), significance)),
            position = position_nudge(x = 1, y = 0.3), size = 5, color = "green", hjust = 0) +
  theme_minimal() +
  theme(
    axis.title.y = element_blank(),
    axis.text.y = element_text(size = 12),
    axis.text.x = element_text(size = 12),
    plot.title = element_text(hjust = 0.5, size = 14),
    legend.title = element_blank(),
    panel.grid = element_blank(),
    axis.ticks = element_line(color = "black"),
    axis.line = element_line(color = "black"),
    panel.border = element_rect(color = "black", fill = NA, size = 1),
    legend.position = "bottom",
    legend.box = "horizontal",
    legend.key = element_rect(color = "black", fill = "white", size = 1),
    legend.background = element_rect(color = "black", fill = "white", size = 1)
  ) +
  labs(
    title = "Carbon scale and intensity (N=1152)",
    x = "Coefficient",
    y = "Variable"
  )

# Draw and save the image
ggsave("regression_coefficients.png", plot = p, width = 6, height = 6, dpi = 450, units = "in")

dev.new(width = 7, height = 5)
print(p)
