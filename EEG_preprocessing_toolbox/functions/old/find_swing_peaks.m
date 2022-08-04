function [peaks,locs,gyr_filt] = find_swing_peaks(gyr, min_height, settings)

% filter gyroscope
gyr_filt = filter_gyro(gyr, settings);

% Find mid-swing peaks
[peaks, locs] = findpeaks(gyr_filt, ...
    'MinPeakDistance', settings.imu.processing.findpeak.min_dist, ...
    'MinPeakHeight', min_height); 

end

