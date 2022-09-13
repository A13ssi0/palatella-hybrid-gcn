close all; clearvars; clc;
rng(12)

subject = 7;

NumHiddenUnits = 150;
NumOutFeatures = 7;
gcnDropOut = 0.3;
gruDropOut = 0.3;

endingName = '_macro';

typeOfDataInput = 'sequence'; %'image'

%%
savingPath='/home/palatella/workspace/palatella_net/';
disp('importing the data')
filename = ['subj',num2str(subject),'_psd.mat'];
[Psd,settings] = startingTrain(filename);

%%
disp('creating new windows label')
settings.movwinLength = 2*settings.windowLength; % [s]
settings.movwinShift = 2*settings.windowShift; % [s]

[train, val, test] = splittingData(Psd,settings,typeOfDataInput);

%% Testing neural network
bestAccuracy.accuracy = 0;

disp('model training')
for q = NumHiddenUnits
    for x = NumOutFeatures 
        for y =  gcnDropOut % of graph
            for z = gruDropOut % of gru
    
                qName = ''; xName = ''; yName=''; zName ='';
                drop = '_drop';
                hidUnits = '_hidF';
                if exist('NumHiddenUnits','var'), qName = [hidUnits,num2str(NumHiddenUnits)]; settings.NumHiddenUnits = q; end
                if exist('NumOutFeatures','var'), xName = ['_outF',num2str(NumOutFeatures)]; settings.NumOutFeatures = x; end
                if exist('gcnDropOut','var'), yName = [drop,num2str(gcnDropOut)]; drop='_'; settings.gcnDropOut = y; end
                if exist('gruDropOut','var'), zName = [drop,num2str(gruDropOut)]; settings.gruDropOut = z; end
                disp([qName, '   ',xName,'   ',yName,'   ',zName])
    

                [net, info, confMatrix, class, pred, accuracyThresholds] = testingNeuralNetwork(settings, train.output, val.input, val.output, train.input, test.input, test.output);
    

                if class.accuracy>bestAccuracy.accuracy
                    bestAccuracy.accuracy = class.accuracy;
                    bestAccuracy.hiddenUnits = q;
                    bestAccuracy.outFeatures = x;
                    bestAccuracy.gcnDrop = y;
                    bestAccuracy.gruDrop = z;
                end
    
%                 savingName = [savingPath,'subj',num2str(subject),'_net',qName,xName,yName,zName,endingName];
%                 save(savingName,'net','info','confMatrix','class','pred','accuracyThresholds','settings','-v7.3');
             end
        end
    end
end

% save bestCaseScenario bestAccuracy


function [net, info, confMatrix, class, pred, accuracyThresholds] = testingNeuralNetwork(settings, outputTrain, inputVal, outputVal, inputTrain, inputTest, outputTest)

    branchEMG = [
        functionLayer(@(X) slicing(X,settings.NumEEG+1,settings.NumEMG), 'Name','SlicingEMG')
        flattenLayer('Name','flattenEMG')
        gruLayer(settings.NumHiddenUnits,'OutputMode','last','Name','gruEMG')
        dropoutLayer(settings.gruDropOut,'Name','GruDropEMG')];
    lgraph = layerGraph(branchEMG);
    

    layers = [
        sequenceInputLayer(settings.inputSize,'Name','input','Normalization','zscore','NormalizationDimension','element')
        sequenceFoldingLayer('Name','fold')
        graphConvWithLearnStruct3LayerZeros(settings.NumFeatures,settings.NumOutFeatures,settings.NumEMG,settings.NumEEG,'Name','GConv')
        reluLayer('Name','relu')
        batchNormalizationLayer
        dropoutLayer(settings.gcnDropOut,'Name','GcnDrop')
        sequenceUnfoldingLayer('Name','unfoldGCN')
        flattenLayer('Name','flattenGCN')
        gruLayer(settings.NumHiddenUnits,'OutputMode','last','Name','gruGCN')
        dropoutLayer(settings.gruDropOut,'Name','GruDropGCN')];
    lgraph = addLayers(lgraph,layers);
    

    branchEEG = [
        functionLayer(@(X) slicing(X,1,settings.NumEEG), 'Name','SlicingEEG')
        flattenLayer('Name','flattenEEG')
        gruLayer(settings.NumHiddenUnits,'OutputMode','last','Name','gruEEG')
        dropoutLayer(settings.gruDropOut,'Name','GruDropEEG')];
    lgraph = addLayers(lgraph,branchEEG);


    endLayer = [
        concatenationLayer(1,3,'Name','concat')
        fullyConnectedLayer(settings.numClasses,'Name','fc')
        softmaxLayer('Name','soft')
        classificationLayer('Name','classification')];
    lgraph = addLayers(lgraph,endLayer);


    lgraph = connectLayers(lgraph,'GruDropEEG','concat/in1');
    lgraph = connectLayers(lgraph,'GruDropGCN','concat/in2');
    lgraph = connectLayers(lgraph,'GruDropEMG','concat/in3');

    lgraph = connectLayers(lgraph,'input','SlicingEMG');
    lgraph = connectLayers(lgraph,'input','SlicingEEG');

    lgraph = connectLayers(lgraph,'fold/miniBatchSize','unfoldGCN/miniBatchSize');
    

    miniBatchSize = 1024*2; %512
    validationFrequency = 2*floor(numel(outputTrain)/miniBatchSize);
    options = trainingOptions('adam', ...
        'MiniBatchSize',miniBatchSize, ...
        'MaxEpochs',20, ...
        'InitialLearnRate',1e-3, ...
        'LearnRateSchedule','piecewise', ...
        'LearnRateDropFactor',1e-1, ...
        'LearnRateDropPeriod',8, ...
        'ValidationData',{inputVal,outputVal}, ...
        'Shuffle', 'once', ...
        'ValidationFrequency',validationFrequency, ...
        'Verbose',false, ...
        'ExecutionEnvironment','gpu');%,...
        %'Plots','training-progress');
    
    % Training
    [net, info] = trainNetwork(inputTrain, outputTrain, lgraph, options);
    
    % Prediction and confusion matrix
    [confMatrix, class, pred] = trial_predict(net, inputTest, outputTest, settings);
    
    accuracyThresholds = thresholdAccuracy(pred.cumul, outputTest, settings, []);
end

function featureMap = slicing(matrix, startingPoint, heigth)
    featureMap = dlarray(matrix(startingPoint:startingPoint+heigth-1,:));
end
