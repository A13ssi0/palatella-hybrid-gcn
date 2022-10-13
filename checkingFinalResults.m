close all; clearvars; clc;

subjects = [7 11 19 23]; %13, 7 11 19 23

%%
accuracies.micro = nan(length(subjects),14);
accuracies.macro = nan(length(subjects),14);

lossMicro = nan(length(subjects),12);

confMatrices.micro = nan(length(subjects),14);
confMatrices.macro = nan(length(subjects),14);

timeAccuracies = nan(length(subjects),14);

adjacencyMatrices = nan(length(subjects),14);

i = 1;
for subj = subjects

    [freqRes, timeRes, mlRes] = loadNetsResults(subject);

    [accuracies.micro(i,:), accuracies.macro(i,:)] = extractingAccuracies(freqRes, timeRes, mlRes);
    lossMicro(1,:) = extractingFinalLosses(freqRes, timeRes);
    [confMatrices.micro(i,:), confMatrices.macro(i,:)] = extractingConfusionMatrices(freqRes, timeRes, mlRes);
    timeAccuracies(i,:,:) = extractingTimeAccuracies(freqRes, timeRes, mlRes)'; 
    %adjacencyMatrices(1,:) = extractingAdjacencyMatrices(freqRes, timeRes);
        
end

%%
acc.micro = mean(accuracies.micro);
acc.macro = mean(accuracies.macro);
sdAcc.micro = sd(accuracies.micro);
sdAcc.macro = sd(accuracies.macro);

