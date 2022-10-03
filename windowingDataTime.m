close all; clearvars; clc;

subject = 7;

filename = ['subj',num2str(subject),'_pruned.mat'];
load(filename)

savingPath='/home/palatella/workspace/palatella_datasets/';

%%
% h_EMG = hilbert(subj.emg.data);
% h_EMG = abs(h_EMG);

h_EMG = subj.emg.data;

triggers = subj.triggers;
data = [subj.eeg.data; h_EMG];
settings = subj.settings;

%% Settings
settings.secCue = 3;
settings.secPostMovement = 2;
settings.secPreMovement = 0;


%% Labels the windows for train
disp('Labeling the windows')

fs = settings.eeg.fs;

nPointCue = settings.secCue*fs;
nPointPostMov = settings.secPostMovement*fs;
nPointPreMov = settings.secPreMovement*fs;

windows = nan(size(data,2),1);
trials = nan(size(data,2),1);
t = 0;

for i = 1:length(triggers.time)-1
    label = triggers.num(i);
    pos = triggers.time(i);

    if( label>0 )
        t = t+1;
        windows(pos-nPointPreMov : pos+nPointPostMov-1) = label;
        windows(pos-nPointCue-nPointPreMov : pos-1-nPointPreMov) = 0;
        trials(pos-nPointCue-nPointPreMov : pos+nPointPostMov-1) = t;
    end
end

triggers.time(1:2:end) = triggers.time(1:2:end) - nPointPreMov;
triggers.time(2:2:end) = triggers.time(1:2:end) + nPointPostMov + nPointPreMov;

subjLabeled.windowsLabel = windows;
subjLabeled.data = data;
subjLabeled.triggers = triggers;
subjLabeled.settings = settings;
%% SAVING
savingName = [savingPath,'subj',num2str(subject),'_labeledRaw.mat'];
save(savingName,'subjLabeled','-v7.3')

