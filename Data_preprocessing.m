close all
clear

 % If your computer is not able to run this real-time, reduce the sample 
% rate or comment out the scalogram part
fs = 80; % Run at 50 Hz

a = arduino('/dev/ttyACM0', 'Mega2560', 'Libraries', 'I2C');  % Change to your arduino
imu = mpu6050(a);

buffer_length_sec = 2; % Seconds of data to store in buffer
accel = zeros(floor(buffer_length_sec * fs) + 1, 3); % Init buffer

t = 0:1/fs:(buffer_length_sec(end)); % Time vector

subplot(2, 1, 1)
plot_accel = plot(t, accel); % Set up accel plot
axis([0, buffer_length_sec, -50, 50]);

subplot(2, 1, 2)
plot_scale = image(zeros(224, 224, 3)); % Set up scalogram

tic % Start timer
last_read_time = 0;

i = 0;
% Run for 60 seconds
while(toc <= 60)
    current_read_time = toc;
    if (current_read_time - last_read_time) >= 1/fs
        i = i + 1;

        accel(1:end-1, :) = accel(2:end, :); % Shift values in FIFO buffer
        accel(end, :) = readAcceleration(imu);

        plot_accel(1).YData = accel(:, 1);
        plot_accel(2).YData = accel(:, 2);
        plot_accel(3).YData = accel(:, 3);

        % Only run scalogram every 3rd sample to save on compute time
        if mod(i, 3) == 0

        fb = cwtfilterbank('SignalLength', length(t), 'SamplingFrequency', fs, ...
            'VoicesPerOctave', 12);
        sig = accel(:, 1);
        [cfs, ~] = wt(fb, sig);
        cfs_abs = abs(cfs);
        accel_i = imresize(cfs_abs/8, [224 224]);


        fb = cwtfilterbank('SignalLength', length(t), 'SamplingFrequency', fs, ...
            'VoicesPerOctave', 12);
        sig = accel(:, 2);
        [cfs, ~] = wt(fb, sig);
        cfs_abs = abs(cfs);
        accel_i(:, :, 2) = imresize(cfs_abs/8, [224 224]);

        fb = cwtfilterbank('SignalLength', length(t), 'SamplingFrequency', fs, ...
            'VoicesPerOctave', 12);
        sig = accel(:, 3);
        [cfs, ~] = wt(fb, sig);
        cfs_abs = abs(cfs);
        accel_i(:, :, 3) = imresize(cfs_abs/8, [224 224]);

        if~(isempty(accel_i(accel_i>1)))
            accel_i(accel_i>1) = 1;
        end

        plot_scale.CData = accel_i;
        end

        last_read_time = current_read_time;
    end
end