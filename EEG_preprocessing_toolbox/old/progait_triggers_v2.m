clc
clear
close all

%% Settings data
progait_settings;
load Channel_Info.mat
subj_type = 'CTRL'; % CTRL, PTRL
subj_num = 1;
data_mode = 'A';
data_file = 2;

%% Load data
datapath = strcat(settings.dirpath, subj_type, '/', ...
    subj_type, num2str(subj_num, '%03d'), '/Mat/EcsoWalking/', ...
    'S', num2str(subj_num), '_ekso_mode', data_mode, '_', num2str(data_file), '.mat');
load(datapath)

%% IMU trigger detection
R_IMU = settings.imu.shank.acc.R.labels(3);
shank_R_acc = data(:,fidx(R_IMU, ChannelInfo));

del = 21000;
fin = 137000;
sig = detrend(shank_R_acc(del:fin));

figure, plot(sig)

%%
triggers = compute_tko_triggers(sig, settings.fs);




 
 
 
 