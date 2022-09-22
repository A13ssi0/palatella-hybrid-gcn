close all; clearvars; clc;
rng(12)

subject = 7;

loadingPath='/home/palatella/workspace/palatella_datasets/';
savingPath='/home/palatella/workspace/palatella_net/';

typeOfMl = 'LDA';
endName = '';

disp('importing the data')
filename = ['subj',num2str(subject),'_featuresEMG.mat'];
load(filename)

doMacro = false;
%%
settings.movwinLength = settings.windowLength; % [s]
settings.movwinShift = settings.windowShift; % [s]

nSamples = length(windowsLabel);

if doMacro
    windowsLabel(windowsLabel>=1 & windowsLabel<=2) = 1;
    windowsLabel(windowsLabel>=3 & windowsLabel<=8) = 2;
    windowsLabel(windowsLabel>=9 & windowsLabel<=11) = 3;
end

tWinlabel = windowsLabel;
tWinlabel(isnan(tWinlabel)) = 0;
idx = find(diff(tWinlabel));

onsetNum = [tWinlabel(idx+1)' idx'+1];


%% dividind in train, validation and test set
disp('creating new windows label')

idxTrain = [];idxTest = [];

settings.classes = unique(windowsLabel(~isnan(windowsLabel)));
if settings.classes(1) == 0,  settings.classes(1)=[]; end


for i = settings.classes
    idxLabel = find(onsetNum(:,1) == i);
    numTrain = round(length(idxLabel)*0.65);
    numTest = round(length(idxLabel)*0.35);

    tempidxTrain = datasample(idxLabel,numTrain,'Replace',false);
    tempidxTest = setdiff(idxLabel, tempidxTrain);

    idxTrain = [idxTrain; tempidxTrain];
    idxTest = [idxTest; tempidxTest];
end
nWindowsTrial = onsetNum(2,2)-onsetNum(1,2);


finalIdxTrain = nan(length(idxTrain)*nWindowsTrial,1);
for i = 1:length(idxTrain)
    finalIdxTrain((1:nWindowsTrial)+(i-1)*nWindowsTrial) = onsetNum(idxTrain(i),2):(onsetNum(idxTrain(i)+1,2)-1);
end

finalIdxTest = nan(length(idxTest)*nWindowsTrial,1);
for i = 1:length(idxTest)
    finalIdxTest((1:nWindowsTrial)+(i-1)*nWindowsTrial) = onsetNum(idxTest(i),2):(onsetNum(idxTest(i)+1,2)-1);
end


%%
trainInput = [
    features.avFreq(:,finalIdxTrain)
    features.MAV(:,finalIdxTrain)
    features.medianFreq(:,finalIdxTrain)
    features.RMS(:,finalIdxTrain)
    features.sd(:,finalIdxTrain)
    features.WL(:,finalIdxTrain)
    features.zCross(:,finalIdxTrain)
];
trainOutput = windowsLabel(finalIdxTrain);

%%
disp('Training Machine Learning Model')
% tmplSVM = templateSVM("KernelFunction","gaussian");
% mlModel = fitcecoc(trainInput,categorical(trainOutput),"ObservationsIn","columns","Learners",tmplSVM);
 mlModel = fitcdiscr(trainInput',categorical(trainOutput'));


%%
testInput = [
    features.avFreq(:,finalIdxTest)
    features.MAV(:,finalIdxTest)
    features.medianFreq(:,finalIdxTest)
    features.RMS(:,finalIdxTest)
    features.sd(:,finalIdxTest)
    features.WL(:,finalIdxTest)
    features.zCross(:,finalIdxTest)
];
testOutput = windowsLabel(finalIdxTest);

pred = predict(mlModel,testInput');
accuracy = sum(pred==categorical(testOutput'))/length(testOutput);

disp(['The accuracy is:  ',num2str(accuracy)])

%%
settings.typeOfMLmodel = typeOfMl;
savingName = [savingPath,'subj',num2str(subject),'_',typeOfMl,'_',endName];
save(savingName,'mlModel','settings');

%%
c = confusionmat(categorical(testOutput)',pred');
figure()
confusionchart(c,'ColumnSummary','absolute','RowSummary','absolute','Normalization','row-normalized');
