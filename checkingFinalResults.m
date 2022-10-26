close all; clearvars; clc;

subjects = [7 11 15 19 23]; 

load timeCourseTriggerAverageHilbert.mat

%%
accuracies.micro = nan(length(subjects),20);
accuracies.macro = nan(length(subjects),20);

losses.micro = nan(length(subjects),20);
losses.macro = nan(length(subjects),20);

confMatrices.micro = cell(length(subjects),20);
confMatrices.macro = cell(length(subjects),20);

timeAccuracies.micro = cell(length(subjects),20);
timeAccuracies.macro = cell(length(subjects),20);

adjacencyMatrices = nan(length(subjects),20);

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

accuracies = correctData(accuracies);
losses = correctData(losses);
confMatrices = correctData(confMatrices);
timeAccuracies = correctData(timeAccuracies);

j = isnan(losses.micro);
j(:,3:3:18) = 0;
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

maxPoint = 100;
tmpTimeAccMicro = nan(5,20,maxPoint);
tmpTimeAccMacro = nan(5,20,maxPoint);
for i = 1:size(tmpTimeAccMicro,2)
    valDownSample = length(timeAccuracies.micro{1,i})/maxPoint;
    for j = 1:size(tmpTimeAccMicro,1)
        tmpTimeAccMicro(j,i,:)  = downsample(timeAccuracies.micro{j,i},valDownSample);
    end
    valDownSample = length(timeAccuracies.macro{1,i})/maxPoint;
    if valDownSample >0 
    for j = 1:size(tmpTimeAccMacro,1)
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
barPlot(scaleAcc*acc.micro,'Mean Accuracy','All classes',scaleAcc*sdAcc.micro);
barPlot(scaleAcc*acc.macro,'Mean Accuracy','Macro classes',scaleAcc*sdAcc.macro,scaleAcc*[0 1]);

barPlot(loss.micro,'Final Mean Loss','All classes',sdLoss.micro);
barPlot(loss.macro,'Final Mean Loss','Macro classes',sdLoss.macro);


%%
plotTimeAccuracies(avTimeAcc.micro,'all classes');
%plotTimeAccuracies(avTimeAcc.macro,'macro classes');


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


subjects = 7;
Atmp = zeros(41);
loadingPath='\Users\aless\OneDrive\Desktop\Tesi\codes\git_repo\final nets\';
loadingNameStart = 'nn_GCN_dGRU_parallel_fullAdjTime';
for sbj = subjects
    loadingName = [loadingPath,loadingNameStart,'subj',num2str(sbj),'_noRaw'];
    net = load(loadingName);
    net = net.net;
    
    settings.NumChannels = 41;
    %Wa = double(net.Layers(3).Wa);
    Wa = double(net.Layers(7).Wa);
    Aui = triu(ones(settings.NumChannels));
    Al = tril(ones(settings.NumChannels),-1);
    A = Aui;
    A(A>0) = Wa;
    A = A + Al.*A';
    A = normAdjacency(A);
    Atmp = Atmp + A;
    % Atmp(end-size(Wa,1)+1:end,1:size(Wa,2)) = A(end-size(Wa,1)+1:end,1:size(Wa,2)).*Wa;
    % Atmp(1:size(Wa,2),end-size(Wa,1)+1:end) = A(1:size(Wa,2),end-size(Wa,1)+1:end).*(Wa)';
end
Atmp = Atmp/length(subjects);

% subjects = 7;
% Atmp = zeros(41);
% loadingPath='\Users\aless\OneDrive\Desktop\Tesi\codes\git_repo\final nets\';
% loadingNameStart = 'nn_GCN_dGRU_parallel_fxdDTime';
% for sbj = subjects
%     loadingName = [loadingPath,loadingNameStart,'subj',num2str(sbj)];
%     net = load(loadingName);
%     net = net.net;
%     
%     settings.NumChannels = 41;
%     Wa = double(net.Layers(7).Wa);
%     A = extractdata(net.Layers(7).A);
%     A(end-size(Wa,1)+1:end,1:size(Wa,2)) = A(end-size(Wa,1)+1:end,1:size(Wa,2)).*Wa;
%     A(1:size(Wa,2),end-size(Wa,1)+1:end) = A(1:size(Wa,2),end-size(Wa,1)+1:end).*(Wa)';
% 
%     %A = normAdjacency(A);
%     Atmp = Atmp + A;
% end
% Atmp = Atmp/length(subjects);

val = 0.6;
limits = [-val val];


xName = cell(41,1);
for i = 1:41
    xName(i) = {['N',num2str(i)]};
end
figure
imagesc(Atmp,limits)
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

%%
x = 0.02:0.02:2;
xEMG = -0.5:1/500:2;
%emgMax = max(abs(timeAverage),[],'all');

figure()
subplot(8,1,[1,2]),
plot(x,avTimeAcc.micro(:,2))
hold on
set(gca,'TickLength',[0 0],'FontWeight','bold')
xlim([-0.5 2])
ylabel('Avg Acc')
for i = 3:8
    subplot(8,1,i), plot(xEMG, timeAverage(i-2,:))
    xlim([-0.5 2])
    %ylim([-emgMax emgMax])
    ylabel(['Ch',num2str(i-2)])
    set(gca,'TickLength',[0 0],'FontWeight','bold')
end
xlabel('time [s]')

