Stroke Prediction Model: Final Report 

Project Analyst: Anshaa Shaikh  Date: 31/10/25 

1. Introduction & Project Objective 

The primary objective of this project was to build and validate a predictive model to identify patients at a high risk of stroke. This model is intended to be used by a healthcare organization to enhance clinical decision-making, allowing for early intervention and preventive measures for at-risk patients. 

2. Data and Methodology 

Data 

The analysis was performed on a dataset of 5,110 patient records (healthcare-dataset-stroke-data.csv) containing 11 clinical and demographic features, such as age, hypertension, average glucose level, and smoking status. 

Methodology 

Data Cleaning: The raw data was cleaned by removing irrelevant columns (e.g., id) and imputing missing bmi values with the dataset's mean. 

Class Imbalance: Exploratory analysis showed a severe class imbalance: only 4.8% of patients in the dataset had a stroke. 

Balancing (ROSE): To prevent the model from simply learning to "always predict No," the training data (80% of the total data) was balanced using the ROSE (Random Over-Sampling Examples) technique. This created a new training set with a 50/50 split of "Yes" and "No" stroke cases. 

Model Selection: Two models were trained and compared: Logistic Regression and Random Forest. The Random Forest model showed superior performance (ROC-AUC of 0.89 vs. 0.825) and was selected as the final model. 

3. Final Model Performance 

The final Random Forest model was evaluated on the 20% "test set" (1,021 patients) that it had never seen before. This provides a realistic estimate of its performance in a clinical setting. 

The most important metric is Sensitivity (Recall), which answers: "Of all the patients who actually had a stroke, what percentage did our model correctly identify?" 

Final Confusion Matrix: 
Confusion Matrix and Statistics 
 
          Reference 
Prediction  No Yes 
       No  726   9 
       Yes 246  40 
                                           
               Accuracy : 0.7502           
                 95% CI : (0.7225, 0.7765) 
    No Information Rate : 0.952            
    P-Value [Acc > NIR] : 1                
                                           
                  Kappa : 0.1709           
                                           
 Mcnemar's Test P-Value : <2e-16           
                                           
            Sensitivity : 0.81633          
            Specificity : 0.74691          
         Pos Pred Value : 0.13986          
         Neg Pred Value : 0.98776          
             Prevalence : 0.04799          
         Detection Rate : 0.03918          
   Detection Prevalence : 0.28012          
      Balanced Accuracy : 0.78162          
                                           
       'Positive' Class : Yes  
Key Performance Metrics: 

Sensitivity (Recall): [81.6%] 

Interpretation: The model successfully identified 81.6% of all stroke patients in the unseen test data. 

Specificity: [74.7%] 

Interpretation: The model successfully identified 74.7% of all healthy (non-stroke) patients. 

Precision: [14.0%] 

Interpretation: When the model predicted a patient was "High Risk," it was correct 14.0% of the time. 

(A note on Precision: The low 14.0% precision is a direct result of the severe class imbalance. Because strokes are so rare, the model "over-predicts" "Yes" to be safe, which is what we want. This is a normal trade-off for achieving a high Sensitivity.) 

 

4. Key Findings: Top Risk Factors 

The "Feature Importance" analysis from the model identified the most significant predictors of a stroke. This directly answers the objective to "identify the most important patient characteristics." 
Key Insights: 

Age is by far the most significant risk factor. 

Average Glucose Level is the second most important predictor. 

Hypertension and BMI are also major contributing factors. 

Factors like gender and Residence_type had a much lower impact on the model's predictions. 

5. Conclusion  

The project was successful. We have built a well-validated Random Forest model that can effectively identify high-risk stroke patients. 

The final, trained model has been "deployed" by being saved to the file final_stroke_model.rds. This file can now be loaded into any R-based application to make real-time predictions on new patients, fulfilling the project's core goal. 