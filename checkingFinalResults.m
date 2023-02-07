close all; clearvars; clc;

subjects = [7 11 15 19 23]; 

load timeCourseTriggerAverageHilbert.mat

%%
accuracies.micro = nan(length(subjects),26);
accuracies.macro = nan(length(subjects),26);

losses.micro = nan(length(subjects),26);
losses.macro = nan(length(subjects),26);

confMatrices.micro = cell(length(subjects),26);
confMatrices.macro = cell(length(subjects),26);

timeAccuracies.micro = cell(length(subjects),26);
timeAccuracies.macro = cell(length(subjects),26);

adjacencyMatrices = nan(length(subjects),26);

i = 1;
for subj = subjects
    
    disp(['subject ',num2str(subj)])
    [freqRes, timeRes, mlRes] = loadNetsResults(subj);

    [accuracies.micro(i,:), accuracies.macro(i,:)] = extractingAccuracies(freqRes, timeRes, mlRes);
    [losses.micro(i,:), losses.macro(i,:)] = extractingFinalLosses(freqRes, timeRes, mlRes);
    [confMatrices.micro(i,:), confMatrices.macro(i,:)] = extractingConfusionMatrices(freqRes, timeRes, mlRes);
    [timeAccuracies.micro(i,:), timeAccuracies.macro(i,:)] = extractingTimeAccuracies(freqRes, timeRes, mlRes); 
       
    i = i+1;
end

accuracies = correctData(accuracies);
losses = correctData(losses);
confMatrices = correctData(confMatrices);
timeAccuracies = correctData(timeAccuracies);

j = isnan(losses.micro);
accuracies.micro(j) = nan;

%%
acc.micro = mean(accuracies.micro,'omitnan');
acc.macro = mean(accuracies.macro,'omitnan');
sdAcc.micro = std(accuracies.micro,'omitnan');
sdAcc.macro = std(accuracies.macro,'omitnan');

loss.micro = mean(losses.micro,'omitnan');
loss.macro = mean(losses.macro,'omitnan');
sdLoss.micro = std(losses.micro,'omitnan');
sdLoss.macro = std(losses.macro,'omitnan');

maxPoint = 50;
tmpTimeAccMicro = nan(5,26,maxPoint);
tmpTimeAccMacro = nan(5,26,maxPoint);
for i = 1:26
    valDownSample = length(timeAccuracies.micro{1,i})/maxPoint;
    if valDownSample<1, valDownSample = 1; end
    for j = 1:size(tmpTimeAccMicro,1)
        if ~isempty(timeAccuracies.micro{j,i})
        tmpTimeAccMicro(j,i,:)  = downsample(timeAccuracies.micro{j,i},valDownSample);
        end
        if ~isempty(timeAccuracies.macro{j,i})
            tmpTimeAccMacro(j,i,:) = downsample(timeAccuracies.macro{j,i},valDownSample);
        end
    end
end
avTimeAcc.micro = squeeze(mean(tmpTimeAccMicro))';
avTimeAcc.macro = squeeze(mean(tmpTimeAccMacro))';

sdTimeAcc.micro = squeeze(std(tmpTimeAccMicro))';
sdTimeAcc.macro = squeeze(std(tmpTimeAccMacro))';

%% 
scaleAcc = 100;
maxAcc = 1.05*max(acc.micro+sdAcc.micro,[],'all');
barPlot(scaleAcc*acc.micro,'Mean Accuracy','Accuracy - All classes',scaleAcc*sdAcc.micro,scaleAcc*[0 maxAcc]);
barPlot(scaleAcc*acc.macro,'Mean Accuracy','Accuracy - Macro classes',scaleAcc*sdAcc.macro,scaleAcc*[0 1]);

maxLossMicro = 1.05*max(loss.micro+sdLoss.micro,[],'all');
maxLossMacro = 1.05*max(loss.macro+sdLoss.macro,[],'all');
barPlot(loss.micro,'Mean Loss','Final loss - All classes',sdLoss.micro,[0 maxLossMicro]);
barPlot(loss.macro,'Mean Loss','Final loss - Macro classes',sdLoss.macro,[0 maxLossMacro]);


%%
plotTimeAccuracies(avTimeAcc.micro,'all classes');
%plotTimeAccuracies(avTimeAcc.macro,'macro classes');

%%
[~,bestNet] = max(max(avTimeAcc.micro));

tmpTimeAverage = timeAverage;
valMin = min(tmpTimeAverage,[],2);
valMax = max(tmpTimeAverage-valMin,[],2);
[mx,idx] = max(valMax);
valOnset = mx*0.15;

x = 0.04:0.04:2;
xx = 0.04:1/500:2;
xEMG = -0.45:1/500:2;

maxDelay = 0.3;
addIdxDelay = 0.3*500;

avTimeInterp = linterp(x,avTimeAcc.micro(:,bestNet),xx);

