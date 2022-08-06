close all; clearvars; clc;


disp('importing the data')
filename = 'subj1_1trial.mat';
[Psd,settings] = startingTrain(filename,1:11);


%% Creating and extracting windows
disp('creating new windows label')

movwinLength = 2*settings.windowLength; % [s]
movwinShift = 2*settings.windowShift; % [s]
settings.NumHiddenUnits = 25;


%% Dividing in sequences
num = single(Psd.triggers.num);
Sxx = single(Psd.data(:,settings.idxFrequencyChoosen,:));
windows = single(Psd.windowsLabel);

disp('Data partition...')

nSamples = size(Sxx,1);
allSxx = single(permute(Sxx,[3,2,4,1]));
clear Sxx Psd

nMonwinSize = movwinLength/settings.windowShift;
nMonwinShift = movwinShift/settings.windowShift;
n_sequences = fix((nSamples-(nMonwinSize-nMonwinShift))/nMonwinShift);
seq_I = cell(n_sequences, 1);
seq_O = nan(n_sequences, 1);
onsetNum = [];
for i = 1:n_sequences
    start = (i-1)*nMonwinShift+1; stop = start + nMonwinSize - 1;
    %start = 1; stop = nMonwinSize;
    seq_I{i} = allSxx(:,:,:,start:stop);
    seq_O(i) = windows(stop);
    if i>1 && seq_O(i)>0 && seq_O(i-1)==0
        onsetNum = [onsetNum; seq_O(i) i];
    elseif i>1 && isnan(seq_O(i)) && seq_O(i-1)>0
        onsetNum = [onsetNum; 0 i];
    end
    %disp(int2str(i))
end
clear allSxx
clearvars -except seq_I seq_O settings onsetNum
%% Creating and extracting windows
disp('creating new windows label')

idxTrain = [];
idxVal = [];
idxTest = [];

% calculating how many trial for class balance
%num = histcounts(onsetNum(:,1));
% numTrain = round(min(numTrials)*settings.fractTrain);
% numVal = round(min(numTrials)*settings.fractVal);
% numTest = round(min(numTrials)*settings.fractTest);

% dividind in train, validation and test set
for i = settings.classes
    idxLabel = find(onsetNum(:,1) == i);
    numTrain = round(length(idxLabel)*settings.fractTrain);
    numVal = round(length(idxLabel)*settings.fractVal);
    numTest = round(length(idxLabel)*settings.fractTest);

    tempidxTrain = datasample(idxLabel,numTrain,'Replace',false);
    tempidxVal = datasample(setdiff(idxLabel, tempidxTrain),numVal,'Replace',false);
    tempidxTest = datasample(setdiff(idxLabel, [tempidxTrain; tempidxVal]),numTest,'Replace',false);
    idxTrain = [idxTrain; tempidxTrain];
    idxVal = [idxVal; tempidxVal];
    idxTest = [idxTest; tempidxTest];
end

disp('creating the input matrix')
nWindowsTrial = onsetNum(2,2)-onsetNum(1,2);

inputTrain = cell(length(idxTrain)*nWindowsTrial,1);
outputTrain = nan(size(inputTrain));
for i = 1:length(idxTrain)
    if onsetNum(idxTrain(i),1) ~= 0
        inputTrain((1:nWindowsTrial)+(i-1)*nWindowsTrial) = seq_I(onsetNum(idxTrain(i),2):onsetNum(idxTrain(i)+1,2)-1);
    else        
        inputTrain((1:nWindowsTrial)+(i-1)*nWindowsTrial) = seq_I((-nWindowsTrial:-1) + onsetNum(idxTrain(i)-1,2));
    end
    outputTrain((1:nWindowsTrial)+(i-1)*nWindowsTrial) = onsetNum(idxTrain(i),1);
end
outputTrain = categorical(outputTrain);

inputVal = cell(length(idxVal)*nWindowsTrial,1);
outputVal = nan(size(inputVal));
for i = 1:length(idxVal)
    if onsetNum(idxVal(i),1) ~= 0
        inputVal((1:nWindowsTrial)+(i-1)*nWindowsTrial) = seq_I(onsetNum(idxVal(i),2):onsetNum(idxVal(i)+1,2)-1);
    else        
        inputVal((1:nWindowsTrial)+(i-1)*nWindowsTrial) = seq_I((-nWindowsTrial:-1) + onsetNum(idxVal(i)-1,2));
    end
    outputVal((1:nWindowsTrial)+(i-1)*nWindowsTrial) = onsetNum(idxVal(i),1);
end
outputVal = categorical(outputVal);

inputTest = cell(length(idxTest)*nWindowsTrial,1);
outputTest = nan(size(inputTest));
for i = 1:length(idxTest)
    if onsetNum(idxTest(i),1) ~= 0
        inputTest((1:nWindowsTrial)+(i-1)*nWindowsTrial) = seq_I(onsetNum(idxTest(i),2):onsetNum(idxTest(i)+1,2)-1);
    else        
        inputTest((1:nWindowsTrial)+(i-1)*nWindowsTrial) = seq_I((-nWindowsTrial:-1) + onsetNum(idxTest(i)-1,2));
    end
    outputTest((1:nWindowsTrial)+(i-1)*nWindowsTrial) = onsetNum(idxTest(i),1);
end
outputTest = categorical(outputTest);

clearvars seq_O seq_I
%% Creating GCN
% layers = graphConvWithLearnStruct3Layer(NumFeatures,NumOutFeatures,NumEMG,NumEEG);
% checkLayer(layers,inputSize,ObservationDimension=4)

layers = [
    sequenceInputLayer(settings.inputSize,'Name','input','Normalization','zscore','NormalizationDimension','element')
    sequenceFoldingLayer('Name','fold')
    graphConvWithLearnStruct3Layer(settings.NumFeatures,settings.NumOutFeatures,settings.NumEMG,settings.NumEEG,'Name','GConv')
    reluLayer('Name','relu')
    batchNormalizationLayer
    dropoutLayer(0.1,'Name','drop')
    sequenceUnfoldingLayer('Name','unfold')
    flattenLayer('Name','flatten')
    gruLayer(settings.NumHiddenUnits,'OutputMode','last','Name','gru')
    dropoutLayer(0.1,'Name','drop')
    fullyConnectedLayer(settings.numClasses,'Name','fc')
    softmaxLayer('Name','soft')
    classificationLayer('Name','classification')];
lgraph = layerGraph(layers);
lgraph = connectLayers(lgraph,'fold/miniBatchSize','unfold/miniBatchSize');

miniBatchSize = 512; %512
validationFrequency = 2*floor(numel(outputTrain)/miniBatchSize);
options = trainingOptions('adam', ...
    'MiniBatchSize',miniBatchSize, ...
    'MaxEpochs',40, ...
    'InitialLearnRate',1e-3, ...
    'LearnRateSchedule','piecewise', ...
    'LearnRateDropFactor',1e-1, ...
    'LearnRateDropPeriod',30, ...
    'ValidationData',{inputVal,outputVal}, ...
    'Shuffle', 'once', ...
    'ValidationFrequency',validationFrequency, ...
    'Plots','training-progress', ...
    'Verbose',false, ...
    'ExecutionEnvironment','gpu');

%% Training
disp('model training')
net = trainNetwork(inputTrain, outputTrain, lgraph, options);

%% Prediction and confusion matrix
[confMatrix, class, pred] = trial_predict(net, inputTest, outputTest, settings);

accuracy = thresholdAccuracy(pred.cumul, outputTest, settings, [], true);
