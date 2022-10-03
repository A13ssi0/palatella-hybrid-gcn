close all; clearvars; clc;
rng(12)

subject = 7;

NumHiddenUnits = 150;
NumOutFeatures = 50;
gcnDropOut = 0.3;
gruDropOut = 0.3;

cutLowFreq = 8;
cutHighFreq = 30;

endingName = ['_DoubleGRU_time_Raw_Filt',num2str(cutLowFreq),'_',num2str(cutHighFreq),'_Fixed'];

typeOfDataInput = 'sequence'; %'image'

%%
savingPath='/home/palatella/workspace/palatella_net/';
disp('importing the data')
filename = ['subj',num2str(subject),'_labeledRaw.mat'];
[timeSeries,settings] = startingTrain(filename,1:11);
fs = settings.eeg.fs;

[b,a] = butter(4,cutLowFreq/(fs/2),'high');
[d,c] = butter(4,cutHighFreq/(fs/2),'low');
for i = 1:settings.NumEEG
    timeSeries.data(i,:) = filtfilt(b,a,timeSeries.data(i,:)); 
    timeSeries.data(i,:) = filtfilt(d,c,timeSeries.data(i,:));  
end

%%
disp('creating new windows label')
settings.windowShift = 1/settings.eeg.fs;
%settings.movwinLength = settings.secPostMovement+settings.secPreMovement; % [s]
settings.movwinLength = 1;
settings.movwinShift = 0.04; % [s]

[train, val, test] = splittingData(timeSeries,settings,typeOfDataInput);

%% Testing neural network
bestAccuracy.accuracy = 0;
% settings.NumFeatures = 1000;
% settings.inputSize(2) = 1000;
disp('model training')

for q = NumHiddenUnits
    for x = NumOutFeatures 
        for y =  gcnDropOut % of graph
            for z = gruDropOut % of gru
    
                qName = ''; xName = ''; yName=''; zName ='';
                drop = '_drop';
                hidUnits = '_hidF';
                if exist('NumHiddenUnits','var'), qName = [hidUnits,num2str(q)]; settings.NumHiddenUnits = q; end
                if exist('NumOutFeatures','var'), xName = ['_outF',num2str(x)]; settings.NumOutFeatures = x; end
                if exist('gcnDropOut','var'), yName = [drop,num2str(y)]; drop='_'; settings.gcnDropOut = y; end
                if exist('gruDropOut','var'), zName = [drop,num2str(z)]; settings.gruDropOut = z; end
                disp([qName, '   ',xName,'   ',yName,'   ',zName])
    

                [net, info, accuracy] = testingNeuralNetwork(settings, train.output, val.input, val.output, train.input, test.input, test.output);
    

                if accuracy>bestAccuracy.accuracy
                    bestAccuracy.accuracy = accuracy;
                    bestAccuracy.hiddenUnits = q;
                    bestAccuracy.outFeatures = x;
                    bestAccuracy.gcnDrop = y;
                    bestAccuracy.gruDrop = z;
                end
    
                  savingName = [savingPath,'subj',num2str(subject),'_net',qName,xName,yName,zName,endingName];
                  save(savingName,'net','info','settings','accuracy','-v7.3');
            end
        end
    end
end

% save bestCaseScenario bestAccuracy


function [net, info, accuracy] = testingNeuralNetwork(settings, outputTrain, inputVal, outputVal, inputTrain, inputTest, outputTest)

    layers = [
        sequenceInputLayer(settings.inputSize,'Name','input','Normalization','zscore','NormalizationDimension','element')
        sequenceFoldingLayer('Name','fold')
        graphConvWithLearnStruct3LayerZeros_fixedDiagonal(settings.NumFeatures,settings.NumOutFeatures,settings.NumEMG,settings.NumEEG,'Name','GConv')
        reluLayer('Name','relu')
        batchNormalizationLayer
        dropoutLayer(settings.gcnDropOut,'Name','GcnDrop')

%         sequenceUnfoldingLayer('Name','unfold')
        functionLayer(@(X) slicing(X,1,settings.NumEEG), 'Name','SlicingEEG')
        sequenceUnfoldingLayer('Name','unfoldEEG')
        flattenLayer('Name','flattenEEG')
        gruLayer(settings.NumHiddenUnits,'OutputMode','last','Name','gruEEG')
        dropoutLayer(settings.gruDropOut,'Name','GruDropEEG');
        ];
    lgraph = layerGraph(layers);

    branchEMG = [
        functionLayer(@(X) slicing(X,settings.NumEEG+1,settings.NumEMG), 'Name','SlicingEMG')
        sequenceUnfoldingLayer('Name','unfoldEMG')
        flattenLayer('Name','flattenEMG')
        gruLayer(settings.NumHiddenUnits,'OutputMode','last','Name','gruEMG')
        dropoutLayer(settings.gruDropOut,'Name','GruDropEMG')];
     lgraph = addLayers(lgraph,branchEMG);

    endLayer = [
        concatenationLayer(1,2,'Name','concat')
        fullyConnectedLayer(settings.numClasses,'Name','fc')
        softmaxLayer('Name','soft')
        classificationLayer('Name','classification')];
     lgraph = addLayers(lgraph,endLayer);

     lgraph = connectLayers(lgraph,'GcnDrop','SlicingEMG');

     lgraph = connectLayers(lgraph,'GruDropEEG','concat/in1');
     lgraph = connectLayers(lgraph,'GruDropEMG','concat/in2');

     lgraph = connectLayers(lgraph,'fold/miniBatchSize','unfoldEEG/miniBatchSize');
     lgraph = connectLayers(lgraph,'fold/miniBatchSize','unfoldEMG/miniBatchSize');
    

    miniBatchSize = 1024/4; %512
    validationFrequency = floor(numel(outputTrain)/miniBatchSize);
    options = trainingOptions('adam', ...
        'MiniBatchSize',miniBatchSize, ...
        'MaxEpochs',7, ...
        'InitialLearnRate',1e-2, ...
        'LearnRateSchedule','piecewise', ...
        'LearnRateDropFactor',1e-1, ...
        'LearnRateDropPeriod',2, ...
        'ValidationData',{inputVal,outputVal}, ...
        'Shuffle', 'once', ...
        'ValidationFrequency',validationFrequency, ...
        'Verbose',false, ...
        'ExecutionEnvironment','gpu',...
        'Plots','training-progress');
    
    % Training
    [net, info] = trainNetwork(inputTrain, outputTrain, lgraph, options);
    
    % Prediction and confusion matrix
    %[confMatrix, class, pred] = trial_predict(net, inputTest, outputTest, settings);
    %accuracyThresholds = thresholdAccuracy(pred.cumul, outputTest, settings, []);
    %YPred = predict(net,val_S(:,:,:,1199:end));
    YLabs = classify(net,inputTest);
    accuracy = sum(YLabs == outputTest)/numel(outputTest);
    disp(['accuracy of: ',num2str(accuracy)]);
end

function featureMap = slicing(matrix, startingPoint, heigth)
    featureMap = dlarray(matrix(startingPoint:startingPoint+heigth-1,:,:,:));
end
