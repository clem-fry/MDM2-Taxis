clear all
load 'sample';
T2 = readtable('test_cleaned.csv');

X1train = sample.pickup_longitude;
X2train = sample.pickup_latitude;
Ytrain = sample.Time;
tree = fitrtree([X1train, X2train], Ytrain);
X1test = T2.pickup_longitude;
X2test = T2.pickup_latitude;
Y_pred = predict(tree, [X1test,X2test]);
fig1 = figure(1);
scatter3(X1test,X2test,Y_pred)
xlabel('Longitude')
ylabel('Latitude')
zlabel('Time(minutes)')

