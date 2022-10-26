function [net, info, confMatrix, class, pred, accuracyThresholds] = nn_GCN_dGRU_parallel(subject, train,val,test,settings,savingPath,isTime,isMacro)
% input = 'sequence'
    if ~exist("isTime",'var'), isTime = false; end
    if ~exist("isMacro",'var'), isMacro = false; end

    if isTime, startingName = 'nn_GCN_dGRU_parallelTime';
    else,      startingName = 'nn_GCN_dGRU_parallelFreq';
    end

    if isMacro,     startingName = [startingName, 'macro_'];   end
    
    disp(['Training GCN_dGRU_parallelFreq for subject ',num2str(subject)]);
     
    [net, info, confMatrix, class, pred, accuracyThresholds] = GCN_dGRU_parallel(settings, train.input, train.output, val.input, val.output,  test.input, test.output, isTime);
    
    trueTestOutput = test.output;
    if exist('savingPath','var')
        savingName = [savingPath,startingName,'subj',num2str(subject),'_noRaw'];
        save(savingName,'net','info','confMatrix','class','pred','accuracyThresholds','settings','trueTestOutput','-v7.3');
    end

end


function [net, info, confMatrix, class, pred, accuracyThresholds] = GCN_dGRU_parallel(settings, inputTrain, outputTrain, inputVal, outputVal, inputTest, outputTest, isTime)

   branchEMG = [
        functionLayer(@(X) slicing(X,settings.NumEEG+1,settings.NumEMG), 'Name','slicingEMG')
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
        functionLayer(@(X) slicing(X,1,settings.NumEEG), 'Name','slicingEEG')
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

    lgraph = connectLayers(lgraph,'fold/miniBatchSize','unfoldGCN/miniBatchSize');
    lgraph = connectLayers(lgraph,'input','slicingEEG');
    lgraph = connectLayers(lgraph,'input','slicingEMG');

    miniBatchSize = 1024/4; %512
    %validationFrequency = floor(numel(outputTrain)/miniBatchSize);
    options = trainingOptions('adam', ...
        'MiniBatchSize',miniBatchSize, ...
        'MaxEpochs',15, ...
        'InitialLearnRate',1e-3, ...
        'LearnRateSchedule','piecewise', ...
        'LearnRateDropFactor',1e-1, ...
        'LearnRateDropPeriod',12, ...
        'Shuffle', 'once', ...
        'Verbose',false, ...
        'ExecutionEnvironment','gpu');%,...
       % 'Plots','training-progress');
    %        'ValidationData',{inputVal,outputVal}, ...
    %'ValidationFrequency',validationFrequency, ...
        
    
    % Training
    [net, info] = trainNetwork(inputTrain, outputTrain, lgraph, options);
    
    % Prediction and confusion matrix
    if isTime
         [confMatrix, class, pred] = trial_predict(net, inputTest, outputTest, settings, [], [], settings.movwinLength);
         accuracyThresholds = thresholdAccuracy(pred.cumul, outputTest, settings, [], [], settings.movwinLength);
    else
        [confMatrix, class, pred] = trial_predict(net, inputTest, outputTest, settings);
        accuracyThresholds = thresholdAccuracy(pred.cumul, outputTest, settings);
    end

end

function featureMap = slicing(matrix, startingPoint, heigth)
    featureMap = dlarray(matrix(startingPoint:startingPoint+heigth-1,:,:,:,:,:));
end
