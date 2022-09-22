clc
clear
close all

%% Settings data
progait_settings;
subj_type = 'CTRL'; % CTRL, PTRL
subj_num = 1;
data_mode = 'A';
data_files = [1];
rest_file = 1;

input_type = 'preproc';
output_type = 'asr';

savedir = strcat(settings.dirpath,'processed_data/', subj_type, '/', ...
    subj_type, num2str(subj_num, '%03d'), '/EcsoWalking/',...
    output_type, 'EEG/');
if ~exist(savedir, 'dir')
    mkdir(savedir)
end

%% Load calibration data
rest_folder = strcat(settings.dirpath, 'processed_data/', subj_type, '/', ...
        subj_type, num2str(subj_num, '%03d'), '/RestingStateEEG/', input_type, 'EEG/');
Files = dir(fullfile(rest_folder,'*.mat'));

datapath = strcat(rest_folder, Files(rest_file).name);
load(datapath)
CALIB = EEG;
clear EEG

%% Load and process data
dataset = cell(1, length(data_files));
original = cell(1, length(data_files));
for f = 1:length(data_files)
    datapath = strcat(settings.dirpath, 'processed_data/', subj_type, '/', ...
        subj_type, num2str(subj_num, '%03d'), '/EcsoWalking/', input_type, 'EEG/', ...
        'S', num2str(subj_num), '_ekso_mode', data_mode, ...
        '_', num2str(data_files(f)), '_', input_type, '.mat');
    load(datapath)
    original{f} = EEG; 
    EEG = compute_asr(EEG, CALIB, settings);
    dataset{f} = EEG; 
end

%% Plot single-chan
or_eeg = (original{1}.data(fidx({'C4'}, {dataset{1}.chanlocs.labels}),:))';  
pr_eeg = (dataset{1}.data(fidx({'C4'}, {dataset{1}.chanlocs.labels}),:))';

del = settings.begin_delay*settings.eeg.fs;
or_eeg = or_eeg(del:end-del+1);
pr_eeg = pr_eeg(del:end-del+1);
time = 0:1/settings.eeg.fs:length(or_eeg)/settings.eeg.fs-1/settings.eeg.fs;

figure
plot(time,or_eeg)
hold on
plot(time,pr_eeg)
legend({'original', 'preprocessed'})
xlabel('time')
ylabel('C4')

%% Plot single-chan spectrum
or_eeg = (original{1}.data(fidx({'C4'}, {dataset{1}.chanlocs.labels}),:))';  
pr_eeg = (dataset{1}.data(fidx({'C4'}, {dataset{1}.chanlocs.labels}),:))';

del = settings.begin_delay*settings.eeg.fs;
or_eeg = or_eeg(del:end-del+1);
pr_eeg = pr_eeg(del:end-del+1);

figure
spectrumplot([or_eeg, pr_eeg], settings.eeg.fs, true, {'original', 'preprocessed'});

%% Plot multi-chan
plot_ch = {'FCz';'FC3';...
           'C3';'C1';'Cz';'C4';...
      'CP1';'CPz';'CP3';...
           'P3';'Pz';'P4';'T7';'T8'};
plot_ch_idx = fidx(plot_ch, {dataset{1}.chanlocs.labels});
del = settings.begin_delay*settings.eeg.fs;
or_eeg = (original{1}.data(plot_ch_idx,del:end-del+1))';  
pr_eeg = (dataset{1}.data(plot_ch_idx,del:end-del+1))';

time = 0:1/settings.eeg.fs:length(or_eeg)/settings.eeg.fs-1/settings.eeg.fs;

tb_eeg = table([or_eeg(:,1), pr_eeg(:,1)], 'VariableNames', plot_ch(1));
for i = 2:length(plot_ch)
    tb_eeg = [tb_eeg table([or_eeg(:,i), pr_eeg(:,i)], 'VariableNames', plot_ch(i))];
end

figure
stackedplot(tb_eeg)

%% Save
for f = 1:length(data_files)
    EEG = dataset{f};
    filename = strcat('S', EEG.subject, '_', EEG.condition, '_', ...
        num2str(EEG.session), '_', output_type, '.mat');
    save([savedir, filename], 'EEG')
end

