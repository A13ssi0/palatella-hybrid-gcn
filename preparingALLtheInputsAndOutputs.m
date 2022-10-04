function [trainPsd, valPsd, testPsd, trainPsdImage, valPsdImage, testPsdImage, settingsPsd, trainTime, valTime, testTime, trainTimeImage, valTimeImage, testTimeImage, settingsTime, trainFeatures, testFeatures, settingsFeatures] = preparingALLtheInputsAndOutputs(numSubject,classes)

    % importings PSD -------------------------------------------------------------------------------
    disp(['importing and splitting the PSD of subject ',num2str(numSubject)])
    filenamePSD = ['subj',num2str(numSubject),'_psd.mat'];
    [Psd,settingsPsd] = startingTrain(filenamePSD,classes);

    typeOfDataInput = 'sequence';
    settingsPsd.movwinLength = 2*settingsPsd.windowLength; % [s]
    settingsPsd.movwinShift = 2*settingsPsd.windowShift; % [s]
    [trainPsd, valPsd, testPsd] = splittingData(Psd,settingsPsd,typeOfDataInput);

    typeOfDataInput = 'image';
    [trainPsdImage, valPsdImage, testPsdImage] = splittingData(Psd,settingsPsd,typeOfDataInput);

    
    % importings time -------------------------------------------------------------------------------
    disp(['importing and splitting the time series of subject ',num2str(numSubject)])
    filenameTime = ['subj',num2str(numSubject),'_labeledRaw.mat'];
    [timeSeries,settingsTime] = startingTrain(filenameTime,classes);
    fs = settingsTime.eeg.fs;

    [b,a] = butter(4,cutLowFreq/(fs/2),'high');
    [d,c] = butter(4,cutHighFreq/(fs/2),'low');
    for i = 1:settingsTime.NumEEG
        timeSeries.data(i,:) = filtfilt(b,a,timeSeries.data(i,:)); 
        timeSeries.data(i,:) = filtfilt(d,c,timeSeries.data(i,:));  
    end

    typeOfDataInput = 'sequence';
    settingsTime.windowShift = 1/fs;
    settingsTime.movwinLength = 1;
    settingsTime.movwinShift = 0.04; 
    [trainTime, valTime, testTime] = splittingData(timeSeries,settingsTime,typeOfDataInput);

    typeOfDataInput = 'image';
    [trainTimeImage, valTimeImage, testTimeImage] = splittingData(timeSeries,settingsTime,typeOfDataInput);


    % importings features -------------------------------------------------------------------------------
    disp(['importing and splitting the features of subject ',num2str(numSubject)])
    filenameFeat = ['subj',num2str(subject),'_featuresEMG.mat'];
    [trainFeatures,testFeatures,settingsFeatures] = startingSplittingFeatures(filenameFeat,classes);

end