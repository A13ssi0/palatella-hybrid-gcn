function [net, info, confMatrix, class, pred, accuracyThresholds] = nn_CNN_2LSTM(subject, train,val,test,settings,savingPath,isMacro,dataType)

    if ~exist("isMacro",'var'), isMacro = false; end

    startingName = ['nn_CNN_2LSTM_',dataType,'_'];
    if isMacro,     startingName = [startingName, 'macro_'];   end
    
    disp(['Training ',startingName,' for subject ',num2str(subject)]);
     
    if strcmp(dataType,'EEG')
        train.input = train.eeg;
        val.input = val.eeg;
        test.input = test.eeg;
        settings.inputSize = size(train.input{1},1:3);
    else
        train.input = train.emg;
        val.input = val.emg;
        test.input = test.emg;
        settings.inputSize = size(train.input{1},1:3);
    end


    [net, info, confMatrix, class, pred, accuracyThresholds, probPredValidation] = CNN_2LSTM(settings, train.input, train.output, val.input, val.output,  test.input, test.output);
    


    trueTestOutput = test.output;
    if exist('savingPath','var')
        savingName = [savingPath,startingName,'subj',num2str(subject)];
        save(savingName,'net','info','confMatrix','class','pred','accuracyThresholds','settings','trueTestOutput','probPredValidation','-v7.3');
    end

end


function [net, info, confMatrix, class, pred, accuracyThresholds, probPredValidation] = CNN_2LSTM(settings, inputTrain, outputTrain, inputVal, outputVal, inputTest, outputTest)

   filterSize = 3;
   numFilters = 32; 
   dropOut = 0.1;
   hiddenUnitsLSTM = [250 100];

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
        classificationLayer('Name','classification')]);


    lgraph = connectLayers(lgraph,'foldCNN/miniBatchSize','unfoldCNN/miniBatchSize');


    miniBatchSize = 512;
    validationFrequency = floor(numel(outputTrain)/miniBatchSize);
    options = trainingOptions('adam', ...
        'MiniBatchSize',miniBatchSize, ...
        'MaxEpochs',15, ...
        'InitialLearnRate',1e-2, ...
        'LearnRateSchedule','piecewise', ...
        'LearnRateDropFactor',1e-1, ...
        'LearnRateDropPeriod',4, ...
        'Shuffle', 'once', ...
        'ValidationFrequency',validationFrequency, ...
        'Verbose',false, ...
        'ExecutionEnvironment','gpu', ...
        'ValidationData',{inputVal,outputVal});%, ...
       % 'ValidationPatience', 3,...
       % 'OutputNetwork','best-validation-loss');
        %'Plots','training-progress');
    
    % Training
    [net, info] = trainNetwork(inputTrain, outputTrain, lgraph, options);
    
    probPredValidation = predict(net, inputVal);

    % Prediction and confusion matrix
    [confMatrix, class, pred] = trial_predict(net, inputTest, outputTest, settings);
    accuracyThresholds = nan;
    %accuracyThresholds = thresholdAccuracy(pred.cumul, outputTest, settings);

end

