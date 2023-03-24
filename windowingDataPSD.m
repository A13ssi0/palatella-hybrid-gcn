close all; clearvars; clc;

% savingPathFat ='/home/palatella/workspace/palatella_datasets/only emg/fatigue/';
% savingPathPar ='/home/palatella/workspace/palatella_datasets/only emg/paraplegic/';
% loadingPath = '/home/palatella/workspace/palatella_datasets/only emg/healthy/';

savingPath = '/home/palatella/workspace/palatella_datasets/imagery dataset/';
loadingPath = '/home/palatella/workspace/palatella_datasets/imagery dataset/';




settings.eeg.fs = 500;
settings.windowLength = 0.5; %[s]
settings.windowShift = 0.02; %[s]
settings.windowFreq = 1/settings.windowShift; %[Hz]
settings.choosenFreq = [2 40];
settings.windowStep = settings.windowShift*settings.eeg.fs;
settings.windowSize = settings.windowLength*settings.eeg.fs;

settings.secCue = 0;
settings.secPostMovement = 2;
settings.secPreMovement = 0;%0.04*fix(5/0.04);

attenuation = 0.7;%[0.1 0.5 0.7 0.9];
signalToNoiseRatio = [10 3 1.5 1 0.5 0.1];

for subject = 7%[7 11 15 19 23] 
    disp(['Importing the data of subject ',num2str(subject)])
    %filename = ['subj',num2str(subject),'_pruned.mat'];
    filename = [loadingPath,'subj',num2str(subject),'_fullDataset'];    
    load(filename)

    %EMG = EMG';

    %for snr = signalToNoiseRatio
%         EMGf = signal_attenuation(EMG, attenuation, 'minmax');
%     
%         EMGf = set_snr(EMGf,snr);
%     
%         subj.emg.data = EMGf;
%         subj.triggers = trigger;
%         subj.eeg.data = [];
%     
        triggers = subj.triggers;
%         triggers = trigger;
    
    
        %%
%         h_EMG = hilbert(subj.emg.data');
%         h_EMG = abs(h_EMG');
        h_EMG = [];
        data = [subj.eeg.data; h_EMG];
    
        savingName = [savingPath,'s',num2str(subject),'_imagery'];
        calcPSD(data,triggers,settings,savingName)
    
%        h_EMG = subj.emg.data;
%         data = [subj.eeg.data; h_EMG];
%     
%         savingName = [savingPathPar,'s',num2str(subject),'_wind25Hz_raw_snr',num2str(snr),'.mat'];
%         calcPSD(data,triggers,settings,savingName);

    %end
    
end
