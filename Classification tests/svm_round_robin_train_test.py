from sklearn import svm, metrics
import csv
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns  # For better visualization of the confusion matrix

# Function to load CSV data
def load_csv_data(file_path):
    with open(file_path, mode='r', encoding='utf-8') as file:
        data = list(csv.reader(file, delimiter=','))
    data = data[1:]  # Skip the header

    features = []
    targets = []

    for row in data:
        current_features = [float(feature) for feature in row[1:]]
        current_target = float(row[0])
        features.append(current_features)
        targets.append(current_target)

    return features, targets

# Load training and evaluation data
train_features, train_targets = load_csv_data('pk_bic256_ax_unwrapped_phase.csv')
test_features, test_targets = load_csv_data('ljspeech_bic256_ax_unwrapped_phase.csv')

# Create a SVM Classifier with RBF kernel and probability estimates enabled
clf = svm.SVC(kernel='rbf', probability=True)

# Train the model using the training set
clf.fit(train_features, train_targets)

# Predict the response for the evaluation dataset
y_pred = clf.predict(test_features)
y_pred_proba = clf.predict_proba(test_features)[:, 1]  # Get probability estimates

# Calculate evaluation metrics
accuracy = metrics.accuracy_score(test_targets, y_pred)
precision = metrics.precision_score(test_targets, y_pred)
recall = metrics.recall_score(test_targets, y_pred)

# Compute ROC curve and ROC area
fpr, tpr, _ = metrics.roc_curve(test_targets, y_pred_proba)
roc_auc = metrics.auc(fpr, tpr)

# Print the metrics
print("Accuracy:", accuracy)
print("Precision:", precision)
print("Recall:", recall)
print("ROC AUC:", roc_auc)

# Generate and plot the confusion matrix
conf_matrix = metrics.confusion_matrix(test_targets, y_pred)
print("Confusion Matrix:\n", conf_matrix)

plt.figure(figsize=(8, 6))
sns.heatmap(conf_matrix, annot=True, fmt='d', cmap='Blues', cbar=False,
            xticklabels=['Predicted Negative', 'Predicted Positive'],
            yticklabels=['Actual Negative', 'Actual Positive'])
plt.xlabel('Predicted Labels')
plt.ylabel('True Labels')
plt.title('Confusion Matrix')
plt.show()

# Plot the ROC curve
plt.figure()
plt.plot(fpr, tpr, color='darkorange',
         lw=2, label='ROC curve (area = %0.2f)' % roc_auc)
plt.plot([0, 1], [0, 1], color='navy', lw=2, linestyle='--')
plt.xlim([0.0, 1.0])
plt.ylim([0.0, 1.05])
plt.xlabel('False Positive Rate')
plt.ylabel('True Positive Rate')
plt.title('Receiver Operating Characteristic')
plt.legend(loc="lower right")
plt.show()
