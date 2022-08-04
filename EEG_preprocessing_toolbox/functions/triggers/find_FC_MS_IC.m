function [FC_pks, FC_locs, MS_pks, MS_locs, ...
    IC_pks, IC_locs, sig_filt] = find_FC_MS_IC(sig,fs,leg,bouts,settings)

% Filter imu signal
order = settings.imu.processing.filter.order;
LP = settings.imu.processing.filter.(leg).LP;
[b,a] = butter(order, LP*2/fs);
sig_filt = filtfilt(b,a,sig);

% Find mid-swing peaks (MS)
[MS_pks, MS_locs] = findpeaks(sig_filt, ...
    'MinPeakDistance', settings.imu.processing.findpeak.min_dist*fs, ...
    'MinPeakHeight', settings.imu.processing.findpeak.(leg).min_height);

% Keep only MS peaks inside walking bouts
idx_bouts = zeros(length(MS_locs),1);
for p = 1:length(MS_locs)
    for i = 1:2:length(bouts)-1
        if MS_locs(p) >= bouts(i) && MS_locs(p) <= bouts(i+1)
            idx_bouts(p) = 1;
            break
        end       
    end
end
MS_pks = MS_pks(idx_bouts==1);
MS_locs = MS_locs(idx_bouts==1);

% Find heel strike (IC)
post_swing = settings.imu.processing.findpeak.post_peak*fs; % [samp]
n_pks = length(MS_locs);
IC_pks = nan(size(MS_locs));
IC_locs = nan(size(MS_locs));
for i = 1:n_pks
    win = MS_locs(i):MS_locs(i)+post_swing-1;
%     [p, l] = findpeaks(-sig_filt(win), ...
%         'MinPeakProminence', settings.imu.processing.findpeak.min_pk_prom, ...
%         'MinPeakHeight', settings.imu.processing.findpeak.min_pk_height); 
Pk_height = -10; %-20
Pk_prom = 1;
flag = true;
while flag
    flag = false;
[p, l] = findpeaks(-sig_filt(win), ...
            'MinPeakProminence', Pk_prom, ...
            'MinPeakHeight', Pk_height);
        if isempty(p)
            Pk_prom = Pk_prom-0.5;
            flag = true;
        end
end
    IC_pks(i) = -p(1);
    IC_locs(i) = MS_locs(i)+l(1)-1;
end

% Find toe-off (FC)
pre_swing = settings.imu.processing.findpeak.pre_peak*fs; % [samp]
n_pks = length(MS_locs);
FC_pks = nan(size(MS_locs));
FC_locs = nan(size(MS_locs));
% figure
for i = 1:n_pks
    win = MS_locs(i)-pre_swing+1:MS_locs(i);
%     d = -sig_filt(win);
d = sig_filt(win);
Pk_height = -80; %-80, 10
Pk_prom = 20;
flag = true;
while flag
    flag = false;
[p, l] = findpeaks(d, ...
            'MinPeakProminence', Pk_prom, ...
            'MinPeakHeight', Pk_height);
        if isempty(p)
            Pk_prom = Pk_prom-5;
            flag = true;
        end
end
        
%             FC_pks(i) = -p(end);
FC_pks(i) = p(end);
            FC_locs(i) = MS_locs(i)-(pre_swing-l(end));
end

end

