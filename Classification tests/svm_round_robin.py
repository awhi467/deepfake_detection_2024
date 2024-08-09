# Import necessary libraries
from sklearn import datasets
from sklearn import svm
from sklearn import metrics
from sklearn.model_selection import train_test_split, KFold
import csv
import numpy as np

# Open and read the .csv file and convert data to a list
with open('ljspeech_rad40.csv', mode='r', encoding='utf-8') as file:
    data = list(csv.reader(file, delimiter=','))

features = []
targets = []

for row in data:
    current_features = list(map(float, row[1:]))  # Convert features to float
    current_target = float(row[0])  # Convert target to float
    features.append(current_features)
    targets.append(current_target)

# Convert lists to numpy arrays for better handling
X = np.array(features)
y = np.array(targets)

# Define the number of folds for cross-validation
k = 10  # You can set this to any number you prefer

# Create a KFold object
kf = KFold(n_splits=k, shuffle=True, random_state=42)

# Initialize lists to store metrics
accuracies = []
precisions = []
recalls = []

# Perform k-fold cross-validation
for train_index, test_index in kf.split(X):
    X_train, X_test = X[train_index], X[test_index]
    y_train, y_test = y[train_index], y[test_index]
    
    # Create a SVM Classifier
    clf = svm.SVC(kernel='rbf')  # Radial Basis Function Kernel
    
    # Train the model using the training sets
    clf.fit(X_train, y_train)
    
    # Predict the response for test dataset
    y_pred = clf.predict(X_test)
    
    # Calculate metrics
    accuracies.append(metrics.accuracy_score(y_test, y_pred))
    precisions.append(metrics.precision_score(y_test, y_pred, zero_division=0))
    recalls.append(metrics.recall_score(y_test, y_pred, zero_division=0))

# Calculate average metrics
print("Average Accuracy:", np.mean(accuracies))
print("Average Precision:", np.mean(precisions))
print("Average Recall:", np.mean(recalls))