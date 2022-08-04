function [swg_pks, swg_locs, sig_filt] = find_swing(sig,fs,leg,bouts,settings)

% Filter imu signal
order = settings.imu.processing.filter.order;
LP = settings.imu.processing.filter.LP;
[b,a] = butter(order, LP*2/fs);
sig_filt = filtfilt(b,a,sig);

% Find mid-swing peaks
[swg_pks, swg_locs] = findpeaks(sig_filt, ...
    'MinPeakDistance', settings.imu.processing.findpeak.min_dist*fs, ...
    'MinPeakHeight', settings.imu.processing.findpeak.(leg).min_height);

% Keep only swing peaks inside walking bouts
idx_bouts = zeros(length(swg_locs),1);
for p = 1:length(swg_locs)
    for i = 1:2:length(bouts)-1
        if swg_locs(p) >= bouts(i) && swg_locs(p) <= bouts(i+1)
            idx_bouts(p) = 1;
            break
        end       
    end
end
swg_pks = swg_pks(idx_bouts==1);
swg_locs = swg_locs(idx_bouts==1);

% swg_pks = swg_pks((swg_locs>=bouts(1) & swg_locs<=bouts(2)) ...
%     | (swg_locs>=bouts(3) & swg_locs<=bouts(4)));
% swg_locs = swg_locs((swg_locs>=bouts(1) & swg_locs<=bouts(2)) ...
%     | (swg_locs>=bouts(3) & swg_locs<=bouts(4)));

end

