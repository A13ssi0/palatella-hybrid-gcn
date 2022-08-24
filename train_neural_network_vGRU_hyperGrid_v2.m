close all; clearvars; clc;
rng(12)

subject = 7;
gridHiddenUnits = 25:10:55;
gridDropOut = 0:0.3:0.9;
savingPath='/home/palatella/workspace/palatella_net/';


%%
disp('importing the data')
filename = ['subj',num2str(subject),'_psd.mat'];
[Psd,settings] = startingTrain(filename,1:11);


%% Creating and extracting windows
disp('creating new windows label')

settings.movwinLength = 2*settings.windowLength; % [s]
settings.movwinShift = 2*settings.windowShift; % [s]

%% Dividing in sequences
num = single(Psd.triggers.num);
Sxx = single(Psd.data(:,settings.idxFrequencyChoosen,:));
windows = single(Psd.windowsLabel);

disp('Data partition...')

nSamples = size(Sxx,1);
allSxx = single(permute(Sxx,[3,2,4,1]));
clear Sxx Psd

nMonwinSize = settings.movwinLength/settings.windowShift;
nMonwinShift = settings.movwinShift/settings.windowShift;
n_sequences = fix((nSamples-(nMonwinSize-nMonwinShift))/nMonwinShift);
seq_O = nan(n_sequences, 1);
onsetNum = [];
for i = 1:n_sequences
    start = (i-1)*nMonwinShift+1; stop = start + nMonwinSize - 1;
    seq_O(i) = windows(stop);
    if i>1 && seq_O(i)>0 && seq_O(i-1)==0
        onsetNum = [onsetNum; seq_O(i) i];
    elseif i>1 && isnan(seq_O(i)) && seq_O(i-1)>0
        onsetNum = [onsetNum; 0 i];
    end
end
clearvars -except allSxx settings onsetNum grid* savingPath subject
%% Creating and extracting windows
disp('creating new windows label')

idxTrain = [];
idxVal = [];
idxTest = [];

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

[inputTrain, outputTrain] = createInputOutputMatrices(allSxx, idxTrain, onsetNum, settings);
[inputVal, outputVal] = createInputOutputMatrices(allSxx, idxVal, onsetNum, settings);
[inputTest, outputTest] = createInputOutputMatrices(allSxx, idxTest, onsetNum, settings);

clearvars -except input* output* settings gridDropOut gridHiddenUnits savingPath subject

%% Testing neural network
bestAccuracy.accuracy = 0;

disp('model training')
for x = gridHiddenUnits 
    for y = gridDropOut % of graph
        for z = gridDropOut % of gru
            disp(['HiddenUnits: ',num2str(x),'   GcnDropOut: ',num2str(y),'   GruDropOut: ',num2str(z)])

            settings.NumHiddenUnits = x;
            settings.gcnDropOut = y;
            settings.gruDropOut = z;

            [net, info, confMatrix, class, pred, accuracyThresholds] = testingNeuralNetwork(settings, outputTrain, inputVal, outputVal, inputTrain, inputTest, outputTest);

            if class.accuracy>bestAccuracy.accuracy
                bestAccuracy.accuracy = class.accuracy;
                bestAccuracy.hiddenUnits = x;
                bestAccuracy.gcnDrop = y;
                bestAccuracy.gruDrop = z;
            end

            savingName = [savingPath,'subj',num2str(subject),'_net_','hdn',num2str(x),'_drop',num2str(y),'_',num2str(z)];
            save(savingName,'net','info','confMatrix','class','pred','accuracyThresholds','settings','-v7.3');
        end
    end
end

save bestCaseScenario bestAccuracy


function [net, info, confMatrix, class, pred, accuracyThresholds] = testingNeuralNetwork(settings, outputTrain, inputVal, outputVal, inputTrain, inputTest, outputTest)
    layers = [
        sequenceInputLayer(settings.inputSize,'Name','input','Normalization','zscore','NormalizationDimension','element')
        sequenceFoldingLayer('Name','fold')
        graphConvWithLearnStruct3Layer(settings.NumFeatures,settings.NumOutFeatures,settings.NumEMG,settings.NumEEG,'Name','GConv')
        reluLayer('Name','relu')
        batchNormalizationLayer
        dropoutLayer(settings.gcnDropOut,'Name','GcnDrop')
        sequenceUnfoldingLayer('Name','unfold')
        flattenLayer('Name','flatten')
        gruLayer(settings.NumHiddenUnits,'OutputMode','last','Name','gru')
        dropoutLayer(settings.gruDropOut,'Name','GruDrop')
        fullyConnectedLayer(settings.numClasses,'Name','fc')
        softmaxLayer('Name','soft')
        classificationLayer('Name','classification')];
    lgraph = layerGraph(layers);
    lgraph = connectLayers(lgraph,'fold/miniBatchSize','unfold/miniBatchSize');
    
    miniBatchSize = 1024; %512
    validationFrequency = 2*floor(numel(outputTrain)/miniBatchSize);
    options = trainingOptions('adam', ...
        'MiniBatchSize',miniBatchSize, ...
        'MaxEpochs',60, ...
        'InitialLearnRate',1e-2, ...
        'LearnRateSchedule','piecewise', ...
        'LearnRateDropFactor',1e-1, ...
        'LearnRateDropPeriod',20, ...
        'ValidationData',{inputVal,outputVal}, ...
        'Shuffle', 'once', ...
        'ValidationFrequency',validationFrequency, ...
        'Verbose',false, ...
        'ExecutionEnvironment','gpu');
        %'Plots','training-progress', ...
    
    % Training
    [net, info] = trainNetwork(inputTrain, outputTrain, lgraph, options);
    
    % Prediction and confusion matrix
    [confMatrix, class, pred] = trial_predict(net, inputTest, outputTest, settings);
    
    accuracyThresholds = thresholdAccuracy(pred.cumul, outputTest, settings, []);
end