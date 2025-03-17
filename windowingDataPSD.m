close all; clearvars;clc;

% spath = 'C:\Users\tomma\Documents\Uni\PhD\GNN\data\preprocessed\';
% dpath=  'C:\Users\tomma\Documents\Uni\PhD\GNN\data\window_psd\';

spath = '/home/palatella/workspace/palatella_datasets/preprocessed/';
dpath=  '/home/palatella/workspace/palatella_datasets/window_psd/';

do_attenuation = false;

settings.eeg.fs = 500;
settings.windowLength = 0.5; %[s]
settings.windowShift = 0.02; %[s]
settings.windowFreq = 1/settings.windowShift; %[Hz]
settings.choosenFreq = [2 40];
settings.windowStep = settings.windowShift*settings.eeg.fs;
settings.windowSize = settings.windowLength*settings.eeg.fs;
settings.NumEEG = 35;
settings.NumEMG = 6;
settings.secCue = 0;
settings.secPostMovement = 2;
settings.secPreMovement = 0;%0.04*fix(5/0.04);

attenuation = 0.7;%[0.1 0.5 0.7 0.9];
signalToNoiseRatio = [10 3 1.5 1 0.5 0.1];

% for subject = [7 11 15 19 23]
for subject = [2]
    disp(['Importing the data of subject ',num2str(subject)])
    load([spath,'subj',num2str(subject),'_pruned.mat'])
    if do_attenuation
        EMG = EMG';
        for snr = signalToNoiseRatio
            EMGf = signal_attenuation(EMG, attenuation, 'minmax');
            
            EMGf = set_snr(EMGf,snr);
            
            subj.emg.data = EMGf;
            subj.triggers = trigger; %???
            subj.eeg.data = [];
           
            triggers = subj.triggers; 
            settings = subj.settings;
            
            h_EMG = subj.emg.data;
            data = [subj.eeg.data; h_EMG];
            
            savingName = [dpath,'subj',num2str(subject),'_wind25Hz_raw_snr',num2str(snr),'.mat'];
            calcPSD(data,triggers,settings,savingName);
        end
    else
        h_EMG = hilbert(subj.emg.data');
        h_EMG = abs(h_EMG');
        data = [subj.eeg.data; h_EMG];
        triggers = subj.triggers;
        savingName = [dpath,'subj',num2str(subject),'_labeled_psd'];
        calcPSD(data,triggers,settings,savingName);
    end
end
