close all; clearvars; clc;

resultsPath = '/home/palatella/workspace/palatella-hybrid-gcn/codes_small_paper/Fusion_methods/';
imgPath = '/home/palatella/workspace/palatella-hybrid-gcn/codes_small_paper/Fusion_methods/weighted images/with 1 perc/';

percentual = [15 10 5 1];

%%
types = [0.9 0.7 1 0.5 0.1];
for att = types %[0.9 0.7 1 0.5 0.1]

    close all

    if att>0.5 && att<1
        netSettings.emg.attenuation = att;
        netSettings.emg.type = 'fatigue';
        k = fix(att*100);
        tp = netSettings.emg.type;
        tp(1) = upper(tp(1));
        titleName =[tp, ' with an attenuation of ', num2str(k), '%'];
    else
        netSettings.emg.snr = att;
        netSettings.emg.type = 'paraplegic';
        k = att;
        tp = netSettings.emg.type;
        tp(1) = upper(tp(1));
        titleName =[tp, ' with a snr of ', num2str(k), 'dB'];
    end

    loadNameComplete = [resultsPath,'finalResults_Weighted_',netSettings.emg.type,num2str(k),'.mat'];
    loadName1Perc = [resultsPath,'finalResults_Weighted_',netSettings.emg.type,num2str(k),'_perc1.mat'];
    [cmRes, f1Score, accuracy, loss, precision, sensitivity, kappas] = mergeResults(loadNameComplete, loadName1Perc);
    

%     fig = printValuesPaper(accuracy, 'Accuracy', titleName, [0 100]);
%     saveas(fig, [imgPath, tp, num2str(k), '_Accuracy.jpg'])
% 
%     fig = printValuesPaper(f1Score, 'F1Score', titleName);
%     saveas(fig, [imgPath, tp, num2str(k), '_F1Score.jpg'])
% 
%     fig = printValuesPaper(loss, 'Loss', titleName);
%     saveas(fig, [imgPath, tp, num2str(k), '_Loss.jpg'])
% 
%     fig = printValuesPaper(precision, 'Precision', titleName);
%     saveas(fig, [imgPath, tp, num2str(k), '_Precision.jpg'])
% 
%     fig = printValuesPaper(sensitivity, 'Sensitivity', titleName);
%     saveas(fig, [imgPath, tp, num2str(k), '_Sensitivity.jpg'])
% 
%     fig = printValuesPaper(kappas, 'Kappa value', titleName);
%     saveas(fig, [imgPath, tp, num2str(k), '_Kappa.jpg'])

    printConfMatrix(cmRes, att);

    close all
    pause(0.3)

end












%%
%     for q = 1:length(percentual)
%     
%         perc = percentual(q);
% 
%         acc = finalResults(:,:,q);
%         f1 = f1Score(:,:,q);
%         lss = loss(:,:,q);
%         cm = cmRes(:,:,q);
%         sens = sensitivity(:,:,q);
%         prec = precision(:,:,q);
%         
%         
%         
%         
%         % meanResults = mean(finalResults);
%         % sdResults = std(finalResults);
%         % 
%         % meanF1 = mean(f1Score);
%         % sdF1 = std(f1Score);
%     
%     end

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

%%
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

