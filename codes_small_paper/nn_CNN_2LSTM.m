function [net, info] = nn_CNN_2LSTM(subject, train,val,test,settings,savingPath,isMacro,dataType)

    if ~exist("isMacro",'var'), isMacro = false; end

    startingName = ['nn_CNN_2LSTM_',dataType,'_'];
    if isMacro,     startingName = [startingName, 'macro_'];   settings.numClasses = 3; end
    
    disp(['Training ',startingName,' for subject ',num2str(subject)]);

    train.input = train.eeg;
    val.input = val.eeg;
    test.input = test.eeg;
    settings.inputSize = size(train.input{1},1:3);

    classes = categorical(unique(train.output));
    classWeights = nan(settings.numClasses,1);
    for i=1:settings.numClasses     
        classFrequency = sum(train.output == classes(i));
        classWeights(i) = numel(train.input)/(settings.numClasses*classFrequency);
    end

    [net, info, probPredValidation] = CNN_2LSTM(settings, train.input, train.output, val.input, val.output, classWeights, classes);

    trueValOutput = val.output;
    trueTestOutput = test.output;
    if exist('savingPath','var')
        savingName = [savingPath,startingName,'subj',num2str(subject),'_smaller'];
        save(savingName,'net','info','settings','trueTestOutput','probPredValidation','trueValOutput','-v7.3');
    end

end


function [net, info, probPredValidation] = CNN_2LSTM(settings, inputTrain, outputTrain, inputVal, outputVal, classWeights, classes)

   filterSize = 3;
   numFilters = 32; 
   dropOut = 0.3;
   hiddenUnitsLSTM = [200 100];

   lgraph = layerGraph([
        sequenceInputLayer(settings.inputSize,'Name','input','Normalization','zscore','NormalizationDimension','element')
        sequenceFoldingLayer('Name','foldCNN')
        convolution2dLayer(filterSize,numFilters)
        reluLayer('Name','relu')
        batchNormalizationLayer
        dropoutLayer(dropOut,'Name','CNNDrop')
        sequenceUnfoldingLayer('Name','unfoldCNN')
        flattenLayer('Name','flatten')
        lstmLayer(hiddenUnitsLSTM(1),'OutputMode','last','Name','LSTM_1')
        dropoutLayer(dropOut,'Name','LSTM1_Drop')
        lstmLayer(hiddenUnitsLSTM(2),'OutputMode','last','Name','LSTM_2')
        dropoutLayer(dropOut,'Name','LSTM2_Drop')
        fullyConnectedLayer(settings.numClasses,'Name','fc')
        softmaxLayer('Name','soft')
        classificationLayer('Name','classification', Classes=classes, ClassWeights=classWeights)]);


    lgraph = connectLayers(lgraph,'foldCNN/miniBatchSize','unfoldCNN/miniBatchSize');


    miniBatchSize = 512/2;
    validationFrequency = floor(numel(outputTrain)/miniBatchSize);
    options = trainingOptions('adam', ...
        'MiniBatchSize',miniBatchSize, ...
        'MaxEpochs',3, ...
        'InitialLearnRate',1e-2, ...
        'LearnRateSchedule','piecewise', ...
        'LearnRateDropFactor',1e-1, ...
        'LearnRateDropPeriod',2, ...
        'Shuffle', 'once', ...
        'ValidationFrequency',validationFrequency, ...
        'Verbose',false, ...
        'ExecutionEnvironment','gpu', ...
        'ValidationData',{inputVal,outputVal});
    
    % Training
    [net, info] = trainNetwork(inputTrain, outputTrain, lgraph, options);
    
    probPredValidation = predict(net, inputVal);
end

