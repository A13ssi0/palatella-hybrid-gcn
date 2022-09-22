clc
clear
close all

%% Settings data
progait_settings;
load chanlocs62.mat
load Channel_Info.mat

%% Resting state dataset
info.subj_id = 1;
info.session_num = 1;

start_path = [settings.dirpath,'/', num2str(info.subj_id, '%03d'), '/Mat/RestingStateEEG/'];
[file,path] = uigetfile({'*.mat';},...
    'Select a resting dataset',start_path);
load(fullfile(path,file))

% del = settings.begin_delay*settings.eeg.fs;
% eeg = squeeze(P_C_S.data(:,del:end-del+1,:));
% eeg = y(:,del:end-del+1);
% eeg(settings.eeg.exclude,:) = [];
% eeg = eeg';

% Make EEGLab struct
EEG = make_EEGLab_struct(eeg,info,chlocs,settings);
EEG_rest = EEG;

%% Walking dataset
start_path = [settings.dirpath, info.subj_group, '/', info.subj_group, num2str(info.subj_id, '%03d'), '/Mat/'];
[file,path] = uigetfile({'*.mat';},...
    'Select a walking dataset',start_path);
load(fullfile(path,file))

% EEG
% del = settings.begin_delay*settings.eeg.fs;
% eeg = resample(data(:,settings.eeg.ch1_idx:settings.eeg.ch64_idx), settings.eeg.fs, settings.fs);
% eeg = eeg(del:end-del+1,:);
% eeg(:,settings.eeg.exclude) = [];
% eeg = eeg';

% EMG 
% del = settings.begin_delay*settings.emg.fs;
% % emg = data(del:end-del+1,settings.emg.ch1_idx:settings.emg.ch8_idx);
% emg = resample(data(:,settings.emg.ch1_idx:settings.emg.ch8_idx), settings.emg.fs, settings.fs);
% emg = emg(del:end-del+1,:);
emg_label = ChannelInfo(settings.emg.ch1_idx:settings.emg.ch8_idx);

% Make EEGLab struct
info.data_mode = 'ekso_modeM'; % ekso_modeA, ekso_modeF, ekso_modeM, walking
info.session_num = 3;

EEG = make_EEGLab_struct(eeg,info,chlocs,settings);

% EMG
EEG.other.emg.data = emg;
EEG.other.emg.label = emg_label;
EEG.other.emg.srate = settings.emg.fs;

% Resting
EEG.other.resting = EEG_rest;

% Saving dataset
if strcmp(info.data_mode, 'walking')
    condition_type = 'FreeWalking';
else
    condition_type = 'EcsoWalking';
end
output_type = 'eeglab';
save_EEG(EEG,condition_type,output_type,settings)


