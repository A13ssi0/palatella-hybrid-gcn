clc
clear
close all

%% Settings data
progait_settings;
subj_type = 'CTRL'; % CTRL, PTRL
subj_num = 1;
data_mode = 'A';
data_files = [1];

input_type = 'eeglab';
output_type = 'preproc';

%% For walking EEG data
savedir = strcat(settings.dirpath,'processed_data/', subj_type, '/', ...
    subj_type, num2str(subj_num, '%03d'), '/EcsoWalking/', output_type, 'EEG/');
if ~exist(savedir, 'dir')
    mkdir(savedir)
end

dataset = cell(1, length(data_files));
original = cell(1, length(data_files));
for f = 1:length(data_files)
    datapath = strcat(settings.dirpath, 'processed_data/', subj_type, '/', ...
        subj_type, num2str(subj_num, '%03d'), '/EcsoWalking/', input_type, 'EEG/', ...
        'S', num2str(subj_num), '_ekso_mode', data_mode, ...
        '_', num2str(data_files(f)), '_', input_type, '.mat');
    load(datapath)
    original{f} = EEG; 
    EEG = compute_preprocessing(EEG, settings);
    dataset{f} = EEG; 
end

%% For resting EEG data
savedir = strcat(settings.dirpath,'processed_data/', subj_type, '/', ...
    subj_type, num2str(subj_num, '%03d'), '/RestingStateEEG/', output_type, 'EEG/');
if ~exist(savedir, 'dir')
    mkdir(savedir)
end

rest_folder = strcat(settings.dirpath, 'processed_data/', subj_type, '/', ...
        subj_type, num2str(subj_num, '%03d'), '/RestingStateEEG/', input_type, 'EEG/');
Files = dir(fullfile(rest_folder,'*.mat'));

dataset = cell(1, length(data_files));
original = cell(1, length(data_files));
for f = 1:length(data_files)
    datapath = strcat(rest_folder, Files(data_files(f)).name);
    load(datapath)
    original{f} = EEG; 
    EEG = compute_preprocessing(EEG, settings);
    dataset{f} = EEG; 
end

%% Plot data scroll
EEG = dataset{1};
eegplot(EEG.data, 'srate', EEG.srate, 'eloc_file', EEG.chanlocs)

%% Plot single-chan
or_eeg = (original{1}.data(fidx({'CPz'}, {dataset{1}.chanlocs.labels}),:))';  
pr_eeg = (dataset{1}.data(fidx({'CPz'}, {dataset{1}.chanlocs.labels}),:))';

del = settings.begin_delay*settings.eeg.fs;
or_eeg = or_eeg(del:end-del+1)-mean(or_eeg(del:end-del+1));
pr_eeg = pr_eeg(del:end-del+1);
time = 0:1/settings.eeg.fs:length(or_eeg)/settings.eeg.fs-1/settings.eeg.fs;

figure
plot(time,or_eeg)
hold on
plot(time,pr_eeg)
legend({'original', 'preprocessed'})
xlabel('time')
ylabel('CPz')

%% Plot single-chan spectrum
or_eeg = (original{1}.data(fidx({'CPz'}, {dataset{1}.chanlocs.labels}),:))';  
pr_eeg = (dataset{1}.data(fidx({'CPz'}, {dataset{1}.chanlocs.labels}),:))';

del = settings.begin_delay*settings.eeg.fs;
or_eeg = or_eeg(del:end-del+1);
pr_eeg = pr_eeg(del:end-del+1);

figure
spectrumplot([or_eeg, pr_eeg], settings.eeg.fs, true, {'original', 'preprocessed'});

%% Plot multi-chan
plot_ch = {'FCz';'FC4';...
           'C3';'Cz';'C4';...
      'CP1';'CPz';'CP2';...
           'P3';'Pz';'P4'};
plot_ch_idx = fidx(plot_ch, {dataset{1}.chanlocs.labels});
del = settings.begin_delay*settings.eeg.fs;
or_eeg = (original{1}.data(plot_ch_idx,del:end-del))';  
pr_eeg = (dataset{1}.data(plot_ch_idx,del:end-del))';

time = 0:1/settings.eeg.fs:length(or_eeg)/settings.eeg.fs-1/settings.eeg.fs;

tb_eeg = table([or_eeg(:,1)-mean(or_eeg(:,1)), pr_eeg(:,1)], 'VariableNames', plot_ch(1));
for i = 2:length(plot_ch)
    tb_eeg = [tb_eeg table([or_eeg(:,i)-mean(or_eeg(:,i)), pr_eeg(:,i)], 'VariableNames', plot_ch(i))];
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




