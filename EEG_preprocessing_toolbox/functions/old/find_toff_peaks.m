function [peaks,locs] = find_toff_peaks(gyr_filt, swg_locs, settings)

% Find toe-off
pre_swing = settings.imu.processing.findpeak.pre_peak; % [samp]
n_pks = length(swg_locs);
peaks = nan(size(swg_locs));
locs = nan(size(swg_locs));
for i = 1:n_pks
    win = swg_locs(i)-pre_swing+1:swg_locs(i);
    [p, l] = findpeaks(-gyr_filt(win), ...
        'MinPeakProminence', settings.imu.processing.findpeak.min_pk_prom, ...
        'MinPeakHeight', settings.imu.processing.findpeak.min_pk_height); 
    peaks(i) = -p(end);
    locs(i) = swg_locs(i)-(pre_swing-l(end));
%     plot(1:length(win),gyr_filt(win))
%     hold on, scatter(l(end),-p(end)), hold off
%     disp("")
end

end

