%Fictree coder

%Data can be changed to analyze different components
load 'sample';
T2 = readtable('test_cleaned.csv');

Xtrain = sample.passenger_count;
Ytrain = sample.Time;
Xtest = T2.passenger_count;

tree = fitctree(Xtrain, Ytrain);
view(tree,'mode','graph');

YPred = predict(tree, Xtest);
scatter(Xtest,YPred)