idxOnsetEMG = find(tmpTimeAverage(idx,:)-valMin(idx,:)>=valOnset,1,'first');
idxOnsetAcc = find(xx==xEMG(idxOnsetEMG));

start = round((-0.45+0.5)*500+1);
figure()
subplot(3,1,[1,2]),
plot(xx,100*avTimeInterp)
ytickformat("percentage")
title('Best Accuracy and mean hilbert EMG')
hold on
xline(xx(idxOnsetAcc))
xline(xx(idxOnsetAcc+addIdxDelay),'--')
set(gca,'TickLength',[0 0],'FontWeight','bold')
xlim([xEMG(1) xEMG(end)])
ylim([min(100*avTimeInterp)*0.95 max(100*avTimeInterp)*1.05])
ylabel('Avg Acc')
for i = 3:3
    subplot(3,1,i), plot(xEMG, timeAverage(i-2,start:end))
    xlim([xEMG(1) xEMG(end)])
    xline(xEMG(idxOnsetEMG))
    xline(xEMG(idxOnsetEMG+addIdxDelay),'--')
    ylabel(['Ch',num2str(i-2), '  [\muV]'])
    set(gca,'TickLength',[0 0],'FontWeight','bold')
end
xlabel('Time [s]')

%% CONFUSION MATRIX AT CERTAIN TIME
%idxEvalutation = find(x>=xEMG(idxOnsetEMG+addIdxDelay),1,'first');
idxEvalutation = find(x>=xEMG(idxOnsetEMG),1,'first');

loadingPath='\Users\aless\OneDrive\Desktop\Tesi\codes\git_repo\final nets\';
loadingName = 'nn_GCN_dGRU_sequence_fxdDTime_';
loadingName = [loadingPath,'fullAdjFxdDiagonal\',loadingName,'subj'];

sbjc = [7 11 15 19 23];
confusionMatrix = calcConfMatrix(loadingName,idxEvalutation,sbjc);
%confusionMatrix = calcConfMatrix(loadingName,length(x),sbjc);

figure()
confusionchart(confusionMatrix,'Normalization','row-normalized');%,'ColumnSummary','absolute','RowSummary','absolute',


%%
%[rMicro,cMicro] = find(accuracies.micro == max(accuracies.micro,[],'all'));
%[rMacro,cMacro] = find(accuracies.macro == max(accuracies.macro,[],'all'));

load('chanlocs35.mat');
ch35 = chanlocs35;
ch7 = readlocs('chanlocs7.locs');
eeg_labels = {ch35.labels};
emg_labels = {ch7(1:6).labels};
load chanlocs64.mat
plot_ch_idx = fidx(eeg_labels,{chanlocs.labels});


% subjects = 7;
% Atmp = zeros(41);
% loadingPath='\Users\aless\OneDrive\Desktop\Tesi\codes\git_repo\final nets\fullAdjfxdDiagonal\';
% loadingNameStart = 'nn_GCN_dGRU_parallel_fxdDTime';
% for sbj = subjects
%     loadingName = [loadingPath,loadingNameStart,'subj',num2str(sbj)];
%     [AdjMatrix,EyeA] = extractAdjMatrix(loadingName);
% end
%Atmp = Atmp/length(subjects);
% 

subjects = 15;
A = zeros(41);
loadingPath='\Users\aless\OneDrive\Desktop\Tesi\codes\git_repo\final nets\';
%loadingNameStart = 'nn_GCN_dGRU_sequence_fxdDTime_';
loadingNameStart = 'nn_GCN_dGRU_sequence_fullAdjTime_';

for sbj = subjects
    loadingName = [loadingPath,loadingNameStart,'subj',num2str(sbj),'_noRaw'];
    %loadingName = [loadingPath,'fullAdjFxdDiagonal\',loadingNameStart,'subj',num2str(sbj)];
    [A,EyeA] = extractAdjMatrix(loadingName,false);
end
A = A/length(subjects);
% A = AdjMatrix;


k = max(A-EyeA,[],'all');
l = min(A-EyeA,[],'all');
lol = max(k,abs(l))*1.25;
val = 0.6;
%val = lol;
limits = [-val val];

xName = cell(41,1);
for i = 1:41
    xName(i) = {['N',num2str(i)]};
end

figure
imagesc(A,limits)
title('Weighted Adjacency Matrix')
xticks(1:size(A,1))
xticklabels(xName)
yticks(1:size(A,1))
yticklabels(cat(2,eeg_labels,emg_labels))
colormap(my_colormap(2))
colorbar


% figure
% ha = tight_subplot(2,length(emg_labels)/2,[0.001 0.001],[0.01 0.1],[0.05 0.05]);
% for m = 1:length(emg_labels)
%     axes(ha(m));
% 
%     y_plt = zeros(length(chanlocs),1);
%     y_plt(plot_ch_idx) = Atmp(length(ch35)+m,1:length(ch35));
% 
%     topoplot(y_plt, chanlocs, 'maplimits', limits, 'electrodes', 'off');
%     title(emg_labels{m},'FontSize',14);
% end




