close all; clearvars; clc;


loadNetPath = '';

subjects = [7 11 13 23 29];


%%
for numSubject = subjects

    isTime = false;
    isMacro = false;

    EEGNet = load_net_paper(loadNetPath,numSubject,'EEG',isMacro,isTime);
    EMGNet = load_net_paper(loadNetPath,numSubject,'EMG',isMacro,isTime);

end