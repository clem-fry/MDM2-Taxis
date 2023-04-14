clear all
load 'sample';
T2 = readtable('test_cleaned.csv');

X1train = sample.pickup_longitude;
X2train = sample.pickup_latitude;
Y1train = sample.dropoff_longitude;
Y2train = sample.dropoff_latitude ;

data = table(X1train, X2train, Y1train, Y2train);


treelong = fitrtree([X1train, X2train], Y1train);
treelat = fitrtree([X1train, X2train], Y2train);

X1test = T2.pickup_longitude;
X2test = T2.pickup_latitude;

Y1_pred = predict(treelong, [X1test,X2test]);
Y2_pred = predict(treelat, [X1test,X2test]);
fig1 = figure(1);
geoplot(X2test, X1test,'b.'); % Start points in red
hold on
 % Hold the plot for adding more data
geoplot(Y2_pred, Y1_pred,'r.'); % End points in green
hold off
% Plot the routes between the start and end points
fig2 = figure(2);
geoplot( [Y2_pred; X2test],[Y1_pred; X1test], 'k--',"LineWidth",0.001); % Routes in blue
