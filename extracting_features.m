close all; clearvars; clc;
rng(12)

subject = 15;

savingPath='/home/palatella/workspace/palatella_datasets/';
disp('importing the data')
filename = ['subj',num2str(subject),'_pruned.mat'];
load(filename)

%%
settings = subj.settings;
dataEMG = subj.emg.data;

settings.windowLength = 0.5; %[s]
settings.windowShift = 0.02; %[s]
choosenFreq = [2 40];
fc = subj.emg.srate;

%%
features = featuresExtraction_EMG(dataEMG, settings.windowLength, settings.windowShift, fc, choosenFreq);

%%
filename = ['subj',num2str(subject),'_psd.mat'];
load(filename)

windowsLabel = PSD.windowsLabel';

%%
savingName = [savingPath,'subj',num2str(subject),'_featuresEMG.mat'];
save(savingName,'features','windowsLabel','settings','-v7.3');
