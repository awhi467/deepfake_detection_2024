#Import scikit-learn dataset library
from sklearn import datasets
from sklearn import svm
from sklearn import metrics
from sklearn.model_selection import train_test_split
import csv

# Open and read the .csv file and convert data to a list
with open('tacotron2_BN_mag_ph_moments_vowels.csv', mode='r', encoding='utf-8') as file:
    data = list(csv.reader(file, delimiter=','))
data = data[1:]

features = []
targets = []

for row in data:
    current_features = row[2:]
    [float(feature) for feature in current_features]
    current_target = float(row[1])
    features.append(current_features)
    targets.append(current_target)

# Split dataset into training set and test set
X_train, X_test, y_train, y_test = train_test_split(features, targets, test_size=0.3) # 80% training and 20% test

#Create a svm Classifier
clf = svm.SVC(kernel='rbf') # Linear Kernel

#Train the model using the training sets
clf.fit(X_train, y_train)

#Predict the response for test dataset
y_pred = clf.predict(X_test)

# Model Accuracy: how often is the classifier correct?
print("Accuracy:",metrics.accuracy_score(y_test, y_pred))

# Model Precision: what percentage of positive tuples are labeled as such?
print("Precision:",metrics.precision_score(y_test, y_pred))

# Model Recall: what percentage of positive tuples are labelled as such?
print("Recall:",metrics.recall_score(y_test, y_pred))