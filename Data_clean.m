T = readtable('train.csv');
sample = datasample(T, 100, 'Replace', false);
date = datetime(sample.pickup_datetime, 'InputFormat', 'yyyy-MM-dd hh:mm:ss');

sample_month = month(date);
sample_day = day(date);
sample_hour = hour(date);
sample_minute = minute(date);

sample.Month = sample_month;
sample.Day = sample_day;
%sample.Hour = sample_hour;
sample.Time = (sample_hour + (sample_minute/60)); % this is the hour and minutes as fraction
%hideRequirementColumn(sample, "pickup_datetime");
sample.dropoff_datetime = [];

not_stored = sample.store_and_fwd_flag == "N";
sample.store_and_fwd_flag = double(not_stored); % converts to binary result

sample.Distance = deg2km(distance(sample.pickup_latitude, sample.pickup_longitude, sample.dropoff_latitude, sample.dropoff_longitude)); % takes account of curvature

sample.days_of_week_onehot = dummyvar(weekday(date));

%outliers, save sample, weather

W = readtable('weather_data_nyc.csv');
%weather_date = datetime(W.date, 'InputFormat', 'd-MM-yyy');

sample.comparable_date = day(datetime(sample.pickup_datetime, 'InputFormat', 'yyyy-MM-dd'), 'dayofyear');
W.comparable_date = day(datetime(W.date, 'InputFormat', 'dd-MM-yy'), 'dayofyear');
sample = join(sample, W, 'Keys', 'comparable_date');
sample.comparable_date = [];
sample.pickup_datetime = [];

sample = rmmissing(sample);
