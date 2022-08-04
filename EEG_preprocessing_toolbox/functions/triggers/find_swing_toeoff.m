function [swg_pks, swg_locs, ...
    toff_pks, toff_locs, sig_filt] = find_swing_toeoff(sig,fs,leg,settings)

% Filter imu signal
order = settings.imu.processing.filter.order;
LP = settings.imu.processing.filter.LP;
[b,a] = butter(order, LP*2/fs);
sig_filt = filtfilt(b,a,sig);

% Find mid-swing peaks
[swg_pks, swg_locs] = findpeaks(sig_filt, ...
    'MinPeakDistance', settings.imu.processing.findpeak.min_dist*fs, ...
    'MinPeakHeight', settings.imu.processing.findpeak.(leg).min_height);

% Find toe-off
pre_swing = settings.imu.processing.findpeak.pre_peak*fs; % [samp]
n_pks = length(swg_locs);
toff_pks = nan(size(swg_locs));
toff_locs = nan(size(swg_locs));
for i = 1:n_pks
    win = swg_locs(i)-pre_swing+1:swg_locs(i);
    [p, l] = findpeaks(-sig_filt(win), ...
        'MinPeakProminence', settings.imu.processing.findpeak.min_pk_prom, ...
        'MinPeakHeight', settings.imu.processing.findpeak.min_pk_height); 
    toff_pks(i) = -p(end);
    toff_locs(i) = swg_locs(i)-(pre_swing-l(end));
end

end

