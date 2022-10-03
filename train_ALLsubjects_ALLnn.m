close all; clearvars; clc;

subjects = [7 11 13 19 23];

NumHiddenUnits = 150;
NumOutFeatures = 42;
gcnDropOut = 0.3;
gruDropOut = 0.3;

savingPath='/home/palatella/workspace/palatella_net/results_run/';

%%
for i = subjects
    disp('importing the data')
    filename = ['subj',num2str(subject),'_psd.mat'];

end