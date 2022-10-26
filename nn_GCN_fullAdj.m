function [net, info, confMatrix, class, pred, accuracyThresholds] = nn_GCN_fullAdj(subject,train,val,test,settings,savingPath,isTime,isMacro)
% input = 'image'
    if ~exist("isTime",'var'), isTime = false; end
    if ~exist("isMacro",'var'), isMacro = false; end

    if isTime, startingName = 'nn_GCN__fullAdjTime';
    else,      startingName = 'nn_GCN__fullAdjFreq';
    end

    if isMacro,     startingName = [startingName, 'macro_'];   end
    
    disp(['Training GCN__fullAdjTime for subject ',num2str(subject)]);
     
    [net, info, confMatrix, class, pred, accuracyThresholds] = GCN_fullAdj(settings, train.input, train.output, val.input, val.output,  test.input, test.output,isTime);
    
    trueTestOutput = test.output;
    if exist('savingPath','var')
        savingName = [savingPath,startingName,'subj',num2str(subject),'_noRaw'];
        save(savingName,'net','info','confMatrix','class','pred','accuracyThresholds','settings','trueTestOutput','-v7.3');
    end

end


function [net, info, confMatrix, class, pred, accuracyThresholds] = GCN_fullAdj(settings, inputTrain, outputTrain, inputVal, outputVal, inputTest, outputTest,isTime)
    
    lgraph = [
        imageInputLayer(settings.inputSize,'Normalization','zscore','NormalizationDimension','element')
        graphConvWithLearnStruct3Layer(settings.NumFeatures,settings.NumOutFeatures,settings.NumEMG,settings.NumEEG)
        reluLayer
        batchNormalizationLayer
        dropoutLayer(settings.gcnDropOut,'Name','drop')
        fullyConnectedLayer(settings.numClasses)
        softmaxLayer
        classificationLayer];

    miniBatchSize = 1024/4; %1024
    validationFrequency = floor(numel(outputTrain)/miniBatchSize);
    options = trainingOptions('adam', ...
        'MiniBatchSize',miniBatchSize, ...
        'MaxEpochs',7, ...
        'InitialLearnRate',1e-3, ...
        'LearnRateSchedule','piecewise', ...
        'LearnRateDropFactor',1e-1, ...
        'LearnRateDropPeriod',6, ...
        'Shuffle', 'once', ...
        'Verbose',false, ...
        'ExecutionEnvironment','gpu');%,...
    %     'Plots','training-progress');
    %        'ValidationData',{inputVal,outputVal}, ...
    %        'ValidationFrequency',validationFrequency, ...
    %        'Plots','training-progress', ...
    
    % Training
    [net, info] = trainNetwork(inputTrain, outputTrain, lgraph, options);
    
    % Prediction and confusion matrix
%     if isTime
%          [confMatrix, class, pred] = trial_predict(net, inputTest, outputTest, settings, [], settings.movwinLength);
%          accuracyThresholds = thresholdAccuracy(pred.cumul, outputTest, settings, [], [], settings.movwinLength);
%     else
        [confMatrix, class, pred] = trial_predict(net, inputTest, outputTest, settings);
        accuracyThresholds = thresholdAccuracy(pred.cumul, outputTest, settings, []);
%     end
end


