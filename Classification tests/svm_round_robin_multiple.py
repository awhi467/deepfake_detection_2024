from sklearn import svm, metrics
from sklearn.model_selection import KFold
import csv
import numpy as np
import os

# Specify the directory containing the CSV files
directory = 'integrated_bispectrum_data'  # Replace with the path to your directory

# Get a list of all CSV files in the specified directory and its subdirectories
csv_files = []
for root, dirs, files in os.walk(directory):
    for file in files:
        if file.endswith('.csv'):
            csv_files.append(os.path.join(root, file))

# Function to process each dataset and save metrics and ROC data to a CSV file
def process_dataset(file_path):
    print(f"Processing dataset: {file_path}")
    
    # Open and read the .csv file and convert data to a list
    with open(file_path, mode='r', encoding='utf-8') as file:
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

    # Lists to store metrics and ROC data for each fold
    accuracy_scores = []
    precision_scores = []
    recall_scores = []
    roc_data = []

    for fold_idx, (train_index, test_index) in enumerate(kf.split(features)):
        X_train = [features[i] for i in train_index]
        y_train = [targets[i] for i in train_index]
        X_test = [features[i] for i in test_index]
        y_test = [targets[i] for i in test_index]
        
        # Create an SVM Classifier with RBF kernel and probability estimates enabled
        clf = svm.SVC(kernel='rbf', probability=True)
        
        # Train the model using the training sets
        clf.fit(X_train, y_train)
        
        # Predict the response for test dataset
        y_pred = clf.predict(X_test)
        y_pred_proba = clf.predict_proba(X_test)[:, 1]  # Get probability estimates
        
        # Calculate metrics for the current fold
        accuracy = metrics.accuracy_score(y_test, y_pred)
        precision = metrics.precision_score(y_test, y_pred)
        recall = metrics.recall_score(y_test, y_pred)
        
        accuracy_scores.append(accuracy)
        precision_scores.append(precision)
        recall_scores.append(recall)
        
        # Compute ROC curve and ROC area for this fold
        fpr, tpr, _ = metrics.roc_curve(y_test, y_pred_proba)
        roc_auc = metrics.auc(fpr, tpr)

        # Store ROC data for this fold
        for fp, tp in zip(fpr, tpr):
            roc_data.append([fold_idx + 1, fp, tp, roc_auc])

    # Calculate average metrics for the current dataset
    avg_accuracy = np.mean(accuracy_scores)
    avg_precision = np.mean(precision_scores)
    avg_recall = np.mean(recall_scores)
    avg_roc_auc = np.mean(roc_auc)

    # Print average metrics for the current dataset
    print(f"Dataset: {file_path}")
    print(f"Average Accuracy: {avg_accuracy:.4f}")
    print(f"Average Precision: {avg_precision:.4f}")
    print(f"Average Recall: {avg_recall:.4f}")
    print(f"Average ROC AUC: {avg_roc_auc:.4f}")

    # Save ROC data to a CSV file
    base_filename = os.path.basename(file_path).replace('.csv', '')
    output_file = os.path.join('roc_output_data', f"{base_filename}_roc_data.csv")
    
    # Write ROC data to a CSV file
    with open(output_file, mode='w', newline='') as f:
        writer = csv.writer(f)
        writer.writerow(['Fold', 'FPR', 'TPR', 'ROC AUC'])
        writer.writerows(roc_data)

    print(f"ROC data saved to {output_file}")

# Directory to save the ROC data
os.makedirs('roc_output_data', exist_ok=True)

# Loop through each file and process the dataset
for file_path in csv_files:
    process_dataset(file_path)
