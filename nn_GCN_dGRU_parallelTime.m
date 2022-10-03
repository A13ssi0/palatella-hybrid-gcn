function [net, info, accuracy] = nn_GCN_dGRU_parallelTime(train,val,test,settings,savingPath,isMacro)
% input = 'sequence'

    startingName = 'nn_GCN_dGRU_parallelTime';
    if isMacro,     startingName = [startingName, 'macro_'];   end
    
    disp(['Training GCN_dGRU_parallelTime for subject ',num2str(settings.numSubject)]);
     
    [net, info, accuracy] = GCN_dGRU_parallelTime(settings, train.input, train.output, val.input, val.output,  test.input, test.output);
    
    if exist('savingPath','var')
        savingName = [savingPath,startingName,'subj',num2str(subject)];
        save(savingName,'net','info','accuracy','settings','-v7.3');
    end

end


function [net, info, accuracy] = GCN_dGRU_parallelTime(settings, inputTrain, outputTrain, inputVal, outputVal, inputTest, outputTest)

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
        'ExecutionEnvironment','gpu');%,...
        %'Plots','training-progress');
    
    % Training
    [net, info] = trainNetwork(inputTrain, outputTrain, lgraph, options);
    
    % Prediction and confusion matrix
    YLabs = classify(net,inputTest);
    accuracy = sum(YLabs == outputTest)/numel(outputTest);
    disp(['accuracy of: ',num2str(accuracy)]);
end

function featureMap = slicing(matrix, startingPoint, heigth)
    featureMap = dlarray(matrix(startingPoint:startingPoint+heigth-1,:,:,:));
end
