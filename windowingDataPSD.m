close all; clearvars; clc;


for subject = 15 %;[11 15 19 23] % 7
    savingPath='/home/palatella/workspace/palatella_datasets/0.5 before 1 after onset/';
    disp(['Importing the data of subject ',num2str(subject)])
    filename = ['subj',num2str(subject),'_pruned.mat'];
    load(filename)
    
    %%
    %h_EMG = hilbert(subj.emg.data');
    %h_EMG = abs(h_EMG');
    %endName = '_psd_corrected_LOONG.mat';

    
     h_EMG = subj.emg.data;
%     endName = '_psdRaw.mat';

    triggers = subj.triggers;
    data = [subj.eeg.data; h_EMG];
    settings = subj.settings;

    
    %% Settings
    settings.windowLength = 0.5; %[s]
    settings.windowShift = 0.02; %[s]
    settings.windowFreq = 1/settings.windowShift; %[Hz]
    settings.choosenFreq = [2 40];
    settings.windowStep = settings.windowShift*settings.eeg.fs;
    settings.windowSize = settings.windowLength*settings.eeg.fs;
    
    settings.secCue = 0;
    settings.secPostMovement = 2;
    settings.secPreMovement = 0;%0.04*fix(5/0.04);

    
    %% Calculating PSD and windowing the events
    disp('Calculating PSD')
    PSD.data = compute_psd(data, settings.windowLength, settings.windowShift, settings.eeg.fs, settings.choosenFreq);
    
    nFreq = settings.windowSize/2+1;
    freq = linspace(0, settings.eeg.fs/2, nFreq);
    freq = freq(2:end);
    idxFreq = settings.choosenFreq(1)<=freq & freq<=settings.choosenFreq(2);
    freq = freq(idxFreq);
    PSD.frequency = freq;
    
    disp('Windowing the events')
    direction = 'backward';
    windowsTime = proc_pos2win(triggers.time, settings.windowStep, direction, settings.windowSize);
    PSD.triggers.time = windowsTime;
    PSD.triggers.num = subj.triggers.num;
    
    PSD.settings = settings;
    
    
    %% Labels the windows for train
    disp('Labeling the windows')
    
    t_max = size(data,2)/settings.eeg.fs;
    
    nWindowCue = settings.secCue/settings.windowShift;
    nWindowPostMov = settings.secPostMovement/settings.windowShift;
    nWindowPreMov = settings.secPreMovement/settings.windowShift;
    
    tw = settings.windowLength : settings.windowShift : (t_max);
    windowsLabel = nan(length(tw),1);
    trials = nan(length(tw),1);
    t = 0;
    
    for i = 1:length(windowsTime)-1
        wPOS = windowsTime(i);
        wlabel = triggers.num(i);
    
        if( wlabel>0 )
            t = t+1;
            windowsLabel(wPOS-nWindowPreMov : wPOS+nWindowPostMov-1) = wlabel;
            windowsLabel(wPOS-nWindowCue-nWindowPreMov : wPOS-1-nWindowPreMov) = 0;
            trials(wPOS-nWindowCue-nWindowPreMov : wPOS+nWindowPostMov-1) = t;
        end
    end
    
    PSD.windowsLabel = windowsLabel;
    PSD.trials = trials;
    
    PSD.triggers.time(2:2:end) = PSD.triggers.time(1:2:end) + nWindowPostMov;
    PSD.triggers.time(1:2:end) = PSD.triggers.time(1:2:end) - nWindowPreMov;
    
    
    %% SAVING
    %savingName = [savingPath,'subj',num2str(subject),endName];
    %save(savingName, 'PSD','-v7.3');
end
