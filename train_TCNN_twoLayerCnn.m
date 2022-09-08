close all; clearvars; clc;
rng(12)

subject = 7;
% gridHiddenUnits = 50:50:250;
% gridNumOutFeatures = [7, 14:14:50];
% gridDropOut = [0 0.1 0.3];

savingPath='/home/palatella/workspace/palatella_net/';


%%
disp('importing the data')
filename = ['subj',num2str(subject),'_psd.mat'];
[Psd,settings] = startingTrain(filename);

settings.nFiltersCnn = 12;
settings.sizeFiltersCnn = 65;
settings.firstDropOut = 0.3;
settings.secondDropOut = 0.3;

%% Creating and extracting windows
disp('creating new windows label')

num = Psd.triggers.num;
Sxx = Psd.data;
windowsLabel = Psd.windowsLabel;

%% Creating and extracting windows
disp('creating new windows label')

idxTrain = [];
idxVal = [];
idxTest = [];

% dividind in train, validation and test set
for i = settings.classes
    idxLabel = find(num == i);
    numTrials = length(idxLabel);
    numTrain = round(numTrials*settings.fractTrain);
    numVal = round(numTrials*settings.fractVal);
    numTest = round(numTrials*settings.fractTest);

    tempidxTrain = datasample(idxLabel,numTrain,'Replace',false);
    tempidxVal = datasample(setdiff(idxLabel, tempidxTrain),numVal,'Replace',false);
    tempidxTest = datasample(setdiff(idxLabel, [tempidxTrain; tempidxVal]),numTest,'Replace',false);

    idxTrain = [idxTrain; tempidxTrain];
    idxVal = [idxVal; tempidxVal];
    idxTest = [idxTest; tempidxTest];
end


[inputTrain, outputTrain] = createInputOutputVectors(Sxx, idxTrain, num, Psd.triggers.time, windowsLabel, settings);
[inputVal, outputVal] = createInputOutputVectors(Sxx, idxVal, num, Psd.triggers.time, windowsLabel, settings);
[inputTest, outputTest] = createInputOutputVectors(Sxx, idxTest, num, Psd.triggers.time, windowsLabel, settings);

clearvars -except input* output* settings grid* savingPath subject

%% Testing neural network
% bestAccuracy.accuracy = 0;
% 
% disp('model training')
% for x = gridNumOutFeatures 
%     for y =  gridDropOut % of graph
%             disp(['OutFeatures: ',num2str(x),'   GcnDropOut: ',num2str(y)])
% 
%             settings.NumOutFeatures = x;
%             settings.gcnDropOut = y;
% 
%             [net, info, confMatrix, class, pred, accuracyThresholds] = testingNeuralNetwork(settings, outputTrain, inputVal, outputVal, inputTrain, inputTest, outputTest);
% 
%             if class.accuracy>bestAccuracy.accuracy
%                 bestAccuracy.accuracy = class.accuracy;
%                 bestAccuracy.outFeatures = x;
%                 bestAccuracy.gcnDrop = y;
%             end
% 
%             savingName = [savingPath,'subj',num2str(subject),'_net_outF',num2str(x),'_drop',num2str(y),'_macroTCNN'];
%             save(savingName,'net','info','confMatrix','class','pred','accuracyThresholds','settings','-v7.3');
%     end
% end
% 
% save bestCaseScenario bestAccuracy

[net, info, confMatrix, class, pred, accuracyThresholds] = testingNeuralNetwork(settings, outputTrain, inputVal, outputVal, inputTrain, inputTest, outputTest);

savingName = [savingPath,'subj',num2str(subject),'_net_macroTCNN'];
save(savingName,'net','info','confMatrix','class','pred','accuracyThresholds','settings','-v7.3');




function [net, info, confMatrix, class, pred, accuracyThresholds] = testingNeuralNetwork(settings, outputTrain, inputVal, outputVal, inputTrain, inputTest, outputTest)
    layers = [
        imageInputLayer(settings.inputSize,'Normalization','zscore','NormalizationDimension','element')
        convolution1dLayer(settings.sizeFiltersCnn,settings.nFiltersCnn)
        eluLayer
        batchNormalizationLayer
        dropoutLayer(settings.firstDropOut,'Name','drop1')
        convolution1dLayer(settings.sizeFiltersCnn,settings.nFiltersCnn)
        eluLayer
        batchNormalizationLayer
        dropoutLayer(settings.secondDropOut,'Name','drop2')
        fullyConnectedLayer(settings.numClasses)
        softmaxLayer
        classificationLayer];
    
    miniBatchSize = 1024*2; %512
    validationFrequency = 2*floor(numel(outputTrain)/miniBatchSize);
    options = trainingOptions('adam', ...
        'MiniBatchSize',miniBatchSize, ...
        'MaxEpochs',30, ...
        'InitialLearnRate',1e-3, ...
        'LearnRateSchedule','piecewise', ...
        'LearnRateDropFactor',1e-1, ...
        'LearnRateDropPeriod',10, ...
        'ValidationData',{inputVal,outputVal}, ...
        'Shuffle', 'once', ...
        'ValidationFrequency',validationFrequency, ...
        'Verbose',false, ...
        'ExecutionEnvironment','gpu');%,...
        %'Plots','training-progress');
    
    % Training
    [net, info] = trainNetwork(inputTrain, outputTrain, layers, options);
    
    % Prediction and confusion matrix
    [confMatrix, class, pred] = trial_predict(net, inputTest, outputTest, settings);
    
    accuracyThresholds = thresholdAccuracy(pred.cumul, outputTest, settings, []);
end