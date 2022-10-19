close all; clearvars; clc;

subjects = [7 11 15 19 23]; 

%%
accuracies.micro = nan(length(subjects),14);
accuracies.macro = nan(length(subjects),14);

losses.micro = nan(length(subjects),14);
losses.macro = nan(length(subjects),14);

confMatrices.micro = cell(length(subjects),14);
confMatrices.macro = cell(length(subjects),14);

timeAccuracies.micro = cell(length(subjects),14);
timeAccuracies.macro = cell(length(subjects),14);

adjacencyMatrices = nan(length(subjects),14);

i = 1;
for subj = subjects
    
    disp(['subject ',num2str(subj)])
    [freqRes, timeRes, mlRes] = loadNetsResults(subj);

    [accuracies.micro(i,:), accuracies.macro(i,:)] = extractingAccuracies(freqRes, timeRes, mlRes);
    [losses.micro(i,:), losses.macro(i,:)] = extractingFinalLosses(freqRes, timeRes, mlRes);
    [confMatrices.micro(i,:), confMatrices.macro(i,:)] = extractingConfusionMatrices(freqRes, timeRes, mlRes);
    [timeAccuracies.micro(i,:), timeAccuracies.macro(i,:)] = extractingTimeAccuracies(freqRes, timeRes, mlRes); 
    %adjacencyMatrices(1,:) = extractingAdjacencyMatrices(freqRes, timeRes);
       
    i = i+1;
end

%%
acc.micro = mean(accuracies.micro);
acc.macro = mean(accuracies.macro);
sdAcc.micro = std(accuracies.micro);
sdAcc.macro = std(accuracies.macro);

loss.micro = mean(losses.micro);
loss.macro = mean(losses.macro);
sdLoss.micro = std(losses.micro);
sdLoss.macro = std(losses.macro);

% medAcc.micro = median(accuracies.micro);
% medAcc.macro = median(accuracies.macro);
% sdMedAcc.micro = mad(accuracies.micro);
% sdMedAcc.macro = mad(accuracies.macro);
% 
% medLoss.micro = median(losses.micro);
% medLoss.macro = median(losses.macro);
% sdMedLoss.micro = mad(losses.micro);
% sdMedLoss.macro = mad(losses.macro);


maxPoint = 100;
tmpTimeAccMicro = nan(5,14,maxPoint);
tmpTimeAccMacro = nan(5,14,maxPoint);
for i = 1:14
    valDownSample = length(timeAccuracies.macro{1,i})/maxPoint;
    for j = 1:5
        tmpTimeAccMacro(j,i,:) = downsample(timeAccuracies.macro{j,i},valDownSample);
        tmpTimeAccMicro(j,i,:)  = downsample(timeAccuracies.micro{j,i},valDownSample);
    end
end
avTimeAcc.micro = squeeze(mean(tmpTimeAccMicro))';
avTimeAcc.macro = squeeze(mean(tmpTimeAccMacro))';

sdTimeAcc.micro = squeeze(std(tmpTimeAccMicro))';
sdTimeAcc.macro = squeeze(std(tmpTimeAccMacro))';

%% 
scaleAcc = 100;
barPlot(scaleAcc*acc.micro,'Mean Accuracy','All classes',scaleAcc*sdAcc.micro);
barPlot(scaleAcc*acc.macro,'Mean Accuracy','Macro classes',scaleAcc*sdAcc.macro,scaleAcc*[0 1]);

% barPlot(scaleAcc*medAcc.micro,'Median Accuracy','All classes',scaleAcc*sdMedAcc.micro);
% barPlot(scaleAcc*medAcc.macro,'Median Accuracy','Macro classes',scaleAcc*sdMedAcc.macro,scaleAcc*[0 1]);


% lossMaxMicro = max([loss.micro+sdLoss.micro,medLoss.micro+sdMedLoss.micro],[],'all');
% lossMaxMacro = max([loss.macro+sdLoss.macro,medLoss.macro+sdMedLoss.macro],[],'all');
% lossMinMicro = min([loss.micro-sdLoss.micro,medLoss.micro-sdMedLoss.micro],[],'all');
% lossMinMacro = min([loss.macro-sdLoss.macro,medLoss.macro-sdMedLoss.macro],[],'all');

barPlot(loss.micro,'Final Mean Loss','All classes',sdLoss.micro);%,[lossMinMicro lossMaxMicro]);
barPlot(loss.macro,'Final Mean Loss','Macro classes',sdLoss.macro);%,[lossMinMacro lossMaxMacro]);

% barPlot(medLoss.micro,'Final Median Loss','All classes',sdMedLoss.micro,[lossMinMicro lossMaxMicro]);
% barPlot(medLoss.macro,'Final MedianLoss','Macro classes',sdMedLoss.macro,[lossMinMacro lossMaxMacro]);


%%
plotTimeAccuracies(avTimeAcc.micro,'all classes');
plotTimeAccuracies(avTimeAcc.macro,'macro classes');


%%
[rMicro,cMicro] = find(accuracies.micro == max(accuracies.micro,[],'all'));
[rMacro,cMacro] = find(accuracies.macro == max(accuracies.macro,[],'all'));

load('chanlocs35.mat');
ch35 = chanlocs35;
ch7 = readlocs('chanlocs7.locs');
eeg_labels = {ch35.labels};
emg_labels = {ch7(1:6).labels};
load chanlocs64.mat
plot_ch_idx = fidx(eeg_labels,{chanlocs.labels});



Atmp = zeros(41);
loadingPath='\Users\aless\OneDrive\Desktop\Tesi\codes\git_repo\final nets\';
loadingNameStart = 'nn_GCN_dGRU_sequence_fullAdjFreq_';
for sbj = subjects
    loadingName = [loadingPath,loadingNameStart,'subj',num2str(sbj),'_noRaw'];
    net = load(loadingName);
    net = net.net;
    
    settings.NumChannels = 41;
    Wa = double(net.Layers(3).Wa);
    Aui = triu(ones(settings.NumChannels));
    Al = tril(ones(settings.NumChannels),-1);
    A = Aui;
    A(A>0) = Wa;
    A = A + Al.*A';
    Atmp = Atmp + normAdjacency(A);
    % Atmp(end-size(Wa,1)+1:end,1:size(Wa,2)) = A(end-size(Wa,1)+1:end,1:size(Wa,2)).*Wa;
    % Atmp(1:size(Wa,2),end-size(Wa,1)+1:end) = A(1:size(Wa,2),end-size(Wa,1)+1:end).*(Wa)';
end
Atmp = Atmp/5;



figure
imagesc(Atmp,[-0.2 0.2])
xticks(1:size(A,1))
xticklabels(cat(2,eeg_labels,emg_labels))
yticks(1:size(A,1))
yticklabels(cat(2,eeg_labels,emg_labels))
colormap(my_colormap(2))
colorbar


figure
ha = tight_subplot(2,length(emg_labels)/2,[0.001 0.001],[0.01 0.1],[0.05 0.05]);
for m = 1:length(emg_labels)
    axes(ha(m));

    y_plt = zeros(length(chanlocs),1);
    y_plt(plot_ch_idx) = Atmp(length(ch35)+m,1:length(ch35));

    topoplot(y_plt, chanlocs, 'maplimits', [-0.2 0.2], 'electrodes', 'off');
    title(emg_labels{m},'FontSize',14);
end




