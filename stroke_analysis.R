# --- STROKE PREDICTION PROJECT ---
# Complete R Script
#
# This script loads, cleans, visualizes, and models
# patient data to predict the likelihood of a stroke.

# --- Step 1: Load Libraries and Inspect Data ---

# Load the main libraries for analysis and modeling
library(tidyverse)
library(caret)
library(ROSE)     # For balancing data
library(pROC)     # For ROC-AUC
library(rpart)    # For decision trees (used by 'rf')

# Load the dataset
patient_data <- read_csv("healthcare-dataset-stroke-data.csv")

# --- Initial Inspection ---
print("--- Step 1: Initial Data Glimpse & Summary ---")
glimpse(patient_data)
summary(patient_data)


# --- Step 2: Data Cleaning and Preprocessing ---
print("--- Step 2: Cleaning Data ---")

# 1. Calculate the mean BMI for imputation
# Must convert to numeric first, which turns "N/A" into NA
mean_bmi <- patient_data %>%
  mutate(bmi = as.numeric(bmi)) %>%
  pull(bmi) %>%
  mean(na.rm = TRUE)
print(paste("Calculated mean BMI for imputation:", mean_bmi))

# 2. Clean the full dataset
patient_data_cleaned <- patient_data %>%
  select(-id) %>%  # Remove the useless 'id' column
  
  # Fix 'bmi'
  mutate(bmi = as.numeric(bmi)) %>%
  mutate(bmi = ifelse(is.na(bmi), mean_bmi, bmi)) %>% # Replace NA with mean
  
  # Convert numeric categories to factors
  mutate(stroke = factor(stroke, levels = c(0, 1), labels = c("No", "Yes")),
         hypertension = factor(hypertension, levels = c(0, 1), labels = c("No", "Yes")),
         heart_disease = factor(heart_disease, levels = c(0, 1), labels = c("No", "Yes"))) %>%
  
  # Convert all character columns to factors
  mutate(across(where(is.character), as.factor))

# 3. Remove 'Other' gender if it exists
if ("Other" %in% levels(patient_data_cleaned$gender)) {
  patient_data_cleaned <- patient_data_cleaned %>%
    filter(gender != "Other")
  print("Removed 'Other' from gender.")
}

# --- Final Check ---
print("--- Summary of NEW cleaned dataset ---")
summary(patient_data_cleaned)


# --- Step 3: Exploratory Data Analysis (EDA) ---
# Note: Plots will appear in the 'Plots' pane.
# We wrap them in print() to ensure they render.
print("--- Step 3: Generating EDA Plots ---")

print(
  ggplot(patient_data_cleaned, aes(x = stroke, fill = stroke)) +
    geom_bar() +
    labs(title = "Distribution of Stroke Cases (Class Imbalance)") +
    theme_minimal()
)

print(
  ggplot(patient_data_cleaned, aes(x = stroke, y = age, fill = stroke)) +
    geom_boxplot() +
    labs(title = "Age Distribution by Stroke Status") +
    theme_minimal()
)

print(
  ggplot(patient_data_cleaned, aes(x = hypertension, fill = stroke)) +
    geom_bar(position = "fill") +
    labs(title = "Proportion of Stroke by Hypertension Status") +
    theme_minimal()
)

# --- Step 4: Model Preparation (Splitting & Balancing) ---
print("--- Step 4: Splitting and Balancing Data ---")

# 1. Split the data
set.seed(123) # for reproducibility
train_index <- createDataPartition(patient_data_cleaned$stroke, 
                                   p = 0.8,
                                   list = FALSE)
train_data <- patient_data_cleaned[train_index, ]
test_data  <- patient_data_cleaned[-train_index, ]

print("Original distribution in Training Data:")
table(train_data$stroke)

# 2. Balance the Training Data using ROSE
set.seed(42)
train_data_balanced <- ROSE(stroke ~ ., data = train_data, N = nrow(train_data), p = 0.5)$data

print("Distribution in NEW Balanced Training Data:")
table(train_data_balanced$stroke)


# --- Step 5: Model Building and Validation ---
print("--- Step 5: Training and Validating Models ---")

# 1. Define Training Control (10-fold Cross-Validation)
train_control <- trainControl(method = "cv",          
                              number = 10,           
                              classProbs = TRUE,
                              summaryFunction = twoClassSummary,
                              savePredictions = "final") 

# 2. Train Logistic Regression
print("Training Logistic Regression model...")
set.seed(42)
model_glm <- train(stroke ~ ., 
                   data = train_data_balanced, 
                   method = "glm",
                   family = "binomial",
                   trControl = train_control,
                   metric = "ROC")

# 3. Train Random Forest
print("Training Random Forest model...")
set.seed(42)
model_rf <- train(stroke ~ ., 
                  data = train_data_balanced, 
                  method = "rf",
                  trControl = train_control,
                  metric = "ROC")

# 4. Compare Models
print("--- Comparison of Model Cross-Validation Results ---")
results <- resamples(list(Logistic = model_glm, RandomForest = model_rf))
print(summary(results))


# --- Step 6: Final Evaluation, Feature Importance & "Deployment" ---
print("--- Step 6: Final Evaluation on Test Data ---")

# Fix for factor levels mismatch
test_data$gender <- factor(test_data$gender, levels = levels(train_data_balanced$gender))

# 1. Make Predictions on the Test Set
predictions_rf <- predict(model_rf, newdata = test_data)

# 2. Create the Final Confusion Matrix
print("--- Final Confusion Matrix on Unseen Test Data ---")
final_results <- confusionMatrix(predictions_rf, test_data$stroke, positive = "Yes")
print(final_results)

# 3. Identify Most Important Features
print("--- Most Important Features (Risk Factors) ---")
feature_importance <- varImp(model_rf)
print(feature_importance)
print(
  plot(feature_importance, main = "Top Risk Factors for Stroke")
)

# 4. "Deploy" (Save) the Model
saveRDS(model_rf, "final_stroke_model.rds")

print("--- Project Complete ---")
print("Final model saved as 'final_stroke_model.rds'")