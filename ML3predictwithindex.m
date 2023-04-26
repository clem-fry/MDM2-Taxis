clear all
load 'sample';
T2 = readtable('clean_test(from_train).csv');

X1train = sample.pickup_longitude;
X2train = sample.pickup_latitude;
Y1train = sample.dropoff_longitude;
Y2train = sample.dropoff_latitude ;

index = find(sample.Hour == 1 | sample.Month == 1 | sample.Day == 1);

X1subset = X1train(index,:);
X2subset = X2train(index,:);
Y1subset = Y1train(index,:);
Y2subset = Y2train(index,:);



X1test = T2.pickup_longitude;
X2test = T2.pickup_latitude;

index2 = find(T2.Hour == 1 | T2.Month == 1 | T2.Day == 1);
X1testsubset = X1test(index2,:);
X2testsubset = X2test(index2,:);


treelong = fitrtree([X1subset, X2subset], Y1subset);
treelat = fitrtree([X1subset, X2subset], Y2subset);
cv1 = crossval(treelong, 'kfold', 10);
kfoldlosslong = kfoldLoss(cv1)
cv2 = crossval(treelat,'kfold',10);
kfoldlosslat = kfoldLoss(cv2)

Y1_pred = predict(treelong, [X1testsubset,X2testsubset]);
Y2_pred = predict(treelat, [X1testsubset,X2testsubset]);
fig1 = figure(1);

fig1 = figure(1);
geoplot(X2test, X1test,'b.'); % Start points in red
hold on
 % Hold the plot for adding more data
geoplot(Y2_pred, Y1_pred,'r.'); % End points in green
hold off



Y1time = sample.Time;
Y1timesubset = Y1time(index,:);

treetime = fitrtree([X1subset, X2subset], Y1timesubset);
Y_predtime = predict(treetime, [X1testsubset,X2testsubset]);
fig3 = figure(3);
scatter3(X1testsubset,X2testsubset,Y_predtime)
xlabel('Longitude')
ylabel('Latitude')
zlabel('Time(minutes)')
title("Time at 1am january 1st ")
cv3 = crossval(treetime,'kfold',10);
kfoldlosstime = kfoldLoss(cv3)






Ydistance = sample.Distance;
Ydistancesubset = Ydistance(index,:);

treedistance = fitrtree([X1subset, X2subset], Ydistancesubset);
Y_preddistance = predict(treedistance, [X1testsubset,X2testsubset]);
fig5= figure(5);
scatter3(X1testsubset,X2testsubset,Y_preddistance)
xlabel('Longitude')
ylabel('Latitude')
zlabel('Distance')
title("Distances at 1am on january 1st")
cv4 = crossval(treedistance,'kfold',10);
kfoldlossdist = kfoldLoss(cv4)





