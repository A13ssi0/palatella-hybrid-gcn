function [trig_pks, trig_locs, swg_pks, swg_locs, sig_filt] = find_swing_trig(sig,fs,leg,bouts,settings)

% Parameters
th_perc = settings.imu.trigger.velocity_threshold.th_perc;

% Filter imu signal
order = settings.imu.processing.filter.order;
LP = settings.imu.processing.filter.LP;
[b,a] = butter(order, LP*2/fs);
sig_filt = filtfilt(b,a,sig);

% Find mid-swing peaks
[swg_pks, swg_locs] = findpeaks(sig_filt, ...
    'MinPeakDistance', settings.imu.processing.findpeak.min_dist*fs, ...
    'MinPeakHeight', settings.imu.processing.findpeak.(leg).min_height);

swg_pks = swg_pks((swg_locs>=bouts(1) & swg_locs<=bouts(2)) ...
    | (swg_locs>=bouts(3) & swg_locs<=bouts(4)));
swg_locs = swg_locs((swg_locs>=bouts(1) & swg_locs<=bouts(2)) ...
    | (swg_locs>=bouts(3) & swg_locs<=bouts(4)));

% Find trigger
pre_swing = settings.imu.processing.findpeak.pre_peak*fs; % [samp]
n_pks = length(swg_locs);
trig_pks = nan(size(swg_locs));
trig_locs = nan(size(swg_locs));
for i = 1:n_pks
    win = swg_locs(i)-pre_swing+1:swg_locs(i);
    [p, l] = findpeaks(-sig_filt(win), ...
        'MinPeakProminence', settings.imu.processing.findpeak.min_pk_prom, ...
        'MinPeakHeight', settings.imu.processing.findpeak.min_pk_height); 
    neg_pks = -p(end);
    prom = swg_pks(i) + neg_pks;
    l = find(sig_filt(win) < prom*th_perc);
    trig_locs(i) = swg_locs(i)-(pre_swing-l(end));
    trig_pks(i) = sig_filt(trig_locs(i));
end

end

