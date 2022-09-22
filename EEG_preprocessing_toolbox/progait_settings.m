%% General settings
settings.dirpath = 'C:\Users\aless\OneDrive\Desktop\Tesi\Subject1';
settings.savedir = 'processed_data_new\';
settings.fs = 1000; % [Hz]
settings.step_epoch = [-2.5 7.4999]; % [sec] %

%% Labels settings
% settings.emg.labels = {'Ch1','Ch2','Ch3','Ch4','Ch5','Ch6','Ch7'};
% settings.eeg.labels = {'FP1';'FPZ';'FP2';'AF7';'AF3';'AF4';'AF8';'F7';'F5';'F3';'F1';'FZ';'F2';'F4';'F6';'F8';'FT7';'FC5';'FC3';'FC1';'FCZ';'FC2';'FC4';'FC6';'FT8';'T7';'C5';'C3';'C1';'CZ';'C2';'C4';'C6';'T8';'TP7';'CP5';'CP3';'CP1';'CPZ';'CP2';'CP4';'CP6';'TP8';'P7';'P5';'P3';'P1';'PZ';'P2';'P4';'P6';'P8';'PO7';'PO3';'POZ';'PO4';'PO8';'O1';'OZ';'O2';'F9';'F10';'P9';'P10'};

%% EMG settings
% settings.emg.preprocessing.filter.HP.order = 8;
% settings.emg.preprocessing.filter.HP.fcutoff = 4;
% settings.emg.preprocessing.filter.LP.order = 16;
% settings.emg.preprocessing.filter.LP.fcutoff = 100;

% settings.emg.preprocessing.filter.HP.order = 4;
% settings.emg.preprocessing.filter.HP.fcutoff = 5;

% %% EEG settings
settings.eeg.fs = 1000; % [Hz]
% 
% settings.eeg.exclude = [61 62]; % [F9 F10]
% 
% settings.eeg.preprocessing.notch.fcutoff = 50;
% settings.eeg.preprocessing.notch.bw = 35;
% settings.eeg.preprocessing.filter.HP.order = 6;
% settings.eeg.preprocessing.filter.HP.fcutoff = 1;
% settings.eeg.preprocessing.filter.LP.order = 16;
% settings.eeg.preprocessing.filter.LP.fcutoff = 45;
% settings.eeg.preprocessing.reference = 'robust'; % 'robust', 'car', 'laplacian', 'no' 
% settings.eeg.preprocessing.lapmask = 'lapmask38.mat';
% settings.eeg.preprocessing.channelSubset = {           'Fp1';'Fpz';'Fp2';...
%                                                                        'F5';'F3';'F1';'Fz';'F2';'F4';'F6';...
%                                                                   'FC5';'FC3';'FC1';'FCz';'FC2';'FC4';'FC6';...
%                                                                        'C5';'C3';'C1';'Cz';'C2';'C4';'C6';...
%                                                                   'CP5';'CP3';'CP1';'CPz';'CP2';'CP4';'CP6';...
%                                                                        'P5';'P3';'P1';'Pz';'P2';'P4';'P6';...
%                                                                                 'PO3';'POz';'PO4'};

