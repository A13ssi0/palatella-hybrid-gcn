close all; clearvars; clc;

%netPath='/home/palatella/workspace/palatella_net/netSmallPaper/';
%testSetPath = '/home/palatella/workspace/palatella_datasets/test set for small paper/';
%subjects = [7 11 13 23 29];

netPath='C:\Users\aless\OneDrive\Desktop\Nuova cartella\netSmallPaper\';
testSetPath = 'C:\Users\aless\OneDrive\Desktop\Nuova cartella\';
subjects = 7;


netSettings.eeg.macro = false;

netSettings.emg.timeDomain = false;
netSettings.emg.macro = false;


%%
for numSubject = subjects

    testSet = load_testSet_paper(testSetPath,numSubject,netSettings);

    EEGNet = load_net_paper(netPath,numSubject,'EEG',netSettings.eeg);
    EMGNet = load_net_paper(netPath,numSubject,'EMG',netSettings.emg);

    results = mergingNestWithFusionMethods(EEGNet,EMGNet,testSet);
end


