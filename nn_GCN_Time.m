function [net, info, accuracy] = nn_GCN_Time(train,val,test,settings,savingPath,isMacro)
% input = 'image'

    startingName = 'nn_GCN_Time_';
    if isMacro,     startingName = [startingName, 'macro_'];   end
    
    disp(['Training GCN_Time for subject ',num2str(settings.numSubject)]);
     
    [net, info, accuracy] = GCN_Time(settings, train.input, train.output, val.input, val.output,  test.input, test.output);
    
    if exist('savingPath','var')
        savingName = [savingPath,startingName,'subj',num2str(subject)];
        save(savingName,'net','info','accuracy','settings','-v7.3');
    end

end


function [net, info, accuracy] = GCN_Time(settings, inputTrain, outputTrain, inputVal, outputVal, inputTest, outputTest)
    
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
        'InitialLearnRate',1e-2, ...
        'LearnRateSchedule','piecewise', ...
        'LearnRateDropFactor',1e-1, ...
        'LearnRateDropPeriod',2, ...
        'ValidationData',{inputVal,outputVal}, ...
        'Shuffle', 'once', ...
        'ValidationFrequency',validationFrequency, ...
        'Plots','training-progress', ...
        'Verbose',false, ...
        'ExecutionEnvironment','gpu');
    
    % Training
    [net, info] = trainNetwork(inputTrain, outputTrain, lgraph, options);
    
    % Prediction and confusion matrix
    YLabs = classify(net,inputTest);
    accuracy = sum(YLabs == outputTest)/numel(outputTest);
    disp(['accuracy of: ',num2str(accuracy)]);
end


