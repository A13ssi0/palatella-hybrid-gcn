close all; clearvars; clc;
load h_Sxx.mat
load labelWindows.mat

Sxx = h_Sxx; clear h_Sxx;

%% Settings
settings.NumChannels = size(Sxx,3);
settings.NumFeatures = size(Sxx,2);
settings.NumOutFeatures = 32; 
settings.NumHiddenUnits = settings.NumOutFeatures;

settings.inputSize = [settings.NumChannels settings.NumFeatures 1];

settings.NumEMG = 6;
settings.NumEEG = settings.NumChannels-settings.NumEMG;

settings.freq_wind = 20;
settings.size_wind = 1/settings.freq_wind;

settings.secPreMovement = 1;
settings.secPostMovement = 0.5;
settings.secZeroPreMovement = 2.5;

settings.fractTrain = 0.80;
settings.classes = 1:6;

% dividing in reach-grab-twist
% windows(windows>=1 & windows<=6) = 1;
% windows(windows>=7 & windows<=9) = 2;
% windows(windows>=10 & windows<=11) = 3;
% settings.classes = 0:3;

settings.numClasses = length(settings.classes);
%idxLast = find(windows==settings.numClasses-1, 1 ,'last');
%windows = windows(1:idxLast);


%% Creating 
newLabelWindows = nan(length(windows),1);
windows(isnan(windows)) = 0;
disp('creating new windows label')

% windowing pre and  post movement
nWindPreMov = settings.secPreMovement/settings.size_wind;
nWindPostMov = settings.secPostMovement/settings.size_wind;
nWindZeroPreMov = settings.secZeroPreMovement/settings.size_wind;

idx = find(diff(windows)>0);
for i = idx'
    newLabelWindows(i-nWindPreMov+1:i+nWindPostMov) = windows(i+1);
    newLabelWindows(i-nWindPreMov-nWindZeroPreMov:i-nWindPreMov) = 0;
end

idxNotNan = find(~isnan(newLabelWindows));
idxTrain = [];
idxVal = [];

% calculating how many points for class balance
numPoints = inf;
for i = settings.classes
    num = sum(newLabelWindows == i);
    if num<numPoints,   numPoints = num; end
end

% dividind in train and validation set
for i = flip(settings.classes)
    idxLabel = find(newLabelWindows == i);
    
    numTrain = round(numPoints*settings.fractTrain);
    numVal = numPoints-numTrain;
    tempidxTrain = datasample(idxLabel,numTrain,'Replace',false);
    tempidxVal = datasample(setdiff(idxLabel, tempidxTrain),numVal,'Replace',false);
    idxTrain = [idxTrain; tempidxTrain];
    idxVal = [idxVal; tempidxVal];
end

for i = unique(newLabelWindows(idxTrain))'
    idxLabel = find(newLabelWindows(idxTrain) == i);
    disp(['Percentage of windows with label ', num2str(i),': ',num2str(round(length(idxLabel)/length(idxTrain),3))])
end

outputTrain = categorical(newLabelWindows(idxTrain));
outputVal = categorical(newLabelWindows(idxVal));

disp('creating the input matrix')
inputTrain = zeros([settings.inputSize length(idxTrain)]);
for i = 1:length(idxTrain)
    inputTrain(:,:,1,i) = squeeze(Sxx(idxTrain(i),:,:))';
end

inputVal = zeros([settings.inputSize length(idxVal)]);
for i = 1:length(idxVal)
    inputVal(:,:,1,i) = squeeze(Sxx(idxVal(i),:,:))';
end

%%
% layers = graphConvWithLearnStruct3Layer(NumFeatures,NumOutFeatures,NumEMG,NumEEG);
% checkLayer(layers,inputSize,ObservationDimension=4)
layers = [
    imageInputLayer(settings.inputSize,'Normalization','zscore')
    graphConvWithLearnStruct3Layer(settings.NumFeatures,settings.NumHiddenUnits,settings.NumEMG,settings.NumEEG)
    reluLayer
    %batchNormalizationLayer
%     graphConvWithLearnStruct3Layer(settings.NumHiddenUnits,settings.NumOutFeatures,settings.NumEMG,settings.NumEEG)
%     reluLayer
    batchNormalizationLayer
    fullyConnectedLayer(settings.numClasses)
    softmaxLayer
    classificationLayer];

miniBatchSize  = 1024;
validationFrequency = floor(numel(outputTrain)/miniBatchSize);
options = trainingOptions('adam', ...
    'MiniBatchSize',miniBatchSize, ...
    'MaxEpochs',60, ...
    'InitialLearnRate',1e-2, ...
    'LearnRateSchedule','piecewise', ...
    'LearnRateDropFactor',1e-1, ...
    'LearnRateDropPeriod',15, ...
    'ValidationData',{inputVal,outputVal}, ...
    'Shuffle', 'once', ...
    'ValidationFrequency',validationFrequency, ...
    'Plots','training-progress', ...
    'Verbose',false);

%%
disp('model training')
net = trainNetwork(inputTrain, outputTrain, layers, options);

%%
%YPred = predict(net,inputVal);
YLabs = classify(net,inputVal);
accuracy = sum(YLabs == outputVal)/numel(outputVal);

C = confusionmat(outputVal,YLabs);
cm = confusionchart(C,'ColumnSummary','column-normalized','RowSummary','row-normalized');

%save confMatrix12 cm