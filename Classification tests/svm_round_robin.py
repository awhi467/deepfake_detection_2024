from sklearn import svm, metrics
from sklearn.model_selection import train_test_split, KFold
import csv
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns

# Open and read the .csv file and convert data to a list
with open('ljspeech_bic256_ax_unwrapped_phase.csv', mode='r', encoding='utf-8') as file:
    data = list(csv.reader(file, delimiter=','))
data = data[1:]

features = []
targets = []

# Extract data from csv data
for row in data:
    current_features = [float(feature) for feature in row[1:]]
    current_target = float(row[0])
    features.append(current_features)
    targets.append(current_target)

# Implement k-fold cross-validation
kf = KFold(n_splits=5, shuffle=True, random_state=42)

# Store scores for each fold
accuracy_scores = []
precision_scores = []
recall_scores = []
fpr_list = []
tpr_list = []
roc_auc_list = []
confusion_matrices = []  # To store confusion matrices for each fold

for train_index, test_index in kf.split(features):
    X_train = [features[i] for i in train_index]
    y_train = [targets[i] for i in train_index]
    X_test = [features[i] for i in test_index]
    y_test = [targets[i] for i in test_index]
    
    # Create a SVM Classifier with RBF kernel and probability estimates enabled
    clf = svm.SVC(kernel='rbf', probability=True)
    
    # Train the model using the training sets
    clf.fit(X_train, y_train)
    
    # Predict the response for test dataset
    y_pred = clf.predict(X_test)
    y_pred_proba = clf.predict_proba(X_test)[:, 1]  # Get probability estimates
    
    # Calculate metrics for the current fold
    accuracy_scores.append(metrics.accuracy_score(y_test, y_pred))
    precision_scores.append(metrics.precision_score(y_test, y_pred))
    recall_scores.append(metrics.recall_score(y_test, y_pred))
    
    # Compute ROC curve and ROC area for this fold
    fpr, tpr, _ = metrics.roc_curve(y_test, y_pred_proba)
    roc_auc = metrics.auc(fpr, tpr)
    
    fpr_list.append(fpr)
    tpr_list.append(tpr)
    roc_auc_list.append(roc_auc)
    
    # Compute confusion matrix
    confusion_matrices.append(metrics.confusion_matrix(y_test, y_pred))

# Calculate and print average metrics across all folds
print("Average Accuracy:", np.mean(accuracy_scores))
print("Average Precision:", np.mean(precision_scores))
print("Average Recall:", np.mean(recall_scores))
print("Average ROC AUC:", np.mean(roc_auc_list))

# Plot the ROC curve for the last fold
print("fpr")
print(fpr_list[-1])
print("tpr")
print(tpr_list[-1])
plt.figure()
plt.plot(fpr_list[-1], tpr_list[-1], color='darkorange',
         lw=2, label='ROC curve (area = %0.2f)' % roc_auc_list[-1])
plt.plot([0, 1], [0, 1], color='navy', lw=2, linestyle='--')
plt.xlim([0.0, 1.0])
plt.ylim([0.0, 1.05])
plt.xlabel('False Positive Rate')
plt.ylabel('True Positive Rate')
plt.title('Receiver Operating Characteristic')
plt.legend(loc="lower right")
plt.show()

# Plot the confusion matrix for the last fold
plt.figure(figsize=(8, 6))
sns.heatmap(confusion_matrices[-1], annot=True, fmt="d", cmap="Blues")
plt.title('Confusion Matrix (Last Fold)')
plt.xlabel('Predicted')
plt.ylabel('Actual')
plt.show()
