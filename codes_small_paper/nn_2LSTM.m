function [net, info] = nn_2LSTM(subject, train,val,test,settings,savingPath,isMacro,dataType,isTime,doFatigue,snr, percRecalibration)

    if ~exist("isMacro",'var') || isempty(isMacro), isMacro = false; end
    if ~exist("isTime",'var') || isempty(isTime), isTime = false; end


    startingName = ['nn_2LSTM_',dataType,'_'];
    if isMacro,     startingName = [startingName, 'macro_'];     settings.numClasses = 3;   end
    if isTime,      startingName = [startingName, 'timeRaw_'];   end
    
    
    disp(['Training ',startingName,' for subject ',num2str(subject)]);
     
    train.input = train.emg;
    val.input = val.emg;
    test.input = test.emg;
    settings.inputSize = size(train.input{1});

    classes = categorical(unique(train.output));
    classWeights = nan(settings.numClasses,1);
    for i=1:settings.numClasses     
        classFrequency = sum(train.output == classes(i));
        classWeights(i) = numel(train.input)/(settings.numClasses*classFrequency);
    end 


    [net, info, probPredValidation] = LSTM2(settings, train.input, train.output, val.input, val.output, classWeights, classes);

    trueValOutput = val.output;
    trueTestOutput = test.output;

    if exist('savingPath','var')
        if exist('snr','var') && ~isempty(snr)
            savingName = [savingPath,startingName,'subj',num2str(subject),'smaller_25Hz_raw_snr',num2str(snr),'.mat'];
        else
            savingName = [savingPath,startingName,'subj',num2str(subject),'smaller_25Hz_raw.mat'];
        end
        save(savingName,'net','info','settings','trueTestOutput','probPredValidation','trueValOutput','-v7.3');
    end


    
    if doFatigue
        attenuation = [0.7 0.9];
        loadingPathFat ='/home/palatella/workspace/palatella_datasets/only emg/fatigue/';
        savingPathFat=savingPath;

        for att = attenuation
            disp(['Attenuation of ',num2str(fix(att*100))])
            filenamePSD = [loadingPathFat,'s',num2str(subject),'_wind25Hz_raw_attenuation',num2str(fix(att*100))];

            classes = 1:11;
            settings.classes = classes;
            [Psd,settings] = startingTrain(filenamePSD,classes);
            settings.numSubject = subject;

            settings.movWinLength = 2*settings.windowLength; % [s]
            settings.movWinShift = 2*settings.windowShift; % [s]
            settings.nWindowsTrial = fix((settings.secPostMovement+settings.secPreMovement)/settings.movWinShift);

            typeOfDataInput = 'sequence';
            [train, val, test] = splittingData(Psd,settings,typeOfDataInput,percRecalibration);

            settings.NumEEG = 0;
            settings.NumEMG = 6;
            [train, val, test, settings] = divide_EEG_EMG_half_time(train, val, test, settings);

            [~, val, test, settings] = microToMacroClasses(train,val,test,settings); 

            val.input = val.emg;
            test.input = test.emg;
            
            probPredValidation = predict(net, val.input);

            trueValOutput = val.output;
            trueTestOutput = test.output;
            savingName = [savingPathFat,startingName,'subj',num2str(subject),'_smaller_attenuation',num2str(fix(att*100))];
            save(savingName,'net','info','settings','trueTestOutput','probPredValidation','trueValOutput','-v7.3');

        end

    end

end


function [net, info, probPredValidation] = LSTM2(settings, inputTrain, outputTrain, inputVal, outputVal, classWeights, classes)
 
   dropOut = 0.1;
   hiddenUnitsLSTM = [250 100];

   lgraph = layerGraph([
        sequenceInputLayer(settings.inputSize,'Name','input','Normalization','zscore','NormalizationDimension','element')
        flattenLayer('Name','flatten')
        lstmLayer(hiddenUnitsLSTM(1),'OutputMode','last','Name','LSTM_1')
        dropoutLayer(dropOut,'Name','LSTM1_Drop')
        lstmLayer(hiddenUnitsLSTM(2),'OutputMode','last','Name','LSTM_2')
        dropoutLayer(dropOut,'Name','LSTM2_Drop')
        fullyConnectedLayer(settings.numClasses,'Name','fc')
        softmaxLayer('Name','soft')
        classificationLayer('Name','classification', Classes=classes, ClassWeights=classWeights)]);


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
        'ValidationData',{inputVal,outputVal});
      
    
    % Training
    [net, info] = trainNetwork(inputTrain, outputTrain, lgraph, options);

    probPredValidation = predict(net, inputVal);

end

