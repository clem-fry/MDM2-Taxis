load('sample')

sample.av_speed = ((sample.Distance)./(sample.trip_duration))*3600;
display(sample);

velocity = sample.av_speed;
TOD = sample.Time;
X = [velocity, TOD];
[cidx, ctrs, RSS] = kmeans(X, 4);

fig1 = figure(1);
scatter(TOD, velocity)
xlabel('Hour of the day');
ylabel('Speed')


fig2 = figure(2);
gscatter(X(:,2), X(:,1), cidx);
xlabel('Hour of the day');
ylabel('Speed')

