load('sample')

sample.av_speed = ((sample.Distance)./(sample.trip_duration) ) *3600;
display(sample);

meanhour = zeros(1, 24);

for i = 0:23
    idx = find(sample.Hour == i);
    hourlyspeed = sample.av_speed(idx);
    M = mean(hourlyspeed);
    meanhour(i+1) = M ; 


end

bar(meanhour)
xlabel('Hour of the day')
ylabel('KPH')
title('Average speed throughout the day')
xlim([0 24])