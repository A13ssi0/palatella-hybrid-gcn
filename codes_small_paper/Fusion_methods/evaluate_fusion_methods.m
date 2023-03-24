close all; clearvars; clc;

%netPath='/home/palatella/workspace/palatella_net/netSmallPaper/';
%testSetPath = '/home/palatella/workspace/palatella_datasets/test set for small paper/';
%subjects = [7 11 13 23 29];

netPath = '/home/palatella/workspace/palatella_datasets/imagery dataset/';
testSetPath = '/home/palatella/workspace/palatella_datasets/imagery dataset/testSets/';

idxLessElectrodesPath = '/home/palatella/workspace/palatella_net/netSmallPaper/idxEEGChannelsLessElectrodes';


subjects = [7 11 15 19 23]; %7
netSettings.eeg.macro = true;
netSettings.eeg.deleteElectrodes = false;


netSettings.emg.macro = true;
netSettings.emg.timeDomain = false;
netSettings.emg.attenuation = 0.9; %[0.7 0.9]
netSettings.emg.snr = 1; %[1 0.5 0.1]
%netSettings.emg.type = 'paraplegic';

%perc = 10;
skipEEG = false;
percentual = [15 10 5 0];

%%
for att = [0.9 0.7  1 0.5 0.1]

if att>0.5
    netSettings.emg.attenuation = att;
    netSettings.emg.type = 'fatigue';
    k = fix(att*100);
else
    netSettings.emg.snr = att;
    netSettings.emg.type = 'paraplegic';
    k = att;
end

finalResults = nan(length(subjects),5,length(percentual));
f1Score = finalResults;

for q = 1:length(percentual)

perc = percentual(q);
folderName = [num2str(perc) ' perc/'];

netPathP = [netPath folderName];
testSetPathP = [testSetPath folderName];
netPathEEG = netPathP;
netPathEMG = netPathP;

for i = 1:length(subjects)

    numSubject = subjects(i);

    testSet = load_testSet_paper(testSetPathP,numSubject,netSettings,netSettings.emg.type,skipEEG);
    testSet.emg.data = deleteSeventhChannel(testSet.emg.data);
    if netSettings.eeg.deleteElectrodes,    testSet.eeg.data = deleteExtraElectrodes(testSet.eeg.data,idxLessElectrodesPath);   end

    EEGNet = load_net_paper(netPathEEG,numSubject,'EEG',netSettings.eeg,'_smaller');
    EMGNet = load_net_paper(netPathEMG,numSubject,'EMG',netSettings.emg);

    %EEGNet.probPredValidation = predict(EEGNet.net,val.input);
    %p = microToMacroClasses(val,val,val);
    %EEGNet.trueValOutput = p.output;
    EEGNet.CMval = extract_net_performances(EEGNet.probPredValidation,EEGNet.trueValOutput);
    EMGNet.CMval = extract_net_performances(EMGNet.probPredValidation,EMGNet.trueValOutput);

    results = mergingNetsWithFusionMethods(EEGNet,EMGNet,testSet);

    finalResults(i,:,q) = [results.eeg.accuracy,results.emg.accuracy,results.naive.accuracy,results.bayesian.accuracy,results.fuzzy.accuracy];
    f1Score(i,:,q) = [results.eeg.f1,results.emg.f1,results.naive.f1,results.bayesian.f1,results.fuzzy.f1];  
end

finalResults = 100*finalResults;
meanResults = mean(finalResults);
sdResults = std(finalResults);

meanF1 = mean(f1Score);
sdF1 = std(f1Score);

save(['/home/palatella/workspace/palatella-hybrid-gcn/codes_small_paper/Fusion_methods/finalResults_',netSettings.emg.type,num2str(k),'.mat'],"finalResults","f1Score") 
end
%%
% figure
% bar(1:5,meanResults), hold on
% errorbar(1:5,meanResults,sdResults,sdResults)
% set(gca,'XTicklabels',{'EEG' 'EMG' 'Naive' 'Bayes' 'Fuzzy'})
% ylim([0 100])
% ylabel('Accuracy')
% if strcmpi(netSettings.emg.type,'healthy')
%     title('Healthy')
% elseif strcmpi(netSettings.emg.type,'fatigue')
%     title(['Fatigue    attenuation=',num2str(netSettings.emg.attenuation*100),'%'])
% else
%     title(['Paraplegic, snr=',num2str(netSettings.emg.snr),', percTuning=',num2str(perc),'%'])
% end

end

% figure
% bar(1:5,meanF1), hold on
% errorbar(1:5,meanF1,sdF1,sdF1)
% set(gca,'XTicklabels',{'EEG' 'EMG' 'Naive' 'Bayes' 'Fuzzy'})
% %ylim([0 100])
% ylabel('Accuracy')
% if strcmpi(netSettings.emg.type,'healthy')
%     title('Healthy')
% elseif strcmpi(netSettings.emg.type,'fatigue')
%     title(['Fatigue    attenuation=',num2str(netSettings.emg.attenuation*100),'%'])
% else
%     title(['Paraplegic    snr=',num2str(netSettings.emg.snr)])
% end

