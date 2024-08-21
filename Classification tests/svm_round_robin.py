from sklearn import svm, metrics
from sklearn.model_selection import train_test_split, KFold
import csv
import numpy as np

# Open and read the .csv file and convert data to a list
with open('ljspeech_sk512_rad128.csv', mode='r', encoding='utf-8') as file:
    data = list(csv.reader(file, delimiter=','))
data = data[1:]

features = []
targets = []

for row in data:
    current_features = row[1:]
    [float(feature) for feature in current_features]
    current_target = float(row[0])
    features.append(current_features)
    targets.append(current_target)

# Implement k-fold cross-validation
kf = KFold(n_splits=5, shuffle=True, random_state=42)

# Store scores for each fold
accuracy_scores = []
precision_scores = []
recall_scores = []

for train_index, test_index in kf.split(features):
    X_train = []
    y_train = []
    X_test = []
    y_test = []

    for i in train_index:
        X_train.append(features[i])
        y_train.append(targets[i])

    for i in test_index:
        X_test.append(features[i])
        y_test.append(targets[i])

    #X_train, X_test = features[train_index], features[test_index]
    #y_train, y_test = targets[train_index], targets[test_index]
    
    # Create a SVM Classifier with RBF kernel
    clf = svm.SVC(kernel='rbf')
    
    # Train the model using the training sets
    clf.fit(X_train, y_train)
    
    # Predict the response for test dataset
    y_pred = clf.predict(X_test)
    
    # Calculate metrics for the current fold
    accuracy_scores.append(metrics.accuracy_score(y_test, y_pred))
    precision_scores.append(metrics.precision_score(y_test, y_pred))
    recall_scores.append(metrics.recall_score(y_test, y_pred))

# Calculate and print average metrics across all folds
print("Average Accuracy:", np.mean(accuracy_scores))
print("Average Precision:", np.mean(precision_scores))
print("Average Recall:", np.mean(recall_scores))

# Note: To evaluate the final model on a separate test set, you can use the following code:

# Split dataset into training set and test set (adjust test_size as needed)
X_train, X_test, y_train, y_test = train_test_split(features, targets, test_size=0.2, random_state=42)

# Train the model using the entire training set
clf_final = svm.SVC(kernel='rbf')
clf_final.fit(X_train, y_train)

# Predict the response for test dataset
y_pred_final = clf_final.predict(X_test)

# Calculate and print metrics on the test set
print("\nTest Accuracy:", metrics.accuracy_score(y_test, y_pred_final))
print("Test Precision:", metrics.precision_score(y_test, y_pred_final))
print("Test Recall:", metrics.recall_score(y_test, y_pred_final))