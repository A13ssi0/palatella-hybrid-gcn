close all; clearvars; clc;

subjects = [7 11 15 19 23]; %13, 7 11 19 23

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


avTimeAcc.micro = cell(1,14);
sdTimeAcc.macro = cell(1,14);

for i = 1:14
    tmpTimeAccMacro = [];
    tmpTimeAccMicro = [];
    for j = 1:5
        tmpTimeAccMacro = [
            tmpTimeAccMacro
            timeAccuracies.macro{j,i}
            ];
        tmpTimeAccMicro = [
            tmpTimeAccMicro
            timeAccuracies.micro{j,i}
            ];
    end
    avTimeAcc.micro{i} = mean(tmpTimeAccMicro);
    avTimeAcc.macro{i} = mean(tmpTimeAccMacro);

    sdTimeAcc.micro{i} = std(tmpTimeAccMicro);
    sdTimeAcc.macro{i} = std(tmpTimeAccMacro);
end

%% 
xTickNames = {'Parallel';'Sequential';'onlyGCN';'LDA';'RF'};

x = [1:4,6:9,11:14,16:17];
color1 = [0.85 0.325 0.098];
color2 = [0.466 0.674 0.188];
color3 = [0.301 0.745 0.933];
%color4 = [0.494 0.184 0.556];

colors = [color1; color1; color2; color2];
colors = [colors;colors;colors; color3; color3];
lineStyle = cell(14,1);
lineStyle(:) = {'-'};
lineStyle(1:2:11) = {'-.'};
%x = 1:14
figure()
hold on
for i = 1:3
    b = bar(i,nan,'FaceColor','flat');
    b.CData = colors(2+6*(i-1),:);
end
bar(1,nan,'white','LineStyle','-.');
bar(1,nan,'white');
for i = 1 : length(x)
    b = bar(x(i),acc.micro(i),'FaceColor','flat','LineWidth',0.5);
    b.CData = colors(i,:);
    % frequency dotted
    if rem(i,2) == 1, b.LineStyle = lineStyle{i}; end
end
er = errorbar(x,acc.micro,sdAcc.micro,sdAcc.micro);
er.Color = [0 0 0];
er.LineStyle = 'none';

xticks([2.5,7.5,12.5,16,17])
set(gca,'XTickLabel',xTickNames,'TickLength',[0 0],'FontWeight','bold')

lgd = legend('Time','Frequency','Features','Partial coherence','Total coherence');
lgd.FontWeight = 'normal';
ylabel('Accuracy')



