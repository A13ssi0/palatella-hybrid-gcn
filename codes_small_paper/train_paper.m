close all; clearvars; clc;

subjects = [7 11 15 19 23];

%attenuation = [0.7 0.9];
signalToNoiseRatio = [1 0.5 0.1];

%savingPath = '/home/palatella/workspace/palatella_net/netSmallPaper/only grasping/';
savingPath = '/home/palatella/workspace/palatella_datasets/imagery dataset/15 perc/';


%%

for numSubject = subjects

    trainEEG(numSubject, savingPath)

    for snr = signalToNoiseRatio

        doAttenuation = false;
        trainEMG(numSubject, savingPath, doAttenuation, snr);

    end
end
