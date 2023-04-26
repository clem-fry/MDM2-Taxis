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
obj.FrameRate = 2;
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
xlabel('Hour of day (ranging from the first hour to the twenty-fourth hour)', 'FontSize', 15);
ylabel('Total number of pickups', 'FontSize', 15);
title('Total number of pickups from sample dataset, during each hour', 'FontSize', 15);


%Busiest time of day
[maxDay idx] = max(total);
fprintf('The busiest time of day is between %s, with %d total pick-ups within this hour.\n', string(times(idx)) , maxDay)

%Quietest time of day
[minDay idx] = min(total);
fprintf('The quietest time of day is between %s, with %d total pick-ups within this hour.\n', string(times(idx)) , minDay)


%% Create a density matrix

div = 100; %Number of divisions. TO-DO: A HYPERPARAMETER TO TUNE??

x = linspace(lon_min, lon_max, div);
y = linspace(lat_min, lat_max, div);

DensityMat = zeros(div, div, 24);

for hour = 0:23
    for i=1:(div-1)
        for j = 1:(div-1)
            idx1 = find((x(i) <= sample.pickup_longitude) & (sample.pickup_longitude < x(i+1)));
            idx2 = find((y(j) <= sample.pickup_latitude) & (sample.pickup_latitude < y(j+1)));
            idx3 = find(sample.Hour == hour);

            %add conditional statements to retrieve data on upper limits
    
            n = numel( intersect(  intersect(idx1, idx2), idx3 ));
            DensityMat(i, j, hour+1) = n;
    
        end
    end
    DensityMat(:, :, hour+1) = DensityMat(:, :, hour+1) ./ max(DensityMat(:, :, hour+1));
end

DensityMat = flipud(DensityMat);

% Density matrix (training data) visualised for each hour of the day
figure('units','normalized','outerposition',[0 0 1 1]);
tiledlayout('flow');
for i = 1:24
    nexttile;
    image = DensityMat(:, :, i);
    imagesc(squeeze(image));
    title_str = ['Hour ', num2str(i)];
    title(title_str, 'FontSize',15);
end
sgtitle('Visualised Density Matrix for the Training Data, for each Hour of the Day', 'Fontsize', 20);


%Create a video from above
obj = VideoWriter('animationTrainMat', 'MPEG-4');
obj.Quality = 100;
obj.FrameRate = 2;
open(obj);
figure;
for i = 1:24
    image = DensityMat(:, :, i);
    imagesc(squeeze(image));
    title_str = ['Hour ', num2str(i)];
    title(title_str, 'FontSize',15);
    %Add current frame to video
    f = getframe(gcf);
    writeVideo(obj,f);
    pause(0.1);
end
obj.close();

%% ML Algorithm - predict local pickup density by location

[Xloc, Yloc, Zloc] = meshgrid(1:div, 1:div, 1:24);
Xloc = Xloc(:);
Yloc = Yloc(:);
Zloc = Zloc(:);
locations = [Xloc, Yloc, Zloc];


%%
svmr = fitrsvm(locations, DensityMat(:)); %Support vector machine regression


%% Now import test data to find accuracy

testSample = readtable('test_cleaned.csv');

%Clean up
testSample.Hour = floor(testSample.Time);
testSample(find(testSample.pickup_longitude < lon_min),:) = [];
testSample(find(testSample.pickup_longitude >= lon_max),:) = [];
testSample(find(testSample.pickup_latitude < lat_min),:) = [];
testSample(find(testSample.pickup_latitude >= lat_max),:) = [];


%Create a density matrix for the test data

testDensityMat = zeros(div, div, 24);

for hour = 0:23
    for i=1:(div-1)
        for j = 1:(div-1)
            idx1 = find((x(i) <= testSample.pickup_longitude) & (testSample.pickup_longitude < x(i+1)));
            idx2 = find((y(j) <= testSample.pickup_latitude) & (testSample.pickup_latitude < y(j+1)));
            idx3 = find(testSample.Hour == hour);

            %add conditional statements to retrieve data on upper limits
    
            n = numel( intersect(  intersect(idx1, idx2), idx3 ));
            testDensityMat(i, j, hour+1) = n;
    
        end
    end
    testDensityMat(:, :, hour+1) = testDensityMat(:, :, hour+1) ./ max(testDensityMat(:, :, hour+1));
end

testDensityMat = flipud(testDensityMat);


% Density matrix (testing data) visualised for each hour of the day
figure('units','normalized','outerposition',[0 0 1 1]);
tiledlayout('flow');
for i = 1:24
    nexttile;
    image = testDensityMat(:, :, i);
    imagesc(squeeze(image));
    title_str = ['Hour ', num2str(i)];
    title(title_str, 'FontSize',15);
end
sgtitle('Visualised Density Matrix for the Testing Data, for each Hour of the Day', 'Fontsize', 20);


% Test data:
Xtest = [testSample.pickup_longitude, testSample.pickup_latitude, randi([0, 23], size(testSample,1), 1)];
Xtest(:, 1) = ((Xtest(:, 1) - x(1)) ./ (x(2)-x(1))) + 1; %NOT quite correct??
Xtest(:, 2) = ((Xtest(:, 2) - y(1)) ./ (y(2)-y(1))) + 1; %NOT quite correct??
Xtest(:, 3) = (Xtest(:, 3) + 1);


%%
%Create a predictor function
Ypred = predict(svmr, Xtest);

% Calculate true Y values
Ytrue = zeros(size(testSample, 1), 1);
for i = 1:size(testSample, 1)
    pos1 = (find(x > testSample.pickup_longitude(i), 1)) - 1;
    pos2 = (find(y > testSample.pickup_latitude(i), 1)) - 1;
    pos3 = testSample.Hour(i) + 1; 
    Ytrue(i, 1) = testDensityMat(pos1, pos2, pos3);
end


%%
% Calculate RMSE
RMSE = sqrt(mean((Ytrue - Ypred).^2));

% Display RMSE
fprintf('Root mean squared error = %f\n', RMSE);

%Mean squared error
mae = meanabs(Ypred - Ytrue);

% Display the result
fprintf('Mean squared error = %f\n', mae);
