close all;clearvars;clc;

subject = 7;
gridHiddenUnits = 5:10:55;
gridDropOut = 0:0.3:0.9;
savingPath='';

accuracies = nan(length(gridHiddenUnits),length(gridDropOut),length(gridDropOut));
cumulAccuracies = nan(length(gridHiddenUnits),length(gridDropOut),length(gridDropOut),100);

for i = 1:length(gridHiddenUnits) 
    for j = 1:length(gridDropOut) % of graph
        for m = 1:length(gridDropOut) % of gru

            x = gridHiddenUnits(i);
            y = gridDropOut(j);
            z = gridDropOut(m);

            savingName = [savingPath,'subj',num2str(subject),'_net_','hdn',num2str(x),'_drop',num2str(y),'_',num2str(z)];
            net = load(savingName,'-mat');

            accuracies(i,j,m) = net.class.accuracy;
            cumulAccuracies(i,j,m,:) = net.accuracyThreshold;
        end
    end
end

[acc,idx] = max(accuracies,'all');
[cumulAcc,cumulIdx] = max(cumulAccuracies,'all');
