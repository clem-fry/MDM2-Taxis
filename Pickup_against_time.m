clear all; close all; clc;

%% Import sample data
Data_clean;

%% Define times
times = [{'Midnight and 1am'}];

for i = 1:10
    stringconvert = [ num2str(i) 'am and ' num2str(i+1) 'am'];
    times = [times {stringconvert}];
end

times = [times {'11am and noon'} {'Noon and 1pm'}];

for i = 1:10
    stringconvert = [ num2str(i) 'pm and ' num2str(i+1) 'pm'];
    times = [times {stringconvert}];
end

times = [times {'11pm and midnight'}];

%% Begin geoscatter

total = [];
lon_min = min(sample.pickup_longitude) - 0.05;
lon_max = max(sample.pickup_longitude) + 0.05;
lat_min = min(sample.pickup_latitude) - 0.05;
lat_max = max(sample.pickup_latitude) + 0.05;

figure;
obj = VideoWriter('animation', 'MPEG-4');
obj.Quality = 100;
obj.FrameRate = 1.5;
open(obj);

for i = 0:23
    Idx = find(sample.Hour == i);
    lat = sample.pickup_latitude(Idx);
    lon = sample.pickup_longitude(Idx);

    total = [total numel(lat)];

    geoscatter(lat, lon, 'filled');

    hold on;
    geobasemap('satellite');
    geolimits([lat_min lat_max],[lon_min lon_max]);

    hold off;
    title_string = ["All taxi pickups from sample, between: " times(i+1)];
    title(title_string, 'FontSize', 15);

    f = getframe(gcf);
    writeVideo(obj,f);

    pause(0.5);
end

obj.close();

%% Descriptive statistics

%Bar chart
hour = 1:24;
figure;
bar(hour, total);
xlabel('Hour of day (ranging from the first hour to the twenty-fourth hour)');
ylabel('Total number of pickups');
title('Total number of pickups from sample dataset, during each hour', 'FontSize', 15);


%Busiest time of day
[max idx] = max(total);
fprintf('The busiest time of day is between %s, with %d total pick-ups within this hour.\n', string(times(idx)) , max)

%Quietest time of day
[min idx] = min(total);
fprintf('The quietest time of day is between %s, with %d total pick-ups within this hour.\n', string(times(idx)) , min)

