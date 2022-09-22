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
    subj_type, num2str(subj_num, '%03d'), '/EcsoWalking/triggers/');
if ~exist(savedir, 'dir')
    mkdir(savedir)
end

%% Load data
% dataset = [];
% Rk = [];
% for f = data_files
%     datapath = strcat(settings.dirpath, subj_type, '/', ...
%         subj_type, num2str(subj_num, '%03d'), '/Mat/EcsoWalking/', ...
%         'S', num2str(subj_num), '_ekso_mode', data_mode, '_', num2str(f), '.mat');
%     load(datapath)
%     dataset = [dataset; data];
%     Rk = [Rk; f*ones(size(data,1),1)];
% end

datapath = strcat(settings.dirpath, subj_type, '/', ...
    subj_type, num2str(subj_num, '%03d'), '/Mat/EcsoWalking/', ...
    'S', num2str(subj_num), '_ekso_mode', data_mode, '_', num2str(data_file), '.mat');
load(datapath)

%% IMU trigger detection
L_IMU = settings.imu.shank.gyr.L.labels(3);
R_IMU = settings.imu.shank.gyr.R.labels(3);
shank_L_speed = data(:,fidx(L_IMU, ChannelInfo));
shank_R_speed = -data(:,fidx(R_IMU, ChannelInfo));
min_pk_height_L = 15;
min_pk_height_R= 20;

[L_swg_pks, L_swg_locs, L_gyr_filt] = find_swing_peaks(shank_L_speed,...
    min_pk_height_L, settings); 
[R_swg_pks, R_swg_locs, R_gyr_filt] = find_swing_peaks(shank_R_speed,...
    min_pk_height_R, settings); 

figure
plot(1:length(L_gyr_filt), L_gyr_filt, 1:length(R_gyr_filt), R_gyr_filt)
legend(cat(1,L_IMU, R_IMU))
hold on
scatter(L_swg_locs, L_swg_pks, 'bo');
scatter(R_swg_locs, R_swg_pks, 'ro');

[L_toff_pks, L_toff_locs] = find_toff_peaks(L_gyr_filt,...
    L_swg_locs, settings); 
[R_toff_pks, R_toff_locs] = find_toff_peaks(R_gyr_filt,...
    R_swg_locs, settings); 

scatter(L_toff_locs, L_toff_pks, 'bo');
scatter(R_toff_locs, R_toff_pks, 'ro');
hold off

%% Save triggers
triggers.L.swing.peaks = L_swg_pks;
triggers.L.swing.locs = L_swg_locs;
triggers.L.toeoff.peaks = L_toff_pks;
triggers.L.toeoff.locs = L_toff_locs;

triggers.R.swing.peaks = R_swg_pks;
triggers.R.swing.locs = R_swg_locs;
triggers.R.toeoff.peaks = R_toff_pks;
triggers.R.toeoff.locs = R_toff_locs;

filename = strcat('S', num2str(subj_num), '_ekso_mode', data_mode, '_', num2str(data_file), '_triggers.mat');
save([savedir, filename], 'triggers')

 
 
 
 