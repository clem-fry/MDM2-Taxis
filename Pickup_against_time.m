clear all; close all; clc;
warning off;

%% Import sample data
%Data_clean;
sample = readtable('clean_train.csv');

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
lat_min = 40.59;
lat_max = 40.9;
lon_min = -74.15;
lon_max = -73.8;

figure('units','normalized','outerposition',[0 0 1 1]);

obj = VideoWriter('animation', 'MPEG-4');
obj.Quality = 100;
obj.FrameRate = 1.5;
open(obj);

for i = 0:23
    Idx = find(sample.Hour == i);
    lat = sample.pickup_latitude(Idx);
    lon = sample.pickup_longitude(Idx);
    total = [total numel(lat)];

    %First subplot
    subplot(1,2,1);
    geoscatter(lat, lon, 'filled', 'LineWidth',1);
    hold on;
    geobasemap('satellite');
    geolimits([lat_min lat_max],[lon_min lon_max]);
    hold off;
    legend('Taxi pickup points', 'FontSize', 15);
    title('All taxi pickups from sample, across the current hour', 'FontSize', 15);

    %Second subplot
    subplot(1,2,2);
    geodensityplot(lat, lon, 'FaceColor','interp');
    %dp = geodensityplot(lat,lon);
    gx = gca;
    gx.AlphaScale = 'log';
    %dp.FaceColor = 'interp';
    colormap hot
    hold on;
    geobasemap('satellite');
    geolimits([lat_min lat_max],[lon_min lon_max]);
    hold off;
    legend('Pickup density', 'FontSize', 15);
    title('The density of taxi pickups from sample, across the current hour', 'FontSize', 15);

    %Plot title
    title_string = ["Taxi sample data between: " times(i+1)];
    sgtitle(title_string, 'FontSize', 25);

    %Add current frame to video
    f = getframe(gcf);
    writeVideo(obj,f);


    pause(0.1);
end

obj.close();

%% Descriptive statistics

%Bar chart
hour = 1:24;
figure('units','normalized','outerposition',[0 0 1 1]);
bar(hour, total);
xlim([0.35 24.65]);
xlabel('Hour of day (ranging from the first hour to the twenty-fourth hour)');
ylabel('Total number of pickups');
title('Total number of pickups from sample dataset, during each hour', 'FontSize', 15);


%Busiest time of day
[max idx] = max(total);
fprintf('The busiest time of day is between %s, with %d total pick-ups within this hour.\n', string(times(idx)) , max)

%Quietest time of day
[min idx] = min(total);
fprintf('The quietest time of day is between %s, with %d total pick-ups within this hour.\n', string(times(idx)) , min)


%% Create a density matrix

div = 100; %Number of divisions

x = linspace(lon_min, lon_max, div);
y = linspace(lat_min, lat_max, div);

DensityMat = zeros(div, div, 24);

for hour = 0:23
    for i=1:(div-1)
        for j = 1:(div-1)
            idx1 = find((x(i) < sample.pickup_longitude) & (sample.pickup_longitude < x(i+1)));
            idx2 = find((y(j) < sample.pickup_latitude) & (sample.pickup_latitude < y(j+1)));
            idx3 = find(sample.Hour == hour);

            %add conditional statements to retrieve data on upper limits
    
            n = numel( intersect(  intersect(idx1, idx2), idx3 ));
            DensityMat(i, j, hour+1) = n;
    
        end
    end
end

DensityMat = flipud(DensityMat);

% Density matrix visualised for each hour of the day
figure;
tiledlayout('flow');
for i = 1:24
    nexttile;
    image = DensityMat(:, :, i);
    imagesc(squeeze(image));
    %ADD TITLES AND LABELS
end


%% ML Algorithm

%Re-shape density matrix to 1D

DensityMat1D = reshape(DensityMat, 1,[], 24);






