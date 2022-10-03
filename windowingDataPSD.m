close all; clearvars; clc;

load subj11_pruned.mat
savingPath = '';

%%
h_EMG = hilbert(subj.emg.data);
h_EMG = abs(h_EMG);

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

settings.secCue = 3;
settings.secPostMovement = 2;
settings.secPreMovement = 0;

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
windows = nan(length(tw),1);
trials = nan(length(tw),1);
t = 0;

for i = 1:length(windowsTime)-1
    wPOS = windowsTime(i);
    wlabel = triggers.num(i);

    if( wlabel>0 )
        t = t+1;
        windows(wPOS-nWindowPreMov : wPOS+nWindowPostMov-1) = wlabel;
        windows(wPOS-nWindowCue-nWindowPreMov : wPOS-1-nWindowPreMov) = 0;
        trials(wPOS-nWindowCue-nWindowPreMov : wPOS+nWindowPostMov-1) = t;
    end
end

PSD.windowsLabel = windows;
PSD.trials = trials;
PSD.triggers.time(1:2:end) = PSD.triggers.time(1:2:end) - nWindowPreMov;
PSD.triggers.time(2:2:end) = PSD.triggers.time(1:2:end) + nWindowPostMov + nWindowPreMov;


%% SAVING
%save(sprintf(savingName, subj,'-v7.3'));
%save subj11_psd PSD -v7.3