% % settings.eeg.preprocessing.channelSubset = {};
% % settings.eeg.preprocessing.channelRemove = {'Fpz','AF7','AF8','FT7','FT8','TP7','TP8','P9','P10','O1','O2'};
% settings.eeg.preprocessing.channelRemove = {};
%                                                                             
settings.eeg.asr.th = 20; % [std]
settings.eeg.asr.block_size = 10;
settings.eeg.asr.window_length = 1; % [sec]
settings.eeg.asr.window_overlap = 0.66; % [%]
settings.eeg.asr.max_bad_channels = 0.1; %0.2
settings.eeg.asr.auto_calib = false;
settings.eeg.asr.iterative = false;
settings.eeg.asr.iter_th = 0.05; % [%]
settings.eeg.asr.max_iter = 20; % [%]
% 
% settings.eeg.cca.window_length = 5.0; % 5 [sec]
% settings.eeg.cca.window_shift = 2.5; % 2.5 [sec]
% settings.eeg.cca.eigratio = 1e6;
% settings.eeg.cca.femg = 20; % [Hz] %15
% settings.eeg.cca.ratio = 10;
% settings.eeg.cca.range = [1 20];
% 
% settings.eeg.ica.method = 'amica'; % 'ica', 'amica'
% settings.eeg.ica.chanselect = false;
% settings.eeg.ica.channelSubset = {};
% settings.eeg.ica.channelRemove = {'Fp1', 'Fpz', 'Fp2'};
% 
% settings.eeg.erds.method = 'bandpower'; % 'bandpower', 'psd'
% settings.eeg.erds.step_epoch = [-0.5 1.0] ; %[-0.5 1.0] 
% settings.eeg.erds.t_ref = [-0.5 0.0]; % absolute time
% settings.eeg.erds.exclude_baseline = false; %true
% settings.eeg.erds.do_laplacian = false; %true
% 
% settings.eeg.erds.bandpower.t_smooth = 0.1;
% settings.eeg.erds.bandpower.t_smooth_plt = 0.1;
% settings.eeg.erds.bandpower.f_width = 2;
% settings.eeg.erds.bandpower.f_step = 1;
% settings.eeg.erds.bandpower.f_range = [2,45];
% settings.eeg.erds.bandpower.class_vec = [1, 2];
% settings.eeg.erds.bandpower.N_classes = 2;
% settings.eeg.erds.bandpower.t_step_label = 500;
% settings.eeg.erds.bandpower.f_step_label = 2;
% settings.eeg.erds.bandpower.t_indicator = 0;
% settings.eeg.erds.bandpower.downsample.enable = false;
% 
% settings.eeg.erds.psd.mlength    = 0.96;
% settings.eeg.erds.psd.wlength    = 0.48;
% settings.eeg.erds.psd.pshift     = 0.24;
% settings.eeg.erds.psd.wshift     = 0.04;
% settings.eeg.erds.psd.f_range = [6,30];
% 
% settings.eeg.ersp.step_epoch = [0 1.0]; % [0 1.0] [sec]
% settings.eeg.ersp.ref_size = 0.5; % [sec]
% settings.eeg.ersp.baseline = [settings.eeg.ersp.step_epoch(1)-settings.eeg.ersp.ref_size-1/settings.eeg.fs...
%     settings.eeg.ersp.step_epoch(1)-1/settings.eeg.fs].*settings.eeg.fs;
% settings.eeg.ersp.winlen = 0.4; % 0.8 [sec]
% settings.eeg.ersp.padratio = 0.064; % [sec] %0.13
% settings.eeg.ersp.freqs = [0 50]; % [Hz]
% settings.eeg.ersp.varwin = 0; % 0 --> FFT with Hanning window, otherwise [3 0.8] --> Wavelet transform
% settings.eeg.ersp.do_laplacian = true;
% settings.eeg.ersp.stat_alpha = NaN; % 0.01, NaN

% settings.eeg.ersp.stat.alpha = 0.01;
% settings.eeg.ersp.stat.pboot = NaN;
% settings.eeg.ersp.stat.baseboot = 1;
% settings.eeg.ersp.stat.boottype = 'shuffle';
% settings.eeg.ersp.stat.basenorm = 'off';
% settings.eeg.ersp.stat.mcorrect = 'none';

%% EEG-EMG settings
% settings.eegemg.cmc.winlen = 0.4; % 0.8 [sec]
% settings.eegemg.cmc.padratio = 0.064; % [sec] %0.13
% settings.eegemg.cmc.freqs = [4 40]; % [Hz]
% settings.eegemg.cmc.varwin = 0; % 0 --> FFT with Hanning window, otherwise [3 0.8] --> Wavelet transform
% settings.eegemg.cmc.do_laplacian = true;
% settings.eegemg.cmc.stat_alpha = NaN; % 0.01, NaN






