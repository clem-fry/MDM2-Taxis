%Fictree coder
load 'sample';

Xtrain = sample.passenger_count;
Ytrain = sample.Time;
tree = fitctree(Xtrain, Ytrain);
view(tree,'mode','graph')