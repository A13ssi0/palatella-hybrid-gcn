function [trainFeatures,testFeatures,settings] = startingSplittingFeatures(filename,classes)

load(filename)

settings.movWinLength = settings.windowLength; % [s]
settings.movWinShift = settings.windowShift; % [s]

if ~exist('classes','var') || isempty(classes)
    windowsLabel(windowsLabel>=1 & windowsLabel<=2) = 1;
    windowsLabel(windowsLabel>=3 & windowsLabel<=8) = 2;
    windowsLabel(windowsLabel>=9 & windowsLabel<=11) = 3;
    settings.classes = 1:3;
else
    settings.classes = classes;
end

tWinlabel = windowsLabel;
tWinlabel(isnan(tWinlabel)) = 0;
idx = find(diff(tWinlabel));

onsetNum = [tWinlabel(idx+1)' idx'+1];


% dividind in train and test set
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


trainFeatures.input = [
    features.avFreq(:,finalIdxTrain)
    features.MAV(:,finalIdxTrain)
    features.medianFreq(:,finalIdxTrain)
    features.RMS(:,finalIdxTrain)
    features.sd(:,finalIdxTrain)
    features.WL(:,finalIdxTrain)
    features.zCross(:,finalIdxTrain)
];
trainFeatures.output = windowsLabel(finalIdxTrain);


testFeatures.input = [
    features.avFreq(:,finalIdxTest)
    features.MAV(:,finalIdxTest)
    features.medianFreq(:,finalIdxTest)
    features.RMS(:,finalIdxTest)
    features.sd(:,finalIdxTest)
    features.WL(:,finalIdxTest)
    features.zCross(:,finalIdxTest)
];
testFeatures.output = windowsLabel(finalIdxTest);
