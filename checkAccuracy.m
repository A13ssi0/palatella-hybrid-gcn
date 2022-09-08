close all;clearvars;clc;

subject = 7;
gridHiddenUnits = [5:10:55, 100:50:250];
gridDropOut = 0:0.3:0.9;
savingPath='/home/palatella/workspace/palatella_net/';

accuracies = nan(length(gridHiddenUnits),length(gridDropOut),length(gridDropOut));
cumulAccuracies = nan(length(gridHiddenUnits),length(gridDropOut),length(gridDropOut),100);

idxAcc = nan(length(gridHiddenUnits), 2);
idxAccCum = nan(length(gridHiddenUnits), 2);


for i = 1:length(gridHiddenUnits) 
    for j = 1:length(gridDropOut) % of graph
        for m = 1:length(gridDropOut) % of gru

            x = gridHiddenUnits(i);
            y = gridDropOut(j);
            z = gridDropOut(m);

            savingName = [savingPath,'subj',num2str(subject),'_net_','outF',num2str(x),'_drop',num2str(y),'_',num2str(z),'_2run'];
            net = load(savingName,'-mat');

            accuracies(i,j,m) = net.class.accuracy;
            cumulAccuracies(i,j,m,:) = net.accuracyThresholds;
        end
    end
    acc = max(accuracies(i,:,:),[],'all');
    cumulAcc = max(cumulAccuracies(i,:,:,:),[],'all');

    [idxAcc(i,1), idxAcc(i,2)] = find(squeeze(accuracies(i,:,:))==acc);
%     [idxAccCum(i,1), idxAccCum(i,2)] = find(squeeze(cumulAccuracies(i,:,:))==cumulAcc);
    disp(['numHiddenUnits: ',num2str(x),'   max_accuracy:',num2str(acc),'   max_cumulative_accuracy:',num2str(cumulAcc)])
end

valueAcc = (idxAcc-1)*0.3;
valueAcc = [gridHiddenUnits' valueAcc];

% valueAcc = (idxAccCum-1)*0.3;

%%
clearvars; 
%close all; 
clc;
% x = 150;
% [row,col] = find(valueAcc(:,1)==x);
% y = valueAcc(row,2);
% z = valueAcc(row,3);
savingPath='/home/palatella/workspace/palatella_net/';
loadingName = [savingPath,'subj',num2str(7),'_net_','hidF',num2str(100),'_outF',num2str(7),'_drop',num2str(0.3),'_',num2str(0.1),'_macroRest'];
load(loadingName,'-mat');
% info = net.info;

idx = ~isnan(info.ValidationAccuracy);
figure()
plot(find(idx), info.ValidationAccuracy(idx),'b'), hold on
plot(1:length(info.TrainingAccuracy),info.TrainingAccuracy,'--'),
ylim([0 100])
title('Accuracy')

idx = ~isnan(info.ValidationLoss);
figure()
plot(find(idx),info.ValidationLoss(idx),'b'), hold on
plot(1:length(info.TrainingLoss),info.TrainingLoss,'--'),
ylim([0 5])
title('Loss')

% figure
% plot(accuracyThresholds)
% ylim([0 1])
% title('Cumulated accuracy')

figure()
confusionchart(confMatrix,'ColumnSummary','absolute','RowSummary','absolute','Normalization','row-normalized');











