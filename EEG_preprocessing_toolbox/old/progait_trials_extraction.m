clc
clear
close all

%% Settings data
progait_settings;
load Channel_Info.mat
subj_type = 'CTRL'; % CTRL, PTRL
subj_num = 1;
data_mode = 'A';
data_file = 1;

savedir = strcat(settings.dirpath,'processed_data/', subj_type, '/', ...
    subj_type, num2str(subj_num, '%03d'), '/EcsoWalking/trials/');
if ~exist(savedir, 'dir')
    mkdir(savedir)
end

%% Load
% Load data
datapath = strcat(settings.dirpath, subj_type, '/', ...
    subj_type, num2str(subj_num, '%03d'), '/Mat/EcsoWalking/', ...
    'S', num2str(subj_num), '_ekso_mode', data_mode, '_', num2str(data_file), '.mat');
load(datapath)

% Load triggers
triggerpath = strcat(settings.dirpath, 'processed_data/', subj_type, '/', ...
    subj_type, num2str(subj_num, '%03d'), '/EcsoWalking/triggers/', ...
    'S', num2str(subj_num), '_ekso_mode', data_mode, '_', num2str(data_file), '_triggers.mat');
load(triggerpath)

%% Trials computation
% Merge left and right triggers
LEFT_LABEL = settings.leg.L.label;
RIGHT_LABEL = settings.leg.R.label;
n_left = length(triggers.L.swing.locs);
n_right = length(triggers.R.swing.locs);
step_order = [LEFT_LABEL*ones(n_left,1); RIGHT_LABEL*ones(n_right,1)];

swg_peaks = [triggers.L.swing.peaks; triggers.R.swing.peaks];
swg_locs = [triggers.L.swing.locs; triggers.R.swing.locs];
[swg_locs, sort_idx] = sort(swg_locs);
step_order = step_order(sort_idx);
swg_peaks = swg_peaks(sort_idx);

% Filter gyro
L_IMU = settings.imu.shank.gyr.L.labels(3);
R_IMU = settings.imu.shank.gyr.R.labels(3);
L_gyr = data(:,fidx(L_IMU, ChannelInfo));
R_gyr = -data(:,fidx(R_IMU, ChannelInfo));
L_gyr_filt = filter_gyro(L_gyr, settings);
R_gyr_filt = filter_gyro(R_gyr, settings);

% Find step onset
pre_swing = settings.imu.processing.findpeak.pre_peak; % [samp]
n_trials = length(swg_locs);
s_onset = nan(n_trials, 1);
for t = 1:n_trials
    win = swg_locs(t)-pre_swing+1:swg_locs(t);
    if step_order(t) == LEFT_LABEL
        idx = find(L_gyr_filt(win) <= 0.5*swg_peaks(t));      
    elseif step_order(t) == RIGHT_LABEL
        idx = find(R_gyr_filt(win) <= 0.5*swg_peaks(t));
    end
    s_onset(t) = swg_locs(t)-(pre_swing-idx(end));
end

figure
plot(1:length(L_gyr_filt), L_gyr_filt, 1:length(R_gyr_filt), R_gyr_filt)
hold on
for t = 1:n_trials
    xline(s_onset(t))
end
hold off

% Extract trials
Tk = zeros(size(data,1),1);
Lk = zeros(size(data,1),1);
for t = 1:n_trials
    t_start = s_onset(t) + settings.step_epoch(1)*settings.fs;
    t_stop = s_onset(t) + settings.step_epoch(2)*settings.fs;
    
    Tk(t_start:t_stop) = t*ones(t_stop-t_start+1, 1);
    Lk(t_start:t_stop) = step_order(t)*ones(t_stop-t_start+1, 1);
end









