clc
clear
close all

%% Settings
progait_settings;
info.subj_group = 'CTRL'; % CTRL, PTRL
info.subj_id = 6;
info.data_mode = 'walking'; % ekso_modeA, walking
info.condition_type = 'FreeWalking'; % EcsoWalking, 'FreeWalking'
info.session_num = 1;

% plot_ch = {'FCz';'C3';'Cz';'P3'};
% plot_ch = {'P3'};
plot_ch = {'Cz'};

%% Load data
% Raw data
info.session_num = 1;
input_type = 'triggers';
EEG_raw = load_EEG(info,input_type,settings);
plot_ch_idx = fidx(plot_ch, {EEG_raw.chanlocs.labels});
raw_eeg = (EEG_raw.data(plot_ch_idx,:))';
clear EEG_raw

% Preproc data
info.session_num = 1;
input_type = 'preproc_ref';
EEG_pr = load_EEG(info,input_type,settings);
plot_ch_idx = fidx(plot_ch, {EEG_pr.chanlocs.labels});
pr_eeg = (EEG_pr.data(plot_ch_idx,:))';
% clear EEG_pr

% ASR data
info.session_num = 1;
input_type = 'asr';
EEG_asr = load_EEG(info,input_type,settings);
plot_ch_idx = fidx(plot_ch, {EEG_asr.chanlocs.labels});
asr_eeg = (EEG_asr.data(plot_ch_idx,:))';
clear EEG_asr

% ICA data
info.session_num = 12;
input_type = 'clean';
EEG_ica = load_EEG(info,input_type,settings);
plot_ch_idx = fidx(plot_ch, {EEG_ica.chanlocs.labels});
ica_eeg = (EEG_ica.data(plot_ch_idx,:))';
clear EEG_ica

% CCA data
info.session_num = 12;
input_type = 'cca';
EEG_cca = load_EEG(info,input_type,settings);
plot_ch_idx = fidx(plot_ch, {EEG_cca.chanlocs.labels});
cca_eeg = (EEG_cca.data(plot_ch_idx,:))';
clear EEG_cca

%% Extract data
start_trig = 1;
stop_trig = 30;

labels = [settings.leg.L.label settings.leg.R.label]; 
[trials_typ,trials_pos] = find_events(EEG_pr.other.imu.triggers.event,labels);


start = trials_pos(start_trig) + settings.step_epoch(1)*settings.eeg.fs;
stop = trials_pos(stop_trig) + settings.step_epoch(2)*settings.eeg.fs;

raw_eeg = raw_eeg(start:stop,:);  
pr_eeg = pr_eeg(start:stop,:);
asr_eeg = asr_eeg(start:stop,:);
ica_eeg = ica_eeg(start:stop,:);
cca_eeg = cca_eeg(start:stop,:);

data_eeg = cat(3, raw_eeg, pr_eeg, asr_eeg, ica_eeg, cca_eeg);
data_eeg = double(data_eeg);
data_legend = {'Raw', 'Proc', 'ASR', 'ICA', 'CCA'};

time = start/settings.eeg.fs:...
    1/settings.eeg.fs:...
    stop/settings.eeg.fs;

%% Plot data
figure
for c = 1:length(plot_ch)
    subplot(length(plot_ch),1,c)
    hold on
    for i = 2:size(data_eeg,3)
        p(i-1) = plot(time, squeeze(data_eeg(:,c,i)));
    end
    for i =start_trig:stop_trig
        xline(trials_pos(i)/settings.eeg.fs)
    end
    hold off
    xlim([time(1) time(end)])
    ylim([-50 50])
    title(['Channel ', plot_ch{c}])
    xlabel('Time [s]')
    ylabel('EEG [uV]')
    legend(p, data_legend(2:end))
end

%% Plot filt data
fcutoff = [8 30];
[b,a] = butter(6, fcutoff./(settings.eeg.fs/2),'bandpass');

figure
sgtitle(['EEG filtered (',num2str(fcutoff(1)),'-',num2str(fcutoff(2)),' Hz)'])
for c = 1:length(plot_ch)
    subplot(length(plot_ch),1,c)
    hold on
    for i = 2:size(data_eeg,3)
        dt = filtfilt(b,a,squeeze(data_eeg(:,c,i)));
        p(i-1) = plot(time, dt);
    end
    for i =start_trig:stop_trig
        xline(trials_pos(i)/settings.eeg.fs)
    end
    hold off
    xlim([time(1) time(end)])
    ylim([-30 30])
    title(['Channel ', plot_ch{c}])
    xlabel('Time [s]')
    ylabel('EEG [uV]')
    legend(p, data_legend(2:end))
end

%%
figure
spectrumplot(squeeze(data_eeg), settings.eeg.fs, true, data_legend);
title(['Channel ', plot_ch{1}])


