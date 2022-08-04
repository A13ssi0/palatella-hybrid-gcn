function gyr_filt = filter_gyro(gyr, settings)

order = settings.imu.processing.filter.order;
LP = settings.imu.processing.filter.LP;
[b,a] = butter(order, LP*2/settings.fs);

gyr_filt = filtfilt(b,a,gyr);

end

