close all; clearvars; clc;

netPath='/home/palatella/workspace/palatella_net/netSmallPaper/';
testSetPath = '/home/palatella/workspace/palatella_datasets/test set for small paper/';

subjects = [7 11 13 23 29];

netSettings.eeg.macro = false;
netSettings.eeg.cutEnd = true;

netSettings.emg.timeDomain = false;
netSettings.emg.macro = false;
netSettings.emg.cutEnd = true;


%%
for numSubject = subjects

    EEGNet = load_net_paper(netPath,numSubject,'EEG',netSettings.eeg);
    EMGNet = load_net_paper(netPath,numSubject,'EMG',netSettings.emg);

    testSet = load_testSet_paper(testSetPath,numSubject,netSettings);
